`timescale 1ns/1ps

module spi_slave(

    //Input
    input clk,
    input reset,
    input cs,
    input sclk,
    input mosi,
    input [7:0] tx_data,

    //Output
    output reg miso,
    output reg [7:0] rx_data,
    output reg done
);

reg [7:0] tx_shift;
reg [7:0] rx_shift;
reg [2:0] bit_count;

reg sclk_prev;
reg cs_prev;


always@(posedge clk or posedge reset) begin
    
    if(reset) begin
        tx_shift <= 0;
        rx_shift <= 0;
        bit_count <= 0;
        miso <= 0;
        rx_data <= 0;
        done <= 0;
        sclk_prev <= 0;
        cs_prev <= 1;
    end

    else begin
        sclk_prev <= sclk;
        cs_prev <= cs;
        done <= 0;

        if(cs) begin
            bit_count <= 0;
            rx_shift <= 0;
            miso <= 0;
        end

        else if(cs_prev) begin
            tx_shift <= tx_data;
            rx_shift <= 0;
            bit_count <= 0;
            miso <= tx_data[7];
        end

        else begin
            

            //Receive data on rising sclk edge
            if(sclk && !sclk_prev) begin
                rx_shift <= {rx_shift[6:0], mosi};

                if(bit_count == 7) begin
                    rx_data <= {rx_shift[6:0], mosi};
                    done <= 1;
                end

                else begin
                    bit_count <= bit_count + 1'b1;
                end

            end


            //Transmit data on falling sclk edge
            else if(!sclk && sclk_prev) begin
                tx_shift <= {tx_shift[6:0], 1'b0};
                miso <= tx_shift[6];
            end

        end 
    end

end

endmodule