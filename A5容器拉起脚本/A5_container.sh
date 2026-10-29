#!/usr/bin/env bash
set -e

HOST_NAME="$(hostname -s)"
CONTAINER_NAME="kyle-fsdp-turbo-verl-kimi-k3"


docker run -dit \
    --user root \
    --network host \
    --ipc=host \
    --net=host \
    --pid=host \
    --name "${CONTAINER_NAME}" \
    --hostname "${HOST_NAME}" \
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
    --entrypoint /bin/bash \
    quay.io/albert54/verl:kimi-k3-fsdpturbo-vllm-cann920-a5-1027 \
    -c "sleep infinity"
