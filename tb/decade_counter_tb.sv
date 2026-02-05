`timescale 1ns / 1ps

module tb_decade_counter;

  logic clk;
  logic en;
  logic rst;
  logic [3:0] count;

  // 2. DUT Instantiation (Device Under Test)
  decade_counter dut (
    .clk(clk),
    .en(en),
    .rst(rst),
    .count(count)
  );

  //  Clock Generation

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // 4. Waveform Dumping
  initial begin
    $dumpfile("decade_counter_wave.vcd");
    // Dumps all signals (level 0) inside the testbench module
    $dumpvars(0, tb_decade_counter);
  end

  // Stimulus
  initial begin
    $monitor("Time=%0t | rst=%b en=%b | count=%d", $time, rst, en, count);
    en = 0;
    rst = 0;
    #10 rst = 1;
    #10 rst = 0;
    $display("--- Start Counting ---");
    en = 1;
    
    // Wait for 15 clock cycles (150ns) to observe wrap-around (0 to 9 to 0)
    #150;
    
    $display("--- Test Pause (Enable Low) ---");
    // Disable enable to check if counter holds value
    en = 0;
    #30; 
    $display("--- Test Async Reset while Counting ---");
    // Re-enable and then reset mid-count
    en = 1;
    #40;
    rst = 1; // Async reset should clear counter immediately
    #10;
    rst = 0;
    #20;
    $finish;
  end
endmodule
