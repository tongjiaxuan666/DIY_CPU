`timescale 1ns/1ps
`include "./src/defines.v"
module openmips_min_sopc_tb();

reg CLOCK_50;
reg rst;
//every 10 ns reverse clock
 initial begin
    CLOCK_50 = 1'b0;
    forever #10 CLOCK_50 = ~CLOCK_50;
 end

 initial begin
    rst =`RstEnable;
    #195 rst = `RstDisable;
    #10000 $finish;
 end
 openmips_min_sopc  openmips_min_sopc0(
    .clk(CLOCK_50),
    .rst(rst)
 );
 initial begin
	$fsdbDumpfile("tb.fsdb");
	$fsdbDumpvars("+all");
end
 endmodule
