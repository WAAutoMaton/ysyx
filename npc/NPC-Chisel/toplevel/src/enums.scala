import chisel3._

object ImmType extends Enumeration {
  val INVALID_TYPE: UInt = 0.U
  val I: UInt = 1.U
  val S: UInt = 2.U
  val B: UInt = 3.U
  val U: UInt = 4.U
  val J: UInt = 5.U
  val R: UInt = 6.U
}

object PCSelV extends Enumeration {
  val KEEP: UInt = 0.U
  val INC4: UInt = 1.U
  val OVERWRITE: UInt = 2.U
}

object ASelV extends Enumeration {
  val ZERO: UInt = 0.U
  val REG: UInt = 1.U
  val PC:  UInt = 2.U
}

object BSelV extends Enumeration {
  val REG: UInt = 0.U
  val IMM: UInt = 1.U
}

object WBSelV extends Enumeration {
  val NO_WB: UInt = 0.U
  val ALU: UInt = 1.U
  val PC4: UInt = 2.U
  val DMEM: UInt = 3.U
}

object ALUSelV extends Enumeration {
  val ZERO: UInt = 0.U
  val ADD: UInt = 1.U
  val SUB: UInt = 2.U
  val GEU: UInt = 3.U
  val GE: UInt = 4.U
}

object LdValue extends Enumeration {
  val INV: UInt = 0.U
  val LB: UInt = 1.U
  val LH: UInt = 2.U
  val LW: UInt = 3.U
  val LBU: UInt = 4.U
  val LHU: UInt = 5.U
}

object StValue extends Enumeration {
  val INV: UInt = 0.U
  val SB: UInt = 1.U
  val SH: UInt = 2.U
  val SW: UInt = 3.U
}
