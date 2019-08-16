`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.08.2019 15:33:07
// Design Name: 
// Module Name: single_clk_fsm
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


module single_clk_fsm(
    input irig_d0,
    input clk,
    output reg irig_d0_out,
    output [1:0] state_vec
    );
    
    localparam [1:0] S0 = 2'b00,
                     S1 = 2'b01,
                     S2 = 2'b10;
                     
    reg [1:0] state_reg,state_next;
    
    always@(posedge clk)
    begin 
      state_reg <= state_next;
    end
    
    always@(*)
    begin
       case(state_reg)
            S0: if(irig_d0)
                begin
                   state_next = S1;
                end
                else
                begin
                   state_next = S0;
                   irig_d0_out = 1'b0;
                end
             S1:begin 
                irig_d0_out = 1'b1;
                state_next = S2;
                 end
             S2:if(irig_d0)
                begin
                 state_next = S2;
                end
                else
                begin
                  state_next = S0;
                end 
              default: state_next = S0;        
       endcase
    end
    
    assign state_vec = state_reg;
endmodule
