`timescale 1ps/1ps
module top_sim();

reg       refclk;
reg       reset;

wire        clk1_p, clk1_n;
wire [4:0]  data1_p, data1_n;
wire        clk2_p, clk2_n;
wire [4:0]  data2_p, data2_n;


reg        tx_clk_1x;
reg  [6:0] tx1_oclk;
reg  [6:0] tx1_odata0, tx1_sdata0;
reg  [6:0] tx1_odata1, tx1_sdata1;
reg  [6:0] tx1_odata2, tx1_sdata2;
reg  [6:0] tx1_odata3, tx1_sdata3;
reg  [6:0] tx1_odata4, tx1_sdata4;
reg        tx1_match;

reg  [6:0] tx2_oclk;
reg  [6:0] tx2_odata0, tx2_sdata0;
reg  [6:0] tx2_odata1, tx2_sdata1;
reg  [6:0] tx2_odata2, tx2_sdata2;
reg  [6:0] tx2_odata3, tx2_sdata3;
reg  [6:0] tx2_odata4, tx2_sdata4;
reg        tx2_match;


reg        rx_clk_1x;
reg [34:0] rx_data;
reg        rx_clkin;
reg  [4:0] rx_datain;
reg  [3:0] rx_count;
reg  [6:0] rx_clkpattern;
wire       rx1_match;
wire       rx2_match;


initial
begin
   refclk = 1'b0;
   reset  = 1'b1;
   //
   tx_clk_1x = 1'b1;
   //
   rx_clk_1x = 1'b0;
   rx_count  = 3'b0;
   rx_clkpattern  = 7'b1100011;
   rx_data[ 6:0 ] = 7'h1;
   rx_data[13:7 ] = 7'h2;
   rx_data[20:14] = 7'h3;
   rx_data[27:21] = 7'h4;
   rx_data[34:28] = 7'h5;
   
   #100000
   reset = 1'b0;
end

always begin
   #1666 refclk = ~refclk;
end

top_txrx_example  top_rxtx (
    .refclk_p    ( refclk),     // Reference clock for input delay control
    .refclk_n    (~refclk),     // Reference clock for input delay control
    .tx_reset    (reset),       // Transmitter Reset (active high)
    .rx_reset    (reset),       // Receiver Reset (active high)
    //
    .clkout1_p   (clk1_p),
    .clkout1_n   (clk1_n),      // 
    .dataout1_p  (data1_p),     //
    .dataout1_n  (data1_n),     //
    .clkout2_p   (clk2_p),
    .clkout2_n   (clk2_n),      // 
    .dataout2_p  (data2_p),     //
    .dataout2_n  (data2_n),     //
    //
    .clkin1_p    (clk1_p),      // 
    .clkin1_n    (clk1_n),      // 
    .datain1_p   (data2_p),     //
    .datain1_n   (data2_n),     //
    .clkin2_p    (clk2_p),
    .clkin2_n    (clk2_n),      // 
    .datain2_p   (data2_p),     //
    .datain2_n   (data2_n),     //
    //
    .rx1_match   (rx1_match),
    .rx2_match   (rx2_match)
   );


// 
// Independent RX data generation
// 
always begin
    #476 rx_clk_1x <= 1'b1;
    #476 rx_clk_1x <= 1'b0;
end

always @ (posedge rx_clk_1x)
begin
   if (rx_count == 6) begin
       rx_count <= 0;
       rx_data[ 6:0 ] <= rx_data[ 6:0 ] + 1'b1;
       rx_data[13:7 ] <= rx_data[13:7 ] + 1'b1;
       rx_data[20:14] <= rx_data[20:14] + 1'b1;
       rx_data[27:21] <= rx_data[27:21] + 1'b1;
       rx_data[34:28] <= rx_data[34:28] + 1'b1;
       end
   else begin
       rx_count <= rx_count + 1'b1;
   end

   rx_clkin     <= rx_clkpattern[rx_count];
   rx_datain[0] <= rx_data[rx_count+7*0];
   rx_datain[1] <= rx_data[rx_count+7*1];
   rx_datain[2] <= rx_data[rx_count+7*2];
   rx_datain[3] <= rx_data[rx_count+7*3];
   rx_datain[4] <= rx_data[rx_count+7*4];
end

// 
// TX1 data checker
// 
always begin
    #476 tx_clk_1x <= 1'b0;
    #476 tx_clk_1x <= 1'b1;
end

always @ (posedge tx_clk_1x)
begin
   tx1_oclk        <= {clk1_p,tx1_oclk[6:1]};
   tx1_odata0[6:0] <= {data1_p[0],tx1_odata0[6:1]};
   tx1_odata1[6:0] <= {data1_p[1],tx1_odata1[6:1]};
   tx1_odata2[6:0] <= {data1_p[2],tx1_odata2[6:1]};
   tx1_odata3[6:0] <= {data1_p[3],tx1_odata3[6:1]};
   tx1_odata4[6:0] <= {data1_p[4],tx1_odata4[6:1]};
end

always @ (posedge tx_clk_1x)
begin
   if (tx1_oclk == 7'b1100011) begin
      if ( (tx1_odata0 == tx1_sdata0 + 1'b1) &&
           (tx1_odata1 == tx1_sdata1 + 1'b1) &&
           (tx1_odata2 == tx1_sdata2 + 1'b1) &&
           (tx1_odata3 == tx1_sdata3 + 1'b1) &&
           (tx1_odata4 == tx1_sdata4 + 1'b1)) begin
         tx1_match = 1'b1;
      end
      else begin
         tx1_match = 1'b0;
      end
      tx1_sdata0 <= tx1_odata0;
      tx1_sdata1 <= tx1_odata1;
      tx1_sdata2 <= tx1_odata2;
      tx1_sdata3 <= tx1_odata3;
      tx1_sdata4 <= tx1_odata4;
   end
end

//
// TX2 data checker
//
always begin
    #476 tx_clk_1x <= 1'b0;
    #476 tx_clk_1x <= 1'b1;
end

always @ (posedge tx_clk_1x)
begin
   tx2_oclk        <= {clk2_p,tx2_oclk[6:1]};
   tx2_odata0[6:0] <= {data2_p[0],tx2_odata0[6:1]};
   tx2_odata1[6:0] <= {data2_p[1],tx2_odata1[6:1]};
   tx2_odata2[6:0] <= {data2_p[2],tx2_odata2[6:1]};
   tx2_odata3[6:0] <= {data2_p[3],tx2_odata3[6:1]};
   tx2_odata4[6:0] <= {data2_p[4],tx2_odata4[6:1]};
end

always @ (posedge tx_clk_1x)
begin
   if (tx2_oclk == 7'b1100011) begin
      if ( (tx2_odata0 == tx2_sdata0 + 1'b1) &&
           (tx2_odata1 == tx2_sdata1 + 1'b1) &&
           (tx2_odata2 == tx2_sdata2 + 1'b1) &&
           (tx2_odata3 == tx2_sdata3 + 1'b1) &&
           (tx2_odata4 == tx2_sdata4 + 1'b1)) begin
         tx2_match = 1'b1;
      end
      else begin
         tx2_match = 1'b0;
      end
      tx2_sdata0 <= tx2_odata0;
      tx2_sdata1 <= tx2_odata1;
      tx2_sdata2 <= tx2_odata2;
      tx2_sdata3 <= tx2_odata3;
      tx2_sdata4 <= tx2_odata4;
   end
end

endmodule
