

// Based on Surelog's SimpleClass1
import uvm_pkg::* ;
`include "uvm_macros.svh"

`uvm_analysis_imp_decl(_too_pkt)

`uvm_analysis_imp_decl(_rcvd_pkt)

`uvm_analysis_imp_decl(_sent_pkt)

class uvm_blocking_get_export #(type T=int)
  extends uvm_port_base #(uvm_tlm_if_base #(T,T));
endclass

class uvm_component;
endclass


virtual class uvm_port_base #(type IF=uvm_void) extends IF;
endclass



class uvm_analysis_imp #(type T=int, type IMP=int);
  local IMP m_imp;
  function void write (input T t);
    m_imp.write (t);
  endfunction
endclass

module top(input a, output b);
	assign b = a;
	always @(posedge a) begin
		`uvm_info("LABEL", "Posedge detected", UVM_HIGH);
	end
endmodule
