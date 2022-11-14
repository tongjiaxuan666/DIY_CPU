`timescale 1ns/1ps
`include "./src/defines.v"
module openmips_min_sopc (
    input wire rst,
    input wire clk
);
//connect reg
wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;
//example openmips
openmips openmips0(
    .clk(clk),
    .rst(rst),
    .rom_addr_o(inst_addr),
    .rom_data_i(inst),
    .rom_ce_o(rom_ce)
);
//example rom
inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr),
    .inst(inst)
);
    
endmodule