
cd /mnt/share/z00804445/tasks/verl_q4_test/verl
git checkout 07ba1a854e57356ccf1c9d604898607a88e3da3e
git apply --whitespace=nowarn /mnt/share/z00804445/tasks/verl_q4_test/patch/verl.patch


docker load -i /mnt/share/z00804445/tasks/verl_q4_test/verl-latest-vllm-950-ubuntu-1109.tar


docker run -dit \
    --ipc=host \
    --net=host \
    --pid=host \
    --name 'kyle_verl_q4_test' \
    --privileged \
    --shm-size 720g \
    --device=/dev/hisi_hdc \
    --device=/dev/davinci_manager \
    --device=/dev/davinci0 \
    --device=/dev/davinci1 \
    --device=/dev/davinci2 \
    --device=/dev/davinci3 \
    --device=/dev/davinci4 \
    --device=/dev/davinci5 \
    --device=/dev/davinci6 \
    --device=/dev/davinci7 \
    --device=/dev/uburma \
    --device=/dev/ummu \
    -e LD_LIBRARY_PATH=/usr/lib64/:/usr/local/Ascend/driver/lib64/driver:/usr/local/Ascend/driver/lib64/common:/usr/lib/aarch64-linux-gnu/:$LD_LIBRARY_PATH \
    -v /root/ascend:/root/ascend \
    -v /etc/ascend_install.info:/etc/ascend_install.info \
    -v /etc/hccn.conf:/etc/hccn.conf \
    -v /usr/bin/msnpureport:/usr/bin/msnpureport \
    -v /usr/local/bin/npu-smi:/usr/local/bin/npu-smi \
    -v /usr/local/sbin/npu-smi:/usr/local/sbin/npu-smi \
    -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
    -v /usr/local/dcmi:/usr/local/dcmi \
    -v /usr/lib64/libnl-3.so.200:/usr/lib64/libnl-3.so.200 \
    -v /usr/lib64/libnl-genl-3.so.200:/usr/lib64/libnl-genl-3.so.200 \
    -v /usr/lib64/urma:/usr/lib64/urma \
    -v /usr/lib64/liburma_common.so:/usr/lib64/liburma_common.so \
    -v /usr/lib64/liburma_common.so.0:/usr/lib64/liburma_common.so.0 \
    -v /usr/lib64/liburma_common.so.0.0.1:/usr/lib64/liburma_common.so.0.0.1 \
    -v /usr/lib64/liburma.so:/usr/lib64/liburma.so \
    -v /usr/lib64/liburma.so.0:/usr/lib64/liburma.so.0 \
    -v /usr/lib64/liburma.so.0.0.3:/usr/lib64/liburma.so.0.0.3 \
    -v /usr/lib64/libummu.so.1:/usr/lib64/libummu.so.1 \
    -v /usr/lib64/libummu.so.1.0.5:/usr/lib64/libummu.so.1.0.5 \
    -v /dev/log:/dev/log \
    -v /home/:/home/ \
    -v /data/:/data/ \
    -v /mnt:/mnt \
    quay.io/ascend/verl:latest-vllm-950-ubuntu-1109 \
    /bin/bash

docker exec -it kyle_verl_q4_test /bin/bash

apt-get update && apt-get install net-tools

cd /vllm-ascend
git checkout 59ebc4384b340065127e9b1e1bb73a257c51895e
git apply --whitespace=nowarn /mnt/share/z00804445/tasks/verl_q4_test/patch/vllm-ascend.patch


cd /mnt/share/z00804445/tasks/verl_q4_test/verl


