import chisel3._
import chisel3.util._

class WBU extends Module{
  val io = IO(new Bundle{
    val in = Flipped(Decoupled(new EXU_Output))
    val out = Decoupled(new IFU_Input)
    val wb_data = Output(UInt(Constant.BitWidth))
    val wb_addr = Output(UInt(Constant.RegAddrLen))
    val wb_en = Output(Bool())
    val dmem = Flipped(new Axi4IO())
  })

  private val state_idle :: state_execute :: state_mem_read :: state_mem_write :: state_read_wait :: state_write_wait :: state_wait_ready :: Nil = Enum(7)
  val state = RegInit(state_idle)
  state := MuxLookup(state, state_idle, List(
    state_idle -> Mux(io.in.valid,
      Mux(io.in.bits.control_signal.dmem_read_en, state_mem_read,
        Mux(io.in.bits.control_signal.dmem_write_en, state_mem_write, state_execute),
    ), state_idle),
    state_execute -> state_wait_ready,
    state_mem_read -> Mux(io.dmem.arready, state_read_wait, state_mem_read),
    state_mem_write -> Mux(io.dmem.awready && io.dmem.wready, state_write_wait, state_mem_write),
    state_read_wait -> Mux(io.dmem.rvalid, state_wait_ready, state_read_wait),
    state_write_wait -> Mux(io.dmem.bvalid, state_wait_ready, state_write_wait),
    state_wait_ready -> Mux(io.out.ready, state_idle, state_wait_ready)
  ))


  val imm = RegInit(UInt(Constant.BitWidth), 0.U)
  imm := Mux(io.in.valid && io.in.ready, io.in.bits.imm, imm)
  val pc = RegInit(UInt(Constant.BitWidth), 0.U)
  pc := Mux(io.in.ready && io.in.valid, io.in.bits.pc, pc)
  val input = Reg(new EXU_Output())
  input := Mux(io.in.ready && io.in.valid, io.in.bits, input)
  val csig = input.control_signal
  val alu_result = input.alu_result
  val csr_pc_result = input.csr_pc_result
  val csr_rdata = input.csr_rdata

  val new_pc = RegInit(UInt(Constant.BitWidth), 0.U)
  new_pc := MuxLookup(csig.PC_sel, pc, Seq(
    PCSelV.KEEP -> pc,
    PCSelV.INC4 -> (pc + 4.U),
    PCSelV.OVERWRITE -> alu_result,
    PCSelV.BRANCH -> Mux(alu_result(0), (pc + imm), (pc + 4.U)),
    PCSelV.ECALL  -> csr_pc_result,
    PCSelV.MRET   -> csr_pc_result
  ))

  io.wb_addr := input.inst(11, 7)
  io.wb_en := (state===state_execute && csig.WB_sel=/=WBSelV.NO_WB) || (state === state_read_wait && io.dmem.rvalid && io.dmem.rready)
  val byte_offset = alu_result(1, 0)


  io.wb_data := MuxLookup(csig.WB_sel, 0.U, Seq(
    WBSelV.ALU -> alu_result,
    WBSelV.PC4 -> (pc + 4.U),
    WBSelV.LW -> io.dmem.rdata,
    WBSelV.LBU -> MuxLookup(byte_offset, io.dmem.rdata(7, 0), Seq(
      "b00".U -> io.dmem.rdata(7, 0),
      "b01".U -> io.dmem.rdata(15, 8),
      "b10".U -> io.dmem.rdata(23, 16),
      "b11".U -> io.dmem.rdata(31, 24)
    )),
    WBSelV.LHU -> MuxLookup(alu_result(1), io.dmem.rdata(15, 0), Seq(
      0.U -> io.dmem.rdata(15, 0),
      1.U -> io.dmem.rdata(31, 16)
    )),
    WBSelV.LB -> MuxLookup(byte_offset, io.dmem.rdata(7, 0).asSInt.pad(32).asUInt, Seq(
      "b00".U -> io.dmem.rdata(7, 0).asSInt.pad(32).asUInt,
      "b01".U -> io.dmem.rdata(15, 8).asSInt.pad(32).asUInt,
      "b10".U -> io.dmem.rdata(23, 16).asSInt.pad(32).asUInt,
      "b11".U -> io.dmem.rdata(31, 24).asSInt.pad(32).asUInt
    )),
    WBSelV.LH -> MuxLookup(alu_result(1), io.dmem.rdata(15, 0).asSInt.pad(32).asUInt, Seq(
      0.U -> io.dmem.rdata(15, 0).asSInt.pad(32).asUInt,
      1.U -> io.dmem.rdata(31, 16).asSInt.pad(32).asUInt
    )),
    WBSelV.CSR -> csr_rdata,
  ))

  io.dmem.araddr := alu_result
  io.dmem.arvalid := state === state_mem_read
  io.dmem.rready := true.B
  io.dmem.arlen := 0.U
  io.dmem.arsize := MuxLookup(csig.dmem_read_type, 0.U, Seq(
    LdValue.LB -> 0.U,
    LdValue.LBU -> 0.U,
    LdValue.LH -> 1.U,
    LdValue.LHU -> 1.U,
    LdValue.LW -> 2.U,
  ))
  io.dmem.arburst := 0.U
  // TODO
  io.dmem.arid := 0.U

  io.dmem.wvalid := state === state_mem_write
  io.dmem.awvalid := state === state_mem_write
  io.dmem.awaddr := alu_result
  io.dmem.awlen := 0.U
  io.dmem.awsize := MuxLookup(csig.dmem_write_type, 0.U, Seq(
    StValue.SB -> 0.U,
    StValue.SH -> 1.U,
    StValue.SW -> 2.U,
  ))
  io.dmem.awburst := 0.U
  // TODO
  io.dmem.awid := 0.U

  io.dmem.wstrb := MuxLookup(csig.dmem_write_type, "b0000".U, Seq(
    StValue.SW -> "b1111".U,
    StValue.SH -> MuxLookup(alu_result(1), "b0011".U, Seq(
      0.U -> "b0011".U,
      1.U -> "b1100".U
    )),
    StValue.SB -> MuxLookup(byte_offset, "b0001".U, Seq(
      "b00".U -> "b0001".U,
      "b01".U -> "b0010".U,
      "b10".U -> "b0100".U,
      "b11".U -> "b1000".U
    ))
  ))
  // Also need to adjust the write data based on the byte offset
  io.dmem.wdata := MuxLookup(csig.dmem_write_type, input.reg2_data, Seq(
    StValue.SW -> input.reg2_data,
    StValue.SH -> MuxLookup(alu_result(1), input.reg2_data, Seq(
      0.U -> input.reg2_data,
      1.U -> (input.reg2_data << 16.U)
    )),
    StValue.SB -> MuxLookup(byte_offset, input.reg2_data, Seq(
      "b00".U -> input.reg2_data,
      "b01".U -> (input.reg2_data << 8.U),
      "b10".U -> (input.reg2_data << 16.U),
      "b11".U -> (input.reg2_data << 24.U)
    ))
  ))
  io.dmem.wlast := false.B
  io.dmem.bready := state === state_write_wait

  io.out.valid := state === state_wait_ready
  io.in.ready := state === state_idle
  io.out.bits.pc := new_pc

}