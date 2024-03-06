// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vour.h for the primary calling header

#include "verilated.h"

#include "Vour__Syms.h"
#include "Vour___024root.h"

VL_ATTR_COLD void Vour___024root___eval_initial__TOP(Vour___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vour__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vour___024root___eval_initial__TOP\n"); );
    // Body
    VL_WRITEF("Hello World\n");
    VL_FINISH_MT("our.v", 2, "");
    vlSymsp->__Vcoverage[0].fetch_add(1, std::memory_order_relaxed);
}

VL_ATTR_COLD void Vour___024root___configure_coverage(Vour___024root* vlSelf, bool first) {
    if (false && vlSelf) {}  // Prevent unused
    Vour__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vour___024root___configure_coverage\n"); );
    // Body
    if (false && first) {}  // Prevent unused
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[0]), first, "our.v", 2, 6, ".our", "v_line/our", "block", "2");
}
