//============================================================
// Basic Verilator-friendly UVM Testbench
//============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

//------------------------------------------------------------
// DUT Interface
//------------------------------------------------------------
interface counter_if(input logic clk);
    logic rst;
    logic en;
    logic [3:0] count;
endinterface

//------------------------------------------------------------
// Sequence Item
//------------------------------------------------------------
class counter_item extends uvm_sequence_item;
    rand bit rst;
    rand bit en;

    `uvm_object_utils(counter_item)

    function new(string name="counter_item");
        super.new(name);
    endfunction

    constraint rst_dist { rst dist {0:=90, 1:=10}; }
endclass

//------------------------------------------------------------
// Sequencer
//------------------------------------------------------------
class counter_sequencer extends uvm_sequencer #(counter_item);
    `uvm_component_utils(counter_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

//------------------------------------------------------------
// Driver
//------------------------------------------------------------
class counter_driver extends uvm_driver #(counter_item);
    `uvm_component_utils(counter_driver)

    virtual counter_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set")
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

//------------------------------------------------------------
// Agent
//------------------------------------------------------------
class counter_agent extends uvm_agent;
    `uvm_component_utils(counter_agent)

    counter_sequencer seqr;
    counter_driver    drv;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        seqr = counter_sequencer::type_id::create("seqr", this);
        drv  = counter_driver   ::type_id::create("drv",  this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

//------------------------------------------------------------
// Environment
//------------------------------------------------------------
class counter_env extends uvm_env;
    `uvm_component_utils(counter_env)

    counter_agent agent;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        agent = counter_agent::type_id::create("agent", this);
    endfunction
endclass

//------------------------------------------------------------
// Sequence
//------------------------------------------------------------
class counter_sequence extends uvm_sequence #(counter_item);
    `uvm_object_utils(counter_sequence)

    function new(string name="counter_sequence");
        super.new(name);
    endfunction

    task body();
        counter_item item;

        // Apply reset
        item = counter_item::type_id::create("item");
        item.rst = 1;
        item.en  = 0;
        start_item(item);
        finish_item(item);

        // Normal operation
        repeat (20) begin
            item = counter_item::type_id::create("item");
            assert(item.randomize());
            start_item(item);
            finish_item(item);
        end
    endtask
endclass

//------------------------------------------------------------
//
