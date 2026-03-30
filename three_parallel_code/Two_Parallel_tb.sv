`timescale 1ns/1ps

module Two_Parallel_tb;

    // Testbench signals
    logic clk;
    logic rst;
    logic signed [15:0] din1, din2;
    logic signed [63:0] dout1;
    logic signed [63:0] dout2;

    parameter MEM_SIZE = 131072; // 2^17
    logic signed [15:0] sin [MEM_SIZE-1:0];
    int addr;

    // Instantiate the DUT
    Two_Parallel uut (
        .clk(clk),
        .rst(rst),
        .din1(din1),
        .din2(din2),
        .dout1(dout1),
        .dout2(dout2)
    );


    initial begin
        // Load mem
        $readmemb("input.data", sin);

        // Initialize signals
        clk = 0;
        rst = 1;
        addr = 0;
        #21276 rst = 0; // Deassert reset after 20ns
    end

    assign din1 = sin[addr];
    assign din2 = sin[addr+1];

    always @(posedge clk) begin
        if (addr < MEM_SIZE) begin
            addr += 2;
        end
    end

    // 47 KHz clock (21276ns period)
    always #10638 clk = ~clk;

endmodule
