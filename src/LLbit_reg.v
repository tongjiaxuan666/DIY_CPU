module LLbit_reg  (
	input	wire	clk,
	input   wire     rst,
    //这个是判断数据是否有错误
	input wire                    flush,
	//写端口
	input wire										LLbit_i,
	input wire                    we,
	
	//读端口1
	output reg                    LLbit_o
);
    always @ (posedge clk) begin
		if (rst == `RstEnable) begin
					LLbit_o <= 1'b0;
		end else if((flush == 1'b1)) begin
					LLbit_o <= 1'b0;
		end else if((we == `WriteEnable)) begin
					LLbit_o <= LLbit_i;
		end
	end
endmodule