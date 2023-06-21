# riscv_openocd

“OpenOCD为Debug神器，烧写神器。本文主要汇总一下相关资料，并基于openocd和开源的RISC-V搭建学习demo。同时，感谢ref中各位大佬分享的优质资料和工程。”



一个好的在线仿真MCU的RTL代码的调试平台能达到事半功倍的效果。总不能改改代码就上FPGA然后接JTAG调试，那样时间成本过高。目前来看，OpenOCD由于其的开源特性以及工具成熟程度，属极优之选。另外，本帐号仅在记录个人笔记时使用，有些私信可能会超时到期遗漏回复，望见谅。本笔记的工程（仅仅为一个学习用的showcase）于如下地址：


01

—

OpenOCD+RISC-V

OpenOCD主要提供三种交互方式：

1）3333端口的gdb调试

2）6666端口的tcl调试

3）4444端口的telnet调试

   本文为telnet调试。


openocd源代码解析请查阅[1-3]。


RISC-V方便找到支持JTAG的开源MCU皆可。由于TinyRISC-V极度精简的设计，而且完全基于Verilog设计，没有由chisel或者其它高级语言综合而来的乱七八糟的代码，仿真时比较好trace, 属于较好的选择。


TinyRISC-V资料请查阅文末[4-5]。

02

—

环境配置



由于本人仅会VCS+Verdi仿真工具链，所以并没有用Verilator等其它环境。

OpenOCD, GCC工具链, SDK可以直接沿用[4]中提供的，也可自行编译或设计。


OpenOCD由如下编译命令生成（可能不对，忘了）：

git clone git://git.code.sf.net/p/openocd/code openocd
./bootstrap
mkdir build
cd build
../configure --prefix /riscv-openocd-riscv/openocd/
make
sudo make install

GCC工具链可参考《33. Adding Custom Instructions to RISC-V GNU toolchain》。

此外，TinyRISC-V的GCC应该在交叉编译时选如下指令集合：

RISCV_ARCH := rv32im
RISCV_ABI := ilp32


VCS&Verdi脚本基于蜂鸟e203 SoC的脚本修改，具体可参考文末[6]。


openocd的cfg文件随便找个脚本参考即可。主要是interface要用remote_bitbang, 如下：


本文中采用OpenOCD中的jtag dpi接口(jtag_dpi.c)与VCS中的DPI function进行通讯，从而实现debug功能。一言概之即C/C++与RTL的混合仿真。类似的设计可参考文末[7]。


另外，tb中jtag_dpi的调节接口继承自[8]。同时，我也找过其他类似的code, 但似乎与VCS DPI的兼容性不太好，仅仅只有[8]是调试通过的。


testbench需要改写并放入jtagdpi模块。该模块由SV和C/C++混写。

其他具体细节，查阅github上工程即可。


03

—

仿真调试


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



04

—

Reference

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



