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
   
   //sw[1:0] = player ID
   //sw[3:2] = num_players
   //sw[4] = reset
   //sw[15] = carry
   assign local_player_ID = sw[1:0]; //indicate player number, will need coordination for enough
                                     // player 0 will be the primary, will do controls
   assign reset = sw[4];  //reset = 1
   assign local_carry = sw[15]; //is carrying = 1, put down = 0
   assign led = sw; //check switch is actually on
   
   //figure out number of players
   logic [1:0] num_players;
   always_comb begin    
        //if the fpga is primary, designate # of players
        if (local_player_ID == 0) begin
            num_players = sw[3:2];
        // else get number from internet
        end else begin
            num_players = 2'b00; // ADD LATER
        end
   end
   
   //local button inputs
   logic local_left, local_right, local_up, local_down, local_chop;
   debounce dbchop(.reset_in(reset),.clock_in(clock),.noisy_in(btnc),.clean_out(local_chop));
   debounce dbleft(.reset_in(reset),.clock_in(clock),.noisy_in(btnl),.clean_out(local_left));
   debounce dbright(.reset_in(reset),.clock_in(clock),.noisy_in(btnr),.clean_out(local_right));
   debounce dbup(.reset_in(reset),.clock_in(clock),.noisy_in(btnu),.clean_out(local_up));
   debounce dbdown(.reset_in(reset),.clock_in(clock),.noisy_in(btnd),.clean_out(local_down));
   
   assign  dp = 1'b1;  // turn off the period
   
   //game logic
   
        //inputs: reset, clock, player_ID, num_players
        //inputs for each player: left, right, up, down, chop, carry
        
        //output: game state, grid of objects, grid of object times, time left, point total, orders, order times, team_name
        //output for each player:  player_direction, player_loc_x, player_loc_y, player_state
   
   //graphics
   //communication

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

