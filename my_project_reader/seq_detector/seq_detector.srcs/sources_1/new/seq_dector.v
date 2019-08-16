`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2019 09:39:47
// Design Name: 
// Module Name: seq_dector
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


module seq_dector(
    input carrier,
    input data,
    input reset,
    output reg irig_d0,
    output reg garbage
    );
    
    localparam [3:0] S0 = 4'b0000,
                     S1 = 4'b0001,
                     S2 = 4'b0010,
                     S3 = 4'b0011,
                     S4 = 4'b0100,
                     S5 = 4'b0101,
                     S6 = 4'b0110,
                     S7 = 4'b0111,
                     S8 = 4'b1000,
                     S9 = 4'b1001,
                     S10 = 4'b1010,
                     S11 = 4'b1011,
                     S12 = 4'b1100,
                     S13 = 4'b1101;
                     
    reg [3:0] state_reg,state_next;
                     
    reg lc_bit;
    
    //SR latch S: data,R: carier
                     
    always@(posedge carrier or posedge data)
    begin
    if(data == 1'b1)
    begin
    lc_bit <=1;
    end
    else
    begin
    lc_bit <=0;
    end
    
    end // end of SR latch
    
    
    //seq circuit in state machine
    always@(negedge carrier,negedge reset)
    begin
    if(reset)
    begin
      state_reg <= S0;
    end
    else
    begin
      state_reg <= state_next;
    end
      
    end
    
    //combinational circuit in state machine
    always@(*)
    begin
        
         case(state_reg)
         
            S0: if(lc_bit==0)
                begin
                  state_next = S0;  
                  irig_d0 = 1'b0;
                  garbage = 1'b1;
                end
                else
                begin
                  state_next = S1;
                end
            S1: if(lc_bit==1)
                begin
                  state_next = S2;
                  irig_d0 = 1'b0;
                  garbage = 1'b0;
                end
                else
                begin
                  state_next = S12;
                end
            S2: if(lc_bit==1'b0)
                begin
                  state_next = S3;
                end
                else
                begin
                  state_next = S11;
                end
             S3: if(lc_bit == 1'b0)
                 begin
                  state_next = S4;
                 end
                 else
                 begin
                  state_next = S0;
                 end
             S4: if(lc_bit == 1'b0)
                 begin
                   state_next = S5;
                 end
                 else
                 begin
                   state_next = S0;
                 end
             S5: if(lc_bit == 1'b0)
                 begin
                   state_next = S6;
                 end
                 else
                 begin
                   state_next = S0;
                 end
             S6: if(lc_bit == 1'b0)
                 begin
                    state_next = S7;
                 end
                 else
                 begin
                    state_next = S8;
                 end
              S8: if(lc_bit == 1'b0)
                  begin
                    state_next = S8;
                  end  
                  else
                  begin
                    state_next = S0;
                  end
               S9: if(lc_bit == 1'b0)
                   begin
                     state_next = S10;
                   end
                   else
                   begin
                     state_next = S0;
                   end
              S10:if(lc_bit==1'b1)
                  begin
                   state_next = S1;
                   irig_d0 = 1'b1;
                  end
                  else
                  begin
                    state_next = S0;
                  end
              S11: if(lc_bit == 1'b0)
                   begin
                    state_next = S4;
                   end
                   else
                   begin
                    state_next = S0;
                   end
              S12: if(lc_bit == 1'b0)
                   begin
                    state_next = S3;
                   end
                   else
                   begin
                    state_next = S0;
                   end
                   
                   
              default state_next = S0;
             
              
                
             
                
         endcase
       
       
       
       
       
    end
    
    
    
                     
endmodule
