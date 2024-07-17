module AxiArbiter(
  input         clock,
  input         reset,
  input  [31:0] io_in1_araddr,
  input         io_in1_arvalid,
  output        io_in1_arready,
  output [31:0] io_in1_rdata,
  output        io_in1_rvalid,
  input  [31:0] io_in2_araddr,
  input         io_in2_arvalid,
  output        io_in2_arready,
  output [31:0] io_in2_rdata,
  output        io_in2_rvalid,
  input  [31:0] io_in2_awaddr,
  input         io_in2_awvalid,
  output        io_in2_awready,
  input  [31:0] io_in2_wdata,
  input  [3:0]  io_in2_wstrb,
  input         io_in2_wvalid,
  output        io_in2_wready,
  output        io_in2_bvalid,
  input         io_in2_bready,
  output [31:0] io_out_araddr,
  output        io_out_arvalid,
  input         io_out_arready,
  input  [31:0] io_out_rdata,
  input         io_out_rvalid,
  output        io_out_rready,
  output [31:0] io_out_awaddr,
  output        io_out_awvalid,
  input         io_out_awready,
  output [31:0] io_out_wdata,
  output [3:0]  io_out_wstrb,
  output        io_out_wvalid,
  input         io_out_wready,
  input         io_out_bvalid,
  output        io_out_bready
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] state_r; // @[AxiArbiter.scala 37:24]
  wire [1:0] _state_r_T = io_in2_arvalid ? 2'h2 : 2'h0; // @[AxiArbiter.scala 41:10]
  wire [1:0] _state_r_T_1 = io_in1_arvalid ? 2'h1 : _state_r_T; // @[AxiArbiter.scala 40:24]
  wire  _io_out_araddr_T = state_r == 2'h1; // @[AxiArbiter.scala 46:32]
  wire  _io_in2_arready_T = state_r == 2'h2; // @[AxiArbiter.scala 52:29]
  reg [1:0] state_w; // @[AxiArbiter.scala 65:24]
  wire [1:0] _state_w_T_2 = io_in2_wvalid | io_in2_awvalid ? 2'h2 : 2'h0; // @[AxiArbiter.scala 69:10]
  wire  _io_out_awaddr_T = state_w == 2'h1; // @[AxiArbiter.scala 74:32]
  wire  _io_in2_awready_T = state_w == 2'h2; // @[AxiArbiter.scala 86:29]
  assign io_in1_arready = _io_out_araddr_T & io_out_arready; // @[AxiArbiter.scala 51:50]
  assign io_in1_rdata = io_out_rdata; // @[AxiArbiter.scala 53:16]
  assign io_in1_rvalid = io_out_rvalid & _io_out_araddr_T; // @[AxiArbiter.scala 57:34]
  assign io_in2_arready = state_r == 2'h2 & io_out_arready; // @[AxiArbiter.scala 52:50]
  assign io_in2_rdata = io_out_rdata; // @[AxiArbiter.scala 54:16]
  assign io_in2_rvalid = io_out_rvalid & _io_in2_arready_T; // @[AxiArbiter.scala 58:34]
  assign io_in2_awready = state_w == 2'h2 & io_out_awready; // @[AxiArbiter.scala 86:50]
  assign io_in2_wready = _io_in2_awready_T & io_out_wready; // @[AxiArbiter.scala 88:49]
  assign io_in2_bvalid = io_out_bvalid & _io_in2_awready_T; // @[AxiArbiter.scala 92:34]
  assign io_out_araddr = state_r == 2'h1 ? io_in1_araddr : io_in2_araddr; // @[AxiArbiter.scala 46:23]
  assign io_out_arvalid = 2'h2 == state_r ? io_in2_arvalid : 2'h1 == state_r & io_in1_arvalid; // @[Mux.scala 81:58]
  assign io_out_rready = 2'h2 == state_r | 2'h1 == state_r; // @[Mux.scala 81:58]
  assign io_out_awaddr = state_w == 2'h1 ? 32'h0 : io_in2_awaddr; // @[AxiArbiter.scala 74:23]
  assign io_out_awvalid = 2'h2 == state_w & io_in2_awvalid; // @[Mux.scala 81:58]
  assign io_out_wdata = _io_out_awaddr_T ? 32'h0 : io_in2_wdata; // @[AxiArbiter.scala 79:22]
  assign io_out_wstrb = _io_out_awaddr_T ? 4'h0 : io_in2_wstrb; // @[AxiArbiter.scala 80:22]
  assign io_out_wvalid = 2'h2 == state_w & io_in2_wvalid; // @[Mux.scala 81:58]
  assign io_out_bready = 2'h2 == state_w & io_in2_bready; // @[Mux.scala 81:58]
  always @(posedge clock) begin
    if (reset) begin // @[AxiArbiter.scala 37:24]
      state_r <= 2'h0; // @[AxiArbiter.scala 37:24]
    end else if (2'h2 == state_r) begin // @[Mux.scala 81:58]
      if (io_out_rvalid) begin // @[AxiArbiter.scala 43:28]
        state_r <= 2'h0;
      end else begin
        state_r <= 2'h2;
      end
    end else if (2'h1 == state_r) begin // @[Mux.scala 81:58]
      if (io_out_rvalid) begin // @[AxiArbiter.scala 42:28]
        state_r <= 2'h0;
      end else begin
        state_r <= 2'h1;
      end
    end else if (2'h0 == state_r) begin // @[Mux.scala 81:58]
      state_r <= _state_r_T_1;
    end else begin
      state_r <= 2'h0;
    end
    if (reset) begin // @[AxiArbiter.scala 65:24]
      state_w <= 2'h0; // @[AxiArbiter.scala 65:24]
    end else if (2'h2 == state_w) begin // @[Mux.scala 81:58]
      if (io_in2_bready & io_out_bvalid) begin // @[AxiArbiter.scala 71:28]
        state_w <= 2'h0;
      end else begin
        state_w <= 2'h2;
      end
    end else if (2'h1 == state_w) begin // @[Mux.scala 81:58]
      state_w <= 2'h1;
    end else if (2'h0 == state_w) begin // @[Mux.scala 81:58]
      state_w <= _state_w_T_2;
    end else begin
      state_w <= 2'h0;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state_r = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  state_w = _RAND_1[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AxiXbar(
  input         clock,
  input         reset,
  input  [31:0] io_in_araddr,
  input         io_in_arvalid,
  output        io_in_arready,
  output [31:0] io_in_rdata,
  output        io_in_rvalid,
  input         io_in_rready,
  input  [31:0] io_in_awaddr,
  input         io_in_awvalid,
  output        io_in_awready,
  input  [31:0] io_in_wdata,
  input  [3:0]  io_in_wstrb,
  input         io_in_wvalid,
  output        io_in_wready,
  output        io_in_bvalid,
  input         io_in_bready,
  output [31:0] io_out_0_araddr,
  output        io_out_0_arvalid,
  input         io_out_0_arready,
  input  [31:0] io_out_0_rdata,
  input         io_out_0_rvalid,
  output        io_out_0_rready,
  output [31:0] io_out_0_awaddr,
  output        io_out_0_awvalid,
  input         io_out_0_awready,
  output [31:0] io_out_0_wdata,
  output [3:0]  io_out_0_wstrb,
  output        io_out_0_wvalid,
  input         io_out_0_wready,
  input         io_out_0_bvalid,
  output        io_out_0_bready
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg  state_r; // @[AxiXbar.scala 41:24]
  wire  _state_r_T_1 = io_in_rready & io_out_0_arvalid & state_r; // @[AxiXbar.scala 45:38]
  wire  _state_r_T_6 = io_in_arvalid ? 1'h0 : 1'h1; // @[AxiXbar.scala 46:35]
  wire  _state_r_T_8 = state_r ? _state_r_T_6 : _state_r_T_1; // @[Mux.scala 81:58]
  wire  _io_out_0_arvalid_T = ~state_r; // @[AxiXbar.scala 55:34]
  reg  state_w; // @[AxiXbar.scala 63:24]
  wire  _state_w_T = io_in_bready & io_out_0_bvalid; // @[AxiXbar.scala 67:50]
  wire  _state_w_T_6 = io_in_awvalid ? 1'h0 : 1'h1; // @[AxiXbar.scala 68:33]
  wire  _state_w_T_8 = state_w ? _state_w_T_6 : _state_w_T; // @[Mux.scala 81:58]
  wire  _io_out_0_awvalid_T = ~state_w; // @[AxiXbar.scala 77:34]
  assign io_in_arready = state_r ? 1'h0 : io_out_0_arready; // @[AxiXbar.scala 58:23]
  assign io_in_rdata = state_r ? 32'h0 : io_out_0_rdata; // @[AxiXbar.scala 59:21]
  assign io_in_rvalid = state_r ? 1'h0 : io_out_0_rvalid; // @[AxiXbar.scala 61:22]
  assign io_in_awready = state_w ? 1'h0 : io_out_0_awready; // @[AxiXbar.scala 83:23]
  assign io_in_wready = state_w ? 1'h0 : io_out_0_wready; // @[AxiXbar.scala 84:22]
  assign io_in_bvalid = state_w ? 1'h0 : io_out_0_bvalid; // @[AxiXbar.scala 86:22]
  assign io_out_0_araddr = io_in_araddr; // @[AxiXbar.scala 54:22]
  assign io_out_0_arvalid = ~state_r & io_in_arvalid; // @[AxiXbar.scala 55:59]
  assign io_out_0_rready = _io_out_0_arvalid_T & io_in_rready; // @[AxiXbar.scala 56:58]
  assign io_out_0_awaddr = io_in_awaddr; // @[AxiXbar.scala 76:22]
  assign io_out_0_awvalid = ~state_w & io_in_awvalid; // @[AxiXbar.scala 77:59]
  assign io_out_0_wdata = io_in_wdata; // @[AxiXbar.scala 78:21]
  assign io_out_0_wstrb = io_in_wstrb; // @[AxiXbar.scala 79:21]
  assign io_out_0_wvalid = _io_out_0_awvalid_T & io_in_wvalid; // @[AxiXbar.scala 80:58]
  assign io_out_0_bready = _io_out_0_awvalid_T & io_in_bready; // @[AxiXbar.scala 81:58]
  always @(posedge clock) begin
    state_r <= reset | _state_r_T_8; // @[AxiXbar.scala 41:{24,24} 43:11]
    state_w <= reset | _state_w_T_8; // @[AxiXbar.scala 63:{24,24} 65:11]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state_r = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  state_w = _RAND_1[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module SRAM(
  input         clock,
  input         reset,
  input  [31:0] io_araddr,
  input         io_arvalid,
  output        io_arready,
  output [31:0] io_rdata,
  output        io_rvalid,
  input         io_rready,
  input  [31:0] io_awaddr,
  input         io_awvalid,
  output        io_awready,
  input  [31:0] io_wdata,
  input  [3:0]  io_wstrb,
  input         io_wvalid,
  output        io_wready,
  output        io_bvalid,
  input         io_bready
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
`endif // RANDOMIZE_REG_INIT
  wire  pmem_valid; // @[SRAM.scala 7:20]
  wire [31:0] pmem_raddr; // @[SRAM.scala 7:20]
  wire [31:0] pmem_rdata; // @[SRAM.scala 7:20]
  wire [31:0] pmem_waddr; // @[SRAM.scala 7:20]
  wire [31:0] pmem_wdata; // @[SRAM.scala 7:20]
  wire [7:0] pmem_wmask; // @[SRAM.scala 7:20]
  wire  pmem_wen; // @[SRAM.scala 7:20]
  reg [31:0] read_delay_cnt; // @[SRAM.scala 8:31]
  reg [31:0] write_delay_cnt; // @[SRAM.scala 9:32]
  reg [1:0] state_r; // @[SRAM.scala 17:24]
  wire [1:0] _state_r_T = io_arvalid ? 2'h1 : 2'h0; // @[SRAM.scala 19:24]
  wire  _read_delay_T = state_r == 2'h1; // @[SRAM.scala 25:29]
  wire [31:0] _read_delay_cnt_T_2 = read_delay_cnt + 32'h1; // @[SRAM.scala 26:72]
  reg [31:0] rdata; // @[SRAM.scala 29:22]
  reg [2:0] state_w; // @[SRAM.scala 37:24]
  wire [2:0] _state_w_T_1 = io_wvalid ? 3'h2 : 3'h0; // @[SRAM.scala 41:12]
  wire [2:0] _state_w_T_2 = io_awvalid ? 3'h1 : _state_w_T_1; // @[SRAM.scala 40:10]
  wire [2:0] _state_w_T_3 = io_awvalid & io_wvalid ? 3'h3 : _state_w_T_2; // @[SRAM.scala 39:24]
  wire [2:0] _state_w_T_4 = io_wvalid ? 3'h3 : 3'h1; // @[SRAM.scala 42:29]
  wire [2:0] _state_w_T_5 = io_awvalid ? 3'h3 : 3'h2; // @[SRAM.scala 43:29]
  wire [2:0] _state_w_T_10 = 3'h0 == state_w ? _state_w_T_3 : 3'h0; // @[Mux.scala 81:58]
  wire [2:0] _state_w_T_12 = 3'h1 == state_w ? _state_w_T_4 : _state_w_T_10; // @[Mux.scala 81:58]
  wire [2:0] _state_w_T_14 = 3'h2 == state_w ? _state_w_T_5 : _state_w_T_12; // @[Mux.scala 81:58]
  wire  _write_delay_T = state_w == 3'h3; // @[SRAM.scala 49:30]
  wire [31:0] _write_delay_cnt_T_2 = write_delay_cnt + 32'h1; // @[SRAM.scala 50:75]
  reg [31:0] waddr; // @[SRAM.scala 52:22]
  reg [31:0] wdata; // @[SRAM.scala 53:22]
  reg [3:0] wstrb; // @[SRAM.scala 54:22]
  wire  _io_awready_T = state_w == 3'h0; // @[SRAM.scala 59:25]
  PMem pmem ( // @[SRAM.scala 7:20]
    .valid(pmem_valid),
    .raddr(pmem_raddr),
    .rdata(pmem_rdata),
    .waddr(pmem_waddr),
    .wdata(pmem_wdata),
    .wmask(pmem_wmask),
    .wen(pmem_wen)
  );
  assign io_arready = state_r == 2'h0; // @[SRAM.scala 28:25]
  assign io_rdata = rdata; // @[SRAM.scala 31:12]
  assign io_rvalid = state_r == 2'h3; // @[SRAM.scala 33:24]
  assign io_awready = state_w == 3'h0 | state_w == 3'h2; // @[SRAM.scala 59:42]
  assign io_wready = _io_awready_T | state_w == 3'h1; // @[SRAM.scala 60:41]
  assign io_bvalid = state_w == 3'h5; // @[SRAM.scala 62:24]
  assign pmem_valid = _read_delay_T | _write_delay_T; // @[SRAM.scala 64:45]
  assign pmem_raddr = io_araddr; // @[SRAM.scala 65:17]
  assign pmem_waddr = waddr; // @[SRAM.scala 66:17]
  assign pmem_wdata = wdata; // @[SRAM.scala 67:17]
  assign pmem_wmask = {{4'd0}, wstrb}; // @[SRAM.scala 68:17]
  assign pmem_wen = state_w == 3'h3; // @[SRAM.scala 69:26]
  always @(posedge clock) begin
    if (reset) begin // @[SRAM.scala 8:31]
      read_delay_cnt <= 32'h0; // @[SRAM.scala 8:31]
    end else if (state_r == 2'h2) begin // @[SRAM.scala 26:24]
      read_delay_cnt <= _read_delay_cnt_T_2;
    end else begin
      read_delay_cnt <= 32'h0;
    end
    if (reset) begin // @[SRAM.scala 9:32]
      write_delay_cnt <= 32'h0; // @[SRAM.scala 9:32]
    end else if (state_w == 3'h4) begin // @[SRAM.scala 50:25]
      write_delay_cnt <= _write_delay_cnt_T_2;
    end else begin
      write_delay_cnt <= 32'h0;
    end
    if (reset) begin // @[SRAM.scala 17:24]
      state_r <= 2'h0; // @[SRAM.scala 17:24]
    end else if (2'h3 == state_r) begin // @[Mux.scala 81:58]
      if (io_rready) begin // @[SRAM.scala 22:30]
        state_r <= 2'h0;
      end else begin
        state_r <= 2'h3;
      end
    end else if (2'h2 == state_r) begin // @[Mux.scala 81:58]
      if (read_delay_cnt >= 32'h1) begin // @[SRAM.scala 21:30]
        state_r <= 2'h3;
      end else begin
        state_r <= 2'h2;
      end
    end else if (2'h1 == state_r) begin // @[Mux.scala 81:58]
      state_r <= 2'h2;
    end else begin
      state_r <= _state_r_T;
    end
    if (reset) begin // @[SRAM.scala 29:22]
      rdata <= 32'h0; // @[SRAM.scala 29:22]
    end else if (_read_delay_T) begin // @[SRAM.scala 30:15]
      rdata <= pmem_rdata;
    end
    if (reset) begin // @[SRAM.scala 37:24]
      state_w <= 3'h0; // @[SRAM.scala 37:24]
    end else if (3'h5 == state_w) begin // @[Mux.scala 81:58]
      if (io_bready) begin // @[SRAM.scala 46:30]
        state_w <= 3'h0;
      end else begin
        state_w <= 3'h5;
      end
    end else if (3'h4 == state_w) begin // @[Mux.scala 81:58]
      if (write_delay_cnt >= 32'h1) begin // @[SRAM.scala 45:31]
        state_w <= 3'h5;
      end else begin
        state_w <= 3'h4;
      end
    end else if (3'h3 == state_w) begin // @[Mux.scala 81:58]
      state_w <= 3'h4;
    end else begin
      state_w <= _state_w_T_14;
    end
    if (reset) begin // @[SRAM.scala 52:22]
      waddr <= 32'h0; // @[SRAM.scala 52:22]
    end else if (io_awvalid) begin // @[SRAM.scala 55:15]
      waddr <= io_awaddr;
    end
    if (reset) begin // @[SRAM.scala 53:22]
      wdata <= 32'h0; // @[SRAM.scala 53:22]
    end else if (io_wvalid) begin // @[SRAM.scala 56:15]
      wdata <= io_wdata;
    end
    if (reset) begin // @[SRAM.scala 54:22]
      wstrb <= 4'h0; // @[SRAM.scala 54:22]
    end else if (io_wvalid) begin // @[SRAM.scala 57:15]
      wstrb <= io_wstrb;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  read_delay_cnt = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  write_delay_cnt = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  state_r = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  rdata = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  state_w = _RAND_4[2:0];
  _RAND_5 = {1{`RANDOM}};
  waddr = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  wdata = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  wstrb = _RAND_7[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module IFU(
  input         clock,
  input         reset,
  output        io_in_ready,
  input         io_in_valid,
  input  [31:0] io_in_bits_pc,
  input         io_out_ready,
  output        io_out_valid,
  output [31:0] io_out_bits_inst,
  output [31:0] io_out_bits_pc,
  output        io_test_imem_en,
  output [31:0] io_test_pc,
  output [31:0] io_imem_araddr,
  output        io_imem_arvalid,
  input         io_imem_arready,
  input  [31:0] io_imem_rdata,
  input         io_imem_rvalid,
  output        io_imem_rready
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] state; // @[IFU.scala 22:22]
  wire [1:0] _state_T = io_in_valid ? 2'h1 : 2'h0; // @[IFU.scala 24:22]
  wire [1:0] _state_T_1 = io_imem_arready ? 2'h2 : 2'h1; // @[IFU.scala 25:22]
  reg [31:0] pc; // @[IFU.scala 29:19]
  reg [31:0] inst; // @[IFU.scala 30:21]
  wire  _io_imem_arvalid_T = state == 2'h1; // @[IFU.scala 32:28]
  assign io_in_ready = state == 2'h0; // @[IFU.scala 45:24]
  assign io_out_valid = state == 2'h3; // @[IFU.scala 46:25]
  assign io_out_bits_inst = inst; // @[IFU.scala 47:20]
  assign io_out_bits_pc = pc; // @[IFU.scala 48:18]
  assign io_test_imem_en = state == 2'h2 | _io_imem_arvalid_T; // @[IFU.scala 50:48]
  assign io_test_pc = pc; // @[IFU.scala 51:14]
  assign io_imem_araddr = pc; // @[IFU.scala 31:18]
  assign io_imem_arvalid = state == 2'h1; // @[IFU.scala 32:28]
  assign io_imem_rready = 1'h1; // @[IFU.scala 33:18]
  always @(posedge clock) begin
    if (reset) begin // @[IFU.scala 22:22]
      state <= 2'h0; // @[IFU.scala 22:22]
    end else if (2'h3 == state) begin // @[Mux.scala 81:58]
      if (io_out_ready) begin // @[IFU.scala 27:28]
        state <= 2'h0;
      end else begin
        state <= 2'h3;
      end
    end else if (2'h2 == state) begin // @[Mux.scala 81:58]
      if (io_imem_rvalid) begin // @[IFU.scala 26:27]
        state <= 2'h3;
      end else begin
        state <= 2'h2;
      end
    end else if (2'h1 == state) begin // @[Mux.scala 81:58]
      state <= _state_T_1;
    end else begin
      state <= _state_T;
    end
    if (reset) begin // @[IFU.scala 29:19]
      pc <= 32'h80000000; // @[IFU.scala 29:19]
    end else if (io_in_valid & io_in_ready) begin // @[IFU.scala 35:12]
      pc <= io_in_bits_pc;
    end
    if (reset) begin // @[IFU.scala 30:21]
      inst <= 32'h0; // @[IFU.scala 30:21]
    end else if (io_imem_rvalid & io_imem_rready) begin // @[IFU.scala 36:14]
      inst <= io_imem_rdata;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  pc = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  inst = _RAND_2[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ImmediateGenerator(
  input  [31:0] io_inst,
  output [31:0] io_imm,
  input  [2:0]  io_imm_type
);
  wire [11:0] _io_imm_T_1 = io_inst[31:20]; // @[ImmediateGenerator.scala 11:34]
  wire [31:0] _io_imm_T_3 = {{20{_io_imm_T_1[11]}},_io_imm_T_1}; // @[ImmediateGenerator.scala 11:49]
  wire [19:0] _io_imm_T_6 = io_inst[31:12]; // @[ImmediateGenerator.scala 12:52]
  wire [31:0] _io_imm_T_7 = {_io_imm_T_6,12'h0}; // @[Cat.scala 33:92]
  wire [20:0] _io_imm_T_13 = {io_inst[31],io_inst[19:12],io_inst[20],io_inst[30:21],1'h0}; // @[ImmediateGenerator.scala 14:32]
  wire [31:0] _io_imm_T_15 = {{11{_io_imm_T_13[20]}},_io_imm_T_13}; // @[ImmediateGenerator.scala 14:47]
  wire [11:0] _io_imm_T_19 = {io_inst[31:25],io_inst[11:7]}; // @[ImmediateGenerator.scala 15:53]
  wire [31:0] _io_imm_T_21 = {{20{_io_imm_T_19[11]}},_io_imm_T_19}; // @[ImmediateGenerator.scala 15:68]
  wire [12:0] _io_imm_T_27 = {io_inst[31],io_inst[7],io_inst[30:25],io_inst[11:8],1'h0}; // @[ImmediateGenerator.scala 17:32]
  wire [31:0] _io_imm_T_29 = {{19{_io_imm_T_27[12]}},_io_imm_T_27}; // @[ImmediateGenerator.scala 17:47]
  wire [31:0] _io_imm_T_31 = 3'h1 == io_imm_type ? _io_imm_T_3 : 32'h0; // @[Mux.scala 81:58]
  wire [31:0] _io_imm_T_33 = 3'h4 == io_imm_type ? _io_imm_T_7 : _io_imm_T_31; // @[Mux.scala 81:58]
  wire [31:0] _io_imm_T_35 = 3'h5 == io_imm_type ? _io_imm_T_15 : _io_imm_T_33; // @[Mux.scala 81:58]
  wire [31:0] _io_imm_T_37 = 3'h2 == io_imm_type ? _io_imm_T_21 : _io_imm_T_35; // @[Mux.scala 81:58]
  assign io_imm = 3'h3 == io_imm_type ? _io_imm_T_29 : _io_imm_T_37; // @[Mux.scala 81:58]
endmodule
module IDU(
  input         clock,
  input         reset,
  output        io_in_ready,
  input         io_in_valid,
  input  [31:0] io_in_bits_inst,
  input  [31:0] io_in_bits_pc,
  input         io_out_ready,
  output        io_out_valid,
  output [2:0]  io_out_bits_control_signal_PC_sel,
  output [1:0]  io_out_bits_control_signal_A_sel,
  output [1:0]  io_out_bits_control_signal_B_sel,
  output [3:0]  io_out_bits_control_signal_WB_sel,
  output [5:0]  io_out_bits_control_signal_ALU_sel,
  output [1:0]  io_out_bits_control_signal_csr_sel,
  output [7:0]  io_out_bits_control_signal_ebreak_en,
  output [7:0]  io_out_bits_control_signal_ebreak_code,
  output        io_out_bits_control_signal_dmem_read_en,
  output        io_out_bits_control_signal_dmem_write_en,
  output [2:0]  io_out_bits_control_signal_dmem_write_type,
  output [31:0] io_out_bits_imm,
  output [31:0] io_out_bits_pc,
  output [31:0] io_out_bits_inst
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  wire [31:0] imm_gen_io_inst; // @[IDU.scala 39:23]
  wire [31:0] imm_gen_io_imm; // @[IDU.scala 39:23]
  wire [2:0] imm_gen_io_imm_type; // @[IDU.scala 39:23]
  reg [1:0] state; // @[IDU.scala 33:22]
  wire [1:0] _state_T = io_in_valid ? 2'h1 : 2'h0; // @[IDU.scala 35:22]
  reg [31:0] inst; // @[IDU.scala 40:21]
  wire  _inst_T = io_in_ready & io_in_valid; // @[IDU.scala 41:27]
  reg [31:0] pc; // @[IDU.scala 42:19]
  wire [31:0] _signals_T = inst & 32'hfe00707f; // @[Lookup.scala 31:38]
  wire  _signals_T_1 = 32'h33 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_3 = 32'h40000033 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_5 = 32'h4033 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_7 = 32'h6033 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_9 = 32'h7033 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_11 = 32'h1033 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_13 = 32'h5033 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_15 = 32'h40005033 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_17 = 32'h2033 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_19 = 32'h3033 == _signals_T; // @[Lookup.scala 31:38]
  wire [31:0] _signals_T_20 = inst & 32'h707f; // @[Lookup.scala 31:38]
  wire  _signals_T_21 = 32'h13 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_23 = 32'h7013 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_25 = 32'h6013 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_27 = 32'h4013 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_29 = 32'h1013 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_31 = 32'h5013 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_33 = 32'h40005013 == _signals_T; // @[Lookup.scala 31:38]
  wire  _signals_T_35 = 32'h2013 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_37 = 32'h3013 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_39 = 32'h2003 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_41 = 32'h3 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_43 = 32'h4003 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_45 = 32'h1003 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_47 = 32'h5003 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_49 = 32'h2023 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_51 = 32'h1023 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_53 = 32'h23 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_55 = 32'h63 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_57 = 32'h1063 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_59 = 32'h4063 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_61 = 32'h5063 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_63 = 32'h6063 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_65 = 32'h7063 == _signals_T_20; // @[Lookup.scala 31:38]
  wire [31:0] _signals_T_66 = inst & 32'h7f; // @[Lookup.scala 31:38]
  wire  _signals_T_67 = 32'h6f == _signals_T_66; // @[Lookup.scala 31:38]
  wire  _signals_T_69 = 32'h67 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_71 = 32'h37 == _signals_T_66; // @[Lookup.scala 31:38]
  wire  _signals_T_73 = 32'h17 == _signals_T_66; // @[Lookup.scala 31:38]
  wire  _signals_T_75 = 32'h100073 == inst; // @[Lookup.scala 31:38]
  wire  _signals_T_77 = 32'h73 == inst; // @[Lookup.scala 31:38]
  wire  _signals_T_79 = 32'h30200073 == inst; // @[Lookup.scala 31:38]
  wire  _signals_T_81 = 32'h1073 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_83 = 32'h2073 == _signals_T_20; // @[Lookup.scala 31:38]
  wire  _signals_T_85 = _signals_T_81 | _signals_T_83; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_86 = _signals_T_79 ? 3'h5 : {{2'd0}, _signals_T_85}; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_87 = _signals_T_77 ? 3'h4 : _signals_T_86; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_88 = _signals_T_75 ? 3'h0 : _signals_T_87; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_89 = _signals_T_73 ? 3'h1 : _signals_T_88; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_90 = _signals_T_71 ? 3'h1 : _signals_T_89; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_91 = _signals_T_69 ? 3'h2 : _signals_T_90; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_92 = _signals_T_67 ? 3'h2 : _signals_T_91; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_93 = _signals_T_65 ? 3'h3 : _signals_T_92; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_94 = _signals_T_63 ? 3'h3 : _signals_T_93; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_95 = _signals_T_61 ? 3'h3 : _signals_T_94; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_96 = _signals_T_59 ? 3'h3 : _signals_T_95; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_97 = _signals_T_57 ? 3'h3 : _signals_T_96; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_98 = _signals_T_55 ? 3'h3 : _signals_T_97; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_99 = _signals_T_53 ? 3'h1 : _signals_T_98; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_100 = _signals_T_51 ? 3'h1 : _signals_T_99; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_101 = _signals_T_49 ? 3'h1 : _signals_T_100; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_102 = _signals_T_47 ? 3'h1 : _signals_T_101; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_103 = _signals_T_45 ? 3'h1 : _signals_T_102; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_104 = _signals_T_43 ? 3'h1 : _signals_T_103; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_105 = _signals_T_41 ? 3'h1 : _signals_T_104; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_106 = _signals_T_39 ? 3'h1 : _signals_T_105; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_107 = _signals_T_37 ? 3'h1 : _signals_T_106; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_108 = _signals_T_35 ? 3'h1 : _signals_T_107; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_109 = _signals_T_33 ? 3'h1 : _signals_T_108; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_110 = _signals_T_31 ? 3'h1 : _signals_T_109; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_111 = _signals_T_29 ? 3'h1 : _signals_T_110; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_112 = _signals_T_27 ? 3'h1 : _signals_T_111; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_113 = _signals_T_25 ? 3'h1 : _signals_T_112; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_114 = _signals_T_23 ? 3'h1 : _signals_T_113; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_115 = _signals_T_21 ? 3'h1 : _signals_T_114; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_116 = _signals_T_19 ? 3'h1 : _signals_T_115; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_117 = _signals_T_17 ? 3'h1 : _signals_T_116; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_118 = _signals_T_15 ? 3'h1 : _signals_T_117; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_119 = _signals_T_13 ? 3'h1 : _signals_T_118; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_120 = _signals_T_11 ? 3'h1 : _signals_T_119; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_121 = _signals_T_9 ? 3'h1 : _signals_T_120; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_122 = _signals_T_7 ? 3'h1 : _signals_T_121; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_123 = _signals_T_5 ? 3'h1 : _signals_T_122; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_124 = _signals_T_3 ? 3'h1 : _signals_T_123; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_130 = _signals_T_73 ? 2'h2 : 2'h0; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_131 = _signals_T_71 ? 2'h0 : _signals_T_130; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_132 = _signals_T_69 ? 2'h1 : _signals_T_131; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_133 = _signals_T_67 ? 2'h2 : _signals_T_132; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_134 = _signals_T_65 ? 2'h1 : _signals_T_133; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_135 = _signals_T_63 ? 2'h1 : _signals_T_134; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_136 = _signals_T_61 ? 2'h1 : _signals_T_135; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_137 = _signals_T_59 ? 2'h1 : _signals_T_136; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_138 = _signals_T_57 ? 2'h1 : _signals_T_137; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_139 = _signals_T_55 ? 2'h1 : _signals_T_138; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_140 = _signals_T_53 ? 2'h1 : _signals_T_139; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_141 = _signals_T_51 ? 2'h1 : _signals_T_140; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_142 = _signals_T_49 ? 2'h1 : _signals_T_141; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_143 = _signals_T_47 ? 2'h1 : _signals_T_142; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_144 = _signals_T_45 ? 2'h1 : _signals_T_143; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_145 = _signals_T_43 ? 2'h1 : _signals_T_144; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_146 = _signals_T_41 ? 2'h1 : _signals_T_145; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_147 = _signals_T_39 ? 2'h1 : _signals_T_146; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_148 = _signals_T_37 ? 2'h1 : _signals_T_147; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_149 = _signals_T_35 ? 2'h1 : _signals_T_148; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_150 = _signals_T_33 ? 2'h1 : _signals_T_149; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_151 = _signals_T_31 ? 2'h1 : _signals_T_150; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_152 = _signals_T_29 ? 2'h1 : _signals_T_151; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_153 = _signals_T_27 ? 2'h1 : _signals_T_152; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_154 = _signals_T_25 ? 2'h1 : _signals_T_153; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_155 = _signals_T_23 ? 2'h1 : _signals_T_154; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_156 = _signals_T_21 ? 2'h1 : _signals_T_155; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_157 = _signals_T_19 ? 2'h1 : _signals_T_156; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_158 = _signals_T_17 ? 2'h1 : _signals_T_157; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_159 = _signals_T_15 ? 2'h1 : _signals_T_158; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_160 = _signals_T_13 ? 2'h1 : _signals_T_159; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_161 = _signals_T_11 ? 2'h1 : _signals_T_160; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_162 = _signals_T_9 ? 2'h1 : _signals_T_161; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_163 = _signals_T_7 ? 2'h1 : _signals_T_162; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_164 = _signals_T_5 ? 2'h1 : _signals_T_163; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_165 = _signals_T_3 ? 2'h1 : _signals_T_164; // @[Lookup.scala 34:39]
  wire  _signals_T_175 = _signals_T_65 ? 1'h0 : 1'h1; // @[Lookup.scala 34:39]
  wire  _signals_T_176 = _signals_T_63 ? 1'h0 : _signals_T_175; // @[Lookup.scala 34:39]
  wire  _signals_T_177 = _signals_T_61 ? 1'h0 : _signals_T_176; // @[Lookup.scala 34:39]
  wire  _signals_T_178 = _signals_T_59 ? 1'h0 : _signals_T_177; // @[Lookup.scala 34:39]
  wire  _signals_T_179 = _signals_T_57 ? 1'h0 : _signals_T_178; // @[Lookup.scala 34:39]
  wire  _signals_T_180 = _signals_T_55 ? 1'h0 : _signals_T_179; // @[Lookup.scala 34:39]
  wire  _signals_T_198 = _signals_T_19 ? 1'h0 : _signals_T_21 | (_signals_T_23 | (_signals_T_25 | (_signals_T_27 | (
    _signals_T_29 | (_signals_T_31 | (_signals_T_33 | (_signals_T_35 | (_signals_T_37 | (_signals_T_39 | (_signals_T_41
     | (_signals_T_43 | (_signals_T_45 | (_signals_T_47 | (_signals_T_49 | (_signals_T_51 | (_signals_T_53 |
    _signals_T_180)))))))))))))))); // @[Lookup.scala 34:39]
  wire  _signals_T_199 = _signals_T_17 ? 1'h0 : _signals_T_198; // @[Lookup.scala 34:39]
  wire  _signals_T_200 = _signals_T_15 ? 1'h0 : _signals_T_199; // @[Lookup.scala 34:39]
  wire  _signals_T_201 = _signals_T_13 ? 1'h0 : _signals_T_200; // @[Lookup.scala 34:39]
  wire  _signals_T_202 = _signals_T_11 ? 1'h0 : _signals_T_201; // @[Lookup.scala 34:39]
  wire  _signals_T_203 = _signals_T_9 ? 1'h0 : _signals_T_202; // @[Lookup.scala 34:39]
  wire  _signals_T_204 = _signals_T_7 ? 1'h0 : _signals_T_203; // @[Lookup.scala 34:39]
  wire  _signals_T_205 = _signals_T_5 ? 1'h0 : _signals_T_204; // @[Lookup.scala 34:39]
  wire  _signals_T_206 = _signals_T_3 ? 1'h0 : _signals_T_205; // @[Lookup.scala 34:39]
  wire  signals_2 = _signals_T_1 ? 1'h0 : _signals_T_206; // @[Lookup.scala 34:39]
  wire  _signals_T_211 = _signals_T_75 | (_signals_T_77 | (_signals_T_79 | (_signals_T_81 | _signals_T_83))); // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_212 = _signals_T_73 ? 3'h4 : {{2'd0}, _signals_T_211}; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_213 = _signals_T_71 ? 3'h4 : _signals_T_212; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_214 = _signals_T_69 ? 3'h1 : _signals_T_213; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_215 = _signals_T_67 ? 3'h5 : _signals_T_214; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_216 = _signals_T_65 ? 3'h3 : _signals_T_215; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_217 = _signals_T_63 ? 3'h3 : _signals_T_216; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_218 = _signals_T_61 ? 3'h3 : _signals_T_217; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_219 = _signals_T_59 ? 3'h3 : _signals_T_218; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_220 = _signals_T_57 ? 3'h3 : _signals_T_219; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_221 = _signals_T_55 ? 3'h3 : _signals_T_220; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_222 = _signals_T_53 ? 3'h2 : _signals_T_221; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_223 = _signals_T_51 ? 3'h2 : _signals_T_222; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_224 = _signals_T_49 ? 3'h2 : _signals_T_223; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_225 = _signals_T_47 ? 3'h1 : _signals_T_224; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_226 = _signals_T_45 ? 3'h1 : _signals_T_225; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_227 = _signals_T_43 ? 3'h1 : _signals_T_226; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_228 = _signals_T_41 ? 3'h1 : _signals_T_227; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_229 = _signals_T_39 ? 3'h1 : _signals_T_228; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_230 = _signals_T_37 ? 3'h1 : _signals_T_229; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_231 = _signals_T_35 ? 3'h1 : _signals_T_230; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_232 = _signals_T_33 ? 3'h1 : _signals_T_231; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_233 = _signals_T_31 ? 3'h1 : _signals_T_232; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_234 = _signals_T_29 ? 3'h1 : _signals_T_233; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_235 = _signals_T_27 ? 3'h1 : _signals_T_234; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_236 = _signals_T_25 ? 3'h1 : _signals_T_235; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_237 = _signals_T_23 ? 3'h1 : _signals_T_236; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_238 = _signals_T_21 ? 3'h1 : _signals_T_237; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_239 = _signals_T_19 ? 3'h6 : _signals_T_238; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_240 = _signals_T_17 ? 3'h6 : _signals_T_239; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_241 = _signals_T_15 ? 3'h6 : _signals_T_240; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_242 = _signals_T_13 ? 3'h6 : _signals_T_241; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_243 = _signals_T_11 ? 3'h6 : _signals_T_242; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_244 = _signals_T_9 ? 3'h6 : _signals_T_243; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_245 = _signals_T_7 ? 3'h6 : _signals_T_244; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_246 = _signals_T_5 ? 3'h6 : _signals_T_245; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_247 = _signals_T_3 ? 3'h6 : _signals_T_246; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_248 = _signals_T_83 ? 4'h8 : 4'h0; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_249 = _signals_T_81 ? 4'h8 : _signals_T_248; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_250 = _signals_T_79 ? 4'h0 : _signals_T_249; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_251 = _signals_T_77 ? 4'h0 : _signals_T_250; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_252 = _signals_T_75 ? 4'h0 : _signals_T_251; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_253 = _signals_T_73 ? 4'h1 : _signals_T_252; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_254 = _signals_T_71 ? 4'h1 : _signals_T_253; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_255 = _signals_T_69 ? 4'h2 : _signals_T_254; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_256 = _signals_T_67 ? 4'h2 : _signals_T_255; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_257 = _signals_T_65 ? 4'h0 : _signals_T_256; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_258 = _signals_T_63 ? 4'h0 : _signals_T_257; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_259 = _signals_T_61 ? 4'h0 : _signals_T_258; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_260 = _signals_T_59 ? 4'h0 : _signals_T_259; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_261 = _signals_T_57 ? 4'h0 : _signals_T_260; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_262 = _signals_T_55 ? 4'h0 : _signals_T_261; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_263 = _signals_T_53 ? 4'h0 : _signals_T_262; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_264 = _signals_T_51 ? 4'h0 : _signals_T_263; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_265 = _signals_T_49 ? 4'h0 : _signals_T_264; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_266 = _signals_T_47 ? 4'h5 : _signals_T_265; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_267 = _signals_T_45 ? 4'h7 : _signals_T_266; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_268 = _signals_T_43 ? 4'h4 : _signals_T_267; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_269 = _signals_T_41 ? 4'h6 : _signals_T_268; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_270 = _signals_T_39 ? 4'h3 : _signals_T_269; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_271 = _signals_T_37 ? 4'h1 : _signals_T_270; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_272 = _signals_T_35 ? 4'h1 : _signals_T_271; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_273 = _signals_T_33 ? 4'h1 : _signals_T_272; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_274 = _signals_T_31 ? 4'h1 : _signals_T_273; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_275 = _signals_T_29 ? 4'h1 : _signals_T_274; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_276 = _signals_T_27 ? 4'h1 : _signals_T_275; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_277 = _signals_T_25 ? 4'h1 : _signals_T_276; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_278 = _signals_T_23 ? 4'h1 : _signals_T_277; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_279 = _signals_T_21 ? 4'h1 : _signals_T_278; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_280 = _signals_T_19 ? 4'h1 : _signals_T_279; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_281 = _signals_T_17 ? 4'h1 : _signals_T_280; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_282 = _signals_T_15 ? 4'h1 : _signals_T_281; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_283 = _signals_T_13 ? 4'h1 : _signals_T_282; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_284 = _signals_T_11 ? 4'h1 : _signals_T_283; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_285 = _signals_T_9 ? 4'h1 : _signals_T_284; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_286 = _signals_T_7 ? 4'h1 : _signals_T_285; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_287 = _signals_T_5 ? 4'h1 : _signals_T_286; // @[Lookup.scala 34:39]
  wire [3:0] _signals_T_288 = _signals_T_3 ? 4'h1 : _signals_T_287; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_289 = _signals_T_83 ? 8'h0 : 8'hff; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_290 = _signals_T_81 ? 8'h0 : _signals_T_289; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_291 = _signals_T_79 ? 8'h0 : _signals_T_290; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_292 = _signals_T_77 ? 8'h0 : _signals_T_291; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_293 = _signals_T_75 ? 8'h1 : _signals_T_292; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_294 = _signals_T_73 ? 8'h0 : _signals_T_293; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_295 = _signals_T_71 ? 8'h0 : _signals_T_294; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_296 = _signals_T_69 ? 8'h0 : _signals_T_295; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_297 = _signals_T_67 ? 8'h0 : _signals_T_296; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_298 = _signals_T_65 ? 8'h0 : _signals_T_297; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_299 = _signals_T_63 ? 8'h0 : _signals_T_298; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_300 = _signals_T_61 ? 8'h0 : _signals_T_299; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_301 = _signals_T_59 ? 8'h0 : _signals_T_300; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_302 = _signals_T_57 ? 8'h0 : _signals_T_301; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_303 = _signals_T_55 ? 8'h0 : _signals_T_302; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_304 = _signals_T_53 ? 8'h0 : _signals_T_303; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_305 = _signals_T_51 ? 8'h0 : _signals_T_304; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_306 = _signals_T_49 ? 8'h0 : _signals_T_305; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_307 = _signals_T_47 ? 8'h0 : _signals_T_306; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_308 = _signals_T_45 ? 8'h0 : _signals_T_307; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_309 = _signals_T_43 ? 8'h0 : _signals_T_308; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_310 = _signals_T_41 ? 8'h0 : _signals_T_309; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_311 = _signals_T_39 ? 8'h0 : _signals_T_310; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_312 = _signals_T_37 ? 8'h0 : _signals_T_311; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_313 = _signals_T_35 ? 8'h0 : _signals_T_312; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_314 = _signals_T_33 ? 8'h0 : _signals_T_313; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_315 = _signals_T_31 ? 8'h0 : _signals_T_314; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_316 = _signals_T_29 ? 8'h0 : _signals_T_315; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_317 = _signals_T_27 ? 8'h0 : _signals_T_316; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_318 = _signals_T_25 ? 8'h0 : _signals_T_317; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_319 = _signals_T_23 ? 8'h0 : _signals_T_318; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_320 = _signals_T_21 ? 8'h0 : _signals_T_319; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_321 = _signals_T_19 ? 8'h0 : _signals_T_320; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_322 = _signals_T_17 ? 8'h0 : _signals_T_321; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_323 = _signals_T_15 ? 8'h0 : _signals_T_322; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_324 = _signals_T_13 ? 8'h0 : _signals_T_323; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_325 = _signals_T_11 ? 8'h0 : _signals_T_324; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_326 = _signals_T_9 ? 8'h0 : _signals_T_325; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_327 = _signals_T_7 ? 8'h0 : _signals_T_326; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_328 = _signals_T_5 ? 8'h0 : _signals_T_327; // @[Lookup.scala 34:39]
  wire [7:0] _signals_T_329 = _signals_T_3 ? 8'h0 : _signals_T_328; // @[Lookup.scala 34:39]
  wire [7:0] signals_5 = _signals_T_1 ? 8'h0 : _signals_T_329; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_348 = _signals_T_47 ? 3'h5 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_349 = _signals_T_45 ? 3'h2 : _signals_T_348; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_350 = _signals_T_43 ? 3'h4 : _signals_T_349; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_351 = _signals_T_41 ? 3'h1 : _signals_T_350; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_352 = _signals_T_39 ? 3'h3 : _signals_T_351; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_353 = _signals_T_37 ? 3'h0 : _signals_T_352; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_354 = _signals_T_35 ? 3'h0 : _signals_T_353; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_355 = _signals_T_33 ? 3'h0 : _signals_T_354; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_356 = _signals_T_31 ? 3'h0 : _signals_T_355; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_357 = _signals_T_29 ? 3'h0 : _signals_T_356; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_358 = _signals_T_27 ? 3'h0 : _signals_T_357; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_359 = _signals_T_25 ? 3'h0 : _signals_T_358; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_360 = _signals_T_23 ? 3'h0 : _signals_T_359; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_361 = _signals_T_21 ? 3'h0 : _signals_T_360; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_362 = _signals_T_19 ? 3'h0 : _signals_T_361; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_363 = _signals_T_17 ? 3'h0 : _signals_T_362; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_364 = _signals_T_15 ? 3'h0 : _signals_T_363; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_365 = _signals_T_13 ? 3'h0 : _signals_T_364; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_366 = _signals_T_11 ? 3'h0 : _signals_T_365; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_367 = _signals_T_9 ? 3'h0 : _signals_T_366; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_368 = _signals_T_7 ? 3'h0 : _signals_T_367; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_369 = _signals_T_5 ? 3'h0 : _signals_T_368; // @[Lookup.scala 34:39]
  wire [2:0] _signals_T_370 = _signals_T_3 ? 3'h0 : _signals_T_369; // @[Lookup.scala 34:39]
  wire [2:0] signals_6 = _signals_T_1 ? 3'h0 : _signals_T_370; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_387 = _signals_T_51 ? 2'h2 : {{1'd0}, _signals_T_53}; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_388 = _signals_T_49 ? 2'h3 : _signals_T_387; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_389 = _signals_T_47 ? 2'h0 : _signals_T_388; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_390 = _signals_T_45 ? 2'h0 : _signals_T_389; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_391 = _signals_T_43 ? 2'h0 : _signals_T_390; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_392 = _signals_T_41 ? 2'h0 : _signals_T_391; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_393 = _signals_T_39 ? 2'h0 : _signals_T_392; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_394 = _signals_T_37 ? 2'h0 : _signals_T_393; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_395 = _signals_T_35 ? 2'h0 : _signals_T_394; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_396 = _signals_T_33 ? 2'h0 : _signals_T_395; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_397 = _signals_T_31 ? 2'h0 : _signals_T_396; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_398 = _signals_T_29 ? 2'h0 : _signals_T_397; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_399 = _signals_T_27 ? 2'h0 : _signals_T_398; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_400 = _signals_T_25 ? 2'h0 : _signals_T_399; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_401 = _signals_T_23 ? 2'h0 : _signals_T_400; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_402 = _signals_T_21 ? 2'h0 : _signals_T_401; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_403 = _signals_T_19 ? 2'h0 : _signals_T_402; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_404 = _signals_T_17 ? 2'h0 : _signals_T_403; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_405 = _signals_T_15 ? 2'h0 : _signals_T_404; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_406 = _signals_T_13 ? 2'h0 : _signals_T_405; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_407 = _signals_T_11 ? 2'h0 : _signals_T_406; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_408 = _signals_T_9 ? 2'h0 : _signals_T_407; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_409 = _signals_T_7 ? 2'h0 : _signals_T_408; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_410 = _signals_T_5 ? 2'h0 : _signals_T_409; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_411 = _signals_T_3 ? 2'h0 : _signals_T_410; // @[Lookup.scala 34:39]
  wire [1:0] signals_7 = _signals_T_1 ? 2'h0 : _signals_T_411; // @[Lookup.scala 34:39]
  wire  _signals_T_420 = _signals_T_67 | (_signals_T_69 | (_signals_T_71 | _signals_T_73)); // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_421 = _signals_T_65 ? 2'h3 : {{1'd0}, _signals_T_420}; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_422 = _signals_T_63 ? 5'h10 : {{3'd0}, _signals_T_421}; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_423 = _signals_T_61 ? 5'h4 : _signals_T_422; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_424 = _signals_T_59 ? 5'hf : _signals_T_423; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_425 = _signals_T_57 ? 5'he : _signals_T_424; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_426 = _signals_T_55 ? 5'hd : _signals_T_425; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_427 = _signals_T_53 ? 5'h1 : _signals_T_426; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_428 = _signals_T_51 ? 5'h1 : _signals_T_427; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_429 = _signals_T_49 ? 5'h1 : _signals_T_428; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_430 = _signals_T_47 ? 5'h1 : _signals_T_429; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_431 = _signals_T_45 ? 5'h1 : _signals_T_430; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_432 = _signals_T_43 ? 5'h1 : _signals_T_431; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_433 = _signals_T_41 ? 5'h1 : _signals_T_432; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_434 = _signals_T_39 ? 5'h1 : _signals_T_433; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_435 = _signals_T_37 ? 5'h9 : _signals_T_434; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_436 = _signals_T_35 ? 5'h8 : _signals_T_435; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_437 = _signals_T_33 ? 5'h7 : _signals_T_436; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_438 = _signals_T_31 ? 5'h6 : _signals_T_437; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_439 = _signals_T_29 ? 5'h5 : _signals_T_438; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_440 = _signals_T_27 ? 5'hc : _signals_T_439; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_441 = _signals_T_25 ? 5'hb : _signals_T_440; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_442 = _signals_T_23 ? 5'ha : _signals_T_441; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_443 = _signals_T_21 ? 5'h1 : _signals_T_442; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_444 = _signals_T_19 ? 5'h9 : _signals_T_443; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_445 = _signals_T_17 ? 5'h8 : _signals_T_444; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_446 = _signals_T_15 ? 5'h7 : _signals_T_445; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_447 = _signals_T_13 ? 5'h6 : _signals_T_446; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_448 = _signals_T_11 ? 5'h5 : _signals_T_447; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_449 = _signals_T_9 ? 5'ha : _signals_T_448; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_450 = _signals_T_7 ? 5'hb : _signals_T_449; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_451 = _signals_T_5 ? 5'hc : _signals_T_450; // @[Lookup.scala 34:39]
  wire [4:0] _signals_T_452 = _signals_T_3 ? 5'h2 : _signals_T_451; // @[Lookup.scala 34:39]
  wire [4:0] signals_8 = _signals_T_1 ? 5'h1 : _signals_T_452; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_453 = _signals_T_83 ? 2'h2 : 2'h0; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_454 = _signals_T_81 ? 2'h1 : _signals_T_453; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_455 = _signals_T_79 ? 2'h0 : _signals_T_454; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_456 = _signals_T_77 ? 2'h0 : _signals_T_455; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_457 = _signals_T_75 ? 2'h0 : _signals_T_456; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_458 = _signals_T_73 ? 2'h0 : _signals_T_457; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_459 = _signals_T_71 ? 2'h0 : _signals_T_458; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_460 = _signals_T_69 ? 2'h0 : _signals_T_459; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_461 = _signals_T_67 ? 2'h0 : _signals_T_460; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_462 = _signals_T_65 ? 2'h0 : _signals_T_461; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_463 = _signals_T_63 ? 2'h0 : _signals_T_462; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_464 = _signals_T_61 ? 2'h0 : _signals_T_463; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_465 = _signals_T_59 ? 2'h0 : _signals_T_464; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_466 = _signals_T_57 ? 2'h0 : _signals_T_465; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_467 = _signals_T_55 ? 2'h0 : _signals_T_466; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_468 = _signals_T_53 ? 2'h0 : _signals_T_467; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_469 = _signals_T_51 ? 2'h0 : _signals_T_468; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_470 = _signals_T_49 ? 2'h0 : _signals_T_469; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_471 = _signals_T_47 ? 2'h0 : _signals_T_470; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_472 = _signals_T_45 ? 2'h0 : _signals_T_471; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_473 = _signals_T_43 ? 2'h0 : _signals_T_472; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_474 = _signals_T_41 ? 2'h0 : _signals_T_473; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_475 = _signals_T_39 ? 2'h0 : _signals_T_474; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_476 = _signals_T_37 ? 2'h0 : _signals_T_475; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_477 = _signals_T_35 ? 2'h0 : _signals_T_476; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_478 = _signals_T_33 ? 2'h0 : _signals_T_477; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_479 = _signals_T_31 ? 2'h0 : _signals_T_478; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_480 = _signals_T_29 ? 2'h0 : _signals_T_479; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_481 = _signals_T_27 ? 2'h0 : _signals_T_480; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_482 = _signals_T_25 ? 2'h0 : _signals_T_481; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_483 = _signals_T_23 ? 2'h0 : _signals_T_482; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_484 = _signals_T_21 ? 2'h0 : _signals_T_483; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_485 = _signals_T_19 ? 2'h0 : _signals_T_484; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_486 = _signals_T_17 ? 2'h0 : _signals_T_485; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_487 = _signals_T_15 ? 2'h0 : _signals_T_486; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_488 = _signals_T_13 ? 2'h0 : _signals_T_487; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_489 = _signals_T_11 ? 2'h0 : _signals_T_488; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_490 = _signals_T_9 ? 2'h0 : _signals_T_489; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_491 = _signals_T_7 ? 2'h0 : _signals_T_490; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_492 = _signals_T_5 ? 2'h0 : _signals_T_491; // @[Lookup.scala 34:39]
  wire [1:0] _signals_T_493 = _signals_T_3 ? 2'h0 : _signals_T_492; // @[Lookup.scala 34:39]
  ImmediateGenerator imm_gen ( // @[IDU.scala 39:23]
    .io_inst(imm_gen_io_inst),
    .io_imm(imm_gen_io_imm),
    .io_imm_type(imm_gen_io_imm_type)
  );
  assign io_in_ready = state == 2'h0; // @[IDU.scala 116:24]
  assign io_out_valid = state == 2'h2; // @[IDU.scala 115:25]
  assign io_out_bits_control_signal_PC_sel = _signals_T_1 ? 3'h1 : _signals_T_124; // @[Lookup.scala 34:39]
  assign io_out_bits_control_signal_A_sel = _signals_T_1 ? 2'h1 : _signals_T_165; // @[Lookup.scala 34:39]
  assign io_out_bits_control_signal_B_sel = {{1'd0}, signals_2}; // @[IDU.scala 100:14 97:18]
  assign io_out_bits_control_signal_WB_sel = _signals_T_1 ? 4'h1 : _signals_T_288; // @[Lookup.scala 34:39]
  assign io_out_bits_control_signal_ALU_sel = {{1'd0}, signals_8}; // @[IDU.scala 109:16 97:18]
  assign io_out_bits_control_signal_csr_sel = _signals_T_1 ? 2'h0 : _signals_T_493; // @[Lookup.scala 34:39]
  assign io_out_bits_control_signal_ebreak_en = {{7'd0}, signals_5 != 8'h0}; // @[IDU.scala 103:18 97:18]
  assign io_out_bits_control_signal_ebreak_code = _signals_T_1 ? 8'h0 : _signals_T_329; // @[Lookup.scala 34:39]
  assign io_out_bits_control_signal_dmem_read_en = signals_6 != 3'h0; // @[IDU.scala 105:34]
  assign io_out_bits_control_signal_dmem_write_en = signals_7 != 2'h0; // @[IDU.scala 107:35]
  assign io_out_bits_control_signal_dmem_write_type = {{1'd0}, signals_7}; // @[IDU.scala 97:18 108:24]
  assign io_out_bits_imm = imm_gen_io_imm; // @[IDU.scala 117:19]
  assign io_out_bits_pc = pc; // @[IDU.scala 119:18]
  assign io_out_bits_inst = inst; // @[IDU.scala 120:20]
  assign imm_gen_io_inst = inst; // @[IDU.scala 112:19]
  assign imm_gen_io_imm_type = _signals_T_1 ? 3'h6 : _signals_T_247; // @[Lookup.scala 34:39]
  always @(posedge clock) begin
    if (reset) begin // @[IDU.scala 33:22]
      state <= 2'h0; // @[IDU.scala 33:22]
    end else if (2'h2 == state) begin // @[Mux.scala 81:58]
      if (io_out_ready) begin // @[IDU.scala 37:28]
        state <= 2'h0;
      end else begin
        state <= 2'h2;
      end
    end else if (2'h1 == state) begin // @[Mux.scala 81:58]
      state <= 2'h2;
    end else if (2'h0 == state) begin // @[Mux.scala 81:58]
      state <= _state_T;
    end else begin
      state <= 2'h0;
    end
    if (reset) begin // @[IDU.scala 40:21]
      inst <= 32'h0; // @[IDU.scala 40:21]
    end else if (io_in_ready & io_in_valid) begin // @[IDU.scala 41:14]
      inst <= io_in_bits_inst;
    end
    if (reset) begin // @[IDU.scala 42:19]
      pc <= 32'h0; // @[IDU.scala 42:19]
    end else if (_inst_T) begin // @[IDU.scala 43:12]
      pc <= io_in_bits_pc;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  inst = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  pc = _RAND_2[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module RegisterFile(
  input         clock,
  input         reset,
  input  [4:0]  io_write_address,
  input  [31:0] io_write_data,
  input         io_write_enable,
  input  [4:0]  io_reg1_addr,
  output [31:0] io_reg1_data,
  input  [4:0]  io_reg2_addr,
  output [31:0] io_reg2_data,
  output [31:0] io_test_reg_out_0,
  output [31:0] io_test_reg_out_1,
  output [31:0] io_test_reg_out_2,
  output [31:0] io_test_reg_out_3,
  output [31:0] io_test_reg_out_4,
  output [31:0] io_test_reg_out_5,
  output [31:0] io_test_reg_out_6,
  output [31:0] io_test_reg_out_7,
  output [31:0] io_test_reg_out_8,
  output [31:0] io_test_reg_out_9,
  output [31:0] io_test_reg_out_10,
  output [31:0] io_test_reg_out_11,
  output [31:0] io_test_reg_out_12,
  output [31:0] io_test_reg_out_13,
  output [31:0] io_test_reg_out_14,
  output [31:0] io_test_reg_out_15,
  output [31:0] io_test_reg_out_16,
  output [31:0] io_test_reg_out_17,
  output [31:0] io_test_reg_out_18,
  output [31:0] io_test_reg_out_19,
  output [31:0] io_test_reg_out_20,
  output [31:0] io_test_reg_out_21,
  output [31:0] io_test_reg_out_22,
  output [31:0] io_test_reg_out_23,
  output [31:0] io_test_reg_out_24,
  output [31:0] io_test_reg_out_25,
  output [31:0] io_test_reg_out_26,
  output [31:0] io_test_reg_out_27,
  output [31:0] io_test_reg_out_28,
  output [31:0] io_test_reg_out_29,
  output [31:0] io_test_reg_out_30,
  output [31:0] io_test_reg_out_31,
  input         io_csr_rw_enable,
  input         io_csr_rs_enable,
  input  [31:0] io_csr_addr,
  input  [31:0] io_csr_wdata,
  output [31:0] io_csr_rdata,
  input         io_csr_ecall_enable,
  input  [31:0] io_pc,
  output [31:0] io_csr_ecall_ret,
  input         io_csr_mret_enable,
  output [31:0] io_csr_mret_ret,
  output [31:0] io_test_csr_out_0,
  output [31:0] io_test_csr_out_1,
  output [31:0] io_test_csr_out_2,
  output [31:0] io_test_csr_out_3
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
  reg [31:0] _RAND_32;
  reg [31:0] _RAND_33;
  reg [31:0] _RAND_34;
  reg [31:0] _RAND_35;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] registers_0; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_1; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_2; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_3; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_4; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_5; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_6; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_7; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_8; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_9; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_10; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_11; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_12; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_13; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_14; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_15; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_16; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_17; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_18; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_19; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_20; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_21; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_22; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_23; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_24; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_25; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_26; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_27; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_28; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_29; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_30; // @[RegisterFile.scala 30:34]
  reg [31:0] registers_31; // @[RegisterFile.scala 30:34]
  reg [31:0] csr_0; // @[RegisterFile.scala 31:28]
  reg [31:0] csr_1; // @[RegisterFile.scala 31:28]
  reg [31:0] csr_2; // @[RegisterFile.scala 31:28]
  reg [31:0] csr_3; // @[RegisterFile.scala 31:28]
  wire [2:0] _csr_id_T_1 = 32'h300 == io_csr_addr ? 3'h0 : 3'h7; // @[Mux.scala 81:58]
  wire [2:0] _csr_id_T_3 = 32'h341 == io_csr_addr ? 3'h1 : _csr_id_T_1; // @[Mux.scala 81:58]
  wire [2:0] _csr_id_T_5 = 32'h342 == io_csr_addr ? 3'h2 : _csr_id_T_3; // @[Mux.scala 81:58]
  wire [2:0] csr_id = 32'h305 == io_csr_addr ? 3'h3 : _csr_id_T_5; // @[Mux.scala 81:58]
  wire [31:0] _GEN_65 = 2'h1 == csr_id[1:0] ? csr_1 : csr_0; // @[RegisterFile.scala 42:{22,22}]
  wire [31:0] _GEN_66 = 2'h2 == csr_id[1:0] ? csr_2 : _GEN_65; // @[RegisterFile.scala 42:{22,22}]
  wire [31:0] _GEN_67 = 2'h3 == csr_id[1:0] ? csr_3 : _GEN_66; // @[RegisterFile.scala 42:{22,22}]
  wire  _T_2 = csr_id != 3'h7; // @[RegisterFile.scala 45:34]
  wire [31:0] _GEN_68 = 2'h0 == csr_id[1:0] ? io_csr_wdata : csr_0; // @[RegisterFile.scala 46:{17,17} 31:28]
  wire [31:0] _GEN_69 = 2'h1 == csr_id[1:0] ? io_csr_wdata : csr_1; // @[RegisterFile.scala 46:{17,17} 31:28]
  wire [31:0] _GEN_70 = 2'h2 == csr_id[1:0] ? io_csr_wdata : csr_2; // @[RegisterFile.scala 46:{17,17} 31:28]
  wire [31:0] _GEN_71 = 2'h3 == csr_id[1:0] ? io_csr_wdata : csr_3; // @[RegisterFile.scala 46:{17,17} 31:28]
  wire [31:0] _GEN_72 = io_csr_rw_enable & csr_id != 3'h7 ? _GEN_68 : csr_0; // @[RegisterFile.scala 31:28 45:41]
  wire [31:0] _GEN_73 = io_csr_rw_enable & csr_id != 3'h7 ? _GEN_69 : csr_1; // @[RegisterFile.scala 31:28 45:41]
  wire [31:0] _GEN_74 = io_csr_rw_enable & csr_id != 3'h7 ? _GEN_70 : csr_2; // @[RegisterFile.scala 31:28 45:41]
  wire [31:0] _GEN_75 = io_csr_rw_enable & csr_id != 3'h7 ? _GEN_71 : csr_3; // @[RegisterFile.scala 31:28 45:41]
  wire [31:0] _csr_T_1 = _GEN_67 | io_csr_wdata; // @[RegisterFile.scala 49:32]
  wire [31:0] _GEN_80 = 2'h0 == csr_id[1:0] ? _csr_T_1 : _GEN_72; // @[RegisterFile.scala 49:{17,17}]
  wire [31:0] _GEN_93 = 5'h1 == io_reg1_addr ? registers_1 : registers_0; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_94 = 5'h2 == io_reg1_addr ? registers_2 : _GEN_93; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_95 = 5'h3 == io_reg1_addr ? registers_3 : _GEN_94; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_96 = 5'h4 == io_reg1_addr ? registers_4 : _GEN_95; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_97 = 5'h5 == io_reg1_addr ? registers_5 : _GEN_96; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_98 = 5'h6 == io_reg1_addr ? registers_6 : _GEN_97; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_99 = 5'h7 == io_reg1_addr ? registers_7 : _GEN_98; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_100 = 5'h8 == io_reg1_addr ? registers_8 : _GEN_99; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_101 = 5'h9 == io_reg1_addr ? registers_9 : _GEN_100; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_102 = 5'ha == io_reg1_addr ? registers_10 : _GEN_101; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_103 = 5'hb == io_reg1_addr ? registers_11 : _GEN_102; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_104 = 5'hc == io_reg1_addr ? registers_12 : _GEN_103; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_105 = 5'hd == io_reg1_addr ? registers_13 : _GEN_104; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_106 = 5'he == io_reg1_addr ? registers_14 : _GEN_105; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_107 = 5'hf == io_reg1_addr ? registers_15 : _GEN_106; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_108 = 5'h10 == io_reg1_addr ? registers_16 : _GEN_107; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_109 = 5'h11 == io_reg1_addr ? registers_17 : _GEN_108; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_110 = 5'h12 == io_reg1_addr ? registers_18 : _GEN_109; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_111 = 5'h13 == io_reg1_addr ? registers_19 : _GEN_110; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_112 = 5'h14 == io_reg1_addr ? registers_20 : _GEN_111; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_113 = 5'h15 == io_reg1_addr ? registers_21 : _GEN_112; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_114 = 5'h16 == io_reg1_addr ? registers_22 : _GEN_113; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_115 = 5'h17 == io_reg1_addr ? registers_23 : _GEN_114; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_116 = 5'h18 == io_reg1_addr ? registers_24 : _GEN_115; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_117 = 5'h19 == io_reg1_addr ? registers_25 : _GEN_116; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_118 = 5'h1a == io_reg1_addr ? registers_26 : _GEN_117; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_119 = 5'h1b == io_reg1_addr ? registers_27 : _GEN_118; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_120 = 5'h1c == io_reg1_addr ? registers_28 : _GEN_119; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_121 = 5'h1d == io_reg1_addr ? registers_29 : _GEN_120; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_122 = 5'h1e == io_reg1_addr ? registers_30 : _GEN_121; // @[RegisterFile.scala 59:{16,16}]
  wire [31:0] _GEN_125 = 5'h1 == io_reg2_addr ? registers_1 : registers_0; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_126 = 5'h2 == io_reg2_addr ? registers_2 : _GEN_125; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_127 = 5'h3 == io_reg2_addr ? registers_3 : _GEN_126; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_128 = 5'h4 == io_reg2_addr ? registers_4 : _GEN_127; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_129 = 5'h5 == io_reg2_addr ? registers_5 : _GEN_128; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_130 = 5'h6 == io_reg2_addr ? registers_6 : _GEN_129; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_131 = 5'h7 == io_reg2_addr ? registers_7 : _GEN_130; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_132 = 5'h8 == io_reg2_addr ? registers_8 : _GEN_131; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_133 = 5'h9 == io_reg2_addr ? registers_9 : _GEN_132; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_134 = 5'ha == io_reg2_addr ? registers_10 : _GEN_133; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_135 = 5'hb == io_reg2_addr ? registers_11 : _GEN_134; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_136 = 5'hc == io_reg2_addr ? registers_12 : _GEN_135; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_137 = 5'hd == io_reg2_addr ? registers_13 : _GEN_136; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_138 = 5'he == io_reg2_addr ? registers_14 : _GEN_137; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_139 = 5'hf == io_reg2_addr ? registers_15 : _GEN_138; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_140 = 5'h10 == io_reg2_addr ? registers_16 : _GEN_139; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_141 = 5'h11 == io_reg2_addr ? registers_17 : _GEN_140; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_142 = 5'h12 == io_reg2_addr ? registers_18 : _GEN_141; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_143 = 5'h13 == io_reg2_addr ? registers_19 : _GEN_142; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_144 = 5'h14 == io_reg2_addr ? registers_20 : _GEN_143; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_145 = 5'h15 == io_reg2_addr ? registers_21 : _GEN_144; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_146 = 5'h16 == io_reg2_addr ? registers_22 : _GEN_145; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_147 = 5'h17 == io_reg2_addr ? registers_23 : _GEN_146; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_148 = 5'h18 == io_reg2_addr ? registers_24 : _GEN_147; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_149 = 5'h19 == io_reg2_addr ? registers_25 : _GEN_148; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_150 = 5'h1a == io_reg2_addr ? registers_26 : _GEN_149; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_151 = 5'h1b == io_reg2_addr ? registers_27 : _GEN_150; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_152 = 5'h1c == io_reg2_addr ? registers_28 : _GEN_151; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_153 = 5'h1d == io_reg2_addr ? registers_29 : _GEN_152; // @[RegisterFile.scala 60:{16,16}]
  wire [31:0] _GEN_154 = 5'h1e == io_reg2_addr ? registers_30 : _GEN_153; // @[RegisterFile.scala 60:{16,16}]
  assign io_reg1_data = 5'h1f == io_reg1_addr ? registers_31 : _GEN_122; // @[RegisterFile.scala 59:{16,16}]
  assign io_reg2_data = 5'h1f == io_reg2_addr ? registers_31 : _GEN_154; // @[RegisterFile.scala 60:{16,16}]
  assign io_test_reg_out_0 = registers_0; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_1 = registers_1; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_2 = registers_2; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_3 = registers_3; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_4 = registers_4; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_5 = registers_5; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_6 = registers_6; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_7 = registers_7; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_8 = registers_8; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_9 = registers_9; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_10 = registers_10; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_11 = registers_11; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_12 = registers_12; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_13 = registers_13; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_14 = registers_14; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_15 = registers_15; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_16 = registers_16; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_17 = registers_17; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_18 = registers_18; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_19 = registers_19; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_20 = registers_20; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_21 = registers_21; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_22 = registers_22; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_23 = registers_23; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_24 = registers_24; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_25 = registers_25; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_26 = registers_26; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_27 = registers_27; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_28 = registers_28; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_29 = registers_29; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_30 = registers_30; // @[RegisterFile.scala 61:19]
  assign io_test_reg_out_31 = registers_31; // @[RegisterFile.scala 61:19]
  assign io_csr_rdata = io_csr_rs_enable | io_csr_rw_enable ? _GEN_67 : 32'h0; // @[RegisterFile.scala 42:22]
  assign io_csr_ecall_ret = csr_3; // @[RegisterFile.scala 43:20]
  assign io_csr_mret_ret = csr_1; // @[RegisterFile.scala 44:19]
  assign io_test_csr_out_0 = csr_0; // @[RegisterFile.scala 62:19]
  assign io_test_csr_out_1 = csr_1; // @[RegisterFile.scala 62:19]
  assign io_test_csr_out_2 = csr_2; // @[RegisterFile.scala 62:19]
  assign io_test_csr_out_3 = csr_3; // @[RegisterFile.scala 62:19]
  always @(posedge clock) begin
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_0 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h0 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_0 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_1 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h1 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_1 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_2 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h2 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_2 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_3 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h3 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_3 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_4 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h4 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_4 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_5 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h5 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_5 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_6 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h6 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_6 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_7 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h7 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_7 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_8 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h8 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_8 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_9 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h9 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_9 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_10 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'ha == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_10 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_11 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'hb == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_11 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_12 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'hc == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_12 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_13 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'hd == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_13 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_14 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'he == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_14 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_15 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'hf == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_15 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_16 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h10 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_16 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_17 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h11 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_17 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_18 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h12 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_18 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_19 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h13 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_19 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_20 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h14 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_20 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_21 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h15 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_21 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_22 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h16 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_22 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_23 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h17 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_23 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_24 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h18 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_24 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_25 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h19 == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_25 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_26 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h1a == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_26 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_27 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h1b == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_27 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_28 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h1c == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_28 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_29 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h1d == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_29 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_30 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h1e == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_30 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 30:34]
      registers_31 <= 32'h0; // @[RegisterFile.scala 30:34]
    end else if (io_write_enable & io_write_address != 5'h0) begin // @[RegisterFile.scala 32:50]
      if (5'h1f == io_write_address) begin // @[RegisterFile.scala 33:33]
        registers_31 <= io_write_data; // @[RegisterFile.scala 33:33]
      end
    end
    if (reset) begin // @[RegisterFile.scala 31:28]
      csr_0 <= 32'h0; // @[RegisterFile.scala 31:28]
    end else if (io_csr_mret_enable) begin // @[RegisterFile.scala 56:28]
      csr_0 <= 32'h80; // @[RegisterFile.scala 57:12]
    end else if (io_csr_ecall_enable) begin // @[RegisterFile.scala 51:29]
      csr_0 <= 32'h1800; // @[RegisterFile.scala 54:12]
    end else if (io_csr_rs_enable & _T_2) begin // @[RegisterFile.scala 48:41]
      csr_0 <= _GEN_80;
    end else begin
      csr_0 <= _GEN_72;
    end
    if (reset) begin // @[RegisterFile.scala 31:28]
      csr_1 <= 32'h0; // @[RegisterFile.scala 31:28]
    end else if (io_csr_ecall_enable) begin // @[RegisterFile.scala 51:29]
      csr_1 <= io_pc; // @[RegisterFile.scala 53:12]
    end else if (io_csr_rs_enable & _T_2) begin // @[RegisterFile.scala 48:41]
      if (2'h1 == csr_id[1:0]) begin // @[RegisterFile.scala 49:17]
        csr_1 <= _csr_T_1; // @[RegisterFile.scala 49:17]
      end else begin
        csr_1 <= _GEN_73;
      end
    end else begin
      csr_1 <= _GEN_73;
    end
    if (reset) begin // @[RegisterFile.scala 31:28]
      csr_2 <= 32'h0; // @[RegisterFile.scala 31:28]
    end else if (io_csr_ecall_enable) begin // @[RegisterFile.scala 51:29]
      csr_2 <= 32'hb; // @[RegisterFile.scala 52:12]
    end else if (io_csr_rs_enable & _T_2) begin // @[RegisterFile.scala 48:41]
      if (2'h2 == csr_id[1:0]) begin // @[RegisterFile.scala 49:17]
        csr_2 <= _csr_T_1; // @[RegisterFile.scala 49:17]
      end else begin
        csr_2 <= _GEN_74;
      end
    end else begin
      csr_2 <= _GEN_74;
    end
    if (reset) begin // @[RegisterFile.scala 31:28]
      csr_3 <= 32'h0; // @[RegisterFile.scala 31:28]
    end else if (io_csr_rs_enable & _T_2) begin // @[RegisterFile.scala 48:41]
      if (2'h3 == csr_id[1:0]) begin // @[RegisterFile.scala 49:17]
        csr_3 <= _csr_T_1; // @[RegisterFile.scala 49:17]
      end else begin
        csr_3 <= _GEN_75;
      end
    end else begin
      csr_3 <= _GEN_75;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  registers_0 = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  registers_1 = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  registers_2 = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  registers_3 = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  registers_4 = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  registers_5 = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  registers_6 = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  registers_7 = _RAND_7[31:0];
  _RAND_8 = {1{`RANDOM}};
  registers_8 = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  registers_9 = _RAND_9[31:0];
  _RAND_10 = {1{`RANDOM}};
  registers_10 = _RAND_10[31:0];
  _RAND_11 = {1{`RANDOM}};
  registers_11 = _RAND_11[31:0];
  _RAND_12 = {1{`RANDOM}};
  registers_12 = _RAND_12[31:0];
  _RAND_13 = {1{`RANDOM}};
  registers_13 = _RAND_13[31:0];
  _RAND_14 = {1{`RANDOM}};
  registers_14 = _RAND_14[31:0];
  _RAND_15 = {1{`RANDOM}};
  registers_15 = _RAND_15[31:0];
  _RAND_16 = {1{`RANDOM}};
  registers_16 = _RAND_16[31:0];
  _RAND_17 = {1{`RANDOM}};
  registers_17 = _RAND_17[31:0];
  _RAND_18 = {1{`RANDOM}};
  registers_18 = _RAND_18[31:0];
  _RAND_19 = {1{`RANDOM}};
  registers_19 = _RAND_19[31:0];
  _RAND_20 = {1{`RANDOM}};
  registers_20 = _RAND_20[31:0];
  _RAND_21 = {1{`RANDOM}};
  registers_21 = _RAND_21[31:0];
  _RAND_22 = {1{`RANDOM}};
  registers_22 = _RAND_22[31:0];
  _RAND_23 = {1{`RANDOM}};
  registers_23 = _RAND_23[31:0];
  _RAND_24 = {1{`RANDOM}};
  registers_24 = _RAND_24[31:0];
  _RAND_25 = {1{`RANDOM}};
  registers_25 = _RAND_25[31:0];
  _RAND_26 = {1{`RANDOM}};
  registers_26 = _RAND_26[31:0];
  _RAND_27 = {1{`RANDOM}};
  registers_27 = _RAND_27[31:0];
  _RAND_28 = {1{`RANDOM}};
  registers_28 = _RAND_28[31:0];
  _RAND_29 = {1{`RANDOM}};
  registers_29 = _RAND_29[31:0];
  _RAND_30 = {1{`RANDOM}};
  registers_30 = _RAND_30[31:0];
  _RAND_31 = {1{`RANDOM}};
  registers_31 = _RAND_31[31:0];
  _RAND_32 = {1{`RANDOM}};
  csr_0 = _RAND_32[31:0];
  _RAND_33 = {1{`RANDOM}};
  csr_1 = _RAND_33[31:0];
  _RAND_34 = {1{`RANDOM}};
  csr_2 = _RAND_34[31:0];
  _RAND_35 = {1{`RANDOM}};
  csr_3 = _RAND_35[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ALU(
  input  [31:0] io_src1,
  input  [31:0] io_src2,
  output [31:0] io_result,
  input  [5:0]  io_sel
);
  wire [31:0] _io_result_T_1 = io_src1 + io_src2; // @[ALU.scala 12:21]
  wire [31:0] _io_result_T_3 = io_src1 - io_src2; // @[ALU.scala 13:21]
  wire [31:0] _io_result_T_4 = io_src1 & io_src2; // @[ALU.scala 14:21]
  wire [31:0] _io_result_T_5 = io_src1 | io_src2; // @[ALU.scala 15:21]
  wire [31:0] _io_result_T_6 = io_src1 ^ io_src2; // @[ALU.scala 16:21]
  wire  _io_result_T_7 = io_src1 == io_src2; // @[ALU.scala 17:21]
  wire  _io_result_T_8 = io_src1 != io_src2; // @[ALU.scala 18:21]
  wire  _io_result_T_11 = $signed(io_src1) < $signed(io_src2); // @[ALU.scala 19:28]
  wire  _io_result_T_14 = $signed(io_src1) >= $signed(io_src2); // @[ALU.scala 20:28]
  wire  _io_result_T_15 = io_src1 < io_src2; // @[ALU.scala 21:21]
  wire  _io_result_T_16 = io_src1 >= io_src2; // @[ALU.scala 22:21]
  wire [62:0] _GEN_0 = {{31'd0}, io_src1}; // @[ALU.scala 23:21]
  wire [62:0] _io_result_T_18 = _GEN_0 << io_src2[4:0]; // @[ALU.scala 23:21]
  wire [31:0] _io_result_T_19 = io_src1 >> io_src2; // @[ALU.scala 24:21]
  wire [31:0] _io_result_T_23 = $signed(io_src1) >>> io_src2[4:0]; // @[ALU.scala 25:45]
  wire [31:0] _io_result_T_29 = 6'h1 == io_sel ? _io_result_T_1 : 32'h0; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_31 = 6'h2 == io_sel ? _io_result_T_3 : _io_result_T_29; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_33 = 6'ha == io_sel ? _io_result_T_4 : _io_result_T_31; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_35 = 6'hb == io_sel ? _io_result_T_5 : _io_result_T_33; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_37 = 6'hc == io_sel ? _io_result_T_6 : _io_result_T_35; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_39 = 6'hd == io_sel ? {{31'd0}, _io_result_T_7} : _io_result_T_37; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_41 = 6'he == io_sel ? {{31'd0}, _io_result_T_8} : _io_result_T_39; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_43 = 6'hf == io_sel ? {{31'd0}, _io_result_T_11} : _io_result_T_41; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_45 = 6'h4 == io_sel ? {{31'd0}, _io_result_T_14} : _io_result_T_43; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_47 = 6'h10 == io_sel ? {{31'd0}, _io_result_T_15} : _io_result_T_45; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_49 = 6'h3 == io_sel ? {{31'd0}, _io_result_T_16} : _io_result_T_47; // @[Mux.scala 81:58]
  wire [62:0] _io_result_T_51 = 6'h5 == io_sel ? _io_result_T_18 : {{31'd0}, _io_result_T_49}; // @[Mux.scala 81:58]
  wire [62:0] _io_result_T_53 = 6'h6 == io_sel ? {{31'd0}, _io_result_T_19} : _io_result_T_51; // @[Mux.scala 81:58]
  wire [62:0] _io_result_T_55 = 6'h7 == io_sel ? {{31'd0}, _io_result_T_23} : _io_result_T_53; // @[Mux.scala 81:58]
  wire [62:0] _io_result_T_57 = 6'h8 == io_sel ? {{62'd0}, _io_result_T_11} : _io_result_T_55; // @[Mux.scala 81:58]
  wire [62:0] _io_result_T_59 = 6'h9 == io_sel ? {{62'd0}, _io_result_T_15} : _io_result_T_57; // @[Mux.scala 81:58]
  assign io_result = _io_result_T_59[31:0]; // @[ALU.scala 11:13]
endmodule
module EXU(
  input         clock,
  input         reset,
  output        io_in_ready,
  input         io_in_valid,
  input  [2:0]  io_in_bits_control_signal_PC_sel,
  input  [1:0]  io_in_bits_control_signal_A_sel,
  input  [1:0]  io_in_bits_control_signal_B_sel,
  input  [3:0]  io_in_bits_control_signal_WB_sel,
  input  [5:0]  io_in_bits_control_signal_ALU_sel,
  input  [1:0]  io_in_bits_control_signal_csr_sel,
  input  [7:0]  io_in_bits_control_signal_ebreak_en,
  input  [7:0]  io_in_bits_control_signal_ebreak_code,
  input         io_in_bits_control_signal_dmem_read_en,
  input         io_in_bits_control_signal_dmem_write_en,
  input  [2:0]  io_in_bits_control_signal_dmem_write_type,
  input  [31:0] io_in_bits_imm,
  input  [31:0] io_in_bits_pc,
  input  [31:0] io_in_bits_inst,
  input         io_out_ready,
  output        io_out_valid,
  output [2:0]  io_out_bits_control_signal_PC_sel,
  output [3:0]  io_out_bits_control_signal_WB_sel,
  output        io_out_bits_control_signal_dmem_read_en,
  output        io_out_bits_control_signal_dmem_write_en,
  output [2:0]  io_out_bits_control_signal_dmem_write_type,
  output [31:0] io_out_bits_imm,
  output [31:0] io_out_bits_pc,
  output [31:0] io_out_bits_inst,
  output [31:0] io_out_bits_alu_result,
  output [31:0] io_out_bits_csr_pc_result,
  output [31:0] io_out_bits_csr_rdata,
  output [31:0] io_out_bits_reg2_data,
  output [31:0] io_test_regs_0,
  output [31:0] io_test_regs_1,
  output [31:0] io_test_regs_2,
  output [31:0] io_test_regs_3,
  output [31:0] io_test_regs_4,
  output [31:0] io_test_regs_5,
  output [31:0] io_test_regs_6,
  output [31:0] io_test_regs_7,
  output [31:0] io_test_regs_8,
  output [31:0] io_test_regs_9,
  output [31:0] io_test_regs_10,
  output [31:0] io_test_regs_11,
  output [31:0] io_test_regs_12,
  output [31:0] io_test_regs_13,
  output [31:0] io_test_regs_14,
  output [31:0] io_test_regs_15,
  output [31:0] io_test_regs_16,
  output [31:0] io_test_regs_17,
  output [31:0] io_test_regs_18,
  output [31:0] io_test_regs_19,
  output [31:0] io_test_regs_20,
  output [31:0] io_test_regs_21,
  output [31:0] io_test_regs_22,
  output [31:0] io_test_regs_23,
  output [31:0] io_test_regs_24,
  output [31:0] io_test_regs_25,
  output [31:0] io_test_regs_26,
  output [31:0] io_test_regs_27,
  output [31:0] io_test_regs_28,
  output [31:0] io_test_regs_29,
  output [31:0] io_test_regs_30,
  output [31:0] io_test_regs_31,
  output [31:0] io_test_csr_0,
  output [31:0] io_test_csr_1,
  output [31:0] io_test_csr_2,
  output [31:0] io_test_csr_3,
  input         io_wb_en,
  input  [31:0] io_wb_data,
  input  [4:0]  io_wb_addr
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
`endif // RANDOMIZE_REG_INIT
  wire  register_file_clock; // @[EXU.scala 34:29]
  wire  register_file_reset; // @[EXU.scala 34:29]
  wire [4:0] register_file_io_write_address; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_write_data; // @[EXU.scala 34:29]
  wire  register_file_io_write_enable; // @[EXU.scala 34:29]
  wire [4:0] register_file_io_reg1_addr; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_reg1_data; // @[EXU.scala 34:29]
  wire [4:0] register_file_io_reg2_addr; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_reg2_data; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_0; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_1; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_2; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_3; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_4; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_5; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_6; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_7; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_8; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_9; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_10; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_11; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_12; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_13; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_14; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_15; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_16; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_17; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_18; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_19; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_20; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_21; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_22; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_23; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_24; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_25; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_26; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_27; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_28; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_29; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_30; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_reg_out_31; // @[EXU.scala 34:29]
  wire  register_file_io_csr_rw_enable; // @[EXU.scala 34:29]
  wire  register_file_io_csr_rs_enable; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_csr_addr; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_csr_wdata; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_csr_rdata; // @[EXU.scala 34:29]
  wire  register_file_io_csr_ecall_enable; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_pc; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_csr_ecall_ret; // @[EXU.scala 34:29]
  wire  register_file_io_csr_mret_enable; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_csr_mret_ret; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_csr_out_0; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_csr_out_1; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_csr_out_2; // @[EXU.scala 34:29]
  wire [31:0] register_file_io_test_csr_out_3; // @[EXU.scala 34:29]
  wire [31:0] alu_io_src1; // @[EXU.scala 35:19]
  wire [31:0] alu_io_src2; // @[EXU.scala 35:19]
  wire [31:0] alu_io_result; // @[EXU.scala 35:19]
  wire [5:0] alu_io_sel; // @[EXU.scala 35:19]
  wire  ebreak_inst_enable; // @[EXU.scala 36:27]
  wire [7:0] ebreak_inst_code; // @[EXU.scala 36:27]
  reg [1:0] state; // @[EXU.scala 27:22]
  wire [1:0] _state_T = io_in_valid ? 2'h1 : 2'h0; // @[EXU.scala 29:22]
  reg [2:0] csig_PC_sel; // @[EXU.scala 52:21]
  reg [1:0] csig_A_sel; // @[EXU.scala 52:21]
  reg [1:0] csig_B_sel; // @[EXU.scala 52:21]
  reg [3:0] csig_WB_sel; // @[EXU.scala 52:21]
  reg [5:0] csig_ALU_sel; // @[EXU.scala 52:21]
  reg [1:0] csig_csr_sel; // @[EXU.scala 52:21]
  reg [7:0] csig_ebreak_en; // @[EXU.scala 52:21]
  reg [7:0] csig_ebreak_code; // @[EXU.scala 52:21]
  reg  csig_dmem_read_en; // @[EXU.scala 52:21]
  reg  csig_dmem_write_en; // @[EXU.scala 52:21]
  reg [2:0] csig_dmem_write_type; // @[EXU.scala 52:21]
  wire  _csig_T = io_in_valid & io_in_ready; // @[EXU.scala 53:27]
  reg [31:0] imm; // @[EXU.scala 54:20]
  reg [31:0] pc; // @[EXU.scala 56:19]
  wire  _pc_T = io_in_ready & io_in_valid; // @[EXU.scala 57:25]
  reg [31:0] inst; // @[EXU.scala 58:21]
  wire [31:0] _alu_io_src1_T_1 = 2'h1 == csig_A_sel ? register_file_io_reg1_data : 32'h0; // @[Mux.scala 81:58]
  wire [31:0] _alu_io_src2_T_1 = 2'h0 == csig_B_sel ? register_file_io_reg2_data : 32'h0; // @[Mux.scala 81:58]
  wire  _ebreak_inst_io_enable_T = state == 2'h1; // @[EXU.scala 71:37]
  wire [7:0] _ebreak_inst_io_enable_T_1 = state == 2'h1 ? csig_ebreak_en : 8'h0; // @[EXU.scala 71:31]
  wire  _register_file_io_csr_ecall_enable_T_1 = csig_PC_sel == 3'h4; // @[EXU.scala 79:79]
  reg [31:0] csr_rdata; // @[EXU.scala 92:26]
  RegisterFile register_file ( // @[EXU.scala 34:29]
    .clock(register_file_clock),
    .reset(register_file_reset),
    .io_write_address(register_file_io_write_address),
    .io_write_data(register_file_io_write_data),
    .io_write_enable(register_file_io_write_enable),
    .io_reg1_addr(register_file_io_reg1_addr),
    .io_reg1_data(register_file_io_reg1_data),
    .io_reg2_addr(register_file_io_reg2_addr),
    .io_reg2_data(register_file_io_reg2_data),
    .io_test_reg_out_0(register_file_io_test_reg_out_0),
    .io_test_reg_out_1(register_file_io_test_reg_out_1),
    .io_test_reg_out_2(register_file_io_test_reg_out_2),
    .io_test_reg_out_3(register_file_io_test_reg_out_3),
    .io_test_reg_out_4(register_file_io_test_reg_out_4),
    .io_test_reg_out_5(register_file_io_test_reg_out_5),
    .io_test_reg_out_6(register_file_io_test_reg_out_6),
    .io_test_reg_out_7(register_file_io_test_reg_out_7),
    .io_test_reg_out_8(register_file_io_test_reg_out_8),
    .io_test_reg_out_9(register_file_io_test_reg_out_9),
    .io_test_reg_out_10(register_file_io_test_reg_out_10),
    .io_test_reg_out_11(register_file_io_test_reg_out_11),
    .io_test_reg_out_12(register_file_io_test_reg_out_12),
    .io_test_reg_out_13(register_file_io_test_reg_out_13),
    .io_test_reg_out_14(register_file_io_test_reg_out_14),
    .io_test_reg_out_15(register_file_io_test_reg_out_15),
    .io_test_reg_out_16(register_file_io_test_reg_out_16),
    .io_test_reg_out_17(register_file_io_test_reg_out_17),
    .io_test_reg_out_18(register_file_io_test_reg_out_18),
    .io_test_reg_out_19(register_file_io_test_reg_out_19),
    .io_test_reg_out_20(register_file_io_test_reg_out_20),
    .io_test_reg_out_21(register_file_io_test_reg_out_21),
    .io_test_reg_out_22(register_file_io_test_reg_out_22),
    .io_test_reg_out_23(register_file_io_test_reg_out_23),
    .io_test_reg_out_24(register_file_io_test_reg_out_24),
    .io_test_reg_out_25(register_file_io_test_reg_out_25),
    .io_test_reg_out_26(register_file_io_test_reg_out_26),
    .io_test_reg_out_27(register_file_io_test_reg_out_27),
    .io_test_reg_out_28(register_file_io_test_reg_out_28),
    .io_test_reg_out_29(register_file_io_test_reg_out_29),
    .io_test_reg_out_30(register_file_io_test_reg_out_30),
    .io_test_reg_out_31(register_file_io_test_reg_out_31),
    .io_csr_rw_enable(register_file_io_csr_rw_enable),
    .io_csr_rs_enable(register_file_io_csr_rs_enable),
    .io_csr_addr(register_file_io_csr_addr),
    .io_csr_wdata(register_file_io_csr_wdata),
    .io_csr_rdata(register_file_io_csr_rdata),
    .io_csr_ecall_enable(register_file_io_csr_ecall_enable),
    .io_pc(register_file_io_pc),
    .io_csr_ecall_ret(register_file_io_csr_ecall_ret),
    .io_csr_mret_enable(register_file_io_csr_mret_enable),
    .io_csr_mret_ret(register_file_io_csr_mret_ret),
    .io_test_csr_out_0(register_file_io_test_csr_out_0),
    .io_test_csr_out_1(register_file_io_test_csr_out_1),
    .io_test_csr_out_2(register_file_io_test_csr_out_2),
    .io_test_csr_out_3(register_file_io_test_csr_out_3)
  );
  ALU alu ( // @[EXU.scala 35:19]
    .io_src1(alu_io_src1),
    .io_src2(alu_io_src2),
    .io_result(alu_io_result),
    .io_sel(alu_io_sel)
  );
  EBreak ebreak_inst ( // @[EXU.scala 36:27]
    .enable(ebreak_inst_enable),
    .code(ebreak_inst_code)
  );
  assign io_in_ready = state == 2'h0; // @[EXU.scala 88:24]
  assign io_out_valid = state == 2'h2; // @[EXU.scala 87:25]
  assign io_out_bits_control_signal_PC_sel = csig_PC_sel; // @[EXU.scala 89:30]
  assign io_out_bits_control_signal_WB_sel = csig_WB_sel; // @[EXU.scala 89:30]
  assign io_out_bits_control_signal_dmem_read_en = csig_dmem_read_en; // @[EXU.scala 89:30]
  assign io_out_bits_control_signal_dmem_write_en = csig_dmem_write_en; // @[EXU.scala 89:30]
  assign io_out_bits_control_signal_dmem_write_type = csig_dmem_write_type; // @[EXU.scala 89:30]
  assign io_out_bits_imm = imm; // @[EXU.scala 97:19]
  assign io_out_bits_pc = pc; // @[EXU.scala 98:18]
  assign io_out_bits_inst = inst; // @[EXU.scala 96:20]
  assign io_out_bits_alu_result = alu_io_result; // @[EXU.scala 90:26]
  assign io_out_bits_csr_pc_result = _register_file_io_csr_ecall_enable_T_1 ? register_file_io_csr_ecall_ret :
    register_file_io_csr_mret_ret; // @[EXU.scala 91:35]
  assign io_out_bits_csr_rdata = csr_rdata; // @[EXU.scala 94:25]
  assign io_out_bits_reg2_data = register_file_io_reg2_data; // @[EXU.scala 95:25]
  assign io_test_regs_0 = register_file_io_test_reg_out_0; // @[EXU.scala 100:16]
  assign io_test_regs_1 = register_file_io_test_reg_out_1; // @[EXU.scala 100:16]
  assign io_test_regs_2 = register_file_io_test_reg_out_2; // @[EXU.scala 100:16]
  assign io_test_regs_3 = register_file_io_test_reg_out_3; // @[EXU.scala 100:16]
  assign io_test_regs_4 = register_file_io_test_reg_out_4; // @[EXU.scala 100:16]
  assign io_test_regs_5 = register_file_io_test_reg_out_5; // @[EXU.scala 100:16]
  assign io_test_regs_6 = register_file_io_test_reg_out_6; // @[EXU.scala 100:16]
  assign io_test_regs_7 = register_file_io_test_reg_out_7; // @[EXU.scala 100:16]
  assign io_test_regs_8 = register_file_io_test_reg_out_8; // @[EXU.scala 100:16]
  assign io_test_regs_9 = register_file_io_test_reg_out_9; // @[EXU.scala 100:16]
  assign io_test_regs_10 = register_file_io_test_reg_out_10; // @[EXU.scala 100:16]
  assign io_test_regs_11 = register_file_io_test_reg_out_11; // @[EXU.scala 100:16]
  assign io_test_regs_12 = register_file_io_test_reg_out_12; // @[EXU.scala 100:16]
  assign io_test_regs_13 = register_file_io_test_reg_out_13; // @[EXU.scala 100:16]
  assign io_test_regs_14 = register_file_io_test_reg_out_14; // @[EXU.scala 100:16]
  assign io_test_regs_15 = register_file_io_test_reg_out_15; // @[EXU.scala 100:16]
  assign io_test_regs_16 = register_file_io_test_reg_out_16; // @[EXU.scala 100:16]
  assign io_test_regs_17 = register_file_io_test_reg_out_17; // @[EXU.scala 100:16]
  assign io_test_regs_18 = register_file_io_test_reg_out_18; // @[EXU.scala 100:16]
  assign io_test_regs_19 = register_file_io_test_reg_out_19; // @[EXU.scala 100:16]
  assign io_test_regs_20 = register_file_io_test_reg_out_20; // @[EXU.scala 100:16]
  assign io_test_regs_21 = register_file_io_test_reg_out_21; // @[EXU.scala 100:16]
  assign io_test_regs_22 = register_file_io_test_reg_out_22; // @[EXU.scala 100:16]
  assign io_test_regs_23 = register_file_io_test_reg_out_23; // @[EXU.scala 100:16]
  assign io_test_regs_24 = register_file_io_test_reg_out_24; // @[EXU.scala 100:16]
  assign io_test_regs_25 = register_file_io_test_reg_out_25; // @[EXU.scala 100:16]
  assign io_test_regs_26 = register_file_io_test_reg_out_26; // @[EXU.scala 100:16]
  assign io_test_regs_27 = register_file_io_test_reg_out_27; // @[EXU.scala 100:16]
  assign io_test_regs_28 = register_file_io_test_reg_out_28; // @[EXU.scala 100:16]
  assign io_test_regs_29 = register_file_io_test_reg_out_29; // @[EXU.scala 100:16]
  assign io_test_regs_30 = register_file_io_test_reg_out_30; // @[EXU.scala 100:16]
  assign io_test_regs_31 = register_file_io_test_reg_out_31; // @[EXU.scala 100:16]
  assign io_test_csr_0 = register_file_io_test_csr_out_0; // @[EXU.scala 101:15]
  assign io_test_csr_1 = register_file_io_test_csr_out_1; // @[EXU.scala 101:15]
  assign io_test_csr_2 = register_file_io_test_csr_out_2; // @[EXU.scala 101:15]
  assign io_test_csr_3 = register_file_io_test_csr_out_3; // @[EXU.scala 101:15]
  assign register_file_clock = clock;
  assign register_file_reset = reset;
  assign register_file_io_write_address = io_wb_addr; // @[EXU.scala 74:34]
  assign register_file_io_write_data = io_wb_data; // @[EXU.scala 76:31]
  assign register_file_io_write_enable = io_wb_en; // @[EXU.scala 75:33]
  assign register_file_io_reg1_addr = inst[19:15]; // @[EXU.scala 77:37]
  assign register_file_io_reg2_addr = inst[24:20]; // @[EXU.scala 78:37]
  assign register_file_io_csr_rw_enable = _ebreak_inst_io_enable_T & csig_csr_sel == 2'h1; // @[EXU.scala 81:61]
  assign register_file_io_csr_rs_enable = _ebreak_inst_io_enable_T & csig_csr_sel == 2'h2; // @[EXU.scala 82:61]
  assign register_file_io_csr_addr = imm; // @[EXU.scala 83:29]
  assign register_file_io_csr_wdata = register_file_io_reg1_data; // @[EXU.scala 84:30]
  assign register_file_io_csr_ecall_enable = _ebreak_inst_io_enable_T & csig_PC_sel == 3'h4; // @[EXU.scala 79:64]
  assign register_file_io_pc = pc; // @[EXU.scala 85:23]
  assign register_file_io_csr_mret_enable = _ebreak_inst_io_enable_T & csig_PC_sel == 3'h5; // @[EXU.scala 80:63]
  assign alu_io_src1 = 2'h2 == csig_A_sel ? pc : _alu_io_src1_T_1; // @[Mux.scala 81:58]
  assign alu_io_src2 = 2'h1 == csig_B_sel ? imm : _alu_io_src2_T_1; // @[Mux.scala 81:58]
  assign alu_io_sel = csig_ALU_sel; // @[EXU.scala 69:14]
  assign ebreak_inst_enable = _ebreak_inst_io_enable_T_1[0]; // @[EXU.scala 71:25]
  assign ebreak_inst_code = csig_ebreak_code; // @[EXU.scala 72:25]
  always @(posedge clock) begin
    if (reset) begin // @[EXU.scala 27:22]
      state <= 2'h0; // @[EXU.scala 27:22]
    end else if (2'h2 == state) begin // @[Mux.scala 81:58]
      if (io_out_ready) begin // @[EXU.scala 31:28]
        state <= 2'h0;
      end else begin
        state <= 2'h2;
      end
    end else if (2'h1 == state) begin // @[Mux.scala 81:58]
      state <= 2'h2;
    end else if (2'h0 == state) begin // @[Mux.scala 81:58]
      state <= _state_T;
    end else begin
      state <= 2'h0;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_PC_sel <= 3'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_PC_sel <= io_in_bits_control_signal_PC_sel;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_A_sel <= 2'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_A_sel <= io_in_bits_control_signal_A_sel;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_B_sel <= 2'h1; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_B_sel <= io_in_bits_control_signal_B_sel;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_WB_sel <= 4'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_WB_sel <= io_in_bits_control_signal_WB_sel;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_ALU_sel <= 6'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_ALU_sel <= io_in_bits_control_signal_ALU_sel;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_csr_sel <= 2'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_csr_sel <= io_in_bits_control_signal_csr_sel;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_ebreak_en <= 8'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_ebreak_en <= io_in_bits_control_signal_ebreak_en;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_ebreak_code <= 8'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_ebreak_code <= io_in_bits_control_signal_ebreak_code;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_dmem_read_en <= 1'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_dmem_read_en <= io_in_bits_control_signal_dmem_read_en;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_dmem_write_en <= 1'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_dmem_write_en <= io_in_bits_control_signal_dmem_write_en;
    end
    if (reset) begin // @[EXU.scala 52:21]
      csig_dmem_write_type <= 3'h0; // @[EXU.scala 52:21]
    end else if (io_in_valid & io_in_ready) begin // @[EXU.scala 53:14]
      csig_dmem_write_type <= io_in_bits_control_signal_dmem_write_type;
    end
    if (reset) begin // @[EXU.scala 54:20]
      imm <= 32'h0; // @[EXU.scala 54:20]
    end else if (_csig_T) begin // @[EXU.scala 55:13]
      imm <= io_in_bits_imm;
    end
    if (reset) begin // @[EXU.scala 56:19]
      pc <= 32'h0; // @[EXU.scala 56:19]
    end else if (io_in_ready & io_in_valid) begin // @[EXU.scala 57:12]
      pc <= io_in_bits_pc;
    end
    if (reset) begin // @[EXU.scala 58:21]
      inst <= 32'h0; // @[EXU.scala 58:21]
    end else if (_pc_T) begin // @[EXU.scala 59:14]
      inst <= io_in_bits_inst;
    end
    if (reset) begin // @[EXU.scala 92:26]
      csr_rdata <= 32'h0; // @[EXU.scala 92:26]
    end else if (_ebreak_inst_io_enable_T) begin // @[EXU.scala 93:19]
      csr_rdata <= register_file_io_csr_rdata;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  csig_PC_sel = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  csig_A_sel = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  csig_B_sel = _RAND_3[1:0];
  _RAND_4 = {1{`RANDOM}};
  csig_WB_sel = _RAND_4[3:0];
  _RAND_5 = {1{`RANDOM}};
  csig_ALU_sel = _RAND_5[5:0];
  _RAND_6 = {1{`RANDOM}};
  csig_csr_sel = _RAND_6[1:0];
  _RAND_7 = {1{`RANDOM}};
  csig_ebreak_en = _RAND_7[7:0];
  _RAND_8 = {1{`RANDOM}};
  csig_ebreak_code = _RAND_8[7:0];
  _RAND_9 = {1{`RANDOM}};
  csig_dmem_read_en = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  csig_dmem_write_en = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  csig_dmem_write_type = _RAND_11[2:0];
  _RAND_12 = {1{`RANDOM}};
  imm = _RAND_12[31:0];
  _RAND_13 = {1{`RANDOM}};
  pc = _RAND_13[31:0];
  _RAND_14 = {1{`RANDOM}};
  inst = _RAND_14[31:0];
  _RAND_15 = {1{`RANDOM}};
  csr_rdata = _RAND_15[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module WBU(
  input         clock,
  input         reset,
  output        io_in_ready,
  input         io_in_valid,
  input  [2:0]  io_in_bits_control_signal_PC_sel,
  input  [3:0]  io_in_bits_control_signal_WB_sel,
  input         io_in_bits_control_signal_dmem_read_en,
  input         io_in_bits_control_signal_dmem_write_en,
  input  [2:0]  io_in_bits_control_signal_dmem_write_type,
  input  [31:0] io_in_bits_imm,
  input  [31:0] io_in_bits_pc,
  input  [31:0] io_in_bits_inst,
  input  [31:0] io_in_bits_alu_result,
  input  [31:0] io_in_bits_csr_pc_result,
  input  [31:0] io_in_bits_csr_rdata,
  input  [31:0] io_in_bits_reg2_data,
  input         io_out_ready,
  output        io_out_valid,
  output [31:0] io_out_bits_pc,
  output [31:0] io_wb_data,
  output [4:0]  io_wb_addr,
  output        io_wb_en,
  output [31:0] io_dmem_araddr,
  output        io_dmem_arvalid,
  input         io_dmem_arready,
  input  [31:0] io_dmem_rdata,
  input         io_dmem_rvalid,
  output        io_dmem_rready,
  output [31:0] io_dmem_awaddr,
  output        io_dmem_awvalid,
  input         io_dmem_awready,
  output [31:0] io_dmem_wdata,
  output [3:0]  io_dmem_wstrb,
  output        io_dmem_wvalid,
  input         io_dmem_wready,
  input         io_dmem_bvalid,
  output        io_dmem_bready
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
`endif // RANDOMIZE_REG_INIT
  reg [2:0] state; // @[WBU.scala 15:22]
  wire [2:0] _state_T = io_in_bits_control_signal_dmem_write_en ? 3'h3 : 3'h1; // @[WBU.scala 19:12]
  wire [2:0] _state_T_1 = io_in_bits_control_signal_dmem_read_en ? 3'h2 : _state_T; // @[WBU.scala 18:10]
  wire [2:0] _state_T_2 = io_in_valid ? _state_T_1 : 3'h0; // @[WBU.scala 17:22]
  wire [2:0] _state_T_3 = io_dmem_arready ? 3'h4 : 3'h2; // @[WBU.scala 22:26]
  wire [2:0] _state_T_5 = io_dmem_awready & io_dmem_wready ? 3'h5 : 3'h3; // @[WBU.scala 23:27]
  wire [2:0] _state_T_6 = io_dmem_rvalid ? 3'h6 : 3'h4; // @[WBU.scala 24:27]
  wire [2:0] _state_T_10 = 3'h0 == state ? _state_T_2 : 3'h0; // @[Mux.scala 81:58]
  wire [2:0] _state_T_12 = 3'h1 == state ? 3'h6 : _state_T_10; // @[Mux.scala 81:58]
  wire [2:0] _state_T_14 = 3'h2 == state ? _state_T_3 : _state_T_12; // @[Mux.scala 81:58]
  wire [2:0] _state_T_16 = 3'h3 == state ? _state_T_5 : _state_T_14; // @[Mux.scala 81:58]
  reg [31:0] imm; // @[WBU.scala 30:20]
  reg [31:0] pc; // @[WBU.scala 32:19]
  wire  _pc_T = io_in_ready & io_in_valid; // @[WBU.scala 33:25]
  reg [2:0] input_control_signal_PC_sel; // @[WBU.scala 34:18]
  reg [3:0] input_control_signal_WB_sel; // @[WBU.scala 34:18]
  reg [2:0] input_control_signal_dmem_write_type; // @[WBU.scala 34:18]
  reg [31:0] input_inst; // @[WBU.scala 34:18]
  reg [31:0] input_alu_result; // @[WBU.scala 34:18]
  reg [31:0] input_csr_pc_result; // @[WBU.scala 34:18]
  reg [31:0] input_csr_rdata; // @[WBU.scala 34:18]
  reg [31:0] input_reg2_data; // @[WBU.scala 34:18]
  reg [31:0] new_pc; // @[WBU.scala 41:23]
  wire [31:0] _new_pc_T_1 = pc + 32'h4; // @[WBU.scala 44:24]
  wire [31:0] _new_pc_T_4 = pc + imm; // @[WBU.scala 46:45]
  wire [31:0] _new_pc_T_7 = input_alu_result[0] ? _new_pc_T_4 : _new_pc_T_1; // @[WBU.scala 46:25]
  wire [31:0] _new_pc_T_11 = 3'h1 == input_control_signal_PC_sel ? _new_pc_T_1 : pc; // @[Mux.scala 81:58]
  wire [31:0] _new_pc_T_13 = 3'h2 == input_control_signal_PC_sel ? input_alu_result : _new_pc_T_11; // @[Mux.scala 81:58]
  wire [4:0] roffset = {input_alu_result[1:0], 3'h0}; // @[WBU.scala 52:33]
  wire [31:0] shift_rdata = io_dmem_rdata >> roffset; // @[WBU.scala 54:32]
  wire [7:0] _io_wb_data_T_5 = shift_rdata[7:0]; // @[WBU.scala 63:36]
  wire [31:0] _io_wb_data_T_7 = {{24{_io_wb_data_T_5[7]}},_io_wb_data_T_5}; // @[WBU.scala 63:51]
  wire [15:0] _io_wb_data_T_9 = shift_rdata[15:0]; // @[WBU.scala 64:37]
  wire [31:0] _io_wb_data_T_11 = {{16{_io_wb_data_T_9[15]}},_io_wb_data_T_9}; // @[WBU.scala 64:52]
  wire [31:0] _io_wb_data_T_13 = 4'h1 == input_control_signal_WB_sel ? input_alu_result : 32'h0; // @[Mux.scala 81:58]
  wire [31:0] _io_wb_data_T_15 = 4'h2 == input_control_signal_WB_sel ? _new_pc_T_1 : _io_wb_data_T_13; // @[Mux.scala 81:58]
  wire [31:0] _io_wb_data_T_17 = 4'h3 == input_control_signal_WB_sel ? shift_rdata : _io_wb_data_T_15; // @[Mux.scala 81:58]
  wire [31:0] _io_wb_data_T_19 = 4'h4 == input_control_signal_WB_sel ? {{24'd0}, shift_rdata[7:0]} : _io_wb_data_T_17; // @[Mux.scala 81:58]
  wire [31:0] _io_wb_data_T_21 = 4'h5 == input_control_signal_WB_sel ? {{16'd0}, shift_rdata[15:0]} : _io_wb_data_T_19; // @[Mux.scala 81:58]
  wire [31:0] _io_wb_data_T_23 = 4'h6 == input_control_signal_WB_sel ? _io_wb_data_T_7 : _io_wb_data_T_21; // @[Mux.scala 81:58]
  wire [31:0] _io_wb_data_T_25 = 4'h7 == input_control_signal_WB_sel ? _io_wb_data_T_11 : _io_wb_data_T_23; // @[Mux.scala 81:58]
  wire [31:0] _io_dmem_araddr_T = {{2'd0}, input_alu_result[31:2]}; // @[WBU.scala 68:32]
  wire [33:0] _GEN_1 = {_io_dmem_araddr_T, 2'h0}; // @[WBU.scala 68:39]
  wire [34:0] _io_dmem_araddr_T_1 = {{1'd0}, _GEN_1}; // @[WBU.scala 68:39]
  wire [62:0] _GEN_2 = {{31'd0}, input_reg2_data}; // @[WBU.scala 75:38]
  wire [62:0] _dmem_write_data_T = _GEN_2 << roffset; // @[WBU.scala 75:38]
  wire [4:0] _io_dmem_wstrb_T_1 = 5'h3 << input_alu_result[1:0]; // @[WBU.scala 82:28]
  wire [3:0] _io_dmem_wstrb_T_3 = 4'h1 << input_alu_result[1:0]; // @[WBU.scala 83:27]
  wire [3:0] _io_dmem_wstrb_T_5 = 3'h3 == input_control_signal_dmem_write_type ? 4'hf : 4'h0; // @[Mux.scala 81:58]
  wire [4:0] _io_dmem_wstrb_T_7 = 3'h2 == input_control_signal_dmem_write_type ? _io_dmem_wstrb_T_1 : {{1'd0},
    _io_dmem_wstrb_T_5}; // @[Mux.scala 81:58]
  wire [4:0] _io_dmem_wstrb_T_9 = 3'h1 == input_control_signal_dmem_write_type ? {{1'd0}, _io_dmem_wstrb_T_3} :
    _io_dmem_wstrb_T_7; // @[Mux.scala 81:58]
  assign io_in_ready = state == 3'h0; // @[WBU.scala 88:24]
  assign io_out_valid = state == 3'h6; // @[WBU.scala 87:25]
  assign io_out_bits_pc = new_pc; // @[WBU.scala 89:18]
  assign io_wb_data = 4'h8 == input_control_signal_WB_sel ? input_csr_rdata : _io_wb_data_T_25; // @[Mux.scala 81:58]
  assign io_wb_addr = input_inst[11:7]; // @[WBU.scala 55:27]
  assign io_wb_en = state == 3'h1 & input_control_signal_WB_sel != 4'h0 | state == 3'h4 & io_dmem_rvalid &
    io_dmem_rready; // @[WBU.scala 56:69]
  assign io_dmem_araddr = _io_dmem_araddr_T_1[31:0]; // @[WBU.scala 68:18]
  assign io_dmem_arvalid = state == 3'h2; // @[WBU.scala 69:28]
  assign io_dmem_rready = 1'h1; // @[WBU.scala 70:18]
  assign io_dmem_awaddr = _io_dmem_araddr_T_1[31:0]; // @[WBU.scala 78:18]
  assign io_dmem_awvalid = state == 3'h3; // @[WBU.scala 77:28]
  assign io_dmem_wdata = _dmem_write_data_T[31:0]; // @[WBU.scala 72:29 75:19]
  assign io_dmem_wstrb = _io_dmem_wstrb_T_9[3:0]; // @[WBU.scala 80:17]
  assign io_dmem_wvalid = state == 3'h3; // @[WBU.scala 76:27]
  assign io_dmem_bready = state == 3'h5; // @[WBU.scala 85:27]
  always @(posedge clock) begin
    if (reset) begin // @[WBU.scala 15:22]
      state <= 3'h0; // @[WBU.scala 15:22]
    end else if (3'h6 == state) begin // @[Mux.scala 81:58]
      if (io_out_ready) begin // @[WBU.scala 26:28]
        state <= 3'h0;
      end else begin
        state <= 3'h6;
      end
    end else if (3'h5 == state) begin // @[Mux.scala 81:58]
      if (io_dmem_bvalid) begin // @[WBU.scala 25:28]
        state <= 3'h6;
      end else begin
        state <= 3'h5;
      end
    end else if (3'h4 == state) begin // @[Mux.scala 81:58]
      state <= _state_T_6;
    end else begin
      state <= _state_T_16;
    end
    if (reset) begin // @[WBU.scala 30:20]
      imm <= 32'h0; // @[WBU.scala 30:20]
    end else if (io_in_valid & io_in_ready) begin // @[WBU.scala 31:13]
      imm <= io_in_bits_imm;
    end
    if (reset) begin // @[WBU.scala 32:19]
      pc <= 32'h0; // @[WBU.scala 32:19]
    end else if (io_in_ready & io_in_valid) begin // @[WBU.scala 33:12]
      pc <= io_in_bits_pc;
    end
    if (_pc_T) begin // @[WBU.scala 35:15]
      input_control_signal_PC_sel <= io_in_bits_control_signal_PC_sel;
    end
    if (_pc_T) begin // @[WBU.scala 35:15]
      input_control_signal_WB_sel <= io_in_bits_control_signal_WB_sel;
    end
    if (_pc_T) begin // @[WBU.scala 35:15]
      input_control_signal_dmem_write_type <= io_in_bits_control_signal_dmem_write_type;
    end
    if (_pc_T) begin // @[WBU.scala 35:15]
      input_inst <= io_in_bits_inst;
    end
    if (_pc_T) begin // @[WBU.scala 35:15]
      input_alu_result <= io_in_bits_alu_result;
    end
    if (_pc_T) begin // @[WBU.scala 35:15]
      input_csr_pc_result <= io_in_bits_csr_pc_result;
    end
    if (_pc_T) begin // @[WBU.scala 35:15]
      input_csr_rdata <= io_in_bits_csr_rdata;
    end
    if (_pc_T) begin // @[WBU.scala 35:15]
      input_reg2_data <= io_in_bits_reg2_data;
    end
    if (reset) begin // @[WBU.scala 41:23]
      new_pc <= 32'h0; // @[WBU.scala 41:23]
    end else if (3'h5 == input_control_signal_PC_sel) begin // @[Mux.scala 81:58]
      new_pc <= input_csr_pc_result;
    end else if (3'h4 == input_control_signal_PC_sel) begin // @[Mux.scala 81:58]
      new_pc <= input_csr_pc_result;
    end else if (3'h3 == input_control_signal_PC_sel) begin // @[Mux.scala 81:58]
      new_pc <= _new_pc_T_7;
    end else begin
      new_pc <= _new_pc_T_13;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  imm = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  pc = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  input_control_signal_PC_sel = _RAND_3[2:0];
  _RAND_4 = {1{`RANDOM}};
  input_control_signal_WB_sel = _RAND_4[3:0];
  _RAND_5 = {1{`RANDOM}};
  input_control_signal_dmem_write_type = _RAND_5[2:0];
  _RAND_6 = {1{`RANDOM}};
  input_inst = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  input_alu_result = _RAND_7[31:0];
  _RAND_8 = {1{`RANDOM}};
  input_csr_pc_result = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  input_csr_rdata = _RAND_9[31:0];
  _RAND_10 = {1{`RANDOM}};
  input_reg2_data = _RAND_10[31:0];
  _RAND_11 = {1{`RANDOM}};
  new_pc = _RAND_11[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TopLevel(
  input         clock,
  input         reset,
  output [31:0] io_test_pc,
  output [31:0] io_test_regs_0,
  output [31:0] io_test_regs_1,
  output [31:0] io_test_regs_2,
  output [31:0] io_test_regs_3,
  output [31:0] io_test_regs_4,
  output [31:0] io_test_regs_5,
  output [31:0] io_test_regs_6,
  output [31:0] io_test_regs_7,
  output [31:0] io_test_regs_8,
  output [31:0] io_test_regs_9,
  output [31:0] io_test_regs_10,
  output [31:0] io_test_regs_11,
  output [31:0] io_test_regs_12,
  output [31:0] io_test_regs_13,
  output [31:0] io_test_regs_14,
  output [31:0] io_test_regs_15,
  output [31:0] io_test_regs_16,
  output [31:0] io_test_regs_17,
  output [31:0] io_test_regs_18,
  output [31:0] io_test_regs_19,
  output [31:0] io_test_regs_20,
  output [31:0] io_test_regs_21,
  output [31:0] io_test_regs_22,
  output [31:0] io_test_regs_23,
  output [31:0] io_test_regs_24,
  output [31:0] io_test_regs_25,
  output [31:0] io_test_regs_26,
  output [31:0] io_test_regs_27,
  output [31:0] io_test_regs_28,
  output [31:0] io_test_regs_29,
  output [31:0] io_test_regs_30,
  output [31:0] io_test_regs_31,
  output [31:0] io_test_csr_0,
  output [31:0] io_test_csr_1,
  output [31:0] io_test_csr_2,
  output [31:0] io_test_csr_3,
  output        io_test_imem_en
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  wire  sram_arbiter_clock; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_reset; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_in1_araddr; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in1_arvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in1_arready; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_in1_rdata; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in1_rvalid; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_in2_araddr; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_arvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_arready; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_in2_rdata; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_rvalid; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_in2_awaddr; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_awvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_awready; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_in2_wdata; // @[TopLevel.scala 12:28]
  wire [3:0] sram_arbiter_io_in2_wstrb; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_wvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_wready; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_bvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_in2_bready; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_out_araddr; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_arvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_arready; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_out_rdata; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_rvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_rready; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_out_awaddr; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_awvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_awready; // @[TopLevel.scala 12:28]
  wire [31:0] sram_arbiter_io_out_wdata; // @[TopLevel.scala 12:28]
  wire [3:0] sram_arbiter_io_out_wstrb; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_wvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_wready; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_bvalid; // @[TopLevel.scala 12:28]
  wire  sram_arbiter_io_out_bready; // @[TopLevel.scala 12:28]
  wire  axi_xbar_clock; // @[TopLevel.scala 13:24]
  wire  axi_xbar_reset; // @[TopLevel.scala 13:24]
  wire [31:0] axi_xbar_io_in_araddr; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_arvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_arready; // @[TopLevel.scala 13:24]
  wire [31:0] axi_xbar_io_in_rdata; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_rvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_rready; // @[TopLevel.scala 13:24]
  wire [31:0] axi_xbar_io_in_awaddr; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_awvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_awready; // @[TopLevel.scala 13:24]
  wire [31:0] axi_xbar_io_in_wdata; // @[TopLevel.scala 13:24]
  wire [3:0] axi_xbar_io_in_wstrb; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_wvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_wready; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_bvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_in_bready; // @[TopLevel.scala 13:24]
  wire [31:0] axi_xbar_io_out_0_araddr; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_arvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_arready; // @[TopLevel.scala 13:24]
  wire [31:0] axi_xbar_io_out_0_rdata; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_rvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_rready; // @[TopLevel.scala 13:24]
  wire [31:0] axi_xbar_io_out_0_awaddr; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_awvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_awready; // @[TopLevel.scala 13:24]
  wire [31:0] axi_xbar_io_out_0_wdata; // @[TopLevel.scala 13:24]
  wire [3:0] axi_xbar_io_out_0_wstrb; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_wvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_wready; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_bvalid; // @[TopLevel.scala 13:24]
  wire  axi_xbar_io_out_0_bready; // @[TopLevel.scala 13:24]
  wire  sram_clock; // @[TopLevel.scala 14:20]
  wire  sram_reset; // @[TopLevel.scala 14:20]
  wire [31:0] sram_io_araddr; // @[TopLevel.scala 14:20]
  wire  sram_io_arvalid; // @[TopLevel.scala 14:20]
  wire  sram_io_arready; // @[TopLevel.scala 14:20]
  wire [31:0] sram_io_rdata; // @[TopLevel.scala 14:20]
  wire  sram_io_rvalid; // @[TopLevel.scala 14:20]
  wire  sram_io_rready; // @[TopLevel.scala 14:20]
  wire [31:0] sram_io_awaddr; // @[TopLevel.scala 14:20]
  wire  sram_io_awvalid; // @[TopLevel.scala 14:20]
  wire  sram_io_awready; // @[TopLevel.scala 14:20]
  wire [31:0] sram_io_wdata; // @[TopLevel.scala 14:20]
  wire [3:0] sram_io_wstrb; // @[TopLevel.scala 14:20]
  wire  sram_io_wvalid; // @[TopLevel.scala 14:20]
  wire  sram_io_wready; // @[TopLevel.scala 14:20]
  wire  sram_io_bvalid; // @[TopLevel.scala 14:20]
  wire  sram_io_bready; // @[TopLevel.scala 14:20]
  wire  ifu_clock; // @[TopLevel.scala 15:19]
  wire  ifu_reset; // @[TopLevel.scala 15:19]
  wire  ifu_io_in_ready; // @[TopLevel.scala 15:19]
  wire  ifu_io_in_valid; // @[TopLevel.scala 15:19]
  wire [31:0] ifu_io_in_bits_pc; // @[TopLevel.scala 15:19]
  wire  ifu_io_out_ready; // @[TopLevel.scala 15:19]
  wire  ifu_io_out_valid; // @[TopLevel.scala 15:19]
  wire [31:0] ifu_io_out_bits_inst; // @[TopLevel.scala 15:19]
  wire [31:0] ifu_io_out_bits_pc; // @[TopLevel.scala 15:19]
  wire  ifu_io_test_imem_en; // @[TopLevel.scala 15:19]
  wire [31:0] ifu_io_test_pc; // @[TopLevel.scala 15:19]
  wire [31:0] ifu_io_imem_araddr; // @[TopLevel.scala 15:19]
  wire  ifu_io_imem_arvalid; // @[TopLevel.scala 15:19]
  wire  ifu_io_imem_arready; // @[TopLevel.scala 15:19]
  wire [31:0] ifu_io_imem_rdata; // @[TopLevel.scala 15:19]
  wire  ifu_io_imem_rvalid; // @[TopLevel.scala 15:19]
  wire  ifu_io_imem_rready; // @[TopLevel.scala 15:19]
  wire  idu_clock; // @[TopLevel.scala 16:19]
  wire  idu_reset; // @[TopLevel.scala 16:19]
  wire  idu_io_in_ready; // @[TopLevel.scala 16:19]
  wire  idu_io_in_valid; // @[TopLevel.scala 16:19]
  wire [31:0] idu_io_in_bits_inst; // @[TopLevel.scala 16:19]
  wire [31:0] idu_io_in_bits_pc; // @[TopLevel.scala 16:19]
  wire  idu_io_out_ready; // @[TopLevel.scala 16:19]
  wire  idu_io_out_valid; // @[TopLevel.scala 16:19]
  wire [2:0] idu_io_out_bits_control_signal_PC_sel; // @[TopLevel.scala 16:19]
  wire [1:0] idu_io_out_bits_control_signal_A_sel; // @[TopLevel.scala 16:19]
  wire [1:0] idu_io_out_bits_control_signal_B_sel; // @[TopLevel.scala 16:19]
  wire [3:0] idu_io_out_bits_control_signal_WB_sel; // @[TopLevel.scala 16:19]
  wire [5:0] idu_io_out_bits_control_signal_ALU_sel; // @[TopLevel.scala 16:19]
  wire [1:0] idu_io_out_bits_control_signal_csr_sel; // @[TopLevel.scala 16:19]
  wire [7:0] idu_io_out_bits_control_signal_ebreak_en; // @[TopLevel.scala 16:19]
  wire [7:0] idu_io_out_bits_control_signal_ebreak_code; // @[TopLevel.scala 16:19]
  wire  idu_io_out_bits_control_signal_dmem_read_en; // @[TopLevel.scala 16:19]
  wire  idu_io_out_bits_control_signal_dmem_write_en; // @[TopLevel.scala 16:19]
  wire [2:0] idu_io_out_bits_control_signal_dmem_write_type; // @[TopLevel.scala 16:19]
  wire [31:0] idu_io_out_bits_imm; // @[TopLevel.scala 16:19]
  wire [31:0] idu_io_out_bits_pc; // @[TopLevel.scala 16:19]
  wire [31:0] idu_io_out_bits_inst; // @[TopLevel.scala 16:19]
  wire  exu_clock; // @[TopLevel.scala 17:19]
  wire  exu_reset; // @[TopLevel.scala 17:19]
  wire  exu_io_in_ready; // @[TopLevel.scala 17:19]
  wire  exu_io_in_valid; // @[TopLevel.scala 17:19]
  wire [2:0] exu_io_in_bits_control_signal_PC_sel; // @[TopLevel.scala 17:19]
  wire [1:0] exu_io_in_bits_control_signal_A_sel; // @[TopLevel.scala 17:19]
  wire [1:0] exu_io_in_bits_control_signal_B_sel; // @[TopLevel.scala 17:19]
  wire [3:0] exu_io_in_bits_control_signal_WB_sel; // @[TopLevel.scala 17:19]
  wire [5:0] exu_io_in_bits_control_signal_ALU_sel; // @[TopLevel.scala 17:19]
  wire [1:0] exu_io_in_bits_control_signal_csr_sel; // @[TopLevel.scala 17:19]
  wire [7:0] exu_io_in_bits_control_signal_ebreak_en; // @[TopLevel.scala 17:19]
  wire [7:0] exu_io_in_bits_control_signal_ebreak_code; // @[TopLevel.scala 17:19]
  wire  exu_io_in_bits_control_signal_dmem_read_en; // @[TopLevel.scala 17:19]
  wire  exu_io_in_bits_control_signal_dmem_write_en; // @[TopLevel.scala 17:19]
  wire [2:0] exu_io_in_bits_control_signal_dmem_write_type; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_in_bits_imm; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_in_bits_pc; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_in_bits_inst; // @[TopLevel.scala 17:19]
  wire  exu_io_out_ready; // @[TopLevel.scala 17:19]
  wire  exu_io_out_valid; // @[TopLevel.scala 17:19]
  wire [2:0] exu_io_out_bits_control_signal_PC_sel; // @[TopLevel.scala 17:19]
  wire [3:0] exu_io_out_bits_control_signal_WB_sel; // @[TopLevel.scala 17:19]
  wire  exu_io_out_bits_control_signal_dmem_read_en; // @[TopLevel.scala 17:19]
  wire  exu_io_out_bits_control_signal_dmem_write_en; // @[TopLevel.scala 17:19]
  wire [2:0] exu_io_out_bits_control_signal_dmem_write_type; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_out_bits_imm; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_out_bits_pc; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_out_bits_inst; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_out_bits_alu_result; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_out_bits_csr_pc_result; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_out_bits_csr_rdata; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_out_bits_reg2_data; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_0; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_1; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_2; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_3; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_4; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_5; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_6; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_7; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_8; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_9; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_10; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_11; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_12; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_13; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_14; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_15; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_16; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_17; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_18; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_19; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_20; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_21; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_22; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_23; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_24; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_25; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_26; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_27; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_28; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_29; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_30; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_regs_31; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_csr_0; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_csr_1; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_csr_2; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_test_csr_3; // @[TopLevel.scala 17:19]
  wire  exu_io_wb_en; // @[TopLevel.scala 17:19]
  wire [31:0] exu_io_wb_data; // @[TopLevel.scala 17:19]
  wire [4:0] exu_io_wb_addr; // @[TopLevel.scala 17:19]
  wire  wbu_clock; // @[TopLevel.scala 18:19]
  wire  wbu_reset; // @[TopLevel.scala 18:19]
  wire  wbu_io_in_ready; // @[TopLevel.scala 18:19]
  wire  wbu_io_in_valid; // @[TopLevel.scala 18:19]
  wire [2:0] wbu_io_in_bits_control_signal_PC_sel; // @[TopLevel.scala 18:19]
  wire [3:0] wbu_io_in_bits_control_signal_WB_sel; // @[TopLevel.scala 18:19]
  wire  wbu_io_in_bits_control_signal_dmem_read_en; // @[TopLevel.scala 18:19]
  wire  wbu_io_in_bits_control_signal_dmem_write_en; // @[TopLevel.scala 18:19]
  wire [2:0] wbu_io_in_bits_control_signal_dmem_write_type; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_in_bits_imm; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_in_bits_pc; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_in_bits_inst; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_in_bits_alu_result; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_in_bits_csr_pc_result; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_in_bits_csr_rdata; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_in_bits_reg2_data; // @[TopLevel.scala 18:19]
  wire  wbu_io_out_ready; // @[TopLevel.scala 18:19]
  wire  wbu_io_out_valid; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_out_bits_pc; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_wb_data; // @[TopLevel.scala 18:19]
  wire [4:0] wbu_io_wb_addr; // @[TopLevel.scala 18:19]
  wire  wbu_io_wb_en; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_dmem_araddr; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_arvalid; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_arready; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_dmem_rdata; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_rvalid; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_rready; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_dmem_awaddr; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_awvalid; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_awready; // @[TopLevel.scala 18:19]
  wire [31:0] wbu_io_dmem_wdata; // @[TopLevel.scala 18:19]
  wire [3:0] wbu_io_dmem_wstrb; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_wvalid; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_wready; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_bvalid; // @[TopLevel.scala 18:19]
  wire  wbu_io_dmem_bready; // @[TopLevel.scala 18:19]
  reg  start_tick; // @[TopLevel.scala 20:27]
  AxiArbiter sram_arbiter ( // @[TopLevel.scala 12:28]
    .clock(sram_arbiter_clock),
    .reset(sram_arbiter_reset),
    .io_in1_araddr(sram_arbiter_io_in1_araddr),
    .io_in1_arvalid(sram_arbiter_io_in1_arvalid),
    .io_in1_arready(sram_arbiter_io_in1_arready),
    .io_in1_rdata(sram_arbiter_io_in1_rdata),
    .io_in1_rvalid(sram_arbiter_io_in1_rvalid),
    .io_in2_araddr(sram_arbiter_io_in2_araddr),
    .io_in2_arvalid(sram_arbiter_io_in2_arvalid),
    .io_in2_arready(sram_arbiter_io_in2_arready),
    .io_in2_rdata(sram_arbiter_io_in2_rdata),
    .io_in2_rvalid(sram_arbiter_io_in2_rvalid),
    .io_in2_awaddr(sram_arbiter_io_in2_awaddr),
    .io_in2_awvalid(sram_arbiter_io_in2_awvalid),
    .io_in2_awready(sram_arbiter_io_in2_awready),
    .io_in2_wdata(sram_arbiter_io_in2_wdata),
    .io_in2_wstrb(sram_arbiter_io_in2_wstrb),
    .io_in2_wvalid(sram_arbiter_io_in2_wvalid),
    .io_in2_wready(sram_arbiter_io_in2_wready),
    .io_in2_bvalid(sram_arbiter_io_in2_bvalid),
    .io_in2_bready(sram_arbiter_io_in2_bready),
    .io_out_araddr(sram_arbiter_io_out_araddr),
    .io_out_arvalid(sram_arbiter_io_out_arvalid),
    .io_out_arready(sram_arbiter_io_out_arready),
    .io_out_rdata(sram_arbiter_io_out_rdata),
    .io_out_rvalid(sram_arbiter_io_out_rvalid),
    .io_out_rready(sram_arbiter_io_out_rready),
    .io_out_awaddr(sram_arbiter_io_out_awaddr),
    .io_out_awvalid(sram_arbiter_io_out_awvalid),
    .io_out_awready(sram_arbiter_io_out_awready),
    .io_out_wdata(sram_arbiter_io_out_wdata),
    .io_out_wstrb(sram_arbiter_io_out_wstrb),
    .io_out_wvalid(sram_arbiter_io_out_wvalid),
    .io_out_wready(sram_arbiter_io_out_wready),
    .io_out_bvalid(sram_arbiter_io_out_bvalid),
    .io_out_bready(sram_arbiter_io_out_bready)
  );
  AxiXbar axi_xbar ( // @[TopLevel.scala 13:24]
    .clock(axi_xbar_clock),
    .reset(axi_xbar_reset),
    .io_in_araddr(axi_xbar_io_in_araddr),
    .io_in_arvalid(axi_xbar_io_in_arvalid),
    .io_in_arready(axi_xbar_io_in_arready),
    .io_in_rdata(axi_xbar_io_in_rdata),
    .io_in_rvalid(axi_xbar_io_in_rvalid),
    .io_in_rready(axi_xbar_io_in_rready),
    .io_in_awaddr(axi_xbar_io_in_awaddr),
    .io_in_awvalid(axi_xbar_io_in_awvalid),
    .io_in_awready(axi_xbar_io_in_awready),
    .io_in_wdata(axi_xbar_io_in_wdata),
    .io_in_wstrb(axi_xbar_io_in_wstrb),
    .io_in_wvalid(axi_xbar_io_in_wvalid),
    .io_in_wready(axi_xbar_io_in_wready),
    .io_in_bvalid(axi_xbar_io_in_bvalid),
    .io_in_bready(axi_xbar_io_in_bready),
    .io_out_0_araddr(axi_xbar_io_out_0_araddr),
    .io_out_0_arvalid(axi_xbar_io_out_0_arvalid),
    .io_out_0_arready(axi_xbar_io_out_0_arready),
    .io_out_0_rdata(axi_xbar_io_out_0_rdata),
    .io_out_0_rvalid(axi_xbar_io_out_0_rvalid),
    .io_out_0_rready(axi_xbar_io_out_0_rready),
    .io_out_0_awaddr(axi_xbar_io_out_0_awaddr),
    .io_out_0_awvalid(axi_xbar_io_out_0_awvalid),
    .io_out_0_awready(axi_xbar_io_out_0_awready),
    .io_out_0_wdata(axi_xbar_io_out_0_wdata),
    .io_out_0_wstrb(axi_xbar_io_out_0_wstrb),
    .io_out_0_wvalid(axi_xbar_io_out_0_wvalid),
    .io_out_0_wready(axi_xbar_io_out_0_wready),
    .io_out_0_bvalid(axi_xbar_io_out_0_bvalid),
    .io_out_0_bready(axi_xbar_io_out_0_bready)
  );
  SRAM sram ( // @[TopLevel.scala 14:20]
    .clock(sram_clock),
    .reset(sram_reset),
    .io_araddr(sram_io_araddr),
    .io_arvalid(sram_io_arvalid),
    .io_arready(sram_io_arready),
    .io_rdata(sram_io_rdata),
    .io_rvalid(sram_io_rvalid),
    .io_rready(sram_io_rready),
    .io_awaddr(sram_io_awaddr),
    .io_awvalid(sram_io_awvalid),
    .io_awready(sram_io_awready),
    .io_wdata(sram_io_wdata),
    .io_wstrb(sram_io_wstrb),
    .io_wvalid(sram_io_wvalid),
    .io_wready(sram_io_wready),
    .io_bvalid(sram_io_bvalid),
    .io_bready(sram_io_bready)
  );
  IFU ifu ( // @[TopLevel.scala 15:19]
    .clock(ifu_clock),
    .reset(ifu_reset),
    .io_in_ready(ifu_io_in_ready),
    .io_in_valid(ifu_io_in_valid),
    .io_in_bits_pc(ifu_io_in_bits_pc),
    .io_out_ready(ifu_io_out_ready),
    .io_out_valid(ifu_io_out_valid),
    .io_out_bits_inst(ifu_io_out_bits_inst),
    .io_out_bits_pc(ifu_io_out_bits_pc),
    .io_test_imem_en(ifu_io_test_imem_en),
    .io_test_pc(ifu_io_test_pc),
    .io_imem_araddr(ifu_io_imem_araddr),
    .io_imem_arvalid(ifu_io_imem_arvalid),
    .io_imem_arready(ifu_io_imem_arready),
    .io_imem_rdata(ifu_io_imem_rdata),
    .io_imem_rvalid(ifu_io_imem_rvalid),
    .io_imem_rready(ifu_io_imem_rready)
  );
  IDU idu ( // @[TopLevel.scala 16:19]
    .clock(idu_clock),
    .reset(idu_reset),
    .io_in_ready(idu_io_in_ready),
    .io_in_valid(idu_io_in_valid),
    .io_in_bits_inst(idu_io_in_bits_inst),
    .io_in_bits_pc(idu_io_in_bits_pc),
    .io_out_ready(idu_io_out_ready),
    .io_out_valid(idu_io_out_valid),
    .io_out_bits_control_signal_PC_sel(idu_io_out_bits_control_signal_PC_sel),
    .io_out_bits_control_signal_A_sel(idu_io_out_bits_control_signal_A_sel),
    .io_out_bits_control_signal_B_sel(idu_io_out_bits_control_signal_B_sel),
    .io_out_bits_control_signal_WB_sel(idu_io_out_bits_control_signal_WB_sel),
    .io_out_bits_control_signal_ALU_sel(idu_io_out_bits_control_signal_ALU_sel),
    .io_out_bits_control_signal_csr_sel(idu_io_out_bits_control_signal_csr_sel),
    .io_out_bits_control_signal_ebreak_en(idu_io_out_bits_control_signal_ebreak_en),
    .io_out_bits_control_signal_ebreak_code(idu_io_out_bits_control_signal_ebreak_code),
    .io_out_bits_control_signal_dmem_read_en(idu_io_out_bits_control_signal_dmem_read_en),
    .io_out_bits_control_signal_dmem_write_en(idu_io_out_bits_control_signal_dmem_write_en),
    .io_out_bits_control_signal_dmem_write_type(idu_io_out_bits_control_signal_dmem_write_type),
    .io_out_bits_imm(idu_io_out_bits_imm),
    .io_out_bits_pc(idu_io_out_bits_pc),
    .io_out_bits_inst(idu_io_out_bits_inst)
  );
  EXU exu ( // @[TopLevel.scala 17:19]
    .clock(exu_clock),
    .reset(exu_reset),
    .io_in_ready(exu_io_in_ready),
    .io_in_valid(exu_io_in_valid),
    .io_in_bits_control_signal_PC_sel(exu_io_in_bits_control_signal_PC_sel),
    .io_in_bits_control_signal_A_sel(exu_io_in_bits_control_signal_A_sel),
    .io_in_bits_control_signal_B_sel(exu_io_in_bits_control_signal_B_sel),
    .io_in_bits_control_signal_WB_sel(exu_io_in_bits_control_signal_WB_sel),
    .io_in_bits_control_signal_ALU_sel(exu_io_in_bits_control_signal_ALU_sel),
    .io_in_bits_control_signal_csr_sel(exu_io_in_bits_control_signal_csr_sel),
    .io_in_bits_control_signal_ebreak_en(exu_io_in_bits_control_signal_ebreak_en),
    .io_in_bits_control_signal_ebreak_code(exu_io_in_bits_control_signal_ebreak_code),
    .io_in_bits_control_signal_dmem_read_en(exu_io_in_bits_control_signal_dmem_read_en),
    .io_in_bits_control_signal_dmem_write_en(exu_io_in_bits_control_signal_dmem_write_en),
    .io_in_bits_control_signal_dmem_write_type(exu_io_in_bits_control_signal_dmem_write_type),
    .io_in_bits_imm(exu_io_in_bits_imm),
    .io_in_bits_pc(exu_io_in_bits_pc),
    .io_in_bits_inst(exu_io_in_bits_inst),
    .io_out_ready(exu_io_out_ready),
    .io_out_valid(exu_io_out_valid),
    .io_out_bits_control_signal_PC_sel(exu_io_out_bits_control_signal_PC_sel),
    .io_out_bits_control_signal_WB_sel(exu_io_out_bits_control_signal_WB_sel),
    .io_out_bits_control_signal_dmem_read_en(exu_io_out_bits_control_signal_dmem_read_en),
    .io_out_bits_control_signal_dmem_write_en(exu_io_out_bits_control_signal_dmem_write_en),
    .io_out_bits_control_signal_dmem_write_type(exu_io_out_bits_control_signal_dmem_write_type),
    .io_out_bits_imm(exu_io_out_bits_imm),
    .io_out_bits_pc(exu_io_out_bits_pc),
    .io_out_bits_inst(exu_io_out_bits_inst),
    .io_out_bits_alu_result(exu_io_out_bits_alu_result),
    .io_out_bits_csr_pc_result(exu_io_out_bits_csr_pc_result),
    .io_out_bits_csr_rdata(exu_io_out_bits_csr_rdata),
    .io_out_bits_reg2_data(exu_io_out_bits_reg2_data),
    .io_test_regs_0(exu_io_test_regs_0),
    .io_test_regs_1(exu_io_test_regs_1),
    .io_test_regs_2(exu_io_test_regs_2),
    .io_test_regs_3(exu_io_test_regs_3),
    .io_test_regs_4(exu_io_test_regs_4),
    .io_test_regs_5(exu_io_test_regs_5),
    .io_test_regs_6(exu_io_test_regs_6),
    .io_test_regs_7(exu_io_test_regs_7),
    .io_test_regs_8(exu_io_test_regs_8),
    .io_test_regs_9(exu_io_test_regs_9),
    .io_test_regs_10(exu_io_test_regs_10),
    .io_test_regs_11(exu_io_test_regs_11),
    .io_test_regs_12(exu_io_test_regs_12),
    .io_test_regs_13(exu_io_test_regs_13),
    .io_test_regs_14(exu_io_test_regs_14),
    .io_test_regs_15(exu_io_test_regs_15),
    .io_test_regs_16(exu_io_test_regs_16),
    .io_test_regs_17(exu_io_test_regs_17),
    .io_test_regs_18(exu_io_test_regs_18),
    .io_test_regs_19(exu_io_test_regs_19),
    .io_test_regs_20(exu_io_test_regs_20),
    .io_test_regs_21(exu_io_test_regs_21),
    .io_test_regs_22(exu_io_test_regs_22),
    .io_test_regs_23(exu_io_test_regs_23),
    .io_test_regs_24(exu_io_test_regs_24),
    .io_test_regs_25(exu_io_test_regs_25),
    .io_test_regs_26(exu_io_test_regs_26),
    .io_test_regs_27(exu_io_test_regs_27),
    .io_test_regs_28(exu_io_test_regs_28),
    .io_test_regs_29(exu_io_test_regs_29),
    .io_test_regs_30(exu_io_test_regs_30),
    .io_test_regs_31(exu_io_test_regs_31),
    .io_test_csr_0(exu_io_test_csr_0),
    .io_test_csr_1(exu_io_test_csr_1),
    .io_test_csr_2(exu_io_test_csr_2),
    .io_test_csr_3(exu_io_test_csr_3),
    .io_wb_en(exu_io_wb_en),
    .io_wb_data(exu_io_wb_data),
    .io_wb_addr(exu_io_wb_addr)
  );
  WBU wbu ( // @[TopLevel.scala 18:19]
    .clock(wbu_clock),
    .reset(wbu_reset),
    .io_in_ready(wbu_io_in_ready),
    .io_in_valid(wbu_io_in_valid),
    .io_in_bits_control_signal_PC_sel(wbu_io_in_bits_control_signal_PC_sel),
    .io_in_bits_control_signal_WB_sel(wbu_io_in_bits_control_signal_WB_sel),
    .io_in_bits_control_signal_dmem_read_en(wbu_io_in_bits_control_signal_dmem_read_en),
    .io_in_bits_control_signal_dmem_write_en(wbu_io_in_bits_control_signal_dmem_write_en),
    .io_in_bits_control_signal_dmem_write_type(wbu_io_in_bits_control_signal_dmem_write_type),
    .io_in_bits_imm(wbu_io_in_bits_imm),
    .io_in_bits_pc(wbu_io_in_bits_pc),
    .io_in_bits_inst(wbu_io_in_bits_inst),
    .io_in_bits_alu_result(wbu_io_in_bits_alu_result),
    .io_in_bits_csr_pc_result(wbu_io_in_bits_csr_pc_result),
    .io_in_bits_csr_rdata(wbu_io_in_bits_csr_rdata),
    .io_in_bits_reg2_data(wbu_io_in_bits_reg2_data),
    .io_out_ready(wbu_io_out_ready),
    .io_out_valid(wbu_io_out_valid),
    .io_out_bits_pc(wbu_io_out_bits_pc),
    .io_wb_data(wbu_io_wb_data),
    .io_wb_addr(wbu_io_wb_addr),
    .io_wb_en(wbu_io_wb_en),
    .io_dmem_araddr(wbu_io_dmem_araddr),
    .io_dmem_arvalid(wbu_io_dmem_arvalid),
    .io_dmem_arready(wbu_io_dmem_arready),
    .io_dmem_rdata(wbu_io_dmem_rdata),
    .io_dmem_rvalid(wbu_io_dmem_rvalid),
    .io_dmem_rready(wbu_io_dmem_rready),
    .io_dmem_awaddr(wbu_io_dmem_awaddr),
    .io_dmem_awvalid(wbu_io_dmem_awvalid),
    .io_dmem_awready(wbu_io_dmem_awready),
    .io_dmem_wdata(wbu_io_dmem_wdata),
    .io_dmem_wstrb(wbu_io_dmem_wstrb),
    .io_dmem_wvalid(wbu_io_dmem_wvalid),
    .io_dmem_wready(wbu_io_dmem_wready),
    .io_dmem_bvalid(wbu_io_dmem_bvalid),
    .io_dmem_bready(wbu_io_dmem_bready)
  );
  assign io_test_pc = ifu_io_test_pc; // @[TopLevel.scala 43:14]
  assign io_test_regs_0 = exu_io_test_regs_0; // @[TopLevel.scala 41:16]
  assign io_test_regs_1 = exu_io_test_regs_1; // @[TopLevel.scala 41:16]
  assign io_test_regs_2 = exu_io_test_regs_2; // @[TopLevel.scala 41:16]
  assign io_test_regs_3 = exu_io_test_regs_3; // @[TopLevel.scala 41:16]
  assign io_test_regs_4 = exu_io_test_regs_4; // @[TopLevel.scala 41:16]
  assign io_test_regs_5 = exu_io_test_regs_5; // @[TopLevel.scala 41:16]
  assign io_test_regs_6 = exu_io_test_regs_6; // @[TopLevel.scala 41:16]
  assign io_test_regs_7 = exu_io_test_regs_7; // @[TopLevel.scala 41:16]
  assign io_test_regs_8 = exu_io_test_regs_8; // @[TopLevel.scala 41:16]
  assign io_test_regs_9 = exu_io_test_regs_9; // @[TopLevel.scala 41:16]
  assign io_test_regs_10 = exu_io_test_regs_10; // @[TopLevel.scala 41:16]
  assign io_test_regs_11 = exu_io_test_regs_11; // @[TopLevel.scala 41:16]
  assign io_test_regs_12 = exu_io_test_regs_12; // @[TopLevel.scala 41:16]
  assign io_test_regs_13 = exu_io_test_regs_13; // @[TopLevel.scala 41:16]
  assign io_test_regs_14 = exu_io_test_regs_14; // @[TopLevel.scala 41:16]
  assign io_test_regs_15 = exu_io_test_regs_15; // @[TopLevel.scala 41:16]
  assign io_test_regs_16 = exu_io_test_regs_16; // @[TopLevel.scala 41:16]
  assign io_test_regs_17 = exu_io_test_regs_17; // @[TopLevel.scala 41:16]
  assign io_test_regs_18 = exu_io_test_regs_18; // @[TopLevel.scala 41:16]
  assign io_test_regs_19 = exu_io_test_regs_19; // @[TopLevel.scala 41:16]
  assign io_test_regs_20 = exu_io_test_regs_20; // @[TopLevel.scala 41:16]
  assign io_test_regs_21 = exu_io_test_regs_21; // @[TopLevel.scala 41:16]
  assign io_test_regs_22 = exu_io_test_regs_22; // @[TopLevel.scala 41:16]
  assign io_test_regs_23 = exu_io_test_regs_23; // @[TopLevel.scala 41:16]
  assign io_test_regs_24 = exu_io_test_regs_24; // @[TopLevel.scala 41:16]
  assign io_test_regs_25 = exu_io_test_regs_25; // @[TopLevel.scala 41:16]
  assign io_test_regs_26 = exu_io_test_regs_26; // @[TopLevel.scala 41:16]
  assign io_test_regs_27 = exu_io_test_regs_27; // @[TopLevel.scala 41:16]
  assign io_test_regs_28 = exu_io_test_regs_28; // @[TopLevel.scala 41:16]
  assign io_test_regs_29 = exu_io_test_regs_29; // @[TopLevel.scala 41:16]
  assign io_test_regs_30 = exu_io_test_regs_30; // @[TopLevel.scala 41:16]
  assign io_test_regs_31 = exu_io_test_regs_31; // @[TopLevel.scala 41:16]
  assign io_test_csr_0 = exu_io_test_csr_0; // @[TopLevel.scala 42:15]
  assign io_test_csr_1 = exu_io_test_csr_1; // @[TopLevel.scala 42:15]
  assign io_test_csr_2 = exu_io_test_csr_2; // @[TopLevel.scala 42:15]
  assign io_test_csr_3 = exu_io_test_csr_3; // @[TopLevel.scala 42:15]
  assign io_test_imem_en = ifu_io_test_imem_en; // @[TopLevel.scala 40:19]
  assign sram_arbiter_clock = clock;
  assign sram_arbiter_reset = reset;
  assign sram_arbiter_io_in1_araddr = ifu_io_imem_araddr; // @[TopLevel.scala 37:23]
  assign sram_arbiter_io_in1_arvalid = ifu_io_imem_arvalid; // @[TopLevel.scala 37:23]
  assign sram_arbiter_io_in2_araddr = wbu_io_dmem_araddr; // @[TopLevel.scala 38:23]
  assign sram_arbiter_io_in2_arvalid = wbu_io_dmem_arvalid; // @[TopLevel.scala 38:23]
  assign sram_arbiter_io_in2_awaddr = wbu_io_dmem_awaddr; // @[TopLevel.scala 38:23]
  assign sram_arbiter_io_in2_awvalid = wbu_io_dmem_awvalid; // @[TopLevel.scala 38:23]
  assign sram_arbiter_io_in2_wdata = wbu_io_dmem_wdata; // @[TopLevel.scala 38:23]
  assign sram_arbiter_io_in2_wstrb = wbu_io_dmem_wstrb; // @[TopLevel.scala 38:23]
  assign sram_arbiter_io_in2_wvalid = wbu_io_dmem_wvalid; // @[TopLevel.scala 38:23]
  assign sram_arbiter_io_in2_bready = wbu_io_dmem_bready; // @[TopLevel.scala 38:23]
  assign sram_arbiter_io_out_arready = axi_xbar_io_in_arready; // @[TopLevel.scala 35:18]
  assign sram_arbiter_io_out_rdata = axi_xbar_io_in_rdata; // @[TopLevel.scala 35:18]
  assign sram_arbiter_io_out_rvalid = axi_xbar_io_in_rvalid; // @[TopLevel.scala 35:18]
  assign sram_arbiter_io_out_awready = axi_xbar_io_in_awready; // @[TopLevel.scala 35:18]
  assign sram_arbiter_io_out_wready = axi_xbar_io_in_wready; // @[TopLevel.scala 35:18]
  assign sram_arbiter_io_out_bvalid = axi_xbar_io_in_bvalid; // @[TopLevel.scala 35:18]
  assign axi_xbar_clock = clock;
  assign axi_xbar_reset = reset;
  assign axi_xbar_io_in_araddr = sram_arbiter_io_out_araddr; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_in_arvalid = sram_arbiter_io_out_arvalid; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_in_rready = sram_arbiter_io_out_rready; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_in_awaddr = sram_arbiter_io_out_awaddr; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_in_awvalid = sram_arbiter_io_out_awvalid; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_in_wdata = sram_arbiter_io_out_wdata; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_in_wstrb = sram_arbiter_io_out_wstrb; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_in_wvalid = sram_arbiter_io_out_wvalid; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_in_bready = sram_arbiter_io_out_bready; // @[TopLevel.scala 35:18]
  assign axi_xbar_io_out_0_arready = sram_io_arready; // @[TopLevel.scala 36:11]
  assign axi_xbar_io_out_0_rdata = sram_io_rdata; // @[TopLevel.scala 36:11]
  assign axi_xbar_io_out_0_rvalid = sram_io_rvalid; // @[TopLevel.scala 36:11]
  assign axi_xbar_io_out_0_awready = sram_io_awready; // @[TopLevel.scala 36:11]
  assign axi_xbar_io_out_0_wready = sram_io_wready; // @[TopLevel.scala 36:11]
  assign axi_xbar_io_out_0_bvalid = sram_io_bvalid; // @[TopLevel.scala 36:11]
  assign sram_clock = clock;
  assign sram_reset = reset;
  assign sram_io_araddr = axi_xbar_io_out_0_araddr; // @[TopLevel.scala 36:11]
  assign sram_io_arvalid = axi_xbar_io_out_0_arvalid; // @[TopLevel.scala 36:11]
  assign sram_io_rready = axi_xbar_io_out_0_rready; // @[TopLevel.scala 36:11]
  assign sram_io_awaddr = axi_xbar_io_out_0_awaddr; // @[TopLevel.scala 36:11]
  assign sram_io_awvalid = axi_xbar_io_out_0_awvalid; // @[TopLevel.scala 36:11]
  assign sram_io_wdata = axi_xbar_io_out_0_wdata; // @[TopLevel.scala 36:11]
  assign sram_io_wstrb = axi_xbar_io_out_0_wstrb; // @[TopLevel.scala 36:11]
  assign sram_io_wvalid = axi_xbar_io_out_0_wvalid; // @[TopLevel.scala 36:11]
  assign sram_io_bready = axi_xbar_io_out_0_bready; // @[TopLevel.scala 36:11]
  assign ifu_clock = clock;
  assign ifu_reset = reset;
  assign ifu_io_in_valid = start_tick | wbu_io_out_valid; // @[TopLevel.scala 23:25]
  assign ifu_io_in_bits_pc = start_tick ? 32'h80000000 : wbu_io_out_bits_pc; // @[TopLevel.scala 24:27]
  assign ifu_io_out_ready = idu_io_in_ready; // @[TopLevel.scala 27:14]
  assign ifu_io_imem_arready = sram_arbiter_io_in1_arready; // @[TopLevel.scala 37:23]
  assign ifu_io_imem_rdata = sram_arbiter_io_in1_rdata; // @[TopLevel.scala 37:23]
  assign ifu_io_imem_rvalid = sram_arbiter_io_in1_rvalid; // @[TopLevel.scala 37:23]
  assign idu_clock = clock;
  assign idu_reset = reset;
  assign idu_io_in_valid = ifu_io_out_valid; // @[TopLevel.scala 27:14]
  assign idu_io_in_bits_inst = ifu_io_out_bits_inst; // @[TopLevel.scala 27:14]
  assign idu_io_in_bits_pc = ifu_io_out_bits_pc; // @[TopLevel.scala 27:14]
  assign idu_io_out_ready = exu_io_in_ready; // @[TopLevel.scala 28:13]
  assign exu_clock = clock;
  assign exu_reset = reset;
  assign exu_io_in_valid = idu_io_out_valid; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_PC_sel = idu_io_out_bits_control_signal_PC_sel; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_A_sel = idu_io_out_bits_control_signal_A_sel; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_B_sel = idu_io_out_bits_control_signal_B_sel; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_WB_sel = idu_io_out_bits_control_signal_WB_sel; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_ALU_sel = idu_io_out_bits_control_signal_ALU_sel; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_csr_sel = idu_io_out_bits_control_signal_csr_sel; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_ebreak_en = idu_io_out_bits_control_signal_ebreak_en; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_ebreak_code = idu_io_out_bits_control_signal_ebreak_code; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_dmem_read_en = idu_io_out_bits_control_signal_dmem_read_en; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_dmem_write_en = idu_io_out_bits_control_signal_dmem_write_en; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_control_signal_dmem_write_type = idu_io_out_bits_control_signal_dmem_write_type; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_imm = idu_io_out_bits_imm; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_pc = idu_io_out_bits_pc; // @[TopLevel.scala 28:13]
  assign exu_io_in_bits_inst = idu_io_out_bits_inst; // @[TopLevel.scala 28:13]
  assign exu_io_out_ready = wbu_io_in_ready; // @[TopLevel.scala 29:13]
  assign exu_io_wb_en = wbu_io_wb_en; // @[TopLevel.scala 33:16]
  assign exu_io_wb_data = wbu_io_wb_data; // @[TopLevel.scala 31:18]
  assign exu_io_wb_addr = wbu_io_wb_addr; // @[TopLevel.scala 32:18]
  assign wbu_clock = clock;
  assign wbu_reset = reset;
  assign wbu_io_in_valid = exu_io_out_valid; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_control_signal_PC_sel = exu_io_out_bits_control_signal_PC_sel; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_control_signal_WB_sel = exu_io_out_bits_control_signal_WB_sel; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_control_signal_dmem_read_en = exu_io_out_bits_control_signal_dmem_read_en; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_control_signal_dmem_write_en = exu_io_out_bits_control_signal_dmem_write_en; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_control_signal_dmem_write_type = exu_io_out_bits_control_signal_dmem_write_type; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_imm = exu_io_out_bits_imm; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_pc = exu_io_out_bits_pc; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_inst = exu_io_out_bits_inst; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_alu_result = exu_io_out_bits_alu_result; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_csr_pc_result = exu_io_out_bits_csr_pc_result; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_csr_rdata = exu_io_out_bits_csr_rdata; // @[TopLevel.scala 29:13]
  assign wbu_io_in_bits_reg2_data = exu_io_out_bits_reg2_data; // @[TopLevel.scala 29:13]
  assign wbu_io_out_ready = ifu_io_in_ready; // @[TopLevel.scala 25:20]
  assign wbu_io_dmem_arready = sram_arbiter_io_in2_arready; // @[TopLevel.scala 38:23]
  assign wbu_io_dmem_rdata = sram_arbiter_io_in2_rdata; // @[TopLevel.scala 38:23]
  assign wbu_io_dmem_rvalid = sram_arbiter_io_in2_rvalid; // @[TopLevel.scala 38:23]
  assign wbu_io_dmem_awready = sram_arbiter_io_in2_awready; // @[TopLevel.scala 38:23]
  assign wbu_io_dmem_wready = sram_arbiter_io_in2_wready; // @[TopLevel.scala 38:23]
  assign wbu_io_dmem_bvalid = sram_arbiter_io_in2_bvalid; // @[TopLevel.scala 38:23]
  always @(posedge clock) begin
    start_tick <= reset; // @[TopLevel.scala 20:{27,27} 21:14]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  start_tick = _RAND_0[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
