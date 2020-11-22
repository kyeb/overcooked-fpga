module action_tb();

//inputs
logic reset;
logic vsync;
logic [1:0] num_players;
logic left, right, up, down, chop, carry;
logic [2:0] game_state;
logic [1:0] player_direction;
logic [8:0] player_loc_x;
logic [8:0] player_loc_y;

//outputs
logic [3:0] player_state;
logic [7:0][12:0][3:0] object_grid;
logic [7:0][12:0][3:0] time_grid;

action uut (.reset(reset),.vsync(vsync),.num_players(num_players),.left(left), 
            .right(right), .up(up), .down(down), .chop(chop), .carry(carry),
            .game_state(game_state),.player_direction(player_direction), 
            .player_loc_x(player_loc_x), .player_loc_y(player_loc_y), .player_state(player_state),
            .object_grid(object_grid),.time_grid(time_grid));
            
 always #5 vsync = !vsync;
            
    initial begin
    reset = 0;
    vsync = 0;
    num_players = 0;
    left = 0;
    right = 0;
    up = 0;
    down = 0;
    chop = 0;
    carry = 0;
    game_state = 0;
    player_direction = 0;
    player_loc_x = 9'd300;
    player_loc_y = 9'd208;
    #10
    reset = 1;
    #10
    reset = 0;
    
    end

endmodule