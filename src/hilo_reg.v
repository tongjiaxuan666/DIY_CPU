`timescale 1ns/1ps
`include "./src/defines.v"
module hilo_reg (
    input wire clk,
    input wire rst,
    //write
    input wire we,
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,

    //read
    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o
);
    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end else begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
    end
    
endmodule