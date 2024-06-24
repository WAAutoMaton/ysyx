import chisel3._

class SRAM extends Module{
  val io = IO(new Bundle{
    val valid = Input(Bool())
    val raddr = Input(UInt(32.W))
    val rdata = Output(UInt(32.W))
    val waddr = Input(UInt(32.W))
    val wdata = Input(UInt(32.W))
    val wmask = Input(UInt(8.W))
    val wen = Input(Bool())
  })
  val pmem = Module(new PMem())
  pmem.io.valid := io.valid
  pmem.io.raddr := io.raddr
  pmem.io.waddr := io.waddr
  pmem.io.wdata := io.wdata
  pmem.io.wmask := io.wmask
  pmem.io.wen := io.wen
  io.rdata := RegNext(pmem.io.rdata)
}
