import chisel3._

class TopLevel() extends Module {
  val io = IO(new Bundle {
    val test_pc = Output(UInt(Constant.BitWidth))
    val test_regs = Output(Vec(Constant.RegisterNum, UInt(Constant.BitWidth)))
    val test_csr = Output(Vec(Constant.CSRNum, UInt(Constant.BitWidth)))
    val test_imem_en = Output(Bool())
  })
  //val PC = RegInit(UInt(Constant.BitWidth), 0x80000000L.U)

  val ifu = Module(new IFU())
  val idu = Module(new IDU())
  val exu = Module(new EXU())
  val wbu = Module(new WBU())

  val start_tick = RegInit(Bool(), true.B)
  start_tick := false.B

  ifu.io.in.valid := Mux(start_tick, true.B, wbu.io.out.valid)
  ifu.io.in.bits.pc := Mux(start_tick, 0x80000000L.U, wbu.io.out.bits.pc)
  wbu.io.out.ready := ifu.io.in.ready

  ifu.io.out <> idu.io.in
  exu.io.in <> idu.io.out
  wbu.io.in <> exu.io.out

  exu.io.wb_data := wbu.io.wb_data
  exu.io.wb_addr := wbu.io.wb_addr
  exu.io.wb_en := wbu.io.wb_en

  io.test_imem_en := ifu.io.test_imem_en
  io.test_regs := exu.io.test_regs
  io.test_csr := exu.io.test_csr
  io.test_pc := ifu.io.test_pc

}

// The Main object extending App to generate the Verilog code.
object TopLevel extends App {
  // Generate Verilog
  val verilog =
    (new chisel3.stage.ChiselStage).emitVerilog(
      new TopLevel(),
      args,
    )
  // Print the generated Verilog code to the console
  // println(verilog)
}
