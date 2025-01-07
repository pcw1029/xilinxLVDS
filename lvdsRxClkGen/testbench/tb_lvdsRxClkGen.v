`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/06 20:39:33
// Design Name: 
// Module Name: tb_lvdsRxClkGen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_lvdsRxClkGen();
    // Parameters for the DUT (Device Under Test)
    parameter real    CLKIN_PERIOD = 12.5;      // Clock period (ns) of input clock on clkin_p
    parameter real    IDELAYE3_REF_FREQ     = 300.0;      // Reference clock frequency for idelay control
    parameter         LANE_NUM     = 4;    
    parameter         DIFF_TERM    = "FALSE";    // Enable internal LVDS termination
    parameter         USE_PLL      = "FALSE";    // Selects either PLL or MMCM for clocking
    parameter         CLK_PATTERN  = 8'b11001100;  // Clock pattern for alignment
    // Testbench signals
    reg clkin_p;
    reg clkin_n;
    reg reset;
    reg idelay_rdy;

    wire rx_clkdiv2;
    wire rx_clkdiv4;
    wire cmt_locked;
    wire [4:0] rx_wr_addr;
    wire [8:0] rx_cntval;
    wire rx_dlyload;
    wire rx_reset;
    wire rx_ready;

    wire px_clk;
    wire [4:0] px_rd_addr;
    wire [2:0] px_rd_seq;
    wire px_ready;

    // Clock generation parameters
    localparam CLK_PERIOD_NS = CLKIN_PERIOD;
    
    // Clock generation
    initial begin
        clkin_p = 0;
        forever #(CLK_PERIOD_NS/2) clkin_p = ~clkin_p;
    end

    initial begin
        clkin_n = 1;
        forever #(CLK_PERIOD_NS/2) clkin_n = ~clkin_n;
    end

    // Reset signal
    initial begin
        reset = 1;
        #100;
        reset = 0;
    end

    // IDELAY Ready signal simulation
    initial begin
        idelay_rdy = 0;
        #200;
        idelay_rdy = 1;
        #10000;
        $finish;
    end

    // Instantiate the Device Under Test (DUT)
    lvdsRxClkGen #(
        .CLKIN_PERIOD(CLKIN_PERIOD),
        .IDELAYE3_REF_FREQ(IDELAYE3_REF_FREQ),
        .LANE_NUM(LANE_NUM),
        .DIFF_TERM(DIFF_TERM),
        .USE_PLL(USE_PLL),
        .CLK_PATTERN(CLK_PATTERN)
    ) dut (
        .clkin_p(clkin_p),
        .clkin_n(clkin_n),
        .reset(reset),
        .idelay_rdy(idelay_rdy),
        .rx_clkdiv2(rx_clkdiv2),
        .rx_clkdiv4(rx_clkdiv4),
        .cmt_locked(cmt_locked),
        .rx_wr_addr(rx_wr_addr),
        .rx_cntval(rx_cntval),
        .rx_dlyload(rx_dlyload),
        .rx_reset(rx_reset),
        .rx_ready(rx_ready),
        .px_clk(px_clk),
        .px_rd_addr(px_rd_addr),
        .px_rd_seq(px_rd_seq),
        .px_ready(px_ready)
    );


endmodule
