import chisel3._
import chisel3.internal.firrtl.Width
import chisel3.util.MuxLookup

class TopLevel() extends Module {
  val DATA_WIDTH: Width = 32.W
  val io = IO(new Bundle {
    val mem_read_address = Output(UInt(DATA_WIDTH))
    val mem_read_value = Input(UInt(DATA_WIDTH))
    val mem_read_en = Output(Bool())
    val test_regs = Output(Vec(32, UInt(DATA_WIDTH)))
  })
  val PC = RegInit(UInt(32.W), 0x80000000L.U)
  io.mem_read_address := PC

  val controller = Module(new Controller())
  io.mem_read_en := controller.io.imem_en

  val register_file = Module(new RegisterFile())
  val alu = Module(new ALU())
  val inst = RegInit(UInt(32.W), 0.U)
  val ebreak_inst = Module(new EBreak())
  val imm_gen = Module(new ImmediateGenerator)
  ebreak_inst.io.enable := inst === 0x00100073L.U

  PC := MuxLookup(controller.io.PC_sel, PC, Seq(
    PCSelValue.KEEP -> PC,
    PCSelValue.INC4 -> (PC + 4.U),
    PCSelValue.OVERWRITE -> alu.io.result,
  ))
  inst := Mux(io.mem_read_en, io.mem_read_value, inst)
  controller.io.inst := inst
  alu.io.src1 := MuxLookup(controller.io.A_sel, 0.U, Seq(
    ASelValue.REG -> register_file.io.reg1_data,
    ASelValue.PC -> PC,
  ))
  alu.io.src2 := MuxLookup(controller.io.B_sel, 0.U, Seq(
    BSelValue.REG -> 0.U,
    BSelValue.IMM -> imm_gen.io.imm,
  ))
  register_file.io.write_data := MuxLookup(controller.io.WB_sel, 0.U, Seq(
    WBSelValue.ALU -> alu.io.result,
    WBSelValue.PC4 -> (PC+4.U),
  ))
  register_file.io.write_address := inst(11, 7)
  register_file.io.write_enable := controller.io.reg_write_en
  register_file.io.reg1_addr := inst(19, 15)
  register_file.io.reg1_read_enable := controller.io.reg_read_en
  imm_gen.io.inst := inst
  imm_gen.io.imm_type := controller.io.imm_type
  io.test_regs := register_file.io.test_reg_out
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
