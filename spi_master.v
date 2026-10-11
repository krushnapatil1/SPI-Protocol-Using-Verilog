`timescale 1ns/1ps

module spi_master #(
    parameter integer DIVIDER = 4
)(
    // Inputs
    input clk,              // System clock
    input reset,            // Reset master
    input start,            // Start transfer
    input [7:0] tx_data,    // Data to transmit
    input miso,             // Data from slave

    // Outputs
    output reg sclk,        // SPI clock (Mode 0)
    output reg mosi,        // Data to slave
    output reg cs,          // Slave select (active LOW)
    output reg [7:0] rx_data, // Received data
    output reg done         // Transfer complete
);

    // Internal registers
    reg [31:0] count;       // Clock divider counter
    reg [1:0] state;        // Current FSM state
    reg [2:0] bit_count;    // Counts 8 bits
    reg [7:0] tx_shift;     // Transmit shift register
    reg [7:0] rx_shift;     // Receive shift register
    reg received_all;

    // FSM state definitions
    localparam IDLE     = 2'b00;
    localparam LOAD     = 2'b01;
    localparam TRANSFER = 2'b10;
    localparam DONE     = 2'b11;


    //CLOCK DIVIDER LOGIC
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            sclk  <= 0;
        end
        else if (state != TRANSFER) begin
            count <= 0;
            sclk  <= 0;
        end
        else if (count == DIVIDER - 1) begin
            count <= 0;
            sclk  <= ~sclk;
        end
        
        else begin
            count <= count + 1;
        end
    end


    //FSM LOGIC
    always@(posedge clk or posedge reset) begin
        
        if(reset) begin
            state <= IDLE;
            bit_count <= 0;
            tx_shift <= 0;
            rx_shift <= 0;
            rx_data <= 0;
            mosi <= 0;
            cs <= 1;
            done <= 0;
            received_all <= 0;
        end

        else begin
            
            case(state)

                //IDLE STATE
                IDLE:begin
                    
                    cs <= 1;
                    done <= 0;

                    if(start)
                        state <= LOAD; 
                end

                //LOAD STATE
                LOAD: begin

                    tx_shift <= tx_data;
                    rx_shift <= 0;
                    bit_count <= 0;
                    cs <= 0;
                    mosi <= tx_data[7];
                    state <= TRANSFER;
                    received_all <= 0;

                end

                //TRANSFER STATE
                TRANSFER: begin
                    
                    //RISING EDGE OF SCLK
                    if(count == DIVIDER - 1 && sclk == 1'b0) begin
                        rx_shift <= {rx_shift[6:0], miso};

                        if(bit_count == 3'd7) begin
                            rx_data <= {rx_shift[6:0], miso};
                            received_all <= 1'b1;
                        end
                        else begin
                            bit_count <= bit_count + 1'b1;
                        end
                    end

                    //FALLING EDGE OF SCLK
                    else if(count == DIVIDER - 1 && sclk == 1'b1) begin
                        
                        if(received_all == 1'b1) begin
                            state <= DONE;
                        end
                        
                        else begin
                            tx_shift <= {tx_shift[6:0], 1'b0};
                            mosi <= tx_shift[6];
                        end
                    end
                    
                end 

                //DONE STATE
                DONE: begin

                    cs <= 1'b1;
                    mosi <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;

                end

            endcase
        end 
    end

endmodule


