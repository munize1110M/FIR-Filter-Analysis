`timescale 1ns/1ps

module Pipelined_FIR_tb;

    // Testbench signals
    logic clk;
    logic rst;
    logic signed [15:0] din;
    logic signed [63:0] dout;

    parameter MEM_SIZE = 131072; // 2^17
    logic signed [15:0] sin [MEM_SIZE-1:0];
    int addr;

    Pipelined_FIR uut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .dout(dout)
    );

    initial begin
        // Load mem
        $readmemb("input.data", sin);

        // Initialize signals
        clk = 0;
        rst = 1;
        addr = 0;
        #21276 rst = 0; // Deassert reset after one cycle
    end

    assign din = sin[addr];

    always @(posedge clk) begin
        if (addr < MEM_SIZE) begin
            addr += 1;
        end
    end

    // 47 KHz clock (21276ns period)
    always #10638 clk = ~clk;

endmodule
