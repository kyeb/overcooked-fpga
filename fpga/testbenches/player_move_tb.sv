module player_move_tb();

//inputs
logic reset;
logic vsync;
logic [1:0] num_players;
logic left, right, up, down, chop, carry;
logic [2:0] game_state;
logic [1:0] local_player_ID;
logic [8:0] player_a_x, player_b_x, player_c_x; 
logic [8:0] player_a_y, player_b_y, player_c_y;

//outputs

logic [8:0] player_loc_x;
logic [8:0] player_loc_y;
logic [1:0] player_direction;

player_move uut (.reset(reset),.vsync(vsync),.num_players(num_players),.left(left), 
            .right(right), .up(up), .down(down), .chop(chop), .carry(carry),
            .game_state(game_state), .local_player_ID(local_player_ID),
            .player_a_x(player_a_x), .player_b_x(player_b_x), .player_c_x(player_c_x), .player_a_y(player_a_y), 
            .player_b_y(player_b_y), .player_c_y(player_c_y),
            
            .player_loc_x(player_loc_x), .player_loc_y(player_loc_y), .player_direction(player_direction));
            
 always #5 vsync = !vsync;
            
    initial begin
    reset = 0;
    vsync = 0;
    num_players = 1;
    left = 0;
    right = 0;
    up = 0;
    down = 0;
    chop = 0;
    carry = 0;
    game_state = 2;
    local_player_ID = 0;
    player_a_x = 9'd400;
    player_b_x = 0;
    player_c_x = 0;
    player_a_y = 9'd208;
    player_b_y = 0;
    player_c_y = 0;
    #10
    reset = 1;
    #10
    reset = 0;
    
    right = 1;
    #500
    right = 0;
    left = 1;
    
    end

endmodule