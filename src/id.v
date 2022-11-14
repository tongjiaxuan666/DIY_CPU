`timescale 1ns/1ps
`include "./src/defines.v"
module id (
    input wire     rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,
    //read the value of Regfile
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,
    //output to Regfile
    output reg          reg1_read_o,
    output reg          reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,
    //output to execute stage
    output reg[`AluOpBus] aluop_o,
    output reg[`AluSelBus] alusel_o,
    output reg[`RegBus]   reg1_o,
    output reg[`RegBus]   reg2_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o
);
//get order num and get function
//[26-31] is for ori ,you can judge if ori from it
wire[5:0] op = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];
// save need imediate num
reg[`RegBus] imm;
//judge vaildable
reg instvaild;
//stage one : decode
always @(*) begin
    if(rst ==`RstEnable) begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o   <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvaild <= `InstVaild;
        reg1_read_o <= 1'b0;
        reg2_addr_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= 32'h0;
    end else begin
         aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o   <= inst_i[15:11];
        wreg_o <= `WriteDisable;
        instvaild <= `InstInvaild;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21];//default read from regfile pole one
        reg2_addr_o <= inst_i[20:16];//default read from regfile pole two
        imm <= `ZeroWord;       
    case (op)
        `EXE_ORI:   begin
        //ori want to write in wanted write,so put wreg_o to writeable
        wreg_o <= `WriteEnable;
        //the subkind of compute is or
        aluop_o <= `EXE_OR_OP;
        //the kind of compute is  logic
        alusel_o <= `EXE_RES_LOGIC;
        //need Regfile one to read pole one
        reg1_read_o <= 1'b1;
        // not need Regfile two to read pole two
        reg2_read_o <= 1'b0;
        //execute immediate num
        imm <= {16'h0, inst_i[15:0]};
        //execute where you want to write in
        wd_o <= inst_i[20:16];
        // ori is Vaild;
        instvaild <= `InstVaild;
        end 
        default: begin
            
        end
    endcase// case op
    end //if
end // always
//stage two : confirm source data one
always @(*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i; // Regfile Readone as input
    end else if (reg1_read_o == 1'b0) begin
        reg1_o <= imm; //imediate num
    end else begin
        reg1_read_o <=`ZeroWord;
    end
end
//stage three : confirm source data two
always @(*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg1_data_i; // Regfile Readone as input
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm; //imediate num
    end else begin
        reg2_read_o <=`ZeroWord;
    end
end
endmodule