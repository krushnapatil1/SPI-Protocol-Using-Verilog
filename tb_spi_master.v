`timescale 1ns/1ps

module tb_spi_master;

reg clk;
reg reset;
reg start;                  //start the spi transfer
reg [7:0] tx_data;          //Data the master transmit
reg [7:0] slave_data;       //Data sent by the slave to the master
reg miso;                   //data comming from the simulated slave

wire sclk;
wire mosi;                  //Master send the data to slave
wire cs;                    //Chip Select
wire [7:0] rx_data;         //Data recieved by the master
wire done;                  //Indicates transfer completion

integer miso_index;         //Tracks the current slabe data bit
integer tx_bit_count;       //Counts the transmitted bits
reg [7:0] observed_tx;      //Stores the mosi bit captured by the testbench


spi_master #(
    .DIVIDER(4)
) dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .tx_data(tx_data),
    .miso(miso),
    .sclk(sclk),
    .mosi(mosi),
    .cs(cs),
    .rx_data(rx_data),
    .done(done)
);


always #5 clk = ~clk;

//Send the First MISO bit
always@(negedge cs) begin
    miso_index = 7;
    miso = slave_data[7];
end

//Prepare the next Bit
always@(negedge sclk) begin
    if(!cs && miso_index > 0) begin
        miso_index = miso_index - 1;
        miso = slave_data[miso_index];
    end
end

//Capture Master's MOSI data
always@(posedge sclk) begin
    if(!cs) begin
        observed_tx = {observed_tx[6:0], mosi};
        tx_bit_count = tx_bit_count + 1;
    end
end


//Initialize the Simuation
initial begin

    $dumpfile("spi_master.vcd");
    $dumpvars(0, tb_spi_master);


    //First Test
    clk = 0;
    reset = 1;
    start = 0;
    tx_data = 8'b10110101;
    slave_data = 8'b11110000;
    miso = 0;
    miso_index = 7;
    observed_tx = 0;
    tx_bit_count = 0;

    #20;
    reset = 0;

    #10;
    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);
    #1;

    $display("Expected TX: %b", tx_data);
    $display("Observed TX: %b", observed_tx);
    $display("Expected RX: %b", slave_data);
    $display("Expected RX: %b", rx_data);
    $display("TX bit count: %0d", tx_bit_count);


    if (observed_tx === tx_data && rx_data === slave_data && tx_bit_count == 8)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");



    
    // Second test
    wait(cs == 1'b1);
    @(negedge clk);

    tx_data = 8'b10101010;
    slave_data = 8'b01010101;
    observed_tx = 0;
    tx_bit_count = 0;
    miso_index = 7;

    start = 1;

    @(negedge clk);
    start = 0;

    wait(done == 1'b1);
    #1;

    $display("\n--- SECOND TEST ---");
    $display("Expected TX: %b", tx_data);
    $display("Observed TX: %b", observed_tx);
    $display("Expected RX: %b", slave_data);
    $display("Received RX: %b", rx_data);
    $display("TX bit count: %0d", tx_bit_count);


    if (observed_tx === tx_data && rx_data === slave_data && tx_bit_count == 8)
        $display("SECOND TEST PASSED");
    else
        $display("SECOND TEST FAILED");

    $finish;
end

initial begin
    #10000;
    $display("Error: Simulation Timeout");

    $finish;
end

endmodule