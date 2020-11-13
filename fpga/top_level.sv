module top_level(
   input clk_100mhz,
   input[15:0] sw,
   input btnc, btnu, btnr, btnd, btnl,
   output logic[3:0] vga_r,
   output logic[3:0] vga_b,
   output logic[3:0] vga_g,
   output logic vga_hs,
   output logic vga_vs,
   output logic [15:0] led,
   output logic ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp
   output logic[7:0] an    // Display location 0-7
   );
   
   assign player_mode = sw[0]; //1 = primary, 0 = secondary
   assign reset = sw[1];  //reset = 1
   assign carry = sw[15]; //is carrying = 1, put down = 0
   assign led = sw; //check switch is actually on
   
   logic left, right, up, down, chop;
   debounce dbchop(.reset_in(reset),.clock_in(clock),.noisy_in(btnc),.clean_out(chop));
   debounce dbleft(.reset_in(reset),.clock_in(clock),.noisy_in(btnl),.clean_out(left));
   debounce dbright(.reset_in(reset),.clock_in(clock),.noisy_in(btnr),.clean_out(right));
   debounce dbup(.reset_in(reset),.clock_in(clock),.noisy_in(btnu),.clean_out(up));
   debounce dbdown(.reset_in(reset),.clock_in(clock),.noisy_in(btnd),.clean_out(down));
   
   assign  dp = 1'b1;  // turn off the period

endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Pushbutton Debounce Module (video version - 24 bits)  
//
///////////////////////////////////////////////////////////////////////////////

module debounce (input reset_in, clock_in, noisy_in,
                 output logic clean_out);

   logic [19:0] count;
   logic new_input;

   always_ff @(posedge clock_in)
     if (reset_in) begin 
        new_input <= noisy_in; 
        clean_out <= noisy_in; 
        count <= 0; end
     else if (noisy_in != new_input) begin new_input<=noisy_in; count <= 0; end
     else if (count == 1000000) clean_out <= new_input;
     else count <= count+1;


endmodule

