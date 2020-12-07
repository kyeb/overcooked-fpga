`timescale 1ns / 1ps

module graphics(
    input clock,
    input reset,
        
    // some global stuff
    input [1:0] local_player_ID,
    input [2:0][7:0] team_name,
    input [1:0] num_players,
    input logic [2:0] game_state, // welcome, game, etc
    
    // overall game
    input [7:0] time_left,
    input [9:0] point_total,
    input [7:0][12:0][3:0] object_grid, 
    input [5:0][3:0] time_grid,
    input [3:0] orders, // how many orders are currently on the screen
    input [3:0][4:0] order_times,
        
    // player input
    input [1:0] player1_direction,
    input [8:0] player1_x,
    input [8:0] player1_y,
    input [3:0] player1_state,
        
    input [1:0] player2_direction,
    input [8:0] player2_x,
    input [8:0] player2_y,
    input [3:0] player2_state,

    input [1:0] player3_direction,
    input [8:0] player3_x,
    input [8:0] player3_y,
    input [3:0] player3_state,

    input [1:0] player4_direction,
    input [8:0] player4_x,
    input [8:0] player4_y,
    input [3:0] player4_state,

    input [10:0] hcount, // horizontal index of current pixel 
    input [9:0]  vcount, // vertical index of current pixel
    input hsync,         // XVGA horizontal sync signal (active low)
    input vsync,         // XVGA vertical sync signal (active low)
    input blank,         // XVGA blanking (1 means output black pixel)
        
    output logic hsync_out,
    output logic vsync_out,
    output logic blank_out,
    output logic [11:0] pixel_out);              

    // game state parameters
    localparam WELCOME = 0;
    localparam START = 1;
    localparam PLAY = 2;
    localparam PAUSE = 3;
    localparam FINISH = 4;

    // player displays
    logic [11:0] player_pixel, player1_pixel, player2_pixel, player3_pixel, player4_pixel;
    player_blob player1 (.pixel_clk_in(clock), .x_in(player1_x), .y_in(player1_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player1_direction), .player_state(player1_state), .pixel_out(player1_pixel));

    player_blob player2 (.pixel_clk_in(clock), .x_in(player2_x), .y_in(player2_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player2_direction), .player_state(player2_state), .pixel_out(player2_pixel));

    player_blob player3 (.pixel_clk_in(clock), .x_in(player3_x), .y_in(player3_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player3_direction), .player_state(player3_state), .pixel_out(player3_pixel));

    player_blob player4 (.pixel_clk_in(clock), .x_in(player4_x), .y_in(player4_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player4_direction), .player_state(player4_state), .pixel_out(player4_pixel));

    // table counters
    logic [11:0] floor_pixel;

    tables tab(.pixel_clk_in(clock), .hcount_in(hcount), .vcount_in(vcount), .pixel_out(floor_pixel));

    // object graphics
    logic [11:0] object_pixel, grid_pixels, info_out0, info_out1, info_out2, info_out3;
    logic [3:0] grid_x;
    logic [2:0] grid_y;
    logic [9:0] x, y;
    pixel_to_grid p2g (.pixel_x(hcount), .pixel_y(vcount), .grid_x(grid_x), .grid_y(grid_y));  
    grid_to_pixel g2p (.grid_x(grid_x), .grid_y(grid_y), .pixel_x(x), .pixel_y(y));
    static_sprites s (.pixel_clk_in(clock), .object_grid(object_grid), .x_in(x), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels));

    // order displays -- TODO: toggle positioning of displays so they look nice
    info_display id0 (.pixel_clk_in(clock), .x_in(50), .hcount(hcount), .y_in(50), .vcount(vcount),
        .order(orders[0]), .order_time(order_times[0]), .pixel_out(info_out0));

    info_display id1 (.pixel_clk_in(clock), .x_in(87), .hcount(hcount), .y_in(50), .vcount(vcount),
        .order(orders[1]), .order_time(order_times[1]), .pixel_out(info_out1));

    info_display id2 (.pixel_clk_in(clock), .x_in(124), .hcount(hcount), .y_in(50), .vcount(vcount),
        .order(orders[2]), .order_time(order_times[2]), .pixel_out(info_out2));
        
     info_display id3 (.pixel_clk_in(clock), .x_in(161), .hcount(hcount), .y_in(50), .vcount(vcount),
        .order(orders[3]), .order_time(order_times[3]), .pixel_out(info_out3));
        
    logic [11:0] welcome_screen;
    
    welcome welc (.pixel_clk_in(clock), .hcount_in(hcount), .vcount_in(vcount), .pixel_out(welcome_screen));
    
    // more grid logic
    always_comb begin
    
        if (hcount > 111 && hcount < 528 && vcount > 111 && vcount < 369) begin
            // update the grid state if we end up on a new square of the grid
            object_pixel = grid_pixels;
        end else begin
            object_pixel = 12'hFFF;
        end
        
        case (num_players)
            0: player_pixel = player1_pixel;
            1: player_pixel = player1_pixel == 12'hFFF ? player2_pixel : player1_pixel;
            2: player_pixel = player1_pixel == 12'hFFF && player2_pixel == 12'hFFF ? player3_pixel :
                            player1_pixel == 12'hFFF && player3_pixel == 12'hFFF ? player2_pixel :
                            player1_pixel;
            3: player_pixel = player1_pixel == 12'hFFF && player2_pixel == 12'hFFF && player3_pixel == 12'hFFF ? player4_pixel :
                            player1_pixel == 12'hFFF && player2_pixel == 12'hFFF && player4_pixel == 12'hFFF ? player3_pixel :
                            player1_pixel == 12'hFFF && player3_pixel == 12'hFFF && player4_pixel == 12'hFFF ? player2_pixel :
                            player1_pixel;
        endcase
        
        hsync_out = hsync;
        vsync_out = vsync;
        blank_out = blank;
     
        if (game_state == WELCOME && welcome_screen != 0) begin
            pixel_out = welcome_screen;
        end else if (player_pixel != 12'hFFF) begin
            pixel_out = player_pixel; 
        end else if (object_pixel != 12'hFFF) begin
            pixel_out = object_pixel;
        end else begin
            pixel_out = floor_pixel + info_out0 + info_out1 + info_out2 + info_out3;
        end
            
    end
    
endmodule
