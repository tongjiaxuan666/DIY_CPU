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