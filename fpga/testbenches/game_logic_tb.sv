module game_logic_tb();

//Inputs

logic reset;
logic clock;
logic vsync;
logic [1:0] local_player_ID;
logic [1:0] num_players;
logic left, right, up, down, chop, carry;

//Outputs

logic [2:0] game_state;
logic [7:0][12:0][3:0] object_grid;
logic [7:0][12:0][3:0] time_grid;
logic [7:0] time_left;
logic [9:0] point_total;
logic [3:0] orders;
logic [3:0][4:0] order_times;
logic [2:0][7:0] team_name;
logic [1:0] player_direction;
logic [8:0] player_loc_x;
logic [8:0] player_loc_y;
logic [3:0] player_state;



game_logic uut (.reset(reset), .clock(clock), .vsync(vsync), .local_player_ID(local_player_ID), .num_players(num_players), 
               .left(left), .right(right), .up(up), .down(down), .chop(chop), .carry(carry), 
               .game_state(game_state), .object_grid(object_grid), .time_grid(time_grid), .time_left(time_left),
               .point_total(point_total), .orders(orders), .order_times(order_times), .team_name(team_name),
               .player_direction(player_direction), .player_loc_x(player_loc_x), .player_loc_y(player_loc_y),
               .player_state(player_state));
               
    always #5 clock = !clock;
    always #5 vsync = !vsync;
   
    initial begin
    reset = 0;
    vsync = 0;
    clock = 0;
    local_player_ID = 0;
    num_players = 0;
    left = 0;
    right = 0;
    up = 0;
    down = 0;
    chop = 0;
    carry = 0;
    
    #5
    reset = 1;
    #10
    reset = 0;
    
    //Welcome menu test
    //move left letter 2
    up = 1;
    #20
    up = 0;
    #20
    
    up = 1;
    #20
    up = 0;
    #20
    
    //move middle letter 2
    right = 1;
    #20
    right = 0;
    #20
    
    down = 1;
    #20
    down = 0;
    #20
    
    down = 1;
    #20
    down = 0;
    #20
    
    //move right letter 1
    right = 1;
    #20
    right = 0;
    #20
    
    up = 1;
    #20
    up = 0;
    #20
    
    chop = 1;
    #20
    chop = 0;
    

    end
   
endmodule          
