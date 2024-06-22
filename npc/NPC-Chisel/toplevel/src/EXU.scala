import chisel3._
import chisel3.util._

class EXU_Output extends Bundle {
  val control_signal = new ControlSignal
  val imm = UInt(Constant.BitWidth)
  val pc = UInt(Constant.BitWidth)
  val inst = UInt(Constant.BitWidth)
  val alu_result = UInt(Constant.BitWidth)
  val csr_pc_result = UInt(Constant.BitWidth)
  val csr_rdata = UInt(Constant.BitWidth)
  val reg2_data = UInt(Constant.BitWidth)
}

class EXU extends Module{
  val io = IO(new Bundle{
    val in = Flipped(Decoupled(new IDU_Output))
    val out = Decoupled(new EXU_Output)
    val test_regs = Output(Vec(Constant.RegisterNum, UInt(Constant.BitWidth)))
    val test_csr = Output(Vec(Constant.CSRNum, UInt(Constant.BitWidth)))
    val wb_en = Input(Bool())
    val wb_data = Input(UInt(Constant.BitWidth))
    val wb_addr = Input(UInt(Constant.RegAddrLen))
  })

  private val state_idle :: state_execute :: state_wait_ready :: Nil = Enum(3)
  val state = RegInit(state_idle)
  state := MuxLookup(state, state_idle, List(
    state_idle -> Mux(io.in.valid, state_execute, state_idle),
    state_execute -> state_wait_ready,
    state_wait_ready -> Mux(io.out.ready, state_idle, state_wait_ready)
  ))

  val register_file = Module(new RegisterFile())
  val alu = Module(new ALU())
  val ebreak_inst = Module(new EBreak())

  val csig_init = Wire(new ControlSignal)
  csig_init.A_sel := ASelV.ZERO
  csig_init.B_sel := BSelV.IMM
  csig_init.WB_sel := WBSelV.NO_WB
  csig_init.PC_sel := PCSelV.KEEP
  csig_init.ALU_sel := ALUSelV.ZERO
  csig_init.csr_sel := CsrVal.INV
  csig_init.dmem_read_en := false.B
  csig_init.dmem_read_type := LdValue.INV
  csig_init.dmem_write_en := false.B
  csig_init.dmem_write_type := StValue.INV
  csig_init.ebreak_en := false.B
  csig_init.ebreak_code := 0.U

  val csig = RegInit(new ControlSignal, csig_init)
  csig := Mux(io.in.valid && io.in.ready, io.in.bits.control_signal, csig)
  val imm = RegInit(UInt(Constant.BitWidth), 0.U)
  imm := Mux(io.in.valid && io.in.ready, io.in.bits.imm, imm)
  val pc = RegInit(UInt(Constant.BitWidth), 0.U)
  pc := Mux(io.in.ready && io.in.valid, io.in.bits.pc, pc)
  val inst = RegInit(UInt(Constant.InstLen), 0.U)
  inst := Mux(io.in.ready && io.in.valid, io.in.bits.inst, inst)

  alu.io.src1 := MuxLookup(csig.A_sel, 0.U, Seq(
    ASelV.REG -> register_file.io.reg1_data,
    ASelV.PC -> pc,
  ))
  alu.io.src2 := MuxLookup(csig.B_sel, 0.U, Seq(
    BSelV.REG -> register_file.io.reg2_data,
    BSelV.IMM -> imm,
  ))
  alu.io.sel := csig.ALU_sel

  ebreak_inst.io.enable := Mux(state===state_execute, csig.ebreak_en, false.B)
  ebreak_inst.io.code   := csig.ebreak_code

  register_file.io.write_address := io.wb_addr
  register_file.io.write_enable := io.wb_en
  register_file.io.write_data := io.wb_data
  register_file.io.reg1_addr := inst(19, 15)
  register_file.io.reg2_addr := inst(24, 20)
  register_file.io.csr_ecall_enable := state === state_execute && csig.PC_sel === PCSelV.ECALL
  register_file.io.csr_mret_enable := state === state_execute && csig.PC_sel === PCSelV.MRET
  register_file.io.csr_rw_enable := state === state_execute && csig.csr_sel === CsrVal.RW
  register_file.io.csr_rs_enable := state === state_execute && csig.csr_sel === CsrVal.RS
  register_file.io.csr_addr := imm
  register_file.io.csr_wdata := register_file.io.reg1_data
  register_file.io.pc := pc

  io.out.valid := state === state_wait_ready
  io.in.ready := state === state_idle
  io.out.bits.control_signal := csig
  io.out.bits.alu_result := alu.io.result
  io.out.bits.csr_pc_result := Mux(csig.PC_sel === PCSelV.ECALL, register_file.io.csr_ecall_ret, register_file.io.csr_mret_ret)
  io.out.bits.csr_rdata := register_file.io.csr_rdata
  io.out.bits.reg2_data := register_file.io.reg2_data
  io.out.bits.inst := inst
  io.out.bits.imm := imm
  io.out.bits.pc := pc

  io.test_regs := register_file.io.test_reg_out
  io.test_csr := register_file.io.test_csr_out
}
