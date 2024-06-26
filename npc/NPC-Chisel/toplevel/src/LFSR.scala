import chisel3._
import chisel3.util._

class LFSR extends Module {
  val io = IO(new Bundle {
    val out = Output(UInt(4.W))
  })

  // 初始化 LFSR 寄存器
  val lfsr = RegInit(1.U(4.W))

  // 反馈多项式的选择：对于 4 位 LFSR，使用 x^4 + x^3 + 1
  val feedback = lfsr(3) ^ lfsr(2)

  // 移位并引入反馈位
  lfsr := Cat(lfsr(2, 0), feedback)

  io.out := lfsr
}