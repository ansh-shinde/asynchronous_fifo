//==============================================================================
// Module Name : test2
// Project     : Asynchronous FIFO
// Author      : Ansh Shinde
//
// Description :
// Verification testbench for asynchronous FIFO.
//
// Test Scenarios:
// 1. FIFO fill operation
// 2. Simultaneous read/write operation
// 3. FIFO drain operation
//
// Features:
// - Independent read/write clocks
// - VCD waveform dumping
// - Internal memory visibility
//
//==============================================================================

module test2;
parameter DEPTH=8, WIDTH=8, N=$clog2(DEPTH);

reg clk_wr, clk_rd, rd, wr, clr, en;
reg  [WIDTH-1:0] data_in;
wire [WIDTH-1:0] data_out;

integer i;

// DUT
top #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut (
    .clk_wr(clk_wr),
    .clk_rd(clk_rd),
    .rd(rd),
    .wr(wr),
    .clr(clr),
    .en(en),
    .data_in(data_in),
    .data_out(data_out)
);

// Dump
initial begin
    $dumpfile("async_fifo.vcd");
    $dumpvars(0, test2);
        $dumpvars(0, dut.dat.str.regfile[0]);
    $dumpvars(0, dut.dat.str.regfile[1]);
    $dumpvars(0, dut.dat.str.regfile[2]);
    $dumpvars(0, dut.dat.str.regfile[3]);
    $dumpvars(0, dut.dat.str.regfile[4]);
    $dumpvars(0, dut.dat.str.regfile[5]);
    $dumpvars(0, dut.dat.str.regfile[6]);
    $dumpvars(0, dut.dat.str.regfile[7]);

end

// Clocks
always #5 clk_wr = ~clk_wr;
always #6 clk_rd = ~clk_rd;

// Initialization
initial begin
    clk_wr = 0;
    clk_rd = 0;
    rd = 0;
    wr = 0;
    clr = 1;
    en  = 0;
    data_in = 0;

    #10 clr = 0;
    en = 1;
end

// ----------------------------------
// WRITE DRIVER (WR CLOCK DOMAIN)
// ----------------------------------
always @(negedge clk_wr) begin
    if (wr) begin
        data_in <= data_in + 1;
    end
end

// ----------------------------------
// READ MONITOR (RD CLOCK DOMAIN)
// ----------------------------------
always @(posedge clk_rd) begin
    #1; // avoid NBA race
    if (rd) begin
        $display("READ: data_out=%0d rd_en=%0b empty=%0b time=%0t",
                  data_out, dut.ctrl.rd_en, dut.ctrl.empty, $time);
    end
end

// ----------------------------------
// TEST SEQUENCE
// ----------------------------------
initial begin

    // ---------------------------
    // 1. FILL FIFO
    // ---------------------------
    wr = 1;
    rd = 0;

    repeat (DEPTH) @(posedge clk_wr);

    // ---------------------------
    // 2. SIMULTANEOUS RD + WR
    // ---------------------------
    @(posedge clk_wr);
    wr = 1;
    rd = 1;

    repeat (15) begin
        @(posedge clk_wr);
        #1;
        $display("SIMUL: data_in=%0d data_out=%0d full=%0b empty=%0b time=%0t",
                  data_in, data_out,
                  dut.ctrl.full, dut.ctrl.empty, $time);
    end

    // ---------------------------
    // 3. DRAIN FIFO
    // ---------------------------
    @(posedge clk_wr);
    wr = 0;
    rd = 1;

    repeat (DEPTH+2) @(posedge clk_rd);

    // END
    #20 $finish;
end

endmodule
