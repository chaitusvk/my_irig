module state_irig (
	input clk,    // Clock
	input rst, // Reset
	input irig_d0,  // d0
	input irig_d1,
	input irig_mark,
	input irig_garbage,
	output state_out,
	output  pps,
	output [3:0] sec_data_u,
	output [3:0] sec_data_t,
	output [3:0] min_data_u,
	output [3:0] min_data_t,
	output [3:0] hour_data_u,
	output [3:0] hour_data_t,
	output [3:0] day_data_u,
	output [3:0] day_data_t,
	output [3:0] day_data_h
	
);
  	 // State machine states
    localparam ST_UNLOCKED = 4'b0000,
      ST_PRELOCK  = 4'b0001,
      ST_START    = 4'b0010,
      ST_SECOND   = 4'b0010,
      ST_MINUTE   = 4'b0100,
      ST_HOUR     = 4'b0101,
      ST_DAY      = 4'b0110,
      ST_DAY2     = 4'b0111,
      ST_YEAR     = 4'b1000,
      ST_UNUSED1  = 4'b1001,
      ST_UNUSED2  = 4'b1010,
      ST_SEC_DAY  = 4'b1011,
      ST_SEC_DAY2 = 4'b1100;

    // Current and next state machine state
    reg [3:0]  state, next_state;

    reg [8:0] sec_frame,min_frame,hour_frame,day_frame,day2_frame,year_frame;

   // reg [3:0] sec_frame_cnt,min_frame_cnt,hours_frame_cnt,year_1_frame_cnt,year_2_frame_cnt;

    reg [3:0] irig_cnt; //count bits in state

    reg pps;


    // Registers
    always @(negedge clk) begin
        if (rst) begin
            state <= ST_UNLOCKED;
            //pps_gate <= 1'b0;
            irig_cnt <= 4'b0;
        end
        else begin
            state <= next_state;
            //pps_gate <= pps_en;

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
        case (state)
          ST_UNLOCKED: begin
              if (irig_mark)
              	begin
                next_state = ST_PRELOCK;
                pps = 1'b0;
                end
          end
          ST_PRELOCK: begin
              if (irig_mark)
                next_state = ST_SECOND;
              else if (irig_d0 || irig_d1||irig_garbage)
                next_state = ST_UNLOCKED;          
          end
          ST_START: begin              
              pps = 1'b1;
              if (irig_mark) begin
                  next_state = ST_SECOND;
              end
          end
          ST_SECOND: begin
          	  pps = 1'b0;
              if(irig_garbage)
              	next_state = ST_UNLOCKED;
              else if(irig_d1) begin
              	   sec_frame[irig_cnt] = 1'b1;
              end
              else if(irig_d0) begin
              	   sec_frame[irig_cnt] = 1'b0;
              end 
              else if (irig_mark)
                next_state = ST_MINUTE;
          end
          ST_MINUTE: begin
          	   if(irig_garbage)
              	next_state = ST_UNLOCKED;
              else if(irig_d1) begin
              	   min_frame[irig_cnt] = 1'b1;
              end
              else if(irig_d0) begin
              	   min_frame[irig_cnt] = 1'b0;
              end 
              else if (irig_mark)
                next_state = ST_HOUR;
              
          end       
          ST_HOUR: begin
              if(irig_garbage)
              	next_state = ST_UNLOCKED;
              else if(irig_d1) begin
              	   hour_frame[irig_cnt] = 1'b1;
              end
              else if(irig_d0) begin
              	   hour_frame[irig_cnt] = 1'b0;
              end 
              else if (irig_mark)
                next_state = ST_DAY;
          end
          ST_DAY: begin
              if(irig_garbage)
              	next_state = ST_UNLOCKED;
              else if(irig_d1) begin
              	   day_frame[irig_cnt] = 1'b1;
              end
              else if(irig_d0) begin
              	   day_frame[irig_cnt] = 1'b0;
              end 
              else if (irig_mark)
                next_state = ST_DAY2;
          end
          ST_DAY2: begin
          	if(irig_garbage)
              	next_state = ST_UNLOCKED;
              else if(irig_d1) begin
              	   day2_frame[irig_cnt] = 1'b1;
              end
              else if(irig_d0) begin
              	   day2_frame[irig_cnt] = 1'b0;
              end 
              else if (irig_mark)
                next_state = ST_YEAR;
              
          end
          ST_YEAR: begin
             if(irig_garbage)
              	next_state = ST_UNLOCKED;
              else if(irig_d1) begin
              	   year_frame[irig_cnt] = 1'b1;
              end
              else if(irig_d0) begin
              	   year_frame[irig_cnt] = 1'b0;
              end 
              else if (irig_mark)
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
                  //pps_en = 1'b1;
                  //ts_finish = 1'b1;
              end
          end
        endcase
    end
    
    assign state_out = state;
    assign sec_data_u = sec_frame[4:1];
    assign sec_data_t = sec_frame[8:5];
    assign min_data_u = min_frame[4:1];
    assign min_data_t = min_frame[8:5];
    assign hour_data_u = hour_frame[4:1];
    assign hour_data_t = hour_frame[8:5];
    assign day_data_u = day_frame[4:1];
    assign day_data_t = day_frame[8:5];
    assign day_data_h = day2_frame[4:1];




endmodule