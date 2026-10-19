# set -x pipefail

# pkill -9 python
ray stop --force
pkill -9 ray
pkill -9 VLLM

unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY

export HCCL_OP_EXPANSION_MODE="AIV" 
export RAY_DEDUP_LOGS=0
export HYDRA_FULL_ERROR=1
export VLLM_ASCEND_ENABLE_NZ=0
export PYTORCH_NPU_ALLOC_CONF=max_split_size_mb:128
# export LD_PRELOAD=/usr/local/lib/libjemalloc.so.2
export PYTHONUNBUFFERED=1  # 关闭 Python 的标准输出 / 错误缓冲

export RAY_DEBUG_POST_MORTEM=0
export RAY_DEBUG=0

export VLLM_ASCEND_TASK_QUEUE_ENABLE=1
export TASK_QUEUE_ENABLE=2 #2
export CPU_AFFINITY_CONF=1  # 0或未设置：表示不启用绑核功能。1：表示开启粗粒度绑核。2：表示开启细粒度绑核。
export HCCL_IF_BASE_PORT=24703
# export MALLOC_MMAP_THRESHOLD_=512768
export LCAL_COMM_ID=127.0.0.1:27001

export ASCEND_LAUNCH_BLOCKING=0

# export VLLM_ASCEND_ENABLE_FLASHCOMM1=1


ulimit -n 32768
# 保证用户基础环境umask设置，避免用户本身环境umask设置导致生成过高权限的文件夹
umask 0027

NNODES=4
NPUS_PER_NODE=8
export ASCEND_RT_VISIBLE_DEVICES=0,1,2,3,4,5,6,7

#修改为对应主节点IP
MASTER_ADDR="172.27.15.128"

#修改为当前节点的通信网卡
export HCCL_HOST_SOCKET_PORT_RANGE=auto
export HCCL_NPU_SOCKET_PORT_RANGE=auto
# SOCKET_IFNAME=$(ifconfig | awk '/^[a-z0-9]+:/ {gsub(/:$/, "", $1); interface=$1} /inet 141\.6/ {print interface}')
SOCKET_IFNAME="data0.3001"
export HCCL_SOCKET_IFNAME=$SOCKET_IFNAME
export GLOO_SOCKET_IFNAME=$SOCKET_IFNAME
export HCCL_CONNECT_TIMEOUT=3000
export HCCL_EXEC_TIMEOUT=3000
# export HCCL_BUFFSIZE=400
export MULTI_STREAM_MEMORY_REUSE=1
export RAY_EXPERIMENTAL_NOSET_ASCEND_RT_VISIBLE_DEVICES=1


# 获取当前节点IP
export CURRENT_IP=$(ifconfig $SOCKET_IFNAME | grep -Eo 'inet (addr:)?([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $NF}')
echo $MASTER_ADDR
echo $CURRENT_IP

#################### Log 目录配置 ###########################
# * 确保 JOB_LOG_DIR 在共享盘下
export JOB_LOG_DIR=/mnt/share/z00804445/tasks/qwen3_moe_verl_mxfp8_dts/verl/logs/4nodes
export JOB_LOG_DIR_CURR=${JOB_LOG_DIR}/$(date +"%Y%m%d_%H%M")
export ASCEND_PROCESS_LOG_PATH=${JOB_LOG_DIR_CURR}/plog/${CURRENT_IP}

###profiling
export PROFILE_STEP=2 # 采集指定步数
export ROLLOUT_PROFILE=true
export UPDATE_PROFILE=true
export WITH_MODULES=false # 采集python调用栈
export WITH_STACK=false # 采集算子调用栈
export WITH_MEMORY=false # 采集内存
export WITH_SHAPE=true # 采集张量形状
export PROFILE_RANKS=0 # 采集rank0
export UPDATE_PROFILE_PATH=${JOB_LOG_DIR_CURR}/update_profile/${CURRENT_IP}
export ROLLOUT_PROFILE_PATH=${JOB_LOG_DIR_CURR}/rollout_profile/${CURRENT_IP}
###end profiling

DEFAULT_SH="run_qwen3_30b_mxfp8_4nodes.sh"

echo "Use $DEFAULT_SH"

if [ "$MASTER_ADDR" = "$CURRENT_IP" ]; then
  # 主节点启动
  ray start --head --port 6766 --dashboard-host=0.0.0.0 --node-ip-address=$CURRENT_IP --dashboard-port=4919 --resources='{"NPU": '$NPUS_PER_NODE'}'

  mkdir -p $JOB_LOG_DIR_CURR
  cp "$(realpath "$0")" "${JOB_LOG_DIR_CURR}/."  # 拷贝当前文件
  cp $(dirname $0)/${DEFAULT_SH} "${JOB_LOG_DIR_CURR}/."
  cp $(dirname $0)/mv_profiling_to_curr.sh "${JOB_LOG_DIR_CURR}/."

  while true; do
      ray_status_output=$(ray status)
      npu_count=$(echo "$ray_status_output" | grep -oP '(?<=/)\d+\.\d+(?=\s*NPU)' | head -n 1)
      npu_count_int=$(echo "$npu_count" | awk '{print int($1)}')
      device_count=$((npu_count_int / $NPUS_PER_NODE))

      # 判断 device_count 是否与 NNODES 相等
      if [ "$device_count" -eq "$NNODES" ]; then
          echo "Ray cluster is ready with $device_count devices (from $npu_count NPU resources), starting Python script."
          ray status
          bash ${DEFAULT_SH}
          break
      else
          echo "Waiting for Ray to allocate $NNODES devices. Current device count: $device_count"
          sleep 5
      fi
  done
else
  # 子节点尝试往主节点注册ray直到成功
  while true; do
      # 尝试连接 Ray 集群
      ray start --address="$MASTER_ADDR:6766" --resources='{"NPU": '$NPUS_PER_NODE'}' --node-ip-address=$CURRENT_IP

      # 检查连接是否成功
      ray status
      if [ $? -eq 0 ]; then
          echo "Successfully connected to the Ray cluster!"
          break
      else
          echo "Failed to connect to the Ray cluster. Retrying in 5 seconds..."
          sleep 5
      fi
  done
fi

sleep 600
