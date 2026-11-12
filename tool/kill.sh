# 出现过杀不干净的任务，使用如下命令一次杀除残余进程

ps -ef | grep "python"| grep -v grep | awk '{print $2}' | xargs -t -i kill -9 {};pkill -9 python; pkill -9 torchrun;ray stop

# 杀默认进程

ps -ef | grep "defunct"|grep python| awk '{print $3}'|xargs -t -i kill -9 {};ps -ef | grep "defunct"|grep torchrun| awk '{print $3}'|xargs -t -i kill -9 {}

#杀vllm
pkill -9 VLLM


ps -ef | grep "python"| grep -v grep | awk '{print $2}' | xargs -t -i kill -9 {}
ps -ef | grep "ray"| grep -v grep | awk '{print $2}' | xargs -t -i kill -9 {}
ps -ef | grep "VLLM"| grep -v grep | awk '{print $2}' | xargs -t -i kill -9 {}
ps -ef | grep "vscode"| grep -v grep | awk '{print $2}' | xargs -t -i kill -9 {}
