`timescale 1ns/1ps
`include "./src/defines.v"
module openmips (
    input wire clk,
    input wire rst,
    input wire[5:0]                int_i,
      //指令wishbone总线
	input wire[`RegBus]           iwishbone_data_i,
	input wire                    iwishbone_ack_i,
	output wire[`RegBus]           iwishbone_addr_o,
	output wire[`RegBus]           iwishbone_data_o,
	output wire                    iwishbone_we_o,
	output wire[3:0]               iwishbone_sel_o,
	output wire                    iwishbone_stb_o,
	output wire                    iwishbone_cyc_o, 
//数据wishbone总线
	input wire[`RegBus]           dwishbone_data_i,
	input wire                    dwishbone_ack_i,
	output wire[`RegBus]           dwishbone_addr_o,
	output wire[`RegBus]           dwishbone_data_o,
	output wire                    dwishbone_we_o,
	output wire[3:0]               dwishbone_sel_o,
	output wire                    dwishbone_stb_o,
	output wire                    dwishbone_cyc_o,

    output wire                    timer_int_o
);
//connect if/id to id
wire[`InstAddrBus] pc;
wire[`InstBus] inst_i;	
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;
//connect id to id/ex
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;
wire id_is_in_delayslot_o;
wire[`RegBus] id_link_address_o;
wire[`RegBus] id_inst_o;
wire[31:0] id_excepttype_o;
wire[`RegBus] id_current_inst_address_o;
//id/ex to ex
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_is_in_delayslot_i;	
wire[`RegBus] ex_link_address_i;
wire[`RegBus] ex_inst_i;
wire[31:0] ex_excepttype_i;	
wire[`RegBus] ex_current_inst_address_i;
//ex to ex_mem
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;
wire[`RegBus] ex_hi_o;
wire[`RegBus] ex_lo_o;
wire ex_whilo_o;
wire[`AluOpBus] ex_aluop_o;
wire[`RegBus] ex_mem_addr_o;
wire[`RegBus] ex_reg1_o;
wire[`RegBus] ex_reg2_o;
wire ex_cp0_reg_we_o;
wire[4:0] ex_cp0_reg_write_addr_o;
wire[`RegBus] ex_cp0_reg_data_o; 
wire[31:0] ex_excepttype_o;
wire[`RegBus] ex_current_inst_address_o;
wire ex_is_in_delayslot_o;
//ex_mem to mem
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;
wire[`RegBus] mem_hi_i;
wire[`RegBus] mem_lo_i;
wire mem_whilo_i;
wire[`AluOpBus] mem_aluop_i;
wire[`RegBus] mem_mem_addr_i;
wire[`RegBus] mem_reg1_i;
wire[`RegBus] mem_reg2_i;	
wire mem_cp0_reg_we_i;
wire[4:0] mem_cp0_reg_write_addr_i;
wire[`RegBus] mem_cp0_reg_data_i;
wire[31:0] mem_excepttype_i;	
wire mem_is_in_delayslot_i;
wire[`RegBus] mem_current_inst_address_i;	
//_mem to mem/wb
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;
wire[`RegBus] mem_hi_o;
wire[`RegBus] mem_lo_o;
wire mem_whilo_o;	
wire mem_LLbit_value_o;
wire mem_LLbit_we_o;
wire mem_cp0_reg_we_o;
wire[4:0] mem_cp0_reg_write_addr_o;
wire[`RegBus] mem_cp0_reg_data_o;	
wire[31:0] mem_excepttype_o;
wire mem_is_in_delayslot_o;
wire[`RegBus] mem_current_inst_address_o;
//mem/wb to regfile
//ex_mem to mem
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;
wire[`RegBus] wb_hi_i;
wire[`RegBus] wb_lo_i;
wire wb_whilo_i;
wire wb_LLbit_value_i;
wire wb_LLbit_we_i;	
wire wb_cp0_reg_we_i;
wire[4:0] wb_cp0_reg_write_addr_i;
wire[`RegBus] wb_cp0_reg_data_i;
wire[31:0] wb_excepttype_i;
wire wb_is_in_delayslot_i;
wire[`RegBus] wb_current_inst_address_i;
//id to regfile
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
//连接执行阶段与hilo模块的输出，读取HI、LO寄存器
wire[`RegBus] 	hi;
wire[`RegBus]   lo;
//连接执行阶段与ex_reg模块，用于多周期的MADD、MADDU、MSUB、MSUBU指令
wire[`DoubleRegBus] hilo_temp_o;
wire[1:0] cnt_o;

wire[`DoubleRegBus] hilo_temp_i;
wire[1:0] cnt_i;
//div ex
wire[`DoubleRegBus] div_result;
wire div_ready;
wire[`RegBus] div_opdata1;
wire[`RegBus] div_opdata2;
wire div_start;
wire div_annul;
wire signed_div;
//跳转指令
wire is_in_delayslot_i;
wire is_in_delayslot_o;
wire next_inst_in_delayslot_o;
wire id_branch_flag_o;
wire[`RegBus] branch_target_address;

wire[5:0] stall;
wire stallreq_from_id;
wire stallreq_from_ex;
wire stallreq_from_if;
wire stallreq_from_mem;
wire LLbit_o;
wire[`RegBus] cp0_data_o;
wire[4:0] cp0_raddr_i;
//异常
wire flush;
wire[`RegBus] new_pc;
wire[`RegBus] cp0_count;
wire[`RegBus]	cp0_compare;
wire[`RegBus]	cp0_status;
wire[`RegBus]	cp0_cause;
wire[`RegBus]	cp0_epc;
wire[`RegBus]	cp0_config;
wire[`RegBus]	cp0_prid; 
wire[`RegBus] latest_epc;

wire rom_ce;

wire[31:0] ram_addr_o;
wire ram_we_o;
wire[3:0] ram_sel_o;
wire[`RegBus] ram_data_o;
wire ram_ce_o;
wire[`RegBus] ram_data_i;
//pc_reg
pc_reg pc_reg0(
    .clk(clk),
    .rst(rst),
	.stall(stall),
    .flush(flush),
	.new_pc(new_pc),
    .branch_flag_i(id_branch_flag_o),
	.branch_target_address_i(branch_target_address),	
    .pc(pc),
    .ce(rom_ce)
);
assign rom_addr_o = pc;
//if/id
if_id if_id0(
    .clk(clk),
    .rst(rst),
    .if_pc(pc),
    .stall(stall),
    .flush(flush),
    .if_inst(rom_data_i),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);
//id module
id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),
  //处于执行阶段的指令要写入的目的寄存器信息
	.ex_wreg_i(ex_wreg_o),
	.ex_wdata_i(ex_wdata_o),
	.ex_wd_i(ex_wd_o),
  //处于访存阶段的指令要写入的目的寄存器信息
	.mem_wreg_i(mem_wreg_o),
	.mem_wdata_i(mem_wdata_o),
	.mem_wd_i(mem_wd_o),
    .is_in_delayslot_i(is_in_delayslot_i),
    //from regfile input
    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),
    //解决load问题
    .ex_aluop_i(ex_aluop_o),
    // output to regfile
    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),
    //output to id/ex
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),
    .excepttype_o(id_excepttype_o),
    .inst_o(id_inst_o),//输出给SRAM
    .next_inst_in_delayslot_o(next_inst_in_delayslot_o),	
	.branch_flag_o(id_branch_flag_o),
	.branch_target_address_o(branch_target_address),       
	.link_addr_o(id_link_address_o),	
	.is_in_delayslot_o(id_is_in_delayslot_o),
    .current_inst_address_o(id_current_inst_address_o),
    .stallreq(stallreq_from_id)
    );
regfile regfile1(
    .clk(clk),
    .rst(rst),
    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i),
    .re1(reg1_read),
    .raddr1(reg1_addr),
    .rdata1(reg1_data),
    .re2(reg2_read),
    .raddr2(reg2_addr),
    .rdata2(reg2_data)
);
//id/ex
id_ex id_ex0(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .flush(flush),
    //message from id
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
    .id_link_address(id_link_address_o),
    .id_is_in_delayslot(id_is_in_delayslot_o),
    .next_inst_in_delayslot_i(next_inst_in_delayslot_o),	
    .id_inst(id_inst_o),
    .id_excepttype(id_excepttype_o),
    .id_current_inst_address(id_current_inst_address_o),	
    //message to ex
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
	.ex_link_address(ex_link_address_i),
  	.ex_is_in_delayslot(ex_is_in_delayslot_i),
	.is_in_delayslot_o(is_in_delayslot_i),
    .ex_inst(ex_inst_i),
    .ex_excepttype(ex_excepttype_i),
    .ex_current_inst_address(ex_current_inst_address_i)	
);
//ex model
ex ex0(
    .rst(rst),
    // message from if/ex
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    .hi_i(hi),
	.lo_i(lo),
    .inst_i(ex_inst_i),
    .wb_hi_i(wb_hi_i),
	.wb_lo_i(wb_lo_i),
	.wb_whilo_i(wb_whilo_i),
	.mem_hi_i(mem_hi_o),
	.mem_lo_i(mem_lo_o),
	.mem_whilo_i(mem_whilo_o),
    .hilo_temp_i(hilo_temp_i),
	.cnt_i(cnt_i),
    //from div
    .div_result_i(div_result),
	.div_ready_i(div_ready), 
    .link_address_i(ex_link_address_i),
	.is_in_delayslot_i(ex_is_in_delayslot_i),	
	.excepttype_i(ex_excepttype_i),
	.current_inst_address_i(ex_current_inst_address_i),
    //访存阶段的指令是否要写CP0，用来检测数据相关
  	.mem_cp0_reg_we(mem_cp0_reg_we_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
    .mem_cp0_reg_data(mem_cp0_reg_data_o),

    //回写阶段的指令是否要写CP0，用来检测数据相关
    .wb_cp0_reg_we(wb_cp0_reg_we_i),
    .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
    .wb_cp0_reg_data(wb_cp0_reg_data_i),

    .cp0_reg_data_i(cp0_data_o),
    .cp0_reg_read_addr_o(cp0_raddr_i),
    
    //向下一流水级传递，用于写CP0中的寄存器
    .cp0_reg_we_o(ex_cp0_reg_we_o),
    .cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
    .cp0_reg_data_o(ex_cp0_reg_data_o),	  
    // output to ex/mem
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .hi_o(ex_hi_o),
    .lo_o(ex_lo_o),
    .whilo_o(ex_whilo_o),
    .hilo_temp_o(hilo_temp_o),
    .cnt_o(cnt_o),	
    //to div
    .div_opdata1_o(div_opdata1),
	.div_opdata2_o(div_opdata2),
	.div_start_o(div_start),
	.signed_div_o(signed_div),
    .aluop_o(ex_aluop_o),
    .mem_addr_o(ex_mem_addr_o),
    .reg2_o(ex_reg2_o),

    .excepttype_o(ex_excepttype_o),
    .is_in_delayslot_o(ex_is_in_delayslot_o),
    .current_inst_address_o(ex_current_inst_address_o),

    .stallreq(stallreq_from_ex)     
);
//ex/mem
ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
    //control
    .stall(stall),
    .flush(flush),
    //from ex
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .ex_hi(ex_hi_o),
	.ex_lo(ex_lo_o),
	.ex_whilo(ex_whilo_o),	
    //to sram
    .ex_aluop(ex_aluop_o),
    .ex_mem_addr(ex_mem_addr_o),
    .ex_reg2(ex_reg2_o),
    .ex_cp0_reg_we(ex_cp0_reg_we_o),
    .ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
    .ex_cp0_reg_data(ex_cp0_reg_data_o),

    .ex_excepttype(ex_excepttype_o),
    .ex_is_in_delayslot(ex_is_in_delayslot_o),
    .ex_current_inst_address(ex_current_inst_address_o),

    .hilo_i(hilo_temp_o),
    .cnt_i(cnt_o),
     //to mem
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_hi(mem_hi_i),
	.mem_lo(mem_lo_i),
    .mem_cp0_reg_we(mem_cp0_reg_we_i),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
    .mem_cp0_reg_data(mem_cp0_reg_data_i),
    //to sram
    .mem_aluop(mem_aluop_i),
    .mem_mem_addr(mem_mem_addr_i),
    .mem_reg2(mem_reg2_i),
	.mem_whilo(mem_whilo_i),
    .mem_excepttype(mem_excepttype_i),
  	.mem_is_in_delayslot(mem_is_in_delayslot_i),
	.mem_current_inst_address(mem_current_inst_address_i),
    .hilo_o(hilo_temp_i),
	.cnt_o(cnt_i)
);
//mem
mem mem0(
    .rst(rst),
    //from ex/mem
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),

    //LLbit_i是LLbit寄存器的值
    .LLbit_i(LLbit_o),
    //但不一定是最新值，回写阶段可能要写LLbit，所以还要进一步判断
    .wb_LLbit_we_i(wb_LLbit_we_i),
    .wb_LLbit_value_i(wb_LLbit_value_i),

    .LLbit_we_o(mem_LLbit_we_o),
    .LLbit_value_o(mem_LLbit_value_o),
    .hi_i(mem_hi_i),
    .lo_i(mem_lo_i),
    .whilo_i(mem_whilo_i),
    .aluop_i(mem_aluop_i),
    .mem_addr_i(mem_mem_addr_i),
    .reg2_i(mem_reg2_i),
    .cp0_reg_we_i(mem_cp0_reg_we_i),
    .cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
    .cp0_reg_data_i(mem_cp0_reg_data_i),
    .cp0_reg_we_o(mem_cp0_reg_we_o),
    .cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
    .cp0_reg_data_o(mem_cp0_reg_data_o),	

    .excepttype_i(mem_excepttype_i),
    .is_in_delayslot_i(mem_is_in_delayslot_i),
    .current_inst_address_i(mem_current_inst_address_i),
    .cp0_status_i(cp0_status),
    .cp0_cause_i(cp0_cause),
    .cp0_epc_i(cp0_epc),
		
	//回写阶段的指令是否要写CP0，用来检测数据相关
  	.wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i),		
    //来自memory的信息
    .mem_data_i(ram_data_i),
     //to mem/wb
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o), 
    .hi_o(mem_hi_o),
	.lo_o(mem_lo_o),
	.whilo_o(mem_whilo_o),

    //送到memory的信息
    .mem_addr_o(ram_addr_o),
    .mem_we_o(ram_we_o),
    .mem_sel_o(ram_sel_o),
    .mem_data_o(ram_data_o),
    .mem_ce_o(ram_ce_o),

    .excepttype_o(mem_excepttype_o),
    .cp0_epc_o(latest_epc),
    .is_in_delayslot_o(mem_is_in_delayslot_o),
    .current_inst_address_o(mem_current_inst_address_o)
);
//mem/wb
mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .flush(flush),
    //from mem
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    .mem_hi(mem_hi_o),
    .mem_lo(mem_lo_o),
    .mem_whilo(mem_whilo_o),	

    .mem_LLbit_we(mem_LLbit_we_o),
    .mem_LLbit_value(mem_LLbit_value_o),	
    .mem_cp0_reg_we(mem_cp0_reg_we_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
    .mem_cp0_reg_data(mem_cp0_reg_data_o),	
     //to mem
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i),
    .wb_hi(wb_hi_i),
    .wb_lo(wb_lo_i),
    .wb_whilo(wb_whilo_i),
    .wb_LLbit_we(wb_LLbit_we_i),
    .wb_LLbit_value(wb_LLbit_value_i),
    .wb_cp0_reg_we(wb_cp0_reg_we_i),
    .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
    .wb_cp0_reg_data(wb_cp0_reg_data_i)	
);
hilo_reg hilo_reg0(
    .clk(clk),
    .rst(rst),

    //写端口
    .we(wb_whilo_i),
    .hi_i(wb_hi_i),
    .lo_i(wb_lo_i),

    //读端口1
    .hi_o(hi),
    .lo_o(lo)	
);
ctrl ctrl0(
		.rst(rst),
	    .stallreq_from_if(stallreq_from_if),	
		.stallreq_from_id(stallreq_from_id),
		.excepttype_i(mem_excepttype_o),
	    .cp0_epc_i(latest_epc),
  	//来自执行阶段的暂停请求
		.stallreq_from_ex(stallreq_from_ex),
        .stallreq_from_mem(stallreq_from_mem),
        .new_pc(new_pc),
	    .flush(flush),

		.stall(stall)       	
	);
div div0(
		.clk(clk),
		.rst(rst),
	
		.signed_div_i(signed_div),
		.opdata1_i(div_opdata1),
		.opdata2_i(div_opdata2),
		.start_i(div_start),
		.annul_i(flush),
	
		.result_o(div_result),
		.ready_o(div_ready)
	);
LLbit_reg LLbit_reg0(
    .clk(clk),
    .rst(rst),
    .flush(flush),//异常标志位
    
    //写端口
    .LLbit_i(wb_LLbit_value_i),
    .we(wb_LLbit_we_i),

    //读端口1
    .LLbit_o(LLbit_o)

);
cp0_reg cp0_reg0(
    .clk(clk),
    .rst(rst),
    
    .we_i(wb_cp0_reg_we_i),
    .waddr_i(wb_cp0_reg_write_addr_i),
    .raddr_i(cp0_raddr_i),
    .data_i(wb_cp0_reg_data_i),
    
    .excepttype_i(mem_excepttype_o),
    .int_i(int_i),
    .current_inst_addr_i(mem_current_inst_address_o),
    .is_in_delayslot_i(mem_is_in_delayslot_o),
    
    .data_o(cp0_data_o),
    .count_o(cp0_count),
    .compare_o(cp0_compare),
    .status_o(cp0_status),
    .cause_o(cp0_cause),
    .epc_o(cp0_epc),
    .config_o(cp0_config),
    .prid_o(cp0_prid),

    .timer_int_o(timer_int_o)  			
);
wishbone_bus_if dwishbone_bus_if(
    .clk(clk),
    .rst(rst),

    //来自控制模块ctrl
    .stall_i(stall),
    .flush_i(flush),


    //CPU侧读写操作信息
    .cpu_ce_i(ram_ce_o),
    .cpu_data_i(ram_data_o),
    .cpu_addr_i(ram_addr_o),
    .cpu_we_i(ram_we_o),
    .cpu_sel_i(ram_sel_o),
    .cpu_data_o(ram_data_i),

    //Wishbone总线侧接口
    .wishbone_data_i(dwishbone_data_i),
    .wishbone_ack_i(dwishbone_ack_i),
    .wishbone_addr_o(dwishbone_addr_o),
    .wishbone_data_o(dwishbone_data_o),
    .wishbone_we_o(dwishbone_we_o),
    .wishbone_sel_o(dwishbone_sel_o),
    .wishbone_stb_o(dwishbone_stb_o),
    .wishbone_cyc_o(dwishbone_cyc_o),

    .stallreq(stallreq_from_mem)	       
	
);

wishbone_bus_if iwishbone_bus_if(
    .clk(clk),
    .rst(rst),

    //来自控制模块ctrl
    .stall_i(stall),
    .flush_i(flush),

    //CPU侧读写操作信息
    .cpu_ce_i(rom_ce),
    .cpu_data_i(32'h00000000),
    .cpu_addr_i(pc),
    .cpu_we_i(1'b0),
    .cpu_sel_i(4'b1111),
    .cpu_data_o(inst_i),

    //Wishbone总线侧接口
    .wishbone_data_i(iwishbone_data_i),
    .wishbone_ack_i(iwishbone_ack_i),
    .wishbone_addr_o(iwishbone_addr_o),
    .wishbone_data_o(iwishbone_data_o),
    .wishbone_we_o(iwishbone_we_o),
    .wishbone_sel_o(iwishbone_sel_o),
    .wishbone_stb_o(iwishbone_stb_o),
    .wishbone_cyc_o(iwishbone_cyc_o),

    .stallreq(stallreq_from_if)	       
	
);
endmodule