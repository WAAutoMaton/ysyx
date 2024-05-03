import chisel3._

object ImmediateType extends Enumeration {
  val INVALID_TYPE: UInt = 0.U
  val I_TYPE: UInt = 1.U
  val S_TYPE: UInt = 2.U
  val B_TYPE: UInt = 3.U
  val U_TYPE: UInt = 4.U
  val J_TYPE: UInt = 5.U
  val R_TYPE: UInt = 6.U
}

object Instruction extends Enumeration {
  val INVALID: UInt = 0.U
  val ADDI: UInt = 1.U
  val JAL: UInt = 2.U
  val JALR: UInt = 3.U
  val LUI: UInt = 4.U
  val SW: UInt = 5.U
  val EBREAK: UInt = 6.U
}

object PCSelValue extends Enumeration {
  val KEEP: UInt = 0.U
  val INC4: UInt = 1.U
  val OVERWRITE: UInt = 2.U
}

object ASelValue extends Enumeration {
  val ZERO: UInt = 0.U
  val REG: UInt = 1.U
  val PC:  UInt = 2.U
}

object BSelValue extends Enumeration {
  val REG: UInt = 0.U
  val IMM: UInt = 1.U
}

object WBSelValue extends Enumeration {
  val NOT_APPLY: UInt = 0.U
  val ALU: UInt = 1.U
  val PC4: UInt = 2.U
}