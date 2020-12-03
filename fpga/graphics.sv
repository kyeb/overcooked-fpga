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

    input [10:0] hcount, // horizontal index of current pixel (0..1023)
    input [9:0]  vcount, // vertical index of current pixel (0..767)
    input hsync,         // XVGA horizontal sync signal (active low)
    input vsync,         // XVGA vertical sync signal (active low)
    input blank,         // XVGA blanking (1 means output black pixel)
        
    output logic hsync_out,
    output logic vsync_out,
    output logic blank_out,
    output logic [11:0] pixel_out);              

    // player displays
    logic [11:0] player_pixel, player1_pixel, player2_pixel, player3_pixel, player4_pixel;
    player_blob player1 (.pixel_clk_in(clock), .vsync(vsync), .x_in(player1_x), .y_in(player1_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player1_direction), .player_state(player1_state), .pixel_out(player1_pixel));

    player_blob player2 (.pixel_clk_in(clock), .vsync(vsync), .x_in(player2_x), .y_in(player2_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player2_direction), .player_state(player2_state), .pixel_out(player2_pixel));

    player_blob player3 (.pixel_clk_in(clock), .vsync(vsync), .x_in(player3_x), .y_in(player3_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player3_direction), .player_state(player3_state), .pixel_out(player3_pixel));

    player_blob player4 (.pixel_clk_in(clock), .vsync(vsync), .x_in(player4_x), .y_in(player4_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player4_direction), .player_state(player4_state), .pixel_out(player4_pixel));

    // table counters
    logic [11:0] floor_pixel;
    table_counter tables (.x_in_counter('d112), .x_in_floor('d144), .hcount_in(hcount), 
        .y_in_counter('d112), .y_in_floor('d144), .vcount_in(vcount), .pixel_out(floor_pixel));

    // object graphics
    logic [11:0] object_pixel;
    logic [12:0] grid_pixels [11:0];

    logic [3:0] y;
    assign y = (vcount - 112) / 32;
    
    static_sprites s0 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[0]));
    static_sprites s1 (.object_grid(object_grid), .x_in(144), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[1]));
    static_sprites s2 (.object_grid(object_grid), .x_in(176), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[2]));
    static_sprites s3 (.object_grid(object_grid), .x_in(208), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[3]));
    static_sprites s4 (.object_grid(object_grid), .x_in(240), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[4]));
    static_sprites s5 (.object_grid(object_grid), .x_in(272), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[5]));
    static_sprites s6 (.object_grid(object_grid), .x_in(304), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[6]));
    static_sprites s7 (.object_grid(object_grid), .x_in(336), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[7]));
    static_sprites s8 (.object_grid(object_grid), .x_in(368), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[8]));
    static_sprites s9 (.object_grid(object_grid), .x_in(400), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[9]));
    static_sprites s10 (.object_grid(object_grid), .x_in(432), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[10]));
    static_sprites s11 (.object_grid(object_grid), .x_in(464), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[11]));
    static_sprites s12 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(y), .vcount(vcount), .pixel_out(grid_pixels[12]));
    
    // more grid logic
    always_ff @(posedge clock) begin
        // bounds of game grid
        if (hcount > 111 && hcount < 367) begin
            // update the grid state if we end up on a new square of the grid
            if ((hcount - 112) % 32 == 0) begin
                object_pixel = grid_pixels[y];
            end 
                 
        end        

        case (num_players)
            0: player_pixel = player1_pixel;
            1: player_pixel = player1_pixel + player2_pixel;
            2: player_pixel = player1_pixel + player2_pixel + player3_pixel;
            3: player_pixel = player1_pixel + player2_pixel + player3_pixel + player4_pixel;
        endcase
        
        hsync_out = hsync;
        vsync_out = vsync;
        blank_out = blank;

        if (player_pixel == 12'hFFF && object_pixel == 12'hFFF) begin
            pixel_out = floor_pixel;
        end else if (object_pixel == 12'hFFF) begin
            pixel_out = player_pixel; 
        end else begin
            pixel_out = object_pixel;
        end
    end
endmodule
