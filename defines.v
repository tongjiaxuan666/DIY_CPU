`define RstEnable 1'b1 //resnet vaild
`define RstDisable 1'b0 //resnet invaild
`define ZeroWord 32'b00000000// 32bit 0
`define WriteEnable 1'b1 //enable to write
`define WriteDisable 1'b0 // disable to write
`define ReadEnable 1'b1 //enable to read
`define ReadDisable 1'b0 //disable to read
`define ChipEnable 1'b1 // enable chip work
`define ChipDisable 1'b0 //disable chip work
// *************************** define about rom ******************************
`define InstAddrBus 31:0 //the width of rom address