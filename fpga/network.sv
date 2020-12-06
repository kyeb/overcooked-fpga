module comms(
        input logic clk,
        input logic [1:0] player_ID,
        input logic rst,
        input logic [1:0] local_direction,
        input logic [8:0] local_loc_x,
        input logic [8:0] local_loc_y,
        input logic [3:0] local_state,
        input logic [2:0] local_game_state,
        input logic [7:0][12:0][3:0] local_object_grid,
        input logic ja_1,
        output logic ja_0,
        output logic [2:0] game_state_out,
        output logic [7:0][12:0][3:0] object_grid_out,
        output logic [1:0] player1_direction, player2_direction, player3_direction, player4_direction,
        output logic [8:0] player1_loc_x, player2_loc_x, player3_loc_x, player4_loc_x,
        output logic [8:0] player1_loc_y, player2_loc_y, player3_loc_y, player4_loc_y,
        output logic [3:0] player1_state, player2_state, player3_state, player4_state,
        output logic [7:0] txstate // for displaying network status
    );
    
    // format for player info packet
    // data[31:30] (2 bits) - player number
    // data[29:28] (2 bits) - player direction
    // data[27:19] (9 bits) - x position
    // data[18:10] (9 bits) - y position
    // data[9:6] (4 bits) - player state
    // data[5:3] (3 bits) - game state if player_ID=0, else 0
    // data[2:0] (3 bits) - packet type.
    //       000: player state
    //       111: TX ACK
    //       001: TODO (probably will be board state or smth)
    // total: 2+2+9+9+4 = 26 bits of data, 6 left empty
    
    
    // register input pin
    logic ja_1_reg;
    logic line_in;
    always_ff @(posedge clk) begin
        ja_1_reg <= ja_1;
        line_in <= ja_1_reg;
    end
    
    logic [31:0] rx_data;
    logic rx_valid;
    serial_rx srx (
        .clk(clk),
        .rst_in(rst),
        .line_in(line_in),
        .valid(rx_valid),
        .data_out(rx_data)
    );
    
    // more readable switching between data transmission types
    localparam DTYPE_ACK =          3'b111;
    localparam DTYPE_PSTATE =       3'b000;
    localparam DTYPE_START_BSTATE = 3'b001;
    
    logic [2:0] dtype;
    assign dtype = rx_data[2:0];
    
    logic [31:0] tx_pdata, tx_bdata;
    logic player_trigger, board_trigger, tx_ready;
    serial_tx stx (
        .clk(clk),
        .rst_in(rst),
        .trigger_in(player_trigger | board_trigger),
        .data_in(tx_pdata | tx_bdata),
        .line_out(ja_0),
        .ready(tx_ready)
    );
    
    
    // RX BOARD STATE
    enum logic [1:0] {RX_IDLE  = 2'b00,
                      RX_BUSY  = 2'b01  // 
                      } rx_bstate;

    always_ff @(posedge clk) begin
        if (rst) begin
            player1_direction <= 0; player1_loc_x <= 0; player1_loc_y <= 0; player1_state <= 0;
            player2_direction <= 0; player2_loc_x <= 0; player2_loc_y <= 0; player2_state <= 0;
            player3_direction <= 0; player3_loc_x <= 0; player3_loc_y <= 0; player3_state <= 0;
            player4_direction <= 0; player4_loc_x <= 0; player4_loc_y <= 0; player4_state <= 0;
        end
        
        // RX player state
        if (rx_valid && dtype == DTYPE_PSTATE && rx_bstate == RX_IDLE) begin
            // received state data from server!! use it for the right player sprite
            case(rx_data[31:30])
                2'b00: if (player_ID != 2'b00) begin // don't overwrite local state with remote
                    player1_direction <= rx_data[29:28];
                    player1_loc_x <= rx_data[27:19];
                    player1_loc_y <= rx_data[18:10];
                    player1_state <= rx_data[9:6];
                    game_state_out <= rx_data[5:3]; // only read in game state from main
                end
                2'b01: if (player_ID != 2'b01) begin
                    player2_direction <= rx_data[29:28];
                    player2_loc_x <= rx_data[27:19];
                    player2_loc_y <= rx_data[18:10];
                    player2_state <= rx_data[9:6];
                end
                2'b10: if (player_ID != 2'b10) begin
                    player3_direction <= rx_data[29:28];
                    player3_loc_x <= rx_data[27:19];
                    player3_loc_y <= rx_data[18:10];
                    player3_state <= rx_data[9:6];
                end
                2'b11: if (player_ID != 2'b11) begin
                    player4_direction <= rx_data[29:28];
                    player4_loc_x <= rx_data[27:19];
                    player4_loc_y <= rx_data[18:10];
                    player4_state <= rx_data[9:6];
                end
            endcase
        end

        
        // use local info for correct player sprite
        if (player_ID == 0) begin
            player1_direction <= local_direction;
            player1_loc_x <= local_loc_x;
            player1_loc_y <= local_loc_y;
            player1_state <= local_state;
        end else if (player_ID == 1) begin
            player2_direction <= local_direction;
            player2_loc_x <= local_loc_x;
            player2_loc_y <= local_loc_y;
            player2_state <= local_state;
        end else if (player_ID == 2) begin
            player3_direction <= local_direction;
            player3_loc_x <= local_loc_x;
            player3_loc_y <= local_loc_y;
            player3_state <= local_state;
        end else if (player_ID == 3) begin
            player4_direction <= local_direction;
            player4_loc_x <= local_loc_x;
            player4_loc_y <= local_loc_y;
            player4_state <= local_state;
        end
    end
    

    // TX PLAYER STATE
    enum logic [1:0] {P_IDLE =    2'b00,
                      TX_PLAYER = 2'b01, // transmitting player state
                      P_WAIT =    2'b11  // waiting for ACK from ESP32
                      } tx_pstate;
    // TX BOARD STATE
    enum logic [2:0] {B_IDLE =    3'b000,
                      TX_BSTART = 3'b001, // transmitting start packet
                      TX_BROW =   3'b010, // transmitting the data, 4 bytes at a time
                      TX_BROW_SENDING = 3'b100,
                      B_WAIT  =   3'b011  // waiting for ack
                      } tx_bstate, prev_bstate;
    logic [31:0] local_full_state, prev_local_full_state;
    logic [2:0] game_state;
    assign txstate = {1'b00, tx_bstate, 2'b00, tx_pstate};
    assign game_state = player_ID == 0 ? local_game_state : 3'b000; // only main transmits game state
    assign local_full_state = {player_ID, local_direction, local_loc_x, local_loc_y, local_state, game_state, 3'b000};
    always_ff @(posedge clk) if (player_ID != 0) begin // send player state only from non-mains
        if (rst) begin
            tx_pstate <= P_IDLE;
            tx_pdata <= 0;
        end else case (tx_pstate)
            P_IDLE : begin
                prev_local_full_state <= local_full_state; // prevents inconsistencies if state changes while not in idle
                if (local_full_state != prev_local_full_state) begin
                    tx_pstate <= TX_PLAYER;
                    tx_pdata <= local_full_state;
                    player_trigger <= 1'b1;
                end else begin
                    tx_pstate <= P_IDLE;
                    player_trigger <= 1'b0;
                    tx_pdata <= 0;
                end
            end
            TX_PLAYER : begin
                if (tx_ready)
                    tx_pstate <= P_WAIT;
                else
                    tx_pstate <= TX_PLAYER;
                player_trigger <= 1'b0;
                tx_pdata <= 0;
            end
            P_WAIT : begin
                if (rx_valid && dtype == DTYPE_ACK) // ACK from ESP32!
                    tx_pstate <= P_IDLE;
                else
                    tx_pstate <= P_WAIT;
            end
            default : begin  // Fault Recovery
                tx_pstate <= P_IDLE;
            end
        endcase
    end

    logic [4:0] tx_counter;
    logic [7:0][12:0][3:0] prev_local_object_grid;
    logic prev_tx_ready; // TEMP
    always_ff @(posedge clk) begin
    if (player_ID == 0) begin
        // MAIN - TX BOARD
        object_grid_out <= local_object_grid;
        prev_tx_ready <= tx_ready;
        prev_local_object_grid <= local_object_grid;
        
        prev_bstate <= tx_bstate;
        
        if (rst)
            tx_bstate <= B_IDLE;
        else case (tx_bstate)
            B_IDLE : begin
                if  (tx_ready) begin
                    tx_bstate <= TX_BSTART;
                    tx_bdata <= {29'b0, DTYPE_START_BSTATE};
                    board_trigger <= 1'b1;
                end else begin
                    tx_bdata <= 0;
                    board_trigger <= 1'b0;
                end
                tx_counter <= 0;
            end
            TX_BSTART : begin
                if (tx_ready && prev_bstate != B_IDLE) begin
                    tx_bstate <= TX_BROW;
                end
                board_trigger <= 1'b0;
            end
            TX_BROW : begin // send packet
                if (tx_counter == 15) begin
                    tx_bstate <= B_WAIT;
                    board_trigger <= 1'b0;
                    tx_bdata <= 0;
                end else begin
                    board_trigger <= 1'b1;
                    tx_bstate <= TX_BROW_SENDING;
                    
                    if (tx_counter == 0)
                        tx_bdata <= {local_object_grid[0][0][3:0], local_object_grid[1][0][3:0], local_object_grid[2][0][3:0], local_object_grid[3][0][3:0],
                                    local_object_grid[4][0][3:0], local_object_grid[5][0][3:0], local_object_grid[6][0][3:0], local_object_grid[7][0][3:0]};
                    else if (tx_counter == 1)
                        tx_bdata <= {local_object_grid[0][1][3:0], local_object_grid[1][1][3:0], local_object_grid[2][1][3:0], local_object_grid[3][1][3:0],
                                    local_object_grid[4][1][3:0], local_object_grid[5][1][3:0], local_object_grid[6][1][3:0], local_object_grid[7][1][3:0]};
                    else if (tx_counter == 2)
                        tx_bdata <= {local_object_grid[0][2][3:0], local_object_grid[1][2][3:0], local_object_grid[2][2][3:0], local_object_grid[3][2][3:0],
                                    local_object_grid[4][2][3:0], local_object_grid[5][2][3:0], local_object_grid[6][2][3:0], local_object_grid[7][2][3:0]};
                    else if (tx_counter == 3)
                        tx_bdata <= {local_object_grid[0][3][3:0], local_object_grid[1][3][3:0], local_object_grid[2][3][3:0], local_object_grid[3][3][3:0],
                                    local_object_grid[4][3][3:0], local_object_grid[5][3][3:0], local_object_grid[6][3][3:0], local_object_grid[7][3][3:0]};
                    else if (tx_counter == 4)
                        tx_bdata <= {local_object_grid[0][4][3:0], local_object_grid[1][4][3:0], local_object_grid[2][4][3:0], local_object_grid[3][4][3:0],
                                    local_object_grid[4][4][3:0], local_object_grid[5][4][3:0], local_object_grid[6][4][3:0], local_object_grid[7][4][3:0]};
                    else if (tx_counter == 5)
                        tx_bdata <= {local_object_grid[0][5][3:0], local_object_grid[1][5][3:0], local_object_grid[2][5][3:0], local_object_grid[3][5][3:0],
                                    local_object_grid[4][5][3:0], local_object_grid[5][5][3:0], local_object_grid[6][5][3:0], local_object_grid[7][5][3:0]};
                    else if (tx_counter == 6)
                        tx_bdata <= {local_object_grid[0][6][3:0], local_object_grid[1][6][3:0], local_object_grid[2][6][3:0], local_object_grid[3][6][3:0],
                                    local_object_grid[4][6][3:0], local_object_grid[5][6][3:0], local_object_grid[6][6][3:0], local_object_grid[7][6][3:0]};
                    else if (tx_counter == 7)
                        tx_bdata <= {local_object_grid[0][7][3:0], local_object_grid[1][7][3:0], local_object_grid[2][7][3:0], local_object_grid[3][7][3:0],
                                    local_object_grid[4][7][3:0], local_object_grid[5][7][3:0], local_object_grid[6][7][3:0], local_object_grid[7][7][3:0]};
                    else if (tx_counter == 8)
                        tx_bdata <= {local_object_grid[0][8][3:0], local_object_grid[1][8][3:0], local_object_grid[2][8][3:0], local_object_grid[3][8][3:0],
                                    local_object_grid[4][8][3:0], local_object_grid[5][8][3:0], local_object_grid[6][8][3:0], local_object_grid[7][8][3:0]};
                    else if (tx_counter == 9)
                        tx_bdata <= {local_object_grid[0][9][3:0], local_object_grid[1][9][3:0], local_object_grid[2][9][3:0], local_object_grid[3][9][3:0],
                                    local_object_grid[4][9][3:0], local_object_grid[5][9][3:0], local_object_grid[6][9][3:0], local_object_grid[7][9][3:0]};
                    else if (tx_counter == 10)
                        tx_bdata <= {local_object_grid[0][10][3:0], local_object_grid[1][10][3:0], local_object_grid[2][10][3:0], local_object_grid[3][10][3:0],
                                    local_object_grid[4][10][3:0], local_object_grid[5][10][3:0], local_object_grid[6][10][3:0], local_object_grid[7][10][3:0]};
                    else if (tx_counter == 11)
                        tx_bdata <= {local_object_grid[0][11][3:0], local_object_grid[1][11][3:0], local_object_grid[2][11][3:0], local_object_grid[3][11][3:0],
                                    local_object_grid[4][11][3:0], local_object_grid[5][11][3:0], local_object_grid[6][11][3:0], local_object_grid[7][11][3:0]};
                    else if (tx_counter == 12)
                        tx_bdata <= {local_object_grid[0][12][3:0], local_object_grid[1][12][3:0], local_object_grid[2][12][3:0], local_object_grid[3][12][3:0],
                                    local_object_grid[4][12][3:0], local_object_grid[5][12][3:0], local_object_grid[6][12][3:0], local_object_grid[7][12][3:0]};
                   else if (tx_counter == 13)
                        // send the time grid, zero padded
                        tx_bdata <= {16'h0000, 16'hffff}; // TODO
                    else if (tx_counter == 14)
                        tx_bdata <= local_full_state;
                end
            end
            TX_BROW_SENDING : begin // packet in transmission
                board_trigger <= 1'b0;
                tx_bdata <= 0;
                if (tx_ready && prev_bstate != TX_BROW) begin
                    tx_counter <= tx_counter + 1;
                    tx_bstate <= TX_BROW;
                end
            end
            B_WAIT : begin
                tx_bdata <= 0;
                board_trigger <= 1'b0;
                if (rx_valid && dtype == DTYPE_ACK) // ACK from ESP32!
                    tx_bstate <= B_IDLE;
                else
                    tx_bstate <= B_WAIT;
            end
            default : tx_bstate <= B_IDLE;
        endcase
        rx_bstate <= RX_IDLE;
    end else begin
    
    // SECONDARIES - RX BOARD STATE
//    if (rst)
//        rx_bstate <= RX_IDLE;
//    case (rx_bstate)
//        RX_IDLE: begin
//            if (rx_valid && dtype == DTYPE_START_BSTATE) begin
                
//            end
//        end
//        RX_BUSY: begin
            
//        end
//        RX_WAIT: begin // I don't think we need this, but leaving here in case i get stuck
        
//        end
//    endcase
    end end
endmodule
