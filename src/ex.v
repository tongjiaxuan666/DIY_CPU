`timescale 1ns/1ps
`include "./src/defines.v"
module ex (
    input wire rst,
    // from id to ex
    input wire[`AluOpBus] aluop_i,
    input wire[`AluSelBus] alusel_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    //the result to output
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o
);
//save the result of symbol compute
    reg[`RegBus] logicout;
//stage one: compute with aluop_i
    always @(*) begin
        if(rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case(aluop_i) 
                `EXE_OR_OP:begin
                    logicout <= reg1_i | reg2_i;
                end
                default: begin
                    logicout <= `ZeroWord;
                end
            endcase
        end//if
    end//always
//stage two: compute instead of alusel_i
    always @(*) begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;
            end 
            default: begin
                wdata_o <= `ZeroWord;
            end
        endcase
    end
    
endmodule