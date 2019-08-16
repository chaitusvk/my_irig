`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2019 13:19:40
// Design Name: 
// Module Name: msec_cntr
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


module msec_cntr(
    input clk_in,
    input load,
    input [9:0] data_msec,
    output  msec_count,
    output  carriage
    );
    
    reg [9:0] msec_count_reg;
    always@(negedge clk_in)
    begin
    if(load == 1'b1)
    begin
       msec_count_reg <= data_msec;
    end
    else
    begin
      if(msec_count_reg == 10'b1111100111)
      begin
        msec_count_reg <= 10'b0000000000;
      end
      else
      begin
      msec_count_reg <= msec_count_reg + 1;
      end
    end
    end
    
    assign  msec_count = msec_count_reg;
    assign  carriage = msec_count_reg[9];
endmodule
