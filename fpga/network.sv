module comms(
        input logic clk,
        input logic player_ID,
        input logic rst,
        input logic [1:0] local_direction,
        input logic [8:0] local_loc_x,
        input logic [8:0] local_loc_y,
        input logic [3:0] local_state,
        output logic [1:0] player1_direction, player2_direction, player3_direction, player4_direction,
        output logic [8:0] player1_loc_x, player2_loc_x, player3_loc_x, player4_loc_x,
        output logic [8:0] player1_loc_y, player2_loc_y, player3_loc_y, player4_loc_y,
        output logic [3:0] player1_state, player2_state, player3_state, player4_state
    );
    
    
    always_comb begin
        player1_direction = local_direction;
        player1_loc_x = local_loc_x;
        player1_loc_y = local_loc_y;
        player1_state = local_state;
        
        
        player2_direction = 0;
        player2_loc_x = 0;
        player2_loc_y = 0;
        player2_state = 0;
    end
endmodule
