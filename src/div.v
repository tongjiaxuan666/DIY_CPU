`timescale 1ns/1ps
`include "./src/defines.v"
module div (
    input wire clk,
    input wire rst,
    input wire signed_div_i,
    input wire[31:0] opdata1_i,
    input wire[31:0] opdata2_i,
    input wire start_i,
    input wire annul_i,
    output reg[63:0] result_o,
    output reg ready_o
);
wire[32:0] div_temp;
reg[5:0] cnt;//试商法进行了第几轮，当等于32的时候，试商法结束
reg[64:0]dividend;
reg[1:0] state;
reg[31:0] divisor;
reg[31:0] temp_op1;
reg[31:0] temp_op2;
//dividend 的低32位保存的是被除数，中间结果，第k次迭代后dividend[k:0]保存的就是当前得到的中间结果
//dividend[31:k+1]就是被除数还没有参与到运算中的数据，dividend高32位就是每次迭代的被减数，所以dividend[63:32]
//就是minuend,divisor就是除数n,此处进行的就是minuend-n运算，结果保存在div_temp
assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        state <= `DivFree;
        ready_o <= `DivResultNotReady;
        result_o <= {`ZeroWord,`ZeroWord};
    end else begin
        case(state)
        `DivFree:begin//DivFree状态
            if(start_i == `DivStart && annul_i == 1'b0) begin
                if(opdata2_i == `ZeroWord) begin
                    state <= `DivByZero; //除数为0
                end else begin//除数不为零
                    state <= `DivOn;
                    cnt <= 6'b000000;
                    if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin
		  					temp_op1 = ~opdata1_i + 1;
		  				end else begin
		  					temp_op1 = opdata1_i;
		  				end
		  				if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin
		  					temp_op2 = ~opdata2_i + 1;
		  				end else begin
		  					temp_op2 = opdata2_i;
		  				end
		  				dividend <= {`ZeroWord,`ZeroWord};
                        dividend[32:1] <= temp_op1;
                        divisor <= temp_op2;
                end
            end else begin //没有开始除法运算
				ready_o <= `DivResultNotReady;
				result_o <= {`ZeroWord,`ZeroWord};
            end
        end
        `DivByZero:		begin               //DivByZero状态
         	dividend <= {`ZeroWord,`ZeroWord};
            state <= `DivEnd;		 		
		end
        //DivOn状态分为三种情况，如果输入信号annul_i为1,表示取消处理器除法运算那么Div模块直接回到Divfree状态
        //如果没有取消除法运算且cnt!=32那么试商法还没有结束，此时div_temp为负数，那么迭代结果是零，如果为正数那么迭代结果为1
        //dividend最低位每次保留迭代结果，同时保持DivOn状态，cnt加1.
        //第三种情况，如果annul_i为零，且cnt=32，那么表示试商法结束，如果是有符号除法，且被除数和除数为一正一负，那么试商法的结果取补码，商
        //和余数都要取补码。商保存在dividend第32位，余数保存在dividend高32位，同时进入DivEnd状态。
        `DivOn: begin //DivOn状态
            if(annul_i == 1'b0)begin
                if(cnt != 6'b100000)begin//cnt不为32试商法还没有结束
                    if(div_temp[32] == 1'b1) begin
                        //如果div_temp[32]为1,表示（minuend - n）结果小于零
                        //将dividend左移一位，这样就将被除数还没有参与运算的最高位加入到下一次迭代的被减数中，同是零追加到中间结果
                        dividend <= {dividend[63:0],1'b0};
                    end else begin
                        //如果div_temp[32]为0,表示运算结果大于零，得到的减法结果与被除数还没有参与运算的最高位加入下一次迭代的被减数中，同时将1追加到中间结果
                        dividend <= {div_temp[31:0],dividend[31:0],1'b1};
                    end
                    cnt <= cnt + 1;
                end else begin //试商法结束
                    if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
                        dividend[31:0] <= (~dividend[31:0] + 1);
                    end
                    if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin              
                        dividend[64:33] <= (~dividend[64:33] + 1);
                    end
                    state <= `DivEnd;
                    cnt <= 6'b000000;            	
                end
            end else begin
		  			state <= `DivFree;
		  	end	
        end
        //除法运算结束，result_o的宽度是64位，其高32位存储余数低32位存储商，设置输出信号为DivResultReady，表示除法结束，然后等待EX模块
        //送来的Divstop命令Div重新回到DivFreez状态
        `DivEnd:	begin               //DivEnd状态
        	result_o <= {dividend[64:33], dividend[31:0]};  
            ready_o <= `DivResultReady;
            if(start_i == `DivStop) begin
          	    state <= `DivFree;
				ready_o <= `DivResultNotReady;
				result_o <= {`ZeroWord,`ZeroWord};       	
            end		  	
		end
        endcase
    end
end
endmodule