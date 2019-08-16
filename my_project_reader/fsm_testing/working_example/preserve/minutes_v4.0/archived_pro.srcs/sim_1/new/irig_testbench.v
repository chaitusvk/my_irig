`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2019 00:40:49
// Design Name: 
// Module Name: irig_testbench
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


`timescale 1 ms / 1 ms

module irig_testbench();
    
    localparam MARK = 3'b100;
    localparam D1 = 3'b010;
    localparam D0 = 3'b001;

    // Inputs to the DUT
    reg clk;
    reg rst;
   // reg irigb;

    reg ec;
    reg lc;
 
    // Output of the DUT
    wire mark;
    wire d_0;
    wire d_1;
    wire [3:0] state;
    wire pps; 
    //wire [8:0] sec_out;  
    //wire [3:0] sec_units;
    wire [3:0]     sec_data_u;
    wire [2:0]     sec_data_t;
    wire [3:0]     min_data_u;
    wire [2:0]     min_data_t;
    
    
    // Instantiate the DUT
    irig i1(.clk_10mhz(clk),
            .rst(rst),
            .each_cycle(ec),
            .large_cycle(lc),
            .mark(mark),
            .d_0(d_0),
            .d_1(d_1),
            .state(state),
            .pps(pps),
            //.sec_out(sec_out)
            .sec_data_u(sec_data_u),
            .sec_data_t(sec_data_t),
            .min_data_u(min_data_u),
            .min_data_t(min_data_t)
            );
            
   //simulation of wave form
    initial begin
        
        ec <= 1'b0;
        lc <= 1'b0;
        clk <= 1'b0;
        rst = 1'b1;
        // Reset goes low
             
        #100 rst = 1'b0;

        // Some garbage bits
        irig_bit(D0);
        irig_bit(MARK);
        irig_bit(D1);
        irig_bit(D0);

        // End of second
        irig_bit(MARK);

        // Now send a full stream
        irig_timestamp();

        // Start of next one...
        irig_bit(MARK);

        $stop;
    end

    always
      #5  ec = ~ec;
    
    always
      #1 clk = ~clk;

    // Send a full timestamp
    task irig_timestamp;        
        begin
            // Frame identifier
            irig_bit(MARK); // 00

            // Seconds: 53 = 101_0011
            // only 8 bits here
            irig_bitstream(9'bx10100011);

            // Minutes: 47 = _100_0111
            irig_bit(MARK); // 09
            irig_bitstream(9'b010000111);
            
            // Hours: 17 = __01_0111
            irig_bit(MARK); // 19
            irig_bitstream(9'b000100111);

            // Day of year 293 (93) = 1001_0011 
            irig_bit(MARK); // 29
            irig_bitstream(9'b100100011);

            // Day of year 293 (2) = _______10
            // Tenth of seconds unused
            irig_bit(MARK); // 39
            irig_bitstream(9'b000000010);

            // Year 16 = 0001_0110
            irig_bit(MARK); // 49
            irig_bitstream(9'b000100110);

            // Unused
            irig_bit(MARK); // 59
            irig_bitstream(9'b0);
            irig_bit(MARK); // 69
            irig_bitstream(9'b0);

            // Seconds in day
            // 17:59:42 = 64782 = _01111110100001110
            irig_bit(MARK); // 79
            irig_bitstream(9'b100001110);
            irig_bit(MARK); // 89
            irig_bitstream(9'b001111110);
            irig_bit(MARK); // 99            
          end
    endtask // irig_timestamp

    // Send a stream of IRIG bits
    // 'x' means skip completely FIX ME?
    task irig_bitstream;
        input [8:0] s;
        begin
        repeat (9) 
          begin
            case (s[0])
              1'b1:
                irig_bit(D1);
              1'b0:
                irig_bit(D0);
            endcase // case (s[0])
            s = s >> 1'b1;
          end 
        end
    endtask
              
    // Send a single width-encoded bit
    task irig_bit;
        input [2:0] ib; // mark, 1, 0
        begin
            @(posedge ec);
            case (ib)
              D0: 
                begin
                    repeat(2)
                     begin
                      #1 lc <= 1'b1;
                      #3 lc <= 1'b0;
                      #1;
                      #5;
                      end
                      #75;
                end
              D1:
                begin
                    repeat(5)
                     begin
                     #1 lc <= 1'b1;
                     #3 lc <= 1'b0;
                     #1;
                     #5;
                     end
                     #45;
                end
              MARK:
                begin 
                    repeat(8)
                    begin
                    #1 lc <= 1'b1;
                    #3 lc <= 1'b0;
                    #1;
                    #5;
                    end
                    #15;
       
                end
            endcase            
        end
    endtask
   // assign sec_units = sec_out[4:1]; 
endmodule
