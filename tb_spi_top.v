
`timescale 1ns/1ps

module tb_spi_top;

reg clk;
reg reset;
reg start;

reg [7:0] master_tx_data;
reg [7:0] slave_tx_data;

wire [7:0] master_rx_data;
wire [7:0] slave_rx_data;

wire master_done;
wire slave_done;

// Instantiate top module
spi_top dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .master_tx_data(master_tx_data),
    .slave_tx_data(slave_tx_data),
    .master_rx_data(master_rx_data),
    .slave_rx_data(slave_rx_data),
    .master_done(master_done),
    .slave_done(slave_done)
);

// Generate system clock
always #5 clk = ~clk;

initial begin

    $dumpfile("spi_top.vcd");
    $dumpvars(0, tb_spi_top);

    // Initialize signals
    clk = 0;
    reset = 1;
    start = 0;

    master_tx_data = 8'hCC;
    slave_tx_data  = 8'hF8;

    // Apply reset
    #20;
    reset = 0;

    // Start SPI transfer
    #20;
    start = 1;

    // Give master time to detect start
    #10;
    start = 0;

    // Wait for transfer to finish
    wait (master_done == 1'b1);

    // Allow outputs to settle
    #20;

    $display("--------------------------------");
    $display("Master TX data : %h", master_tx_data);
    $display("Slave RX data  : %h", slave_rx_data);
    $display("Slave TX data  : %h", slave_tx_data);
    $display("Master RX data : %h", master_rx_data);
    $display("Master done    : %b", master_done);
    $display("Slave done     : %b", slave_done);
    $display("--------------------------------");

    if (slave_rx_data == master_tx_data)
        $display("MASTER TO SLAVE: PASS");
    else
        $display("MASTER TO SLAVE: FAIL");

    if (master_rx_data == slave_tx_data)
        $display("SLAVE TO MASTER: PASS");
    else
        $display("SLAVE TO MASTER: FAIL");

    $finish;

end

// Safety timeout in case the master never finishes
initial begin
    #100000;
    $display("ERROR: Simulation timeout");
    $finish;
end

endmodule
