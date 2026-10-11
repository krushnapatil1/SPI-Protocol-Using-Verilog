
`timescale 1ns/1ps

module spi_top(
    input clk,
    input reset,
    input start,

    input [7:0] master_tx_data,
    input [7:0] slave_tx_data,

    output [7:0] master_rx_data,
    output [7:0] slave_rx_data,

    output master_done,
    output slave_done
);

wire sclk;
wire cs;
wire mosi;
wire miso;

// SPI Master
spi_master master (
    .clk(clk),
    .reset(reset),
    .start(start),
    .tx_data(master_tx_data),
    .miso(miso),
    .cs(cs),
    .sclk(sclk),
    .mosi(mosi),
    .rx_data(master_rx_data),
    .done(master_done)
);

// SPI Slave
spi_slave slave (
    .clk(clk),
    .reset(reset),
    .cs(cs),
    .sclk(sclk),
    .mosi(mosi),
    .tx_data(slave_tx_data),
    .miso(miso),
    .rx_data(slave_rx_data),
    .done(slave_done)
);

endmodule
