`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2019 23:05:49
// Design Name: 
// Module Name: irig_symbol_decode
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


module irig_symbol_decode(
    input each_cycle,
    input large_cycle,
    input clk,
    input rst,
    output reg start_of_symbl,
    output reg end_of_symbl,
    output reg mark,
    output reg irig_d0,
    output reg irig_d1
    );
    
    // defining regsisters
    reg [4:0] lc_frame;
    reg [3:0] count; //for counting lc pulsestyle_ondetect
    reg [3:0]lc_count; //for decoding 
    reg [3:0] ec_count;
    reg lc_previous,lc_current;
    reg lc_bit;
    reg pre_end_sym;
    
    
    //sr latch of lc and ec
    always@(posedge large_cycle or posedge each_cycle)
    begin
    if(large_cycle ==1)
    begin
    lc_bit <=1;
    end
    else
    begin
    if(each_cycle ==1)
     lc_bit <=0;
    end
    end
    
    // previous lc ,present lc
    
    always@(negedge each_cycle)
    begin
    
    lc_previous <= lc_current;
    lc_current <= lc_bit;
    /*if(lc_current==0 && lc_bit ==1)
    begin
    lc_count <=0;
    end
    */
    
    if(lc_bit)
    begin
    lc_count <= lc_count + 1;
    lc_frame[ec_count] <= 1;
    
    end
    else
    begin
    lc_frame[ec_count] <= 0;
    end
    
    end
    
    always@(posedge each_cycle)
    begin
      if(lc_previous == 0 && lc_current ==1)
      begin
      start_of_symbl <= 1;
      ec_count <= 0; //actually one 
      lc_count <=0; //this gives sythesis error
      end
      else
      begin
      start_of_symbl <= 0;
      ec_count <=ec_count +1;
      end
      if(ec_count ==8)
      begin
      end_of_symbl <= 1;
      end
      else
        end_of_symbl <= 0;
    end
    
    always@(posedge clk)
    begin
    if(rst)
    begin
    mark <= 0;
    irig_d1 <= 0;
    irig_d0 <= 0;
    end
    else
    begin
    
   
    mark <= (lc_count >=7)&& !mark && !pre_end_sym  && end_of_symbl ;
    irig_d1 <= (lc_count >=4)&&(lc_count <6)&& !irig_d1 && !pre_end_sym  && end_of_symbl;
    irig_d0 <= (lc_count >=1)&&(lc_count <4)&& ! irig_d0 && !pre_end_sym  && end_of_symbl;
    
    pre_end_sym <= end_of_symbl;
    
    end
    end
endmodule
