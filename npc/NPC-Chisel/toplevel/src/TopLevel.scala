import chisel3._
import chisel3.util.MuxLookup

class TopLevel() extends Module {
  val io = IO(new Bundle {
    val test_pc = Output(UInt(Constant.BitWidth))
    val test_regs = Output(Vec(32, UInt(Constant.BitWidth)))
    val test_imem_en = Output(Bool())
  })
  val PC = RegInit(UInt(Constant.BitWidth), 0x80000000L.U)
  io.test_pc := PC

  val controller = Module(new Controller())

  val imem = Module(new PMem())
  val dmem = Module(new PMem())
  val register_file = Module(new RegisterFile())
  val alu = Module(new ALU())
  val inst = RegInit(UInt(Constant.InstLen), 0.U)
  val ebreak_inst = Module(new EBreak())
  val imm_gen = Module(new ImmediateGenerator)
  ebreak_inst.io.enable := controller.io.ebreak_en
  ebreak_inst.io.code   := controller.io.ebreak_code

  PC := MuxLookup(controller.io.PC_sel, PC, Seq(
    PCSelV.KEEP -> PC,
    PCSelV.INC4 -> (PC + 4.U),
    PCSelV.OVERWRITE -> alu.io.result,
    PCSelV.BRANCH -> Mux(alu.io.result(0), (PC + imm_gen.io.imm), (PC + 4.U)),
  ))
  inst := Mux(controller.io.imem_en, imem.io.rdata, inst)
  controller.io.inst := inst
  alu.io.src1 := MuxLookup(controller.io.A_sel, 0.U, Seq(
    ASelV.REG -> register_file.io.reg1_data,
    ASelV.PC -> PC,
  ))
  alu.io.src2 := MuxLookup(controller.io.B_sel, 0.U, Seq(
    BSelV.REG -> register_file.io.reg2_data,
    BSelV.IMM -> imm_gen.io.imm,
  ))
  alu.io.sel := controller.io.ALU_sel
  register_file.io.write_data := MuxLookup(controller.io.WB_sel, 0.U, Seq(
    WBSelV.ALU -> alu.io.result,
    WBSelV.PC4 -> (PC+4.U),
    WBSelV.LW -> dmem.io.rdata,
    WBSelV.LBU -> dmem.io.rdata(7, 0),
    WBSelV.LHU -> dmem.io.rdata(15, 0),
    WBSelV.LB -> dmem.io.rdata(7, 0).asSInt.pad(32).asUInt,
    WBSelV.LH -> dmem.io.rdata(15, 0).asSInt.pad(32).asUInt,
  ))
  register_file.io.write_address := inst(11, 7)
  register_file.io.write_enable := controller.io.reg_write_en
  register_file.io.reg1_addr := inst(19, 15)
  register_file.io.reg1_read_enable := controller.io.reg_read_en
  register_file.io.reg2_addr := inst(24, 20)
  register_file.io.reg2_read_enable := controller.io.reg_read_en
  imm_gen.io.inst := inst
  imm_gen.io.imm_type := controller.io.imm_type
  io.test_regs := register_file.io.test_reg_out

  imem.io.valid := controller.io.imem_en
  imem.io.raddr := PC
  imem.io.waddr:=0.U
  imem.io.wdata:=0.U
  imem.io.wmask:=0.U
  imem.io.wen := false.B
  io.test_imem_en := controller.io.imem_en

  val dmem_write_data = RegInit(UInt(Constant.BitWidth), 0.U)
  dmem_write_data := register_file.io.reg2_data
  dmem.io.valid := controller.io.dmem_read_en || controller.io.dmem_write_en
  dmem.io.raddr := alu.io.result
  dmem.io.wen := controller.io.dmem_write_en
  dmem.io.waddr := alu.io.result
  dmem.io.wdata := dmem_write_data
  dmem.io.wmask := controller.io.dmem_write_mask
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
