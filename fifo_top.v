//==============================================================================
// Module Name : top
// Project     : Asynchronous FIFO
// Author      : Ansh Shinde
//
// Description :
//
// Top-level module for asynchronous FIFO.
//
// Integrates:
// - FIFO datapath
// - FIFO control path
//
// Features:
// - Independent read/write clocks
// - Gray-coded pointer synchronization
// - Full/empty detection
// - Parameterized FIFO depth and width
//
//==============================================================================

module top #(parameter DEPTH=8, 
                        WIDTH=8,
                        N=$clog2(DEPTH)
             )(
               input clk_wr,clk_rd,rd,wr,clr,en,
               input  [WIDTH-1:0] data_in,
               output [WIDTH-1:0] data_out
              );
    wire [N:0] gray_adrs_wr,gray_adrs_rd,bin_adrs_wr,bin_adrs_rd;
    wire full,nr_full,empty,nr_empty,rd_en,wr_en;
    data #(.DEPTH(DEPTH),
           .WIDTH(WIDTH)
          )dat(
               .clk_wr(clk_wr),
               .clk_rd(clk_rd),
               .full(full),
               .empty(empty),
               .nr_full(nr_full),
               .nr_empty(nr_empty),
               .wr(wr),
               .rd(rd),
               .clr(clr),
               .wr_en(wr_en),
               .rd_en(rd_en),
               .data_in(data_in),
               .data_out(data_out),
               .gray_adrs_wr(gray_adrs_wr),
               .gray_adrs_rd(gray_adrs_rd),
               .bin_adrs_wr(bin_adrs_wr),
               .bin_adrs_rd(bin_adrs_rd)
              );
    
     control #(.DEPTH(DEPTH),
               .WIDTH(WIDTH)
              )ctrl(
                    .wr(wr),
                    .clk_rd(clk_rd),
                    .clk_wr(clk_wr),
                    .en(en),
                    .gray_adrs_wr(gray_adrs_wr),
                    .gray_adrs_rd(gray_adrs_rd),
                    .full(full),
                    .nr_full(nr_full),
                    .empty(empty),
                    .nr_empty(nr_empty),
                    .rd_en(rd_en),
                    .wr_en(wr_en),
                    .bin_adrs_wr(bin_adrs_wr),
                    .bin_adrs_rd(bin_adrs_rd),
                    .clr(clr)
                   );
endmodule



               
