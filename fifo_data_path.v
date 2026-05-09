//==============================================================================
// Module Name : data
// Project     : Asynchronous FIFO
// Author      : Ansh Shinde
// Description :
//
// Top-level datapath module for asynchronous FIFO.
//
// This module integrates:
// 1. FIFO memory array
// 2. Write pointer generation logic
// 3. Read pointer generation logic
//
// Features:
// - Separate read and write clocks
// - Gray-coded address generation
// - Parameterized FIFO depth and width
// - Independent read/write operation
//
// Submodules:
// - memo   : FIFO storage memory
// - wr_ptr : Write pointer generator
// - rd_ptr : Read pointer generator
//
//==============================================================================

module data #(parameter DEPTH=8, 
                        WIDTH=8,
                        N=$clog2(DEPTH)
              )(
                input clk_wr,clk_rd,full,empty,nr_full,nr_empty,wr,rd,clr,wr_en,rd_en,
                input  [WIDTH-1:0] data_in,
                output [WIDTH-1:0] data_out,
                output [N:0]       gray_adrs_wr,gray_adrs_rd, bin_adrs_wr,bin_adrs_rd
                );

//------------------------------------------------------------------------------
// FIFO Memory Instance
//------------------------------------------------------------------------------                
              memo #(.DEPTH(DEPTH),
                     .WIDTH(WIDTH)
                     )str(
                          .data_in(data_in),
                          .data_out(data_out),
                          .clk_rd(clk_rd),
                          .clk_wr(clk_wr),
                          .wr(wr),
                          .rd(rd),
                          .adrs_rd(bin_adrs_rd[N-1:0]),
                          .adrs_wr(bin_adrs_wr[N-1:0]),
                          .full(full),
                          .nr_full(nr_full),
                          .empty(empty),
                          .nr_empty(nr_empty),
                          .wr_en(wr_en),
                          .rd_en(rd_en)
                         );

//------------------------------------------------------------------------------
// Write pointer Instance
//------------------------------------------------------------------------------
             wr_ptr  #(.DEPTH(DEPTH),
                     .WIDTH(WIDTH)
                     )ptr1(
                           .wr(wr),
                           .clk_wr(clk_wr),
                           .clr(clr),
                           .wr_en(wr_en),
                           .full(full),
                           .nr_full(nr_full),
                           .bin_adrs_wr(bin_adrs_wr),
                           .gray_adrs_wr(gray_adrs_wr)
                          );

//------------------------------------------------------------------------------
// Read pointer Instance
//------------------------------------------------------------------------------
             rd_ptr  #(.DEPTH(DEPTH),
                     .WIDTH(WIDTH)
                     )ptr2(
                           .rd(rd),
                           .clk_rd(clk_rd),
                           .clr(clr),
                           .rd_en(rd_en),
                           .empty(empty),
                           .nr_empty(nr_empty),
                           .bin_adrs_rd(bin_adrs_rd),
                           .gray_adrs_rd(gray_adrs_rd)
                          );

endmodule


//------------------------------------------------------------------------------------------------
// Module Name : memo
// Description :
// Dual-port FIFO memory block supporting independent
// read and write operations.
//------------------------------------------------------------------------------------------------
module memo #(parameter DEPTH=8, 
                        WIDTH=8,
                        N=$clog2(DEPTH)
              )(
                input                  clk_rd,clk_wr,wr,rd,full,nr_full,empty,nr_empty,rd_en,wr_en,
                input      [WIDTH-1:0] data_in,
                output reg [WIDTH-1:0] data_out,
                input          [N-1:0]   adrs_rd,
                input          [N-1:0]   adrs_wr
                );

               reg [WIDTH-1:0] regfile[0:DEPTH-1];

              always@(posedge clk_rd)begin
              if(rd_en && rd )begin
              data_out<=regfile[adrs_rd];
              end
              end
              always@(posedge clk_wr)begin
              if(wr_en && wr )begin
              regfile[adrs_wr]<=data_in;
              end
              end
endmodule


//------------------------------------------------------------------------------
// Module Name : wr_ptr
// Description :
// Generates binary and Gray-coded write pointers
//------------------------------------------------------------------------------   
module wr_ptr#(
         parameter DEPTH=8, 
                   WIDTH=8,
                   N=$clog2(DEPTH)
        )(
          input          wr,clk_wr,clr,wr_en,full,nr_full,
          output    [N:0] gray_adrs_wr,
          output reg[N:0] bin_adrs_wr
         );

        always@(posedge clk_wr or posedge clr)begin
        if(clr)begin
        bin_adrs_wr<={(N+1){1'b0}};  
        end
        else if(wr_en && wr )begin
        bin_adrs_wr<=bin_adrs_wr+1;
        end
        end

        assign gray_adrs_wr=bin_adrs_wr^(bin_adrs_wr>>1); // binary to gray conversion

endmodule

//------------------------------------------------------------------------------
// Module Name : rd_ptr
// Description :
// Generates binary and Gray-coded read pointers
//------------------------------------------------------------------------------
module rd_ptr#(
         parameter DEPTH=8, 
                   WIDTH=8,
                   N=$clog2(DEPTH)
        )(
          input          rd,clk_rd,clr,rd_en,empty,nr_empty,
          output    [N:0] gray_adrs_rd,
          output reg[N:0] bin_adrs_rd
         );

        always@(posedge clk_rd or posedge clr)begin
        if(clr)begin
        bin_adrs_rd<={(N+1){1'b0}};
        end
        else if(rd_en && rd )begin
        bin_adrs_rd<=bin_adrs_rd+1;
        end
        end

        assign gray_adrs_rd=bin_adrs_rd^(bin_adrs_rd>>1); // binary to gray conversion

endmodule

