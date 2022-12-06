`timescale 1ns/1ps
`include "./src/defines.v"
module wishbone_bus_if(

	input	wire	clk,
	input wire		rst,
	
	//来自ctrl模块
	input wire[5:0]               stall_i,//ctrl传入流水线暂停信号
	input                         flush_i,//ctrl传入流水线清除信号
	
	//CPU侧的接口
	input wire                    cpu_ce_i,//来自处理器的访问请求信号
	input wire[`RegBus]           cpu_data_i,//来自处理器的数据
	input wire[`RegBus]           cpu_addr_i,//来自处理器的地址
	input wire                    cpu_we_i,//处理器写操作指示信号
	input wire[3:0]               cpu_sel_i,//处理器选择信号
	output reg[`RegBus]           cpu_data_o,//输出到处理器的数据
	
	//Wishbone侧的接口
	input wire[`RegBus]           wishbone_data_i,//wishbone总线输入数据
	input wire                    wishbone_ack_i,//wishbone总线输入的响应
	output reg[`RegBus]           wishbone_addr_o,//总线输出地址
	output reg[`RegBus]           wishbone_data_o,//总线输出的数据
	output reg                    wishbone_we_o,//总线的写使能信号
	output reg[3:0]               wishbone_sel_o,//总线的字节选择信号
	output reg                    wishbone_stb_o,//总线选通信号
	output reg                    wishbone_cyc_o,//总线周期信号

	output reg                    stallreq	       
	
);
reg[1:0] wishbone_state;//保存wishbone总线接口的状态
reg[`RegBus] rd_buf;//寄存通过wishbone总线访问到的数据
always @(posedge clk) begin
    if(rst == `RstEnable) begin
			wishbone_state <= `WB_IDLE;
			wishbone_addr_o <= `ZeroWord;
			wishbone_data_o <= `ZeroWord;
			wishbone_we_o <= `WriteDisable;
			wishbone_sel_o <= 4'b0000;
			wishbone_stb_o <= 1'b0;
			wishbone_cyc_o <= 1'b0;
			rd_buf <= `ZeroWord;
//			cpu_data_o <= `ZeroWord;
    end else begin
        case (wishbone_state)
            `WB_IDLE:		begin
                if((cpu_ce_i == 1'b1) && (flush_i == `False_v)) begin
                    wishbone_stb_o <= 1'b1;
                    wishbone_cyc_o <= 1'b1;
                    wishbone_addr_o <= cpu_addr_i;
                    wishbone_data_o <= cpu_data_i;
                    wishbone_we_o <= cpu_we_i;
                    wishbone_sel_o <=  cpu_sel_i;
                    wishbone_state <= `WB_BUSY;
                    rd_buf <= `ZeroWord;
//					end else begin
//						wishbone_state <= WB_IDLE;
//						wishbone_addr_o <= `ZeroWord;
//						wishbone_data_o <= `ZeroWord;
//						wishbone_we_o <= `WriteDisable;
//						wishbone_sel_o <= 4'b0000;
//						wishbone_stb_o <= 1'b0;
//						wishbone_cyc_o <= 1'b0;
//						cpu_data_o <= `ZeroWord;			
                end							
            end
            `WB_BUSY:		begin
                if(wishbone_ack_i == 1'b1) begin
                    wishbone_stb_o <= 1'b0;
                    wishbone_cyc_o <= 1'b0;
                    wishbone_addr_o <= `ZeroWord;
                    wishbone_data_o <= `ZeroWord;
                    wishbone_we_o <= `WriteDisable;
                    wishbone_sel_o <=  4'b0000;
                    wishbone_state <= `WB_IDLE;
                    if(cpu_we_i == `WriteDisable) begin
                        rd_buf <= wishbone_data_i;
                    end
                    if(stall_i != 6'b000000) begin
                        wishbone_state <= `WB_WAIT_FOR_STALL;
                    end	
                end else if(flush_i == `True_v) begin
                    wishbone_stb_o <= 1'b0;
                    wishbone_cyc_o <= 1'b0;
                    wishbone_addr_o <= `ZeroWord;
                    wishbone_data_o <= `ZeroWord;
                    wishbone_we_o <= `WriteDisable;
                    wishbone_sel_o <=  4'b0000;
                    wishbone_state <= `WB_IDLE;
                    rd_buf <= `ZeroWord;
					end
			end		
            `WB_WAIT_FOR_STALL:		begin
                if(stall_i == 6'b000000) begin
                    wishbone_state <= `WB_IDLE;
                end
			end
            default: begin
            end 
			endcase
		end    //if
	end      //always
    //组合逻辑电路
    always @ (*) begin
		if(rst == `RstEnable) begin
			stallreq <= `NoStop;
			cpu_data_o <= `ZeroWord;
		end else begin
			stallreq <= `NoStop;
			case (wishbone_state)
				`WB_IDLE:		begin
					if((cpu_ce_i == 1'b1) && (flush_i == `False_v)) begin
						stallreq <= `Stop;
						cpu_data_o <= `ZeroWord;				
					end
				end
				`WB_BUSY:		begin
					if(wishbone_ack_i == 1'b1) begin
						stallreq <= `NoStop;
						if(wishbone_we_o == `WriteDisable) begin
						    cpu_data_o <= wishbone_data_i;  
						end else begin
						    cpu_data_o <= `ZeroWord;
						end							
					end else begin
						stallreq <= `Stop;	
						cpu_data_o <= `ZeroWord;				
					end
				end
				`WB_WAIT_FOR_STALL:		begin
					stallreq <= `NoStop;
					cpu_data_o <= rd_buf;
				end
				default: begin
				end 
			endcase
		end    //if
	end      //always
endmodule