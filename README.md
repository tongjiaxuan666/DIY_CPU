# DIY_CPU
## 1.1 项目简介
本项目参考自己动手写CPU书籍，目标是完成MIPS五级流水线架构CPU。
## 1.2 编译方式
```
find ./ -name "*.v" >> filelist.f //添加RTL源文件
make compile //运行VCS编译
make verdi //查看波形
```
## 2.项目完善过程

- 首先是完成了单指令ori命令的五级流水线架构搭建
- 考虑到流水线中取出指令的地址可能为执行阶段或者回写阶段得到数据，增加id中ex 和 mem直接输出到译码阶段的功能。
- 进一步丰富指令集，实现了移位操作等。
- 增加移动操作。在EX模块中增加特殊寄存器HI LO来保存移位信息。
- chapter7.1增加算数指令。有符号和无符号乘除，溢出标志位等
- chapter7.2增加累加累减功能。增加流水线暂停功能。
- chapter 7.3 增加除法模块。用状态机和试商法完成。
- chapter 8 增加跳转指令
- chapter 9.1 增加了SRAM模块，发现了因为读写内存没有EXE过程，所以执行阶段得到的数据不能立即传输给译码阶段，修改了书上的测试用例，增加了空指令。得到了正确结果。
- chapter 9.2 增加了sc ll命令。和LLbit_reg模块
- chapter 9.3 解决了load问题。使用了流水线暂停技术
- chapter 10 实现了协处理器CP0
- chapter 11 实现了中断，系统调用等异常情况的跳转，到这里openmips的功能已经完成了。
- chapter 12 增加了 wishbone总线 修改了openmips，去除了rom和ram接口