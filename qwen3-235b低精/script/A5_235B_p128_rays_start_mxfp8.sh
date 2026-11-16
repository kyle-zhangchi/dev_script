# set -x pipefail

# pkill -9 python
ray stop --force
pkill -9 ray
pkill -9 VLLM

unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY

export PROFILE_STEP=2 # 采集指定步数
export ROLLOUT_PROFILE=true
export UPDATE_PROFILE=true
export WITH_MODULES=false # 采集python调用栈
export WITH_STACK=false # 采集算子调用栈
export WITH_MEMORY=false # 采集内存
export WITH_SHAPE=true # 采集张量形状
export PROFILE_RANKS=0 # 采集rank0

export RAY_DEDUP_LOGS=0
export HYDRA_FULL_ERROR=1
export VLLM_ASCEND_ENABLE_NZ=0
export PYTORCH_NPU_ALLOC_CONF=max_split_size_mb:128
# export LD_PRELOAD=/usr/local/lib/libjemalloc.so.2
export PYTHONUNBUFFERED=1  # 关闭 Python 的标准输出 / 错误缓冲

# ulimit -n 32768
# # mkdir logs
# # # 保证用户基础环境umask设置，避免用户本身环境umask设置导致生成过高权限的文件夹
# # umask 0027

export RAY_DEBUG_POST_MORTEM=0
export RAY_DEBUG=0

# rm -rf /mnt/share/q00887491/plog/qwen235b_0514_verl0115
# export ASCEND_PROCESS_LOG_PATH=/mnt/share/q00887491/plog/qwen235b_0514_verl0115

export VLLM_ASCEND_TASK_QUEUE_ENABLE=1
export TASK_QUEUE_ENABLE=2 #2
export CPU_AFFINITY_CONF=1  # 0或未设置：表示不启用绑核功能。1：表示开启粗粒度绑核。2：表示开启细粒度绑核。
# export HCCL_IF_BASE_PORT=24703
# export MALLOC_MMAP_THRESHOLD_=512768
# export LCAL_COMM_ID=127.0.0.1:27001

export ASCEND_LAUNCH_BLOCKING=0

export VLLM_ASCEND_ENABLE_FLASHCOMM1=1
# export HCCL_OP_EXPANSION_MODE="AI_CPU"

# export ASCEND_GLOBAL_EVENT_ENABLE=1 # HCCL问题定位
# export HCCL_ENTRY_LOG_ENABLE=1
# export VLLM_LOGGING_LEVEL=DEBUG
# export VLLM_TRACE_FUNCTION=1
# export SPDLOG_LEVEL=debug # spdlog日志level
# export ASDOPS_LOG_LEVEL=DEBUG # TRACE DEBUG INFO WARN ERROR FATAL
# export ASDOPS_LOG_TO_FILE=1
# export ASCEND_GLOBAL_LOG_LEVEL=0 # 0:debug, 1:info, 2:warn, 3:error

# export TIKTOKEN_ENCODINGS_BASE="/home/q00887491/encodings"
# export TIKTOKEN_RS_CACHE_DIR="/home/q00887491/encodings/"

ulimit -n 32768
# 保证用户基础环境umask设置，避免用户本身环境umask设置导致生成过高权限的文件夹
umask 0027

NNODES=16
NPUS_PER_NODE=8
export ASCEND_RT_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
# export ASCEND_RT_VISIBLE_DEVICES=4,5,6,7
# export RAY_EXPERIMENTAL_NOSET_ASCEND_RT_VISIBLE_DEVICES=1


#修改为对应主节点IP
# MASTER_ADDR="141.62.17.110"
MASTER_ADDR="172.27.17.70"
# MASTER_ADDR="141.62.17.122"

# export HCCL_OP_EXPANSION_MODE="CCU_SCHED"

#修改为当前节点的通信网卡
export HCCL_HOST_SOCKET_PORT_RANGE="auto"
export HCCL_NPU_SOCKET_PORT_RANGE="auto"
# export HCCL_HOST_SOCKET_PORT_RANGE=60000-60050
# export HCCL_NPU_SOCKET_PORT_RANGE=61000-61050
# SOCKET_IFNAME=$(ifconfig | awk '/^[a-z0-9]+:/ {gsub(/:$/, "", $1); interface=$1} /inet 141\.6/ {print interface}')
SOCKET_IFNAME="data0.3001"
export HCCL_SOCKET_IFNAME=$SOCKET_IFNAME
export GLOO_SOCKET_IFNAME=$SOCKET_IFNAME
export HCCL_CONNECT_TIMEOUT=1800
export HCCL_EXEC_TIMEOUT=1800
export HCCL_BUFFSIZE=800
export MULTI_STREAM_MEMORY_REUSE=1 # 加了这个 by yzb
# export VLLM_VERSION=0.20.2
# export VLLM_VERSION=0.19.1
export RAY_EXPERIMENTAL_NOSET_ASCEND_RT_VISIBLE_DEVICES=1


# 获取当前节点IP
CURRENT_IP=$(ifconfig $SOCKET_IFNAME | grep -Eo 'inet (addr:)?([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $NF}')
echo $MASTER_ADDR
echo $CURRENT_IP

#################### Log 目录配置 ###########################
# * 确保 JOB_LOG_DIR 在共享盘下
export JOB_LOG_DIR=/mnt/share/q00887491/logs/20260819_1900mxfp8/
export JOB_LOG_DIR_CURR=${JOB_LOG_DIR}/$(date +"%Y%m%d_%H%M")
export ASCEND_PROCESS_LOG_PATH=${JOB_LOG_DIR_CURR}/plog/${CURRENT_IP}
export MY_PROFILING_PATH=/home/q00887491_profiling/$(basename "$JOB_LOG_DIR_CURR")
export ROLLOUT_PROFILE_PATH=${MY_PROFILING_PATH}/vllm
mkdir -p $MY_PROFILING_PATH
# mkdir -p $MY_VLLM_PROFILING_PATH


DEFAULT_SH="A5_235B_p128_mxfp8.sh"

echo "Use $DEFAULT_SH"

if [ "$MASTER_ADDR" = "$CURRENT_IP" ]; then
  # 主节点启动
  ray start --head --port 6766 --dashboard-host=0.0.0.0 --node-ip-address=$CURRENT_IP --dashboard-port=4919 --resources='{"NPU": '$NPUS_PER_NODE'}'

  mkdir -p $JOB_LOG_DIR_CURR
  cp "$(realpath "$0")" "${JOB_LOG_DIR_CURR}/."  # 拷贝当前文件
  cp $(dirname $0)/${DEFAULT_SH} "${JOB_LOG_DIR_CURR}/."
  cp $(dirname $0)/qcs-mv_profiling_to_curr.sh "${JOB_LOG_DIR_CURR}/."

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
