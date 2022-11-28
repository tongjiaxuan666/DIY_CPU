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
    //HI、LO寄存器的值
	input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,
    //增加输入接口
	input wire[`DoubleRegBus]     hilo_temp_i,
	input wire[1:0]               cnt_i,
	//回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
	input wire[`RegBus]           wb_hi_i,
	input wire[`RegBus]           wb_lo_i,
	input wire                    wb_whilo_i,
	//与除法模块相连
	input wire[`DoubleRegBus]     div_result_i,
	input wire                    div_ready_i,
	//访存阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
	input wire[`RegBus]           mem_hi_i,
	input wire[`RegBus]           mem_lo_i,
	input wire                    mem_whilo_i,
	//是否转移、以及link address
	input wire[`RegBus]           link_address_i,
	input wire                    is_in_delayslot_i,	
    //the result to output
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
    output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	output reg                    whilo_o,
    //增加输出接口
    output reg[`DoubleRegBus]     hilo_temp_o,
	output reg[1:0]               cnt_o,
	//新增除法模块的除数
	output reg[`RegBus]           div_opdata1_o,
	output reg[`RegBus]           div_opdata2_o,
	output reg                    div_start_o,
	output reg                    signed_div_o,
	output reg		stallreq       

);
//save the result of symbol compute
    reg[`RegBus] logicout;
    reg[`RegBus] shiftres; // save shift result
	reg[`RegBus] moveres; //save move result
	reg[`RegBus] HI;     //special reg HI
	reg[`RegBus] LO;    //special reg LO
    reg[`RegBus] arithmeticres;//保存算数运算的结果
	reg[`DoubleRegBus] mulres;//保存乘法结果宽度为64位
    reg stallreq_for_madd_msub;	           
	reg stallreq_for_div;//由于除法模块导致流水线暂停                                                                                                      
    wire[`RegBus] reg2_i_mux;//保存第二个操作数reg2_i的补码
	wire[`RegBus] reg1_i_not;//保存第一个操作数reg1_i取反后的值
	wire[`RegBus] result_sum;//保存加法的结果
	wire ov_sum; //保存溢出情况
	wire reg1_eq_reg2;//第一个操作数是否等于第二个操作数
	wire reg1_lt_reg2;//第一个操作数是否小于第二个操作数
	wire[`RegBus] opdata1_mult;//乘法操作中的被乘数
	wire[`RegBus] opdata2_mult;//乘法操作中的乘数
	wire[`DoubleRegBus] hilo_temp;//临时保存乘法结果，宽度为64位
    reg[`DoubleRegBus] hilo_temp1;//用于累加累乘
//stage one: compute with aluop_i
    always @(*) begin
        if(rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case(aluop_i) 
                `EXE_OR_OP:begin
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP:begin
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_NOR_OP:begin                    
                    logicout <= ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP:begin
                    logicout <= reg1_i ^ reg2_i;
                end
                default: begin
                    logicout <= `ZeroWord;
                end
            endcase
        end//if
    end//always
// shift
always @(*) begin
    if(rst == `RstEnable) begin
        shiftres <= `ZeroWord;
    end else begin
        case(aluop_i) 
            `EXE_SLL_OP:begin
                shiftres <= reg2_i << reg1_i[4:0];
            end
            `EXE_SRL_OP:begin
                shiftres <= reg2_i >> reg1_i[4:0];
            end
            `EXE_SRA_OP:begin
                shiftres <= ({32{reg2_i[31]}}<<(6'd32-{1'b0,reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
            end
            default: begin
                shiftres <= `ZeroWord;
            end
        endcase
        end//if
end
//算数运算的第一段，算出下面五个变量的值
//（1） 如果是减法或者有符号比较运算，那么reg2_i_mux等于第二个操作数reg2_i的补码
//否则reg2_i_mux直接等于reg2_i
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || 
                     (aluop_i == `EXE_SUBU_OP) ||
					 (aluop_i == `EXE_SLT_OP) ) ? 
                     (~reg2_i)+1 : reg2_i;
//(2)分三种情况：
    //A：如果是加法运算：此时reg2_i_mux就是第二个操作数reg2_i,所以result_sum就是
    //加法运算的结果。
    //B：如果是减法运算：此时reg2_i_mux就是第二个操作数reg2_i的补码，所以result_sum
    //为减法运算的结果
    //C：如果是符号比较运算：如果是有符号比较运算，此时reg2_i_mux也就是第二个操作数reg2_i
    //的补码，所以result_sum是减法运算的结果，可以通过判断减法的结果是否小于零，进而判断
    //第一个操作数是否小于第二个操作数
assign result_sum = reg1_i + reg2_i_mux;
//（3）计算是否溢出，加法指令（add 和 addi）,减法指令（sub）执行的过程，需要判断是否
//溢出，满足以下两种情况之一有溢出。
//  A：reg1_i 为正数，reg2_i_mux为正数，但是两者之和为负数
//  B：reg1_i 为负数，reg_i_mux为负数，但是两者之和为正数
assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
				((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));  
//（4）计算操作数1是否小于操作数2分为两种情况：
//  A：aluop_i为EXE_STL_OP表示有符号比较运算，此时又分为三种情况
//      A1：reg1_i为负数，reg2_i为正数，显然reg1_i小于reg2_i
//      A2:reg1_i 为正数，reg2_i为正数，并且reg1_i减去reg2_i的值小于零（即result_sum为负数），
//      此时reg1_i<reg2_i
//      A3:reg1_i为负数，reg2_i为负数，并且reg1_i减去reg2_i的值小于零（即result_sum为负数），
//        此时reg1_i<reg2_i
//  B:无符号数比较可以直接用比较运算符比较reg1_i和reg2_i
assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ?
					((reg1_i[31] && !reg2_i[31]) || 
					 (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
			        (reg1_i[31] && reg2_i[31] && result_sum[31]))
			         :	(reg1_i < reg2_i);
//(5)对操作数1取反
assign reg1_i_not = ~reg1_i;
//算数运算第二段，根据不同的运算类型，给arithmeticres赋值
always @ (*) begin
		if(rst == `RstEnable) begin
			arithmeticres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP:		begin
					arithmeticres <= reg1_lt_reg2 ;
				end
				`EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:		begin
					arithmeticres <= result_sum; 
				end
				`EXE_SUB_OP, `EXE_SUBU_OP:		begin
					arithmeticres <= result_sum; 
				end		
				`EXE_CLZ_OP:		begin
					arithmeticres <= reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
				end
				`EXE_CLO_OP:		begin
					arithmeticres <= (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
													 reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
													 reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
													 reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
													 reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
													 reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
													 reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
													 reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
													 reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
													 reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
													 reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;
				end
				default:				begin
					arithmeticres <= `ZeroWord;
				end
			endcase
		end
	end
//算数运算第三段进行乘法运算
//（1）取得乘法运算的被乘数如果有符号乘法且被乘数为负数取补码
//得到最新的HI、LO寄存器的值，此处要解决指令数据相关问题
assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) 
                    || (aluop_i == `EXE_MULT_OP)
                    ||(aluop_i == `EXE_MADD_OP) 
                    || (aluop_i == `EXE_MSUB_OP))
					&& (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
//（2）取得乘法的乘数，如果为有符号乘法且乘数为负数取补码
assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) 
                    || (aluop_i == `EXE_MULT_OP)
                    ||(aluop_i == `EXE_MADD_OP) 
                    || (aluop_i == `EXE_MSUB_OP))
                    && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;	
//（3）得到临时乘法结果，保存在变量hilo_temp中
assign hilo_temp = opdata1_mult * opdata2_mult;
always @ (*) begin
    if(rst == `RstEnable) begin
        mulres <= {`ZeroWord,`ZeroWord};
    end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)||(aluop_i == `EXE_MADD_OP)||(aluop_i == `EXE_MSUB_OP))begin
        if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin
            mulres <= ~hilo_temp + 1;
        end else begin
            mulres <= hilo_temp;
        end
    end else begin
            mulres <= hilo_temp;
    end
end
always @ (*) begin
    if(rst == `RstEnable) begin
        {HI,LO} <= {`ZeroWord,`ZeroWord};
    end else if(mem_whilo_i == `WriteEnable) begin
        {HI,LO} <= {mem_hi_i,mem_lo_i};
    end else if(wb_whilo_i == `WriteEnable) begin
        {HI,LO} <= {wb_hi_i,wb_lo_i};
    end else begin
        {HI,LO} <= {hi_i,lo_i};			
    end
end
//MFHI、MFLO、MOVN、MOVZ指令
always @ (*) begin
    if(rst == `RstEnable) begin
        moveres <= `ZeroWord;
    end else begin
        moveres <= `ZeroWord;
    case (aluop_i)
    `EXE_MFHI_OP:		begin
        moveres <= HI;
    end
    `EXE_MFLO_OP:		begin
        moveres <= LO;
    end
    `EXE_MOVZ_OP:		begin
        moveres <= reg1_i;
    end
    `EXE_MOVN_OP:		begin
        moveres <= reg1_i;
    end
    default : begin
    end
    endcase
    end
end
// MADD， MADDU，MSUB，MSUBU指令
always @ (*) begin
		if(rst == `RstEnable) begin
			hilo_temp_o <= {`ZeroWord,`ZeroWord};
			cnt_o <= 2'b00;
			stallreq_for_madd_msub <= `NoStop;
		end else begin
			case (aluop_i) 
				`EXE_MADD_OP, `EXE_MADDU_OP:		begin
					if(cnt_i == 2'b00) begin //第一时钟周期暂停流水线
						hilo_temp_o <= mulres;
						cnt_o <= 2'b01;
						stallreq_for_madd_msub <= `Stop;
						hilo_temp1 <= {`ZeroWord,`ZeroWord};
					end else if(cnt_i == 2'b01) begin//第二时钟周期累加重新启动流水线
						hilo_temp_o <= {`ZeroWord,`ZeroWord};						
						cnt_o <= 2'b10;
						hilo_temp1 <= hilo_temp_i + {HI,LO};
						stallreq_for_madd_msub <= `NoStop;
					end
				end
				`EXE_MSUB_OP, `EXE_MSUBU_OP:		begin
					if(cnt_i == 2'b00) begin
						hilo_temp_o <=  ~mulres + 1 ;
						cnt_o <= 2'b01;
						stallreq_for_madd_msub <= `Stop;
					end else if(cnt_i == 2'b01)begin
						hilo_temp_o <= {`ZeroWord,`ZeroWord};						
						cnt_o <= 2'b10;
						hilo_temp1 <= hilo_temp_i + {HI,LO};
						stallreq_for_madd_msub <= `NoStop;
					end				
				end
				default:	begin
					hilo_temp_o <= {`ZeroWord,`ZeroWord};
					cnt_o <= 2'b00;
					stallreq_for_madd_msub <= `NoStop;				
				end
			endcase
		end
	end	

  //DIV、DIVU指令，输出div模块的控制信息，获取div模块给出的结果
	always @ (*) begin
		if(rst == `RstEnable) begin
			stallreq_for_div <= `NoStop;
	    	div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
		end else begin
			stallreq_for_div <= `NoStop;
	    	div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;	
			case (aluop_i) 
				`EXE_DIV_OP:		begin
					if(div_ready_i == `DivResultNotReady) begin
	    				div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b1;
						stallreq_for_div <= `Stop;
					end else if(div_ready_i == `DivResultReady) begin
	    				div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b1;
						stallreq_for_div <= `NoStop;
					end else begin						
	    				div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end					
				end
				`EXE_DIVU_OP:		begin
					if(div_ready_i == `DivResultNotReady) begin
	    				div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `Stop;
					end else if(div_ready_i == `DivResultReady) begin
	    				div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end else begin						
	    				div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end					
				end
				default: begin
				end
			endcase
		end
	end
    //流水线暂停：chapter7.1只有累加乘和累加减法指令会让流水线暂停，所以stallreq直接等于stallreq_for_madd_msub
always @ (*) begin
    stallreq = stallreq_for_madd_msub||stallreq_for_div;
end
//stage two: compute instead of alusel_i
    always @(*) begin
        wd_o <= wd_i;
        //如果是add,addi,sub,subi，且发生溢出，那么不写入默认寄存器
        if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || 
            (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
            wreg_o <= `WriteDisable;
        end else begin
            wreg_o <= wreg_i;
        end
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;
            end 
            `EXE_RES_SHIFT:begin
                wdata_o <= shiftres;
            end
	 	    `EXE_RES_MOVE:		begin
	 		    wdata_o <= moveres;
	 	    end
            `EXE_RES_ARITHMETIC:	begin
	 		    wdata_o <= arithmeticres;
	 	    end
	 	    `EXE_RES_MUL:		begin
	 		    wdata_o <= mulres[31:0];
	 	    end	
			`EXE_RES_JUMP_BRANCH:	begin
	 			wdata_o <= link_address_i;
	 		end	 
            default: begin
                wdata_o <= `ZeroWord;
            end
        endcase
    end
    //rewrite hi lo
	always @ (*) begin
		if(rst == `RstEnable) begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;	
        end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
			whilo_o <= `WriteEnable;
			hi_o <= mulres[63:32];
			lo_o <= mulres[31:0];	
        end else if((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
			whilo_o <= `WriteEnable;
			hi_o <= hilo_temp1[63:32];
			lo_o <= hilo_temp1[31:0];
		end else if((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
			whilo_o <= `WriteEnable;
			hi_o <= hilo_temp1[63:32];
			lo_o <= hilo_temp1[31:0];	
		end else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
			whilo_o <= `WriteEnable;
			hi_o <= div_result_i[63:32];
			lo_o <= div_result_i[31:0];	
		end else if(aluop_i == `EXE_MTHI_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= reg1_i;
			lo_o <= LO;
		end else if(aluop_i == `EXE_MTLO_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= HI;
			lo_o <= reg1_i;
		end else begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end				
	end	
    
endmodule