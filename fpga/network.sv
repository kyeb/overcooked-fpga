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
        output logic [1:0] txstate // for displaying network status
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
    localparam DTYPE_ACK = 3'b111;
    localparam DTYPE_PSTATE = 3'b000;
    localparam DTYPE_OTHER = 3'b001;
    logic [2:0] dtype;
    assign dtype = rx_data[2:0];
    
    logic [31:0] tx_data;
    logic tx_trigger, tx_ready;
    serial_tx stx (
        .clk(clk),
        .rst_in(rst),
        .trigger_in(tx_trigger),
        .data_in(tx_data),
        .line_out(ja_0),
        .ready(tx_ready)
    );
    

    always_ff @(posedge clk) begin
        if (rst) begin
            player1_direction <= 0; player1_loc_x <= 0; player1_loc_y <= 0; player1_state <= 0;
            player2_direction <= 0; player2_loc_x <= 0; player2_loc_y <= 0; player2_state <= 0;
            player3_direction <= 0; player3_loc_x <= 0; player3_loc_y <= 0; player3_state <= 0;
            player4_direction <= 0; player4_loc_x <= 0; player4_loc_y <= 0; player4_state <= 0;
        end
        
        // RX player state
        if (rx_valid && dtype == DTYPE_PSTATE) begin
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
        end else if (rx_valid && dtype == DTYPE_OTHER) begin
            // TODO
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
    

    // TX ALL THE THINGS
    enum logic [1:0] {IDLE =      2'b00,
                      TX_PLAYER = 2'b01,
                      TX_BOARD =  2'b10,
                      WAIT =      2'b11} tx_state;
    logic [31:0] local_full_state, prev_local_full_state;
    logic [2:0] game_state;
    assign txstate = tx_state;
    always_ff @(posedge clk) begin
        game_state = player_ID == 0 ? local_game_state : 3'b000; // only main transmits game state
        local_full_state <= {player_ID, local_direction, local_loc_x, local_loc_y, local_state, game_state, 3'b000};

        if (rst)
            tx_state <= IDLE;
        else case (tx_state)
            IDLE : begin
                prev_local_full_state <= local_full_state; // prevents inconsistencies if state changes while not in idle
                if (local_full_state != prev_local_full_state) begin
                    tx_state <= TX_PLAYER;
                    tx_data <= local_full_state;
                    tx_trigger <= 1'b1;
                end else if (0) begin // TODO
                    tx_state <= TX_BOARD;
                end else begin
                    tx_state <= IDLE;
                    tx_trigger <= 1'b0;
                end
            end
            TX_PLAYER : begin
                if (tx_ready)
                    tx_state <= WAIT;
                else
                    tx_state <= TX_PLAYER;
                tx_trigger <= 1'b0;
            end
            TX_BOARD : begin
                // TODO
                if (1)
                    tx_state <= IDLE;
                tx_trigger <= 1'b0;
            end
            WAIT : begin
                if (rx_valid && dtype == DTYPE_ACK) // ACK from ESP32!
                    tx_state <= IDLE;
                else
                    tx_state <= WAIT;
            end
            default : begin  // Fault Recovery
                tx_state <= IDLE;
            end
        endcase
    end

    // MAIN - TX BOARD
    always_ff @(posedge clk) begin if (player_ID == 0) begin
        
    end end
    
    // SECONDARY - RX BOARD
    always_ff @(posedge clk) begin if (player_ID != 0) begin
        
    end end
    
    
    // TODO: register outputs to cross clock domains
    always_ff @(posedge clk) begin
    end
endmodule
