///////////////////////////////////////////////////////////////////////////////
//
// RECEIVE (RX)
//
///////////////////////////////////////////////////////////////////////////////

module serial_rx(
        input logic         clk,
        input logic         rst_in,
        input logic         line_in,
        output logic        valid,
        output logic [31:0] data_out // NUM_BYTES*8-1
    );
    parameter NUM_BYTES = 4;
    parameter DIVISOR = 868;
    
    logic byte_valid;
    logic [7:0] byte_out;
    serial_rx_byte #(.DIVISOR(DIVISOR)) rx_byte (
        .clk(clk),
        .rst_in(rst_in),
        .line_in(line_in),
        .data_out(byte_out),
        .valid(byte_valid)
    );
    
    enum logic [1:0] {
            IDLE        = 2'b00,
            RX          = 2'b01,
            NEXT        = 2'b11,
            DELAY       = 2'b10
        } state = IDLE;
    
    // state machine to rx more than one byte
    logic [4:0] byte_count;
    always_ff @(posedge clk) begin
        if (rst_in) begin
            state <= IDLE;
            byte_count <= 0;
        end else
        case(state)
            IDLE: begin
                if (byte_valid) begin
                    state <= RX;
                    data_out <= byte_out;
                    byte_count <= 1;
                end
                
                valid <= 0;
            end
            RX: begin
                if (byte_valid) begin
                    state <= NEXT;
                    data_out <= data_out | (byte_out << (byte_count << 3));
                    byte_count <= byte_count + 1;
                end
                valid <= 0;
            end
            NEXT: begin
                if (byte_count == NUM_BYTES) begin
                    valid <= 1;
                    state <= IDLE;
                end else
                    state <= RX;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
endmodule


module serial_rx_byte(
        input logic         clk,
        input logic         rst_in,
        input logic         line_in,
        output logic        valid,
        output logic [7:0]  data_out
    );
    parameter DIVISOR = 868;
    
    enum logic [1:0] {
            IDLE        = 2'b00,
            START_BIT   = 2'b01,
            RX          = 2'b11,
            DONE        = 2'b10
        } state = IDLE;

    logic [3:0] bit_count;
    logic [10:0] cycle_count;
    
    always_ff @(posedge clk) begin
        if (rst_in) begin
            // reset logic
            bit_count <= 0;
            cycle_count <= 0;
            data_out <= 8'b0;
        end else
        
        case (state)
            IDLE: begin
                valid <= 0;
                if (line_in == 1'b0) begin
                    cycle_count <= 0;
                    state <= START_BIT;
                    data_out <= 0;
                end
            end
            START_BIT: begin
                // wait until middle to start sampling so samples aren't near edges
                if (cycle_count >= DIVISOR*3/2 - 1) begin
                    cycle_count <= 0;
                    bit_count <= 0;
                    state <= RX;
                end else if (cycle_count == DIVISOR/2) begin
                    // make sure still held low
                    if (line_in == 1'b1)
                        state <= IDLE;
                    cycle_count <= cycle_count + 1;
                end else begin
                    cycle_count <= cycle_count + 1;
                end
            end
            RX: begin
                if (bit_count > 7) begin
                    state <= DONE;
                end else begin
                    if (cycle_count == 0) begin
                        // sample!
                        data_out[bit_count] <= line_in;
                        bit_count <= bit_count + 1;
                        cycle_count <= 1;
                    end else if (cycle_count == DIVISOR - 1)
                        cycle_count <= 0;
                    else
                        cycle_count <= cycle_count + 1;
                end
            end
            DONE: begin
                // hold valid high for 1 cycle
                valid <= 1;
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
endmodule


///////////////////////////////////////////////////////////////////////////////
//
// TRANSMIT (TX)
//
///////////////////////////////////////////////////////////////////////////////

module serial_tx(
        input logic        clk,
        input logic        rst_in,
        input logic        trigger_in,
        input logic [31:0] data_in, // NUM_BYTES*8-1
        output logic       line_out
    );
    parameter DIVISOR = 868;
    parameter NUM_BYTES = 4;
    logic trigger_byte, tx_ready;
    logic [7:0] byte_out;
    logic [NUM_BYTES*8-1:0] data;
    serial_tx_byte #(.DIVISOR(DIVISOR)) tx_byte (
        .clk(clk),
        .rst_in(rst_in),
        .trigger_in(trigger_byte),
        .val_in(byte_out),
        .line_out(line_out),
        .ready(tx_ready)
    );
    
    enum logic [2:0] {
            IDLE        = 3'b000,
            START_SEND  = 3'b001,
            SEND_WAIT   = 3'b011,
            SENDING     = 3'b010,
            DELAY       = 3'b110
        } state = IDLE;
    
    // State machine to tx NUM_BYTES bytes
    logic [3:0] byte_count;
    logic [9:0] wait_count;
    always_ff @(posedge clk) begin
        if (rst_in) begin
            byte_out <= 0;
            byte_count <= 0;
            data <= 0;
        end else
        case (state)
            IDLE: begin
                if (trigger_in) begin
                    state <= START_SEND;
                    data <= data_in;
                end
                byte_count <= 0;
            end
            START_SEND: begin
                if (tx_ready) begin
                    state <= SEND_WAIT;
                    
                    data <= {data[7:0], data[NUM_BYTES*8-1:8]};
                    byte_out <= data[7:0];
                    trigger_byte <= 1;
                    byte_count <= byte_count + 1;
                end
            end
            // for some reason, tx_ready takes an extra cycle to go low after starting. wait for it.
            SEND_WAIT: begin
                if (!tx_ready) 
                    state <= SENDING;
            end
            SENDING: begin
                if (tx_ready && byte_count == NUM_BYTES) begin
                    state <= IDLE;
                end else if (tx_ready) begin
                    state <= DELAY;
                    wait_count <= 0;
                end else begin
                    trigger_byte <= 0;
                end
            end
            DELAY: begin
                if (wait_count == DIVISOR) begin
                    state <= START_SEND;
                end else begin
                    wait_count <= wait_count + 1;
                end
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
endmodule


module serial_tx_byte(
        input logic        clk,
        input logic        rst_in,
        input logic        trigger_in,
        input logic [7:0]  val_in,
        output logic       line_out,
        output logic       ready
    );
    parameter DIVISOR = 868;
    
    logic [9:0] shift_buffer;
    logic [3:0] bit_count;
    logic [9:0] cycle_count;

    always_ff @(posedge clk) begin
        if (rst_in || bit_count == 10) begin
            // reset logic
            line_out <= 1'b1;
            bit_count <= 0;
            cycle_count <= 0;
            shift_buffer <= 10'b0;
            ready <= 1;
        end else if (trigger_in) begin
            // set up buffer
            shift_buffer[0] <= 1'b0;
            shift_buffer[8:1] <= val_in;
            shift_buffer[9] <= 1'b1;
            line_out <= 1'b1;
            ready <= 0;
        end else if (shift_buffer != 0) begin
            // transmitting!
            if (cycle_count == DIVISOR) begin
                // every DIVISOR clock cycles, output next bit and shift
                line_out <= shift_buffer[0];
                shift_buffer <= {shift_buffer[0], shift_buffer[9:1]};
                bit_count <= bit_count + 1;
                cycle_count <= 0;
            end else begin
                cycle_count <= cycle_count + 1;
            end
        end
    end
endmodule