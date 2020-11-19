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
   
   logic clock;
   clk_wiz_25 clk25 (.clk_in1(clk_100mhz), .clk_out1(clock));
   
   logic [10:0] hcount_in;
   logic [9:0] vcount_in;
   logic vsync_in, hsync_in, blank_in;
   xvga vga(.vclock_in(clock), .hcount_out(hcount_in), .vcount_out(vcount_in), .vsync_out(vsync_in),
        .hsync_out(hsync_in), .blank_out(blank_in));
   
   //sw[1:0] = player ID
   //sw[3:2] = num_players
   //sw[4] = reset
   //sw[14] = pause
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
    assign frame_update = (hcount_in==0)&&(vcount_in==0);
    game_logic gl (.reset(reset),.clock(clock), .frame_update(frame_update), .local_player_ID(local_player_ID), .num_players(num_players),
                   .left(left), .right(right), .up(up), .down(down), .chop(chop), .carry(carry),.game_state(game_state),
                   .object_grid(object_grid), .time_grid(time_grid), .time_left(time_left), .point_total(point_total), 
                   .orders(orders), .order_times(order_times), .team_name(team_name), .player_direction(player_direction), 
                   .player_loc_x(player_loc_x), .player_loc_y(player_loc_y), .player_state(player_state) );
                   
    
    //graphics
    logic border = (hcount==0 | hcount==639 | vcount==0 | vcount==479);
   logic [10:0] hcount;    // pixel on current line
   logic [9:0] vcount;     // line number
   logic hsync, vsync, blank;
   logic [11:0] pixel;
   logic [11:0] rgb;
    
   graphics game(.clock(clock), .reset(reset), .team_name(team_name), .local_player_ID(local_player_ID), .num_players(num_players),
      .game_state(game_state), .time_left(time_left), .point_total(point_total), .object_grid(object_grid),
      .time_grid(time_grid), .orders(orders), .order_times(order_times), .player_direction(player_direction), .player_x(player_x),
      .player_state(player_state), .hcount(hcount_in), .vcount(vcount_in), .hsync(hsync_in), .vsync(vsync_in),
      .blank(blank_in), .hsync_out(hsync), .vsync_out(vsync), .blank_out(blank), .pixel_out(pixel));
    
    logic b,hs,vs;
    always_ff @(posedge clock) begin
      if (sw[1:0] == 2'b01) begin
         // 1 pixel outline of visible area (white)
         hs <= hsync;
         vs <= vsync;
         b <= blank;
         rgb <= {12{border}};
      end else if (sw[1:0] == 2'b10) begin
         // color bars
         hs <= hsync;
         vs <= vsync;
         b <= blank;
         rgb <= {{4{hcount[8]}}, {4{hcount[7]}}, {4{hcount[6]}}} ;
      end else begin
         // default: pong
         hs <= hsync;
         vs <= vsync;
         b <= blank;
         rgb <= pixel;
      end
    end

    assign rgb = sw[0] ? {12{border}} : pixel ; //{{4{hcount[7]}}, {4{hcount[6]}}, {4{hcount[5]}}};

    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;
   
//   //communication

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

