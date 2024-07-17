import chisel3._
import chisel3.util.{Decoupled, Enum, MuxLookup}

class IFU_Input extends Bundle{
  val pc = UInt(Constant.BitWidth)
}

class IFU_Output extends Bundle{
  val inst = UInt(Constant.InstLen)
  val pc = UInt(Constant.BitWidth)
}

class IFU extends Module{
  val io = IO(new Bundle{
    val in = Flipped(Decoupled(new IFU_Input))
    val out = Decoupled(new IFU_Output)
    val test_imem_en = Output(Bool())
    val test_pc = Output(UInt(Constant.BitWidth))
    val imem = Flipped(new AxiLiteIO())
  })
  private val state_idle :: state_read :: state_read_wait :: state_wait_ready :: Nil = Enum(4)
  val state = RegInit(state_idle)
  state := MuxLookup(state, state_idle, List(
    state_idle -> Mux(io.in.valid, state_read, state_idle),
    state_read -> Mux(io.imem.arready, state_read_wait, state_read),
    state_read_wait -> Mux(io.imem.rvalid, state_wait_ready, state_read_wait),
    state_wait_ready -> Mux(io.out.ready, state_idle, state_wait_ready)
  ))
  val pc = RegInit(UInt(Constant.BitWidth), 0x80000000L.U)
  val inst = RegInit(UInt(Constant.InstLen), 0.U)
  io.imem.araddr := pc
  io.imem.arvalid := state === state_read
  io.imem.rready := true.B

  pc := Mux(io.in.valid && io.in.ready, io.in.bits.pc, pc)
  inst := Mux(io.imem.rvalid && io.imem.rready, io.imem.rdata, inst)

  io.imem.wvalid := false.B
  io.imem.awvalid := false.B
  io.imem.awaddr := 0.U
  io.imem.wdata := 0.U
  io.imem.wstrb := 0.U
  io.imem.bready := false.B

  io.in.ready := state === state_idle
  io.out.valid := state === state_wait_ready
  io.out.bits.inst := inst
  io.out.bits.pc := pc

  io.test_imem_en := state === state_read_wait || state===state_read
  io.test_pc := pc
}
