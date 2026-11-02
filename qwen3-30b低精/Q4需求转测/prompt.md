帮我用ssh连接177.5.25.1，账号为root，已配置免密，进入docker exec -it kyle_verl_mxfp8 /bin/bash的容器中，注意你只能在这个容器内运行！
cd /mnt/share/z00804445/tasks/verl_w8a8_new/verl目录下，bash rays-start-mxfp8-1nodes.sh运行后，出现报错/mnt/share/z00804445/tasks/verl_w8a8_new/verl/logs/1nodes/20261102_1130/run_20261102_1130.log
但是verl在git checkout 18eb23dde5ec84edf51a8b780a74a116524aa5cb后可以运行，日志为/mnt/share/z00804445/tasks/verl_w8a8_new/verl/logs/1nodes/20261102_1137/run_20261102_1137.log
原因应该是最近verl重构了低精度的部分，把在昇腾适配上的代码删除了
现在你需要在NPU上适配verl的新架构，请定位问题并运行调试
你可以调小脚本的配置进行调试