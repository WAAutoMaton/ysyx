# "一生一芯"工程项目

这是"一生一芯"的工程项目. 通过运行
```bash
bash init.sh subproject-name
```
进行初始化, 具体请参考[实验讲义][lecture note].

[lecture note]: https://ysyx.oscc.cc/docs/

## 运行 RT-Thread

使用

```bash
git clone --recursive git@github.com:WAAutoMaton/ysyx.git
```
克隆项目本项目

将 fceux 的 rom 放置到 `fceux-am/nes` 目录下。

然后运行

```bash
cd ysyx
export NPC_HOME=$(pwd)/npc
export NEMU_HOME=$(pwd)/nemu
export AM_HOME=$(pwd)/abstract-machine
cd rt-thread-am/bsp/abstract-machine/
make init
make ARCH=riscv32e-npc BATCH_MODE=batch-on run
```