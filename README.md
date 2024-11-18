# "一生一芯"工程项目

这是"一生一芯"的工程项目. 通过运行

[lecture note]: https://ysyx.oscc.cc/docs/

## 拉取与构建项目

安装 `mill`, `riscv64-linux-gnu-gcc`

```bash
git clone --recursive git@github.com:WAAutoMaton/ysyx.git
cd ysyx
export NPC_HOME=$(pwd)/npc
export NEMU_HOME=$(pwd)/nemu
export AM_HOME=$(pwd)/abstract-machine
cd npc/NPC-Chisel
make chisel
```

## 运行 CPU-test

```bash
cd am-kernels/tests/cpu-tests
make ARCH=riscv32e-ysyxsoc BATCH_MODE=batch-on ALL=<test-name> run
```
`<test-name>` 留空则表示运行所有测试

## 运行 RT-Thread

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