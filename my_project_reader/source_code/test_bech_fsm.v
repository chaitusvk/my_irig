`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.08.2019 16:47:55
// Design Name: 
// Module Name: test_bech_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_bech_fsm();

reg clk;
reg irig_d0;
wire irig_d0_out;
wire [1:0] state_vec;

single_clk_fsm UUT(
    .irig_d0(irig_d0),
    .clk(clk),
    .irig_d0_out(irig_d0_out),
    .state_vec(state_vec)
    );
    
   initial
   begin
    clk =1'b0;
    irig_do = 1'b0;
    #14 irig_do = 1'b1;
    #10 irig_do = 1'b0;
    #5  irig_do = 1'b1;
    #10 irig_do = 1'b0;
    #100 $stop;
   end
    
    always
    #1 clk <= ~clk;
endmodule
