`timescale 1ns/1ps
`include "./src/defines.v"
module id (
    //处于执行阶段的指令运算结果
    input wire ex_wreg_i,
    input wire[`RegBus] ex_wdata_i,
    input wire[`RegAddrBus] ex_wd_i,
    //处于访存阶段指令运算结果
    input wire mem_wreg_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus] mem_wd_i,
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
reg instvalid;
//stage one : decode
always @(*) begin
    if(rst ==`RstEnable) begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o   <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstValid;
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
        instvalid <= `InstInvaild;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21];//default read from regfile pole one
        reg2_addr_o <= inst_i[20:16];//default read from regfile pole two
        imm <= `ZeroWord;       
    case (op)
        `EXE_SPECIAL_INST: begin
            case(op2)
            5'b00000:   begin
                case(op3) 
                    `EXE_OR:    begin
                        wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_OR_OP;
                        alusel_o <= `EXE_RES_LOGIC; 	
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b1;
                        instvalid <= `InstValid;	
                    end  
                    `EXE_AND:	begin
		    			wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_AND_OP;
		  				alusel_o <= `EXE_RES_LOGIC;	  
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b1;	
		  				instvalid <= `InstValid;	
					end 
                    `EXE_XOR:	begin
		    			wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_XOR_OP;
		  				alusel_o <= `EXE_RES_LOGIC;		
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b1;	
		  				instvalid <= `InstValid;	
					end  
                    `EXE_NOR:	begin
		    			wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_NOR_OP;
		  				alusel_o <= `EXE_RES_LOGIC;		
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b1;	
		  				instvalid <= `InstValid;	
					end 
                    `EXE_SLLV: begin
						wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_SLL_OP;
		  				alusel_o <= `EXE_RES_SHIFT;		
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b1;
		  				instvalid <= `InstValid;	
					end 
                    `EXE_SRLV: begin
					    wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_SRL_OP;
		  				alusel_o <= `EXE_RES_SHIFT;		
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b1;
		  				instvalid <= `InstValid;	
					end 
                    `EXE_SRAV: begin
						wreg_o <= `WriteEnable;		
                        aluop_o <= `EXE_SRA_OP;
		  				alusel_o <= `EXE_RES_SHIFT;		
                        reg1_read_o <= 1'b1;	
                        reg2_read_o <= 1'b1;
		  				instvalid <= `InstValid;			
		  			end
                    `EXE_SYNC: begin
						wreg_o <= `WriteDisable;		
                        aluop_o <= `EXE_NOP_OP;
		  				alusel_o <= `EXE_RES_NOP;		
                        reg1_read_o <= 1'b0;	
                        reg2_read_o <= 1'b1;
		  				instvalid <= `InstValid;	
					end
                    default:begin
					end
                endcase//op3
            end
            default: begin
                
            end
            endcase//op2
        end    
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
            instvalid <= `InstValid;
            end 
        `EXE_ANDI:	begin
		  	wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_AND_OP;
		  	alusel_o <= `EXE_RES_LOGIC;	
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
			imm <= {16'h0, inst_i[15:0]};		
            wd_o <= inst_i[20:16];		  	
			instvalid <= `InstValid;	
			end	 

	    `EXE_XORI:	begin
		  	wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_XOR_OP;
		  	alusel_o <= `EXE_RES_LOGIC;	
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
			imm <= {16'h0, inst_i[15:0]};		
            wd_o <= inst_i[20:16];		  	
			instvalid <= `InstValid;	
			end	
        `EXE_LUI:	begin
		  	wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_OR_OP;
		  	alusel_o <= `EXE_RES_LOGIC; 
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b0;	  	
			imm <= {inst_i[15:0], 16'h0};		
            wd_o <= inst_i[20:16];		  	
			instvalid <= `InstValid;	
			end		
		`EXE_PREF:	begin
		  	wreg_o <= `WriteDisable;		
            aluop_o <= `EXE_NOP_OP;
		  	alusel_o <= `EXE_RES_NOP; 
            reg1_read_o <= 1'b0;	
            reg2_read_o <= 1'b0;	  	  	
			instvalid <= `InstValid;	
			end 
        default: begin
            
        end
    endcase// case op
    if (inst_i[31:21] == 11'b00000000000) begin
		if (op3 == `EXE_SLL) begin
		  	wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_SLL_OP;
		  	alusel_o <= `EXE_RES_SHIFT; 
            reg1_read_o <= 1'b0;	
            reg2_read_o <= 1'b1;	  	
			imm[4:0] <= inst_i[10:6];		
            wd_o <= inst_i[15:11];
			instvalid <= `InstValid;	
		end else if ( op3 == `EXE_SRL ) begin
		  	wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_SRL_OP;
		  	alusel_o <= `EXE_RES_SHIFT; 
            reg1_read_o <= 1'b0;	
            reg2_read_o <= 1'b1;	  	
			imm[4:0] <= inst_i[10:6];		
            wd_o <= inst_i[15:11];
			instvalid <= `InstValid;	
		end else if ( op3 == `EXE_SRA ) begin
		  	wreg_o <= `WriteEnable;		
            aluop_o <= `EXE_SRA_OP;
		  	alusel_o <= `EXE_RES_SHIFT; 
            reg1_read_o <= 1'b0;	
            reg2_read_o <= 1'b1;	  	
			imm[4:0] <= inst_i[10:6];		
            wd_o <= inst_i[15:11];
			instvalid <= `InstValid;	
		end
	end	
    end //if
end // always
//stage two : confirm source data one
//第五章增加了两种情况，如果Regfile模块读端口1或2读取的寄存器就是执行阶段要写的目的寄存器，那么直接把执行阶段的结果作为reg1_o的值
//二是读取的寄存器就是访问存储器阶段要写的寄存器，那么直接将访问存储器的结果作为reg的值
always @(*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
        reg1_o <= ex_wdata_i;
    end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
        reg1_o <= mem_wdata_i;
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
    end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
        reg2_o <= ex_wdata_i;
    end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
        reg2_o <= mem_wdata_i;
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i; // Regfile Readone as input
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm; //imediate num
    end else begin
        reg2_read_o <=`ZeroWord;
    end
end
endmodule