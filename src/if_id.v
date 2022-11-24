`timescale 1ns/1ps
`include "./src/defines.v"
module if_id(
    input wire clk,
    input wire rst,
    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus]     if_inst,
    input wire[5:0] stall,
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus]   id_inst
);
//（1）当stall[1]为Stop,stall[2]为NoStop,表示取指阶段暂停，而译码阶段继续，所以空指令进入下一阶段的译码阶段
// （2）stall[1]为NoStop的时候，取指阶段继续，取得的指令进入译码阶段。
//（3）其余情况下，保持译码阶段的寄存器不变
    always @(posedge clk) begin
        if(rst ==`RstEnable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else if(stall[1] == `Stop && stall[2] == `NoStop)begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (stall[1] == `NoStop) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule