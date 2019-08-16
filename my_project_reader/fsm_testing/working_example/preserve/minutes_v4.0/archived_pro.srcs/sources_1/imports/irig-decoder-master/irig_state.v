module irig_state (
                   input            clk,
                   input            rst,
                   input            end_of_symbl,
                   input            irig_d0,
                   input            irig_d1,
                   input            irig_mark,
                   output [3:0]     state_var,      
                   output reg       pps_gate,
                   output [3:0]     sec_data_u,
                   output [2:0]     sec_data_t,
                   output [3:0]     min_data_u,
                   output [2:0]     min_data_t
                   );

    // State machine states
    localparam ST_UNLOCKED = 4'd0,
      ST_PRELOCK  = 4'b1,
      ST_START    = 4'd2,
      ST_SECOND   = 4'd3,
      ST_MINUTE   = 4'd4,
      ST_HOUR     = 4'd5,
      ST_DAY      = 4'd6,
      ST_DAY2     = 4'd7,
      ST_YEAR     = 4'd8,
      ST_UNUSED1  = 4'd9,
      ST_UNUSED2  = 4'd10,
      ST_SEC_DAY  = 4'd11,
      ST_SEC_DAY2 = 4'd12;

    

    // Count of the IRIG bits within a state
    reg [3:0]                       irig_cnt;

    // PPS generation internal signal
    // Output is registered version
    reg                             pps_en;
    
    // Current and next state machine state
    reg [3:0]                       state, next_state;
    
    reg [8:0] sec_frame;
    reg [8:0] min_frame;

    // Registers
    always @(posedge clk) begin
        if (rst) begin
            state <= ST_UNLOCKED;
            pps_gate <= 1'b0;
            irig_cnt <= 4'b0;
        end
        else begin
            state <= next_state;
            pps_gate <= pps_en;

            // Count the IRIG bits received between every MARK
            if (irig_mark)
              irig_cnt <= 4'b0;
            else 
              irig_cnt <= irig_cnt + (irig_d0 | irig_d1);
        end
    end

    // IRIG decoding state machine
    // FIX ME add checks that cause loss of lock
    always @(*) begin
        next_state = state;
        pps_en = 1'b0;
        
        case (state)
          ST_UNLOCKED: begin
              if (irig_mark)
                next_state = ST_PRELOCK;
          end
          ST_PRELOCK: begin
              if (irig_mark)
                next_state = ST_SECOND;
              else if (irig_d0 || irig_d1)
                next_state = ST_UNLOCKED;          
          end
          ST_START: begin              
              pps_en = 1'b1;
              if (irig_mark) begin
                  next_state = ST_SECOND;
              end
          end
          ST_SECOND: begin
             
             if(irig_d1) 
             begin
                sec_frame[irig_cnt] = 1'b1;
             end
             else if(irig_d0) 
                  begin
                    sec_frame[irig_cnt] = 1'b0;
                  end 
                  else if (irig_mark)
                          next_state = ST_MINUTE;
                          

             /* if (irig_mark)
                next_state = ST_MINUTE;*/
          end
          ST_MINUTE: begin
             if(irig_d1) 
             begin
              min_frame[irig_cnt] = 1'b1;
             end
             else if(irig_d0) 
                  begin
                  min_frame[irig_cnt] = 1'b0;
                  end 
                  else if (irig_mark)
                           next_state = ST_HOUR;
             
              /*if (irig_mark)
                next_state = ST_HOUR;*/
                
          end       
          ST_HOUR: begin
             
              if (irig_mark)
                next_state = ST_DAY;
          end
          ST_DAY: begin
             

              if (irig_mark)
                next_state = ST_DAY2;
          end
          ST_DAY2: begin
              
              if (irig_mark)
                next_state = ST_YEAR;
          end
          ST_YEAR: begin
             
              if (irig_mark)
                next_state = ST_UNUSED1;
          end
          ST_UNUSED1: begin
              if (irig_mark)
                next_state = ST_UNUSED2;
          end
          ST_UNUSED2: begin
              if (irig_mark)
                next_state = ST_SEC_DAY;
          end
          ST_SEC_DAY: begin
             
              if (irig_mark)
                next_state = ST_SEC_DAY2;
          end
          ST_SEC_DAY2: begin
              
              if (irig_mark) begin
                  next_state = ST_START;
                  pps_en = 1'b1;
                  
              end
          end
        endcase
    end
    assign state_var = state;
    assign sec_data_u = sec_frame[3:0];
    assign sec_data_t = sec_frame[7:5];
    assign min_data_u = min_frame[3:0];
    assign min_data_t = min_frame[7:5];
    
endmodule
