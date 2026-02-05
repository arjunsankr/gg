// Basic UVM Testbench for Verilator
`include "uvm_macros.svh"
import uvm_pkg::*;

// --- DUT Interface ---
interface counter_if(input logic clk);
    logic rst;
    logic en;
    logic [3:0] count;
endinterface

// --- UVM Components ---

class counter_item extends uvm_sequence_item;
    rand bit rst;
    rand bit en;
    bit [3:0] count;
    
    `uvm_object_utils_begin(counter_item)
        `uvm_field_int(rst, UVM_DEFAULT)
        `uvm_field_int(en, UVM_DEFAULT)
        `uvm_field_int(count, UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new(string name="counter_item"); super.new(name); endfunction
    
    // Verilator supports standard constraints now!
    constraint rst_dist { rst dist {0:=90, 1:=10}; }
endclass

class counter_driver extends uvm_driver#(counter_item);
    `uvm_component_utils(counter_driver)
    virtual counter_if vif;
    
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "No virtual interface set")
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            @(negedge vif.clk);
            vif.rst <= req.rst;
            vif.en  <= req.en;
            seq_item_port.item_done();
        end
    endtask
endclass

class counter_test extends uvm_test;
    `uvm_component_utils(counter_test)
    // Simplified for brevity - normally you'd have env, agent, etc.
    counter_driver drv;
    
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    
    function void build_phase(uvm_phase phase);
        drv = counter_driver::type_id::create("drv", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        counter_item item;
        phase.raise_objection(this);
        
        // Reset sequence
        item = counter_item::type_id::create("item");
        item.rst = 1; item.en = 0;
        drv.seq_item_port.put_response(item); // Direct drive for simplicity in example
        
        // Run loop
        repeat(20) begin
            item = new();
            void'(item.randomize());
            // In a real UVM agent, the sequencer handles this interaction
            // Here we just print to prove it works
            `uvm_info("TEST", $sformatf("Generated: rst=%b en=%b", item.rst, item.en), UVM_LOW)
            #10; 
        end
        phase.drop_objection(this);
    endtask
endclass

// --- Top Module ---
module tb_top;
    logic clk;
    
    // Clock generation (Now supported by Verilator --timing)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    counter_if vif(clk);
    
    decade_counter dut (
        .clk(vif.clk),
        .rst(vif.rst),
        .en (vif.en),
        .count(vif.count)
    );
    
    initial begin
        uvm_config_db#(virtual counter_if)::set(null, "*", "vif", vif);
        run_test("counter_test");
    end
endmodule
