conda activate verl-kyle-py312

source /home/pkg/b080/cann/set_env.sh

cd /home/z00804445/tasks/verl_mindspeed_low_precision/verl

bash rays-start-mxfp8-4nodes.sh

bash rays-start-bf16-4nodes.sh

nohup bash rays-start-mxfp8-4nodes.sh > ray_mxfp8.log 2>&1 &

nohup bash rays-start-bf16-4nodes.sh > ray_bf16.log 2>&1 &

ln -s ../vllm-ascend/vllm_ascend vllm_ascend