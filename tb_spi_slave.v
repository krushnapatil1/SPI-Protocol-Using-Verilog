`timescale 1ns/1ps
module tb_spi_slave;

reg clk;
reg reset;
reg cs;
reg sclk;
reg mosi;               //Serial input data sent to the slave
reg[7:0] tx_data;       //Byte the slave should transmit

wire miso;              //The serial bit transmitted by the slave
wire [7:0] rx_data;     //The complete received byte
wire done;              //Indicates that slave has received all eight bits

integer i;
reg [7:0] received_miso;    //stores the eight sampled MISO bits so we can compare the transmitted byte with 8'b11111000


spi_slave dut(
    .clk(clk),
    .reset(reset),
    .cs(cs),
    .sclk(sclk),
    .mosi(mosi),
    .tx_data(tx_data),
    .miso(miso),
    .rx_data(rx_data),
    .done(done)
);

always #5 clk = ~clk;

initial begin
    
    $dumpfile("spi_slave.vcd");
    $dumpvars(0, tb_spi_slave);

    clk = 0;
    reset = 1;
    cs = 1;
    sclk = 0;
    mosi = 0;
    tx_data = 8'b11111000;
    received_miso = 0;

    #20;
    reset = 0;

    #20;
    cs = 0;

    #30;


    //Send 8 bits, MSB first

    for(i = 7; i >= 0; i = i - 1) begin
        mosi = (8'b11001100 >> i) & 1'b1;

        #30;
        received_miso[i] = miso;

        sclk = 1;
        #30;

        sclk = 0;
        #30;

    end

    cs = 1;
    #30;


    $display("Expected RX : 11001100 ");
    $display("Actual RX: %b", rx_data);

    $display("Expected TX: 11111000");
    $display("Actual TX: %b", received_miso);


    if(rx_data == 8'b11001100)
        $display("RX PASS");
    else
        $display("RX FFAIL");


    if(received_miso == 8'b11111000)
        $display("TX PASS");
    else
        $display("TX FAIL");

        
    $finish;

end

endmodule