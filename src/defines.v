// global define
`define RstEnable 1'b1
`define RstDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus    7:0 //the width of translation aluop_o
`define AluSelBus   2:0 //the width of translation alusel_o
`define InstVaild   1'b0 //vaild operator
`define InstInvaild 1'b1 //invaild operator
`define True_v      1'b1//meaning true
`define False_v     1'b0//meaning false
`define ChipDisable 1'b0
`define ChipEnable  1'b1
// something about operator
`define EXE_ORI 6'b001101     //the order of ori
`define EXE_NOP 6'b000000


//AluOp
`define EXE_OR_OP   8'b00100101
`define EXE_NOP_OP  8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_NOP   3'b000
//instruction memory about rom
`define ZeroWord    32'h00000000
`define InstAddrBus 31:0  //address
`define InstBus     31:0 //Data
`define InstMemNum  131071 //rom fact size 128K
`define InstMemNumLog2 17     //the real width of rom


//************************ reg total define
`define RegAddrBus  4:0   //regfile addr width
`define RegBus      31:0  //regfile data width
`define RegWidth    32    //in common use reg width
`define DoubleRegwidth 64 // double reg width
`define DoubleRegBus  63:0 //double data width
`define RegNum        32 //the num of reg
`define RegNumLog2    5 //the num of common reg
`define NOPRegAddr    5'b00000