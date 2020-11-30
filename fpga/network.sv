module comms(
        input logic clk,
        input logic vsync,
        input logic player_ID,
        input logic rst,
        input logic [1:0] local_direction,
        input logic [8:0] local_loc_x,
        input logic [8:0] local_loc_y,
        input logic [3:0] local_state,
        input logic ja_1,
        output logic ja_0,
        output logic [1:0] player1_direction, player2_direction, player3_direction, player4_direction,
        output logic [8:0] player1_loc_x, player2_loc_x, player3_loc_x, player4_loc_x,
        output logic [8:0] player1_loc_y, player2_loc_y, player3_loc_y, player4_loc_y,
        output logic [3:0] player1_state, player2_state, player3_state, player4_state
    );
    
    // format for player info packet
    // data[31:30] (2 bits) - player number
    // data[29:28] (2 bits) - player direction
    // data[27:19] (9 bits) - x position
    // data[18:10] (9 bits) - y position
    // data[9:6] (4 bits) - state
    // data[5:0] (6 bits) - zero filled
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
    
    logic [31:0] tx_data;
    logic tx_trigger;
    serial_tx stx (
        .clk(clk),
        .rst_in(rst),
        .trigger_in(tx_trigger),
        .data_in(tx_data),
        .line_out(ja_0)
    );
    
    // MAIN - RX
    always_ff @(posedge clk) begin if (player_ID == 0) begin
        if (rst) begin
            player2_direction <= 0; player2_loc_x <= 0; player2_loc_y <= 0; player2_state <= 0;
            player3_direction <= 0; player3_loc_x <= 0; player3_loc_y <= 0; player3_state <= 0;
            player4_direction <= 0; player4_loc_x <= 0; player4_loc_y <= 0; player4_state <= 0;
        end
        
        // received info from server!!
        if (rx_valid) begin
            case(rx_data[31:30])
                2'b00: begin
                    // this should not happen yet??
                end
                2'b01: begin
                    player2_direction <= rx_data[29:28];
                    player2_loc_x <= rx_data[27:19];
                    player2_loc_y <= rx_data[18:10];
                    player2_state <= rx_data[9:6];
                end
                2'b10: begin
                    player3_direction <= rx_data[29:28];
                    player3_loc_x <= rx_data[27:19];
                    player3_loc_y <= rx_data[18:10];
                    player3_state <= rx_data[9:6];
                end
                2'b11: begin
                    player4_direction <= rx_data[29:28];
                    player4_loc_x <= rx_data[27:19];
                    player4_loc_y <= rx_data[18:10];
                    player4_state <= rx_data[9:6];
                end
            endcase
        end
    end end
    
    // MAIN - TX
    always_ff @(posedge clk) begin if (player_ID == 0) begin
        
    end end
    
    
    
    // SECONDARY - RX
    always_ff @(posedge clk) begin if (player_ID != 0) begin
        
    end end
    
    // SECONDARY - TX
    always_ff @(posedge clk) begin if (player_ID != 0) begin
        
    end end
    
    
    
    
    // TODO: register outputs to cross clock domains
    always_ff @(posedge clk) begin
        player1_direction <= local_direction;
        player1_loc_x <= local_loc_x;
        player1_loc_y <= local_loc_y;
        player1_state <= local_state;
    end
endmodule
