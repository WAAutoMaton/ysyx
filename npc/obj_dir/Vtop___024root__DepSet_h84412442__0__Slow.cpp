// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "verilated.h"

#include "Vtop__Syms.h"
#include "Vtop___024root.h"

VL_ATTR_COLD void Vtop___024root___eval_initial__TOP(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_initial__TOP\n"); );
    // Init
    VlWide<5>/*159:0*/ __Vtemp_hfa101174__0;
    // Body
    if (VL_UNLIKELY((0U != VL_TESTPLUSARGS_I(std::string{"trace"})))) {
        __Vtemp_hfa101174__0[0U] = 0x2e766364U;
        __Vtemp_hfa101174__0[1U] = 0x64756d70U;
        __Vtemp_hfa101174__0[2U] = 0x766c745fU;
        __Vtemp_hfa101174__0[3U] = 0x6f67732fU;
        __Vtemp_hfa101174__0[4U] = 0x6cU;
        vlSymsp->_vm_contextp__->dumpfile(VL_CVT_PACK_STR_NW(5, __Vtemp_hfa101174__0));
        vlSymsp->_traceDumpOpen();
        vlSymsp->__Vcoverage[3].fetch_add(1, std::memory_order_relaxed);
        VL_WRITEF("[%0t] Tracing to logs/vlt_dump.vcd...\n\n",
                  64,VL_TIME_UNITED_Q(1),-12);
    } else {
        vlSymsp->__Vcoverage[4].fetch_add(1, std::memory_order_relaxed);
    }
    VL_WRITEF("[%0t] Model running...\n\n",64,VL_TIME_UNITED_Q(1),
              -12);
    vlSymsp->__Vcoverage[5].fetch_add(1, std::memory_order_relaxed);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__stl(Vtop___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtop___024root___eval_triggers__stl(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.at(0U) = (0U == vlSelf->__VstlIterCount);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtop___024root___dump_triggers__stl(vlSelf);
    }
#endif
}

VL_ATTR_COLD void Vtop___024root___configure_coverage(Vtop___024root* vlSelf, bool first) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___configure_coverage\n"); );
    // Body
    if (false && first) {}  // Prevent unused
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[0]), first, "vsrc/top.v", 2, 9, ".top", "v_toggle/top", "a", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[1]), first, "vsrc/top.v", 3, 9, ".top", "v_toggle/top", "b", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[2]), first, "vsrc/top.v", 4, 10, ".top", "v_toggle/top", "f", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[3]), first, "vsrc/top.v", 8, 7, ".top", "v_branch/top", "if", "8-11");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[4]), first, "vsrc/top.v", 8, 8, ".top", "v_branch/top", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[5]), first, "vsrc/top.v", 7, 3, ".top", "v_line/top", "block", "7,13");
}
