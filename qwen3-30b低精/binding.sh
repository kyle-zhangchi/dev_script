cd /mnt/share/z00804445/core/msboost_1088/affinity-sched
export PYTHONPATH=$PWD


# 1. 执行 -d 观察调度策略是否正确
python examples/affinity_verl.py -tp-size 2 -dp-size 4 -d

# 2. 执行 -r 使能自适应亲和调度
python examples/affinity_verl.py -tp-size 2 -dp-size 4 -r

# 3. 若不符合预期，可执行 -restore 重置绑核操作，恢复亲和性到初始状态
python examples/affinity_verl.py -tp-size 2 -dp-size 4 -restore