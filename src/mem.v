`timescale 1ns/1ps
`include "./src/defines.v"
module mem (
    input wire rst,
    //come from execiton
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,
    //output result
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o 
);
always @(*) begin
    if(rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteEnable;
        wdata_o <= `ZeroWord;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
    end
end
    
endmodule