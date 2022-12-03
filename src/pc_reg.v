`timescale 1ns/1ps
`include "./src/defines.v"
module pc_reg (
    input wire    clk,
    input wire    rst,
    //来自控制阶段的信息
    input wire[5:0] stall,
    input wire                    flush,
	input wire[`RegBus]           new_pc,
    //来自译码阶段的信息
	input wire                    branch_flag_i,
	input wire[`RegBus]           branch_target_address_i,
    output reg[`InstAddrBus] pc,
    output reg ce
);
    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            ce <= `ChipDisable;
        end
        else begin
            ce <= `ChipEnable;
        end
    end
    always @(posedge clk) begin
        if(ce == `ChipDisable) begin //disable. pc to 0
            pc <= `ZeroWord;
        end else begin
            //输入信号flush = 1为异常发生，将从CTRL模块给出的异常处理地址new_pc开始执行
            if(flush == 1'b1) begin
				pc <= new_pc;
            end else if(stall[0] == `NoStop )begin
                if(branch_flag_i == `Branch) begin
                    pc <= branch_target_address_i;
                end else begin
                    pc <= pc + 4'h4;      //enable pc + 4
                end
            end
        end
    end
endmodule