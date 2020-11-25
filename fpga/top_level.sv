module top_level(
   input clk_100mhz,
   input [15:0] sw,
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
   
   // create clock for display
   logic clock;
   clk_wiz_25 clk25 (.clk_in1(clk_100mhz), .clk_out1(clock));
   
   // digit display
   logic [31:0] valz;
   assign  dp = 1'b1;  // turn off the period
   seven_seg_controller my_controller (.clk_in(clock), .rst_in(reset), .val_in(valz), 
                                        .cat_out({cg, cf, ce, cd, cc, cb, ca}), .an_out(an));
   
   // vga signals
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
   logic [1:0] local_player_ID;
   logic [1:0] num_players;
   assign local_player_ID = sw[1:0]; //indicate player number, will need coordination 
                                     // player 0 will be the primary, will do controls
   assign num_players = sw[3:2];
   assign reset = sw[4];  //reset = 1
   assign local_carry = sw[15]; //is carrying = 1, put down = 0
   assign pause = sw[14];
   assign led = sw; //check switch is actually on
   
   //local button inputs
   logic local_left, local_right, local_up, local_down, local_chop;
   debounce dbchop(.reset_in(reset),.clock_in(clock),.noisy_in(btnc),.clean_out(local_chop));
   debounce dbleft(.reset_in(reset),.clock_in(clock),.noisy_in(btnl),.clean_out(local_left));
   debounce dbright(.reset_in(reset),.clock_in(clock),.noisy_in(btnr),.clean_out(local_right));
   debounce dbup(.reset_in(reset),.clock_in(clock),.noisy_in(btnu),.clean_out(local_up));
   debounce dbdown(.reset_in(reset),.clock_in(clock),.noisy_in(btnd),.clean_out(local_down));
   
   //variables only main controls
   logic [2:0] comms_game_state, local_game_state, game_state;
   logic [7:0][12:0][3:0] comms_object_grid, local_object_grid, object_grid;
   logic [5:0][3:0] comms_time_grid, local_time_grid, time_grid; 
   logic [7:0] comms_time_left, local_time_left, time_left; 
   logic [9:0] comms_point_total, local_point_total, point_total; 
   logic [3:0] comms_orders, local_orders, orders;
   logic [3:0][4:0] comms_order_times, local_order_times, order_times; 
   logic [2:0][7:0] comms_team_name, local_team_name, team_name; 
   
   // variables unique to FPGA
   logic [1:0] local_direction, player1_direction, player2_direction, player3_direction, player4_direction;
   logic [8:0] local_loc_x, player1_loc_x, player2_loc_x, player3_loc_x, player4_loc_x;
   logic [8:0] local_loc_y, player1_loc_y, player2_loc_y, player3_loc_y, player4_loc_y;
   logic [3:0] local_state, player1_state, player2_state, player3_state, player4_state;
   
   //comms 
        //send to main: player ID (2), player direction (2), player_loc_x(9), player_loc_y(9), player state (4)
        // receive from main: 
            // high priority: object grid (8x13x4), time_grid (6x4), other 3 player info
            // low priority: game state (3), team_name(3x8), order_times (4x5), time_left(8), point_total(10), orders(4), other 3 positions
            
    always_comb begin
        if (local_player_ID == 0) begin
            game_state = local_game_state;
            object_grid = local_object_grid;
            time_grid = local_time_grid;
            time_left = local_time_left;
            point_total = local_point_total;
            orders = local_orders;
            order_times = local_order_times;
            team_name = local_team_name;
            
            player1_direction = local_direction;
            player1_loc_x = local_loc_x;
            player1_loc_y = local_loc_y;
            player1_state = local_state;
        end else begin
            game_state = comms_game_state;
            object_grid = comms_object_grid;
            time_grid = comms_time_grid;
            time_left = comms_time_left;
            point_total = comms_point_total;
            orders = comms_orders;
            order_times = comms_order_times;
            team_name = comms_team_name;
        end
    end
    
    //if main, receive other 3 and send back out
    //if not main, send position, receive other 3 from main
            
    main_FPGA_control ctl (.reset(reset), .vsync(vsync_in), .pause(pause),
                   .left(local_left), .right(local_right), .up(local_up), .down(local_down), .chop(local_chop), .carry(local_carry),
                   .player1_direction(player1_direction), .player1_x(player1_loc_x), .player1_y(player1_loc_y), .player1_state(player1_state),
                   .player2_direction(player2_direction), .player2_x(player2_loc_x), .player2_y(player2_loc_y), .player2_state(player2_state),
                   .player3_direction(player3_direction), .player3_x(player3_loc_x), .player3_y(player3_loc_y), .player3_state(player3_state),
                   .player4_direction(player4_direction), .player4_x(player4_loc_x), .player4_y(player4_loc_y), .player4_state(player4_state),
                   
                   .game_state(local_game_state),.object_grid(local_object_grid), .time_grid(local_time_grid), .time_left(local_time_left), 
                   .point_total(local_point_total), .orders(local_orders), .order_times(local_order_times), .team_name(local_team_name));
    
    //add collisions here
    game_logic gl (.reset(reset), .vsync(vsync_in), .game_state(game_state), .object_grid(object_grid),
                   .left(local_left), .right(local_right), .up(local_up), .down(local_down), .chop(local_chop), .carry(local_carry),
                   
                   .player_direction(local_direction), .player_loc_x(local_loc_x), .player_loc_y(local_loc_y), .player_state(local_state));
    
    assign valz = {29'b0, game_state};

    //graphics
    logic [10:0] hcount;    // pixel on current line
    logic [9:0] vcount;     // line number
    logic hsync, vsync, blank;
    logic [11:0] pixel;
    logic [11:0] rgb;
    logic border = (hcount>=0 & hcount<639 & vcount>=0 & vcount<479);
        
    graphics game(.clock(clock), .reset(reset), .team_name(team_name), .local_player_ID(local_player_ID), .num_players(num_players),
        .game_state(game_state), .time_left(time_left), .point_total(point_total), .object_grid(object_grid), .time_grid(time_grid), .orders(orders), .order_times(order_times), 
        .player1_direction(player1_direction), .player1_x(player1_loc_x), .player1_y(player1_loc_y), .player1_state(player1_state), 
        .player2_direction(player2_direction), .player2_x(player2_loc_x), .player2_y(player2_loc_y), .player2_state(player2_state), 
        .player3_direction(player3_direction), .player3_x(player3_loc_x), .player3_y(player3_loc_y), .player3_state(player3_state), 
        .player4_direction(player4_direction), .player4_x(player4_loc_x), .player4_y(player4_loc_y), .player4_state(player4_state), 
        .hcount(hcount_in), .vcount(vcount_in), .hsync(hsync_in), .vsync(vsync_in), .blank(blank_in), .hsync_out(hsync), .vsync_out(vsync), .blank_out(blank), .pixel_out(pixel));
        
    logic b,hs,vs;
    always_ff @(posedge clock) begin
        hs <= hsync;
        vs <= vsync;
        b <= blank;
        rgb <= border ? pixel : 0;
    end

    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;

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



module seven_seg_controller(input logic         clk_in,
                            input logic         rst_in,
                            input logic [31:0]  val_in,
                            output logic[6:0]   cat_out,
                            output logic[7:0]   an_out
    );
    
    logic[7:0]      segment_state;
    logic[31:0]     segment_counter;
    logic [3:0]     routed_vals;
    logic [6:0]     led_out;
    
    binary_to_seven_seg my_converter ( .val_in(routed_vals), .led_out(led_out));
    assign cat_out = ~led_out;
    assign an_out = ~segment_state;

    
    always_comb begin
        case(segment_state)
            8'b0000_0001:   routed_vals = val_in[3:0];
            8'b0000_0010:   routed_vals = val_in[7:4];
            8'b0000_0100:   routed_vals = val_in[11:8];
            8'b0000_1000:   routed_vals = val_in[15:12];
            8'b0001_0000:   routed_vals = val_in[19:16];
            8'b0010_0000:   routed_vals = val_in[23:20];
            8'b0100_0000:   routed_vals = val_in[27:24];
            8'b1000_0000:   routed_vals = val_in[31:28];
            default:        routed_vals = val_in[3:0];       
        endcase
    end
    
    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            segment_state <= 8'b0000_0001;
            segment_counter <= 32'b0;
        end else begin
            if (segment_counter == 32'd100_000)begin
                segment_counter <= 32'd0;
                segment_state <= {segment_state[6:0],segment_state[7]};
            end else begin
                segment_counter <= segment_counter +1;
            end
        end
    end
        
endmodule //seven_seg_controller


module binary_to_seven_seg ( input [3:0] val_in, output logic [6:0] led_out);

    always_comb begin
        case(val_in)
            4'b0:   led_out = 7'b011_1111;
            4'b1:   led_out = 7'b000_0110;
            4'b10:  led_out = 7'b101_1011;
            4'b11:  led_out = 7'b100_1111;
            4'b100: led_out = 7'b110_0110;
            4'b101: led_out = 7'b110_1101;
            4'b110: led_out = 7'b111_1101;
            4'b111: led_out = 7'b000_0111;
            4'b1000:led_out = 7'b111_1111; 
            4'b1001:led_out = 7'b110_1111; 
            4'b1010:led_out = 7'b111_0111;
            4'b1011:led_out = 7'b111_1100;
            4'b1100:led_out = 7'b011_1001;
            4'b1101:led_out = 7'b101_1110;
            4'b1110:led_out = 7'b111_1001;
            4'b1111:led_out = 7'b111_0001;
            default:led_out = 7'b000_0000;
        endcase
    end


endmodule //binary_to_hex
