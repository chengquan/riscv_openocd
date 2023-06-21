# riscv_openocd

“OpenOCD为Debug神器，烧写神器。本文主要汇总一下相关资料，并基于openocd和开源的RISC-V搭建学习demo。同时，感谢ref中各位大佬分享的优质资料和工程。”



#仿真调试


github上的工程调试需要启动3个终端，分别用于 1) VCS仿真  2）OpenOCD Link 3）Telnet交互，具体如下：


Terminal 1）for VCS

cd SIM
make clean
make install
make run_test

即可得到如下输出，显示44853port正在监听：


Terminal 2）for OpenOCD

cd openocd
openocd -f chaos996.cfg

即可得到如下输出，即表明openocd连接已建立：


Terminal 3）for Telnet

telnet localhost 4444

连接到4444号port, 输入一些常规测试命令：

结束仿真以后，在termial 1）中键入如下命令启动verdi查看波形：

make wave

即可使用verdi打开rom中0x00000000地址查看数据是否被改写，波形如下：

其他指令的测试查阅openocd的UG即可。


#Reference

[1] OpenOCD github

https://github.com/riscv/riscv-openocd

[2] OpenOCD代码结构浅析(基于RISCV)

https://zhuanlan.zhihu.com/p/25949449

[3] OpenOCD刷写FLASH代码结构浅析(基于RISCV)

https://zhuanlan.zhihu.com/p/507467621

[4] TinyRISC-V gitee

https://gitee.com/liangkangnan/tinyriscv

[5] RISC-V JTAG调试

https://liangkangnan.gitee.io/2020/03/21/%E6%B7%B1%E5%85%A5%E6%B5%85%E5%87%BARISC-V%E8%B0%83%E8%AF%95/

[6] 蜂鸟E203 github

https://github.com/riscv-mcu/e203_hbirdv2

[7] 用telnet+openocd+jtag_dpi+vcs仿真调试RISCV的cpu

https://blog.csdn.net/beA_doc/article/details/127041266

[8] JTAG dpi github

https://github.com/yaozhaosh/e200_opensource/tree/master

​



