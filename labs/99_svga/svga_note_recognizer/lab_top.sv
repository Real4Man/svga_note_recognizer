`include "config.svh"

module lab_top
# (
    parameter  clk_mhz       = 50,
               w_key         = 4,
               w_sw          = 8,
               w_led         = 8,
               w_digit       = 8,
               w_gpio        = 100,

               screen_width  = 640,
               screen_height = 480,

               w_red         = 4,
               w_green       = 4,
               w_blue        = 4,

               w_x           = $clog2 ( screen_width  ),
               w_y           = $clog2 ( screen_height )
)
(
    input                        clk,
    input                        slow_clk,
    input                        rst,

    // Keys, switches, LEDs

    input        [w_key   - 1:0] key,
    input        [w_sw    - 1:0] sw,
    output logic [w_led   - 1:0] led,

    // A dynamic seven-segment display

    output logic [          7:0] abcdefgh,
    output logic [w_digit - 1:0] digit,

    // Graphics

    input        [w_x     - 1:0] x,
    input        [w_y     - 1:0] y,

    output logic [w_red   - 1:0] red,
    output logic [w_green - 1:0] green,
    output logic [w_blue  - 1:0] blue,

    // Microphone, sound output and UART

    input        [         23:0] mic,
    output       [         15:0] sound,
    input                        mic_we,

    input                        uart_rx,
    output                       uart_tx,

    // General-purpose Input/Output

    inout        [w_gpio  - 1:0] gpio
);

    //------------------------------------------------------------------------

    assign led        = '0;
    assign abcdefgh   = '0;
    assign digit      = '0;
    // assign red        = '0;
    // assign green      = '0;
    // assign blue       = '0;
    assign sound      = '0;
    assign uart_tx    = '1;
    
    logic [11:0]    color;
    logic [11:0]    color_q;
    
    logic [w_x - 1:0] pixel_x;
    logic [w_y - 1:0] pixel_y;
    
    logic [w_x - 1:0] pixel_x_q;
    logic [w_x - 1:0] pixel_x_q2;

    logic   [3:0]                   osc_vga_r;
    logic   [3:0]                   osc_vga_g;
    logic   [3:0]                   osc_vga_b;
    logic   [3:0]                   osc_state;

    logic   [3:0]                   note_vga_r;
    logic   [3:0]                   note_vga_g;
    logic   [3:0]                   note_vga_b;

   
    logic               rstp;
    logic               vsync;

    logic [15:0]        mic16;

    assign mic16 = mic [23:8];
    
    assign pixel_x = x;
    assign pixel_y = y;

    always @(posedge clk) begin
 
        rstp <= #1 rst;
        pixel_x_q  <= #1 pixel_x;
        pixel_x_q2 <= #1 pixel_x_q;
    
        if( pixel_y>15 && pixel_x>15 && pixel_x<(1024-16) && pixel_y<(768-16))
            //color_q <= display_on & (bitmap_out[pixel_x_q2[3:1]]) ? 12'h0F0 : 0;
            //color_q <= #1 { osc_vga_r, osc_vga_g, osc_vga_b };
            //color_q <= #1 { note_vga_r, note_vga_g, note_vga_b };
            if( pixel_y<384 )
                color_q <= #1 { note_vga_r, note_vga_g, note_vga_b };
            else
                color_q <= #1 { osc_vga_r, osc_vga_g, osc_vga_b };
        else
            color_q <= #1 '0;
    
        vsync <= #1 (pixel_y==0) ? 1'b0 : 1'b1;

    end

    //assign {red, green, blue } = color_q;
    assign red   = color_q[11:8];
    assign green = color_q[7:4];
    assign blue  = color_q[3:0];

    note_grid note_grid
    (
        .clk            (   clk         ),
        .reset_p        (   rstp        ),

        .x              (   pixel_x     ),
        .y              (   pixel_y     ),
        .vga_r          (   note_vga_r   ),
        .vga_g          (   note_vga_g   ),
        .vga_b          (   note_vga_b   )

    );

    osc_mic 
    #(
        .is_simulation   ( 0 )
    )
    osc_mic
    (
      
        .clk            (   clk         ),
        .reset_p        (   rstp        ),
    
        .data           (   mic16       ),
        .data_we        (   mic_we      ),
    
        .threshold      (   16'h0010    ),
    
    
        .x              (   pixel_x     ),
        .y              (   pixel_y     ),
        .vga_r          (   osc_vga_r   ),
        .vga_g          (   osc_vga_g   ),
        .vga_b          (   osc_vga_b   ),
        .vsync          (   vsync      ),
        .state          (   osc_state   )
    );    



logic [15:0] prev_value;
logic [19:0] counter;
logic [19:0] distance;

localparam [15:0] threshold = 16'h1100;

always_ff @ (posedge clk)
    if( rstp )
    begin
        prev_value <= #1 16'h0;
        counter    <= #1 20'h0;
        distance   <= #1 20'h0;
    end
    else
    begin

        if( mic_we ) begin
            prev_value  <= #1 mic16;

            if (  mic16 >= threshold  &&  prev_value <  threshold ) begin
                distance <= counter;
                counter  <= 20'h0;
            end else begin
                if( ~counter[19] )
                    counter <= counter + 20'h1;    
            end
            
        end 

    end    

logic [2:0]         d0_stp;
logic [4:0]         d0_cnt_high;
logic [4:0]         d0_cnt_low;
logic [15:0]        d0_counter;
logic [15:0]        d0_distanse;
logic               d0_distance_step;

logic [2:0]         n_d0_stp;
logic [4:0]         n_d0_cnt_high;
logic [4:0]         n_d0_cnt_low;
logic [15:0]        n_d0_counter;
logic [15:0]        n_d0_distanse;
logic               n_d0_distance_step;

localparam logic[15:0]  threshold_low  = -16'd120;
localparam logic[15:0]  threshold_high =  16'd120;

always_comb begin   : pr_d0_comb
    
    n_d0_stp = d0_stp;
    n_d0_counter = d0_counter;
    n_d0_distanse = d0_distanse;
    n_d0_cnt_high = d0_cnt_high;
    n_d0_cnt_low  = d0_cnt_low;

    n_d0_distance_step = 0;

    if( mic_we )
        n_d0_counter++;

    case( d0_stp )

    0: begin // wait for low value

        n_d0_cnt_high = '0;

        if( mic_we ) begin
            if( $signed( mic16) < $signed(threshold_low) ) begin
                n_d0_cnt_low++;
            end else begin
                n_d0_cnt_low = 0;
            end

            if( n_d0_cnt_low[4] )
                n_d0_stp = 1;


        end
        
    end

    1: begin    // wait for high value

        n_d0_cnt_low = '0;

        if( mic_we ) begin
            if( $signed(mic16) > $signed(threshold_high) ) begin
                n_d0_cnt_high++;
            end else begin
                n_d0_cnt_high = '0;
            end

            if( n_d0_cnt_high[4] )
                n_d0_stp = 2;
        end
        
    end

    2: begin
        n_d0_distanse = d0_counter;
        n_d0_distance_step = 1;
        n_d0_counter = '0;
        n_d0_stp = 0;
    end

    endcase


end

always_ff @(posedge clk) begin  : pr_d0_ff
   
    d0_distance_step <= #1 n_d0_distance_step;
    
    if( rstp ) begin
        d0_stp <= #1 '0;
        d0_counter <= #1 '0;
        d0_distanse <= #1 '0;
        d0_cnt_high <= #1 '0;
        d0_cnt_low  <= #1 '0;
    end else begin
        d0_stp <= #1 n_d0_stp;
        d0_counter <= #1 n_d0_counter;
        d0_distanse <= #1 n_d0_distanse;
        d0_cnt_high <= #1 n_d0_cnt_high;
        d0_cnt_low  <= #1 n_d0_cnt_low;
    end
end


logic [3:0]         d1_stp;
logic [9:0]         d1_temp_counter;
logic               d1_16_step;
logic               d1_8_step;
logic               d1_4_step;
logic               d1_2_step;
logic               d1_1_step;
logic               d1_8_flag;
logic               d1_4_flag;
logic               d1_2_flag;
logic               d1_1_flag;

logic [3:0]         n_d1_stp;
logic [9:0]         n_d1_temp_counter;
logic               n_d1_16_step;
logic               n_d1_8_step;
logic               n_d1_4_step;
logic               n_d1_2_step;
logic               n_d1_1_step;
logic               n_d1_8_flag;
logic               n_d1_4_flag;
logic               n_d1_2_flag;
logic               n_d1_1_flag;

localparam              mic_sample_rate = 48835; // Частота следования отсчётов с микрофона
localparam              temp_period = 240;       // темп - число ударов в минуту
localparam [9:0]       temp_1_16_cnt = 763;     // число отсчётов микрофона в 1/16 такта

localparam [15:0]       start_level = 16'd80;


logic               d1_rstp;

assign d1_rstp = rstp;  // TODO: надо как то сбрасывать по клашише

always_comb begin   : pr_d1_comb
    

    n_d1_stp      = d1_stp;
    n_d1_temp_counter = d1_temp_counter;
    n_d1_8_flag   = d1_8_flag;
    n_d1_4_flag   = d1_4_flag;
    n_d1_2_flag   = d1_2_flag;
    n_d1_1_flag   = d1_1_flag;


    n_d1_16_step  = 0;
    n_d1_8_step   = 0;
    n_d1_4_step   = 0;
    n_d1_2_step   = 0;
    n_d1_1_step   = 0;

    case( d1_stp )

    0: begin    // wait for start level

        n_d1_temp_counter = '0;

        if( mic_we ) begin
            if( $signed(mic16) >= $signed(start_level) )
                n_d1_stp = 1;
        end

        
    end

    endcase

    if( d1_stp ) begin

        if( mic_we )
            n_d1_temp_counter++;

        if( d1_temp_counter == temp_1_16_cnt ) begin
            n_d1_16_step = 1;
            n_d1_temp_counter = '0;
        end

        if( d1_16_step ) begin

            if( d1_8_flag )
                n_d1_8_step = 1;

            n_d1_8_flag = ~n_d1_8_flag;

        end


        if( d1_8_step ) begin

            if( d1_4_flag )
                n_d1_4_step = 1;

            n_d1_4_flag = ~n_d1_4_flag;

        end


        if( d1_4_step ) begin

            if( d1_2_flag )
                n_d1_2_step = 1;

            n_d1_2_flag = ~n_d1_2_flag;

        end


        if( d1_2_step ) begin

            if( d1_1_flag )
                n_d1_1_step = 1;

            n_d1_1_flag = ~n_d1_1_flag;

        end


    end


end

always_ff @(posedge clk) begin  : pr_d1_ff

    d1_16_step  <= #1 n_d1_16_step;
    d1_8_step   <= #1 n_d1_8_step;
    d1_4_step   <= #1 n_d1_4_step;
    d1_2_step   <= #1 n_d1_2_step;
    d1_1_step   <= #1 n_d1_1_step;

    
    if( d1_rstp ) begin

        d1_stp <= #1 '0;
        d1_temp_counter <= #1 '0;
        d1_8_flag  <= #1 '0;
        d1_4_flag  <= #1 '0;
        d1_2_flag  <= #1 '0;
        d1_1_flag  <= #1 '0;
        
    end else begin
        
        d1_stp      <= #1 n_d1_stp;
        d1_temp_counter <= #1 n_d1_temp_counter;
        d1_8_flag   <= #1 n_d1_8_flag;
        d1_4_flag   <= #1 n_d1_4_flag;
        d1_2_flag   <= #1 n_d1_2_flag;
        d1_1_flag   <= #1 n_d1_1_flag;

    end
    
end

endmodule
