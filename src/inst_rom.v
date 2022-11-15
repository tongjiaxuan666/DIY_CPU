`timescale 1ns/1ps
`include "./src/defines.v"
module inst_rom (
    input wire ce,
    input wire[`InstAddrBus] addr,
    output reg[`InstBus] inst
);
//define a array which size is InstMemNum,the width is InstBus
reg[`InstBus] inst_mem[0:`InstMemNum - 1];
// use file inst_rom.data to intialize the data reg
initial begin
    $readmemh("./src/TestAsm/inst_rom.data", inst_mem);
end
always @(*) begin
    if(ce == `ChipDisable) begin
        inst <= `ZeroWord;
    end else begin
        inst <= inst_mem[addr[`InstMemNumLog2+1: 2]];
    end
end
    
endmodule