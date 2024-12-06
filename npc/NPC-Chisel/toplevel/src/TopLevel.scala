import chisel3._

class TopLevel() extends Module {
  val io = IO(new Bundle {
    val interrupt = Input(Bool())
    val master = Flipped(new Axi4IO())
    val slave = new Axi4IO()
    val test_pc = Output(UInt(Constant.BitWidth))
    val test_regs = Output(Vec(Constant.RegisterNum, UInt(Constant.BitWidth)))
    val test_csr = Output(Vec(Constant.CSRNum, UInt(Constant.BitWidth)))
    val test_imem_en = Output(Bool())
  })
  //val PC = RegInit(UInt(Constant.BitWidth), 0x80000000L.U)

  val clint = Module(new CLINT())
  val sram_arbiter = Module(new AxiArbiter())
  val axi_xbar = Module(new AxiXbar(2, Array((0L,0xFFFFFFFFL), (0xa0000048L,0xa000004FL))))
  val ifu = Module(new IFU())
  val idu = Module(new IDU())
  val exu = Module(new EXU())
  val wbu = Module(new WBU())
  val difftest = Module(new DiffTestSignal())

  val start_tick = RegInit(Bool(), true.B)
  start_tick := false.B

  ifu.io.in.valid := Mux(start_tick, true.B, wbu.io.out.valid)
  ifu.io.in.bits.pc := Mux(start_tick, 0x20000000L.U, wbu.io.out.bits.pc)
  wbu.io.out.ready := ifu.io.in.ready

  ifu.io.out <> idu.io.in
  exu.io.in <> idu.io.out
  wbu.io.in <> exu.io.out

  exu.io.wb_data := wbu.io.wb_data
  exu.io.wb_addr := wbu.io.wb_addr
  exu.io.wb_en := wbu.io.wb_en

  axi_xbar.io.in <> sram_arbiter.io.out
  io.master <> axi_xbar.io.out(0)
  clint.io <> axi_xbar.io.out(1)
  sram_arbiter.io.in1 <> ifu.io.imem
  sram_arbiter.io.in2 <> wbu.io.dmem

  io.slave.bresp := 0.U
  io.slave.bvalid := false.B
  io.slave.arready := false.B
  io.slave.bid := 0.U
  io.slave.rvalid := false.B
  io.slave.rdata := 0.U
  io.slave.rresp := 0.U
  io.slave.awready := false.B
  io.slave.rlast := false.B
  io.slave.wready := false.B
  io.slave.rid := 0.U

  io.test_imem_en := ifu.io.test_imem_en
  io.test_regs := exu.io.test_regs
  io.test_csr := exu.io.test_csr
  io.test_pc := ifu.io.test_pc

  difftest.io.enable := ifu.io.test_imem_en
  difftest.io.regs := exu.io.test_regs
  difftest.io.csr := exu.io.test_csr
  difftest.io.pc := ifu.io.test_pc

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
