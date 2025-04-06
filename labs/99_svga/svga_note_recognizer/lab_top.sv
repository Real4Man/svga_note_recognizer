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
//localparam [9:0]       temp_1_16_cnt = 763;     // число отсчётов микрофона в 1/16 такта
localparam [9:0]       temp_1_16_cnt = (60/temp_period/16)*mic_sample_rate;     // число отсчётов микрофона в 1/16 такта

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

localparam  freq_100_C  = 26163,
            freq_100_Cs = 27718,
            freq_100_D  = 29366,
            freq_100_Ds = 31113,
            freq_100_E  = 32963,
            freq_100_F  = 34923,
            freq_100_Fs = 36999,
            freq_100_G  = 39200,
            freq_100_Gs = 41530,
            freq_100_A  = 44000,
            freq_100_As = 46616,
            freq_100_B  = 49388;

logic [9:0]     mem_distance_low[64];
logic [9:0]     mem_distance_high[64];

function [9:0] high_distance (input [18:0] freq_100);
                high_distance = 103 * mic_sample_rate / freq_100;
endfunction

//------------------------------------------------------------------------

function [9:0] low_distance (input [18:0] freq_100);
                low_distance = 97 * mic_sample_rate  / freq_100;;
endfunction

initial begin
     
        mem_distance_low[1]  = low_distance( freq_100_C  );
        mem_distance_low[2]  = low_distance( freq_100_Cs );
        mem_distance_low[3]  = low_distance( freq_100_D  );
        mem_distance_low[4]  = low_distance( freq_100_Ds );
        mem_distance_low[5]  = low_distance( freq_100_E  );
        mem_distance_low[6]  = low_distance( freq_100_F  );
        mem_distance_low[7]  = low_distance( freq_100_Fs );
        mem_distance_low[8]  = low_distance( freq_100_G  );
        mem_distance_low[9]  = low_distance( freq_100_Gs );
        mem_distance_low[10] = low_distance( freq_100_A  );
        mem_distance_low[11] = low_distance( freq_100_As );
        mem_distance_low[12] = low_distance( freq_100_B  );
        mem_distance_low[13] = low_distance( 2 * freq_100_C  );
        mem_distance_low[14] = low_distance( 2 * freq_100_Cs );
        mem_distance_low[15] = low_distance( 2 * freq_100_D  );
        mem_distance_low[16] = low_distance( 2 * freq_100_Ds );
        mem_distance_low[17] = low_distance( 2 * freq_100_E  );
        mem_distance_low[18] = low_distance( 2 * freq_100_F  );
        mem_distance_low[19] = low_distance( 2 * freq_100_Fs );
        mem_distance_low[20] = low_distance( 2 * freq_100_G  );
        mem_distance_low[21] = low_distance( 2 * freq_100_Gs );
        mem_distance_low[22] = low_distance( 2 * freq_100_A  );
        mem_distance_low[23] = low_distance( 2 * freq_100_As );
        mem_distance_low[24] = low_distance( 2 * freq_100_B  );
        mem_distance_low[25] = low_distance( 4 * freq_100_C  );
        mem_distance_low[26] = low_distance( 4 * freq_100_Cs );
        mem_distance_low[27] = low_distance( 4 * freq_100_D  );
        mem_distance_low[28] = low_distance( 4 * freq_100_Ds );
        mem_distance_low[29] = low_distance( 4 * freq_100_E  );
        mem_distance_low[30] = low_distance( 4 * freq_100_F  );
        mem_distance_low[31] = low_distance( 4 * freq_100_Fs );
        mem_distance_low[32] = low_distance( 4 * freq_100_G  );
        mem_distance_low[33] = low_distance( 4 * freq_100_Gs );
        mem_distance_low[34] = low_distance( 4 * freq_100_A  );
        mem_distance_low[35] = low_distance( 4 * freq_100_As );
        mem_distance_low[36] = low_distance( 4 * freq_100_B  );

        mem_distance_high[1]  = high_distance( freq_100_C  );
        mem_distance_high[2]  = high_distance( freq_100_Cs );
        mem_distance_high[3]  = high_distance( freq_100_D  );
        mem_distance_high[4]  = high_distance( freq_100_Ds );
        mem_distance_high[5]  = high_distance( freq_100_E  );
        mem_distance_high[6]  = high_distance( freq_100_F  );
        mem_distance_high[7]  = high_distance( freq_100_Fs );
        mem_distance_high[8]  = high_distance( freq_100_G  );
        mem_distance_high[9]  = high_distance( freq_100_Gs );
        mem_distance_high[10] = high_distance( freq_100_A  );
        mem_distance_high[11] = high_distance( freq_100_As );
        mem_distance_high[12] = high_distance( freq_100_B  );
        mem_distance_high[13] = high_distance( 2 * freq_100_C  );
        mem_distance_high[14] = high_distance( 2 * freq_100_Cs );
        mem_distance_high[15] = high_distance( 2 * freq_100_D  );
        mem_distance_high[16] = high_distance( 2 * freq_100_Ds );
        mem_distance_high[17] = high_distance( 2 * freq_100_E  );
        mem_distance_high[18] = high_distance( 2 * freq_100_F  );
        mem_distance_high[19] = high_distance( 2 * freq_100_Fs );
        mem_distance_high[20] = high_distance( 2 * freq_100_G  );
        mem_distance_high[21] = high_distance( 2 * freq_100_Gs );
        mem_distance_high[22] = high_distance( 2 * freq_100_A  );
        mem_distance_high[23] = high_distance( 2 * freq_100_As );
        mem_distance_high[24] = high_distance( 2 * freq_100_B  );
        mem_distance_high[25] = high_distance( 4 * freq_100_C  );
        mem_distance_high[26] = high_distance( 4 * freq_100_Cs );
        mem_distance_high[27] = high_distance( 4 * freq_100_D  );
        mem_distance_high[28] = high_distance( 4 * freq_100_Ds );
        mem_distance_high[29] = high_distance( 4 * freq_100_E  );
        mem_distance_high[30] = high_distance( 4 * freq_100_F  );
        mem_distance_high[31] = high_distance( 4 * freq_100_Fs );
        mem_distance_high[32] = high_distance( 4 * freq_100_G  );
        mem_distance_high[33] = high_distance( 4 * freq_100_Gs );
        mem_distance_high[34] = high_distance( 4 * freq_100_A  );
        mem_distance_high[35] = high_distance( 4 * freq_100_As );
        mem_distance_high[36] = high_distance( 4 * freq_100_B  );


end

logic [15:0]        d2_distance_collection[64];
logic               d2_mic_we_z0;
logic               d2_mic_we_z1;

logic [3:0]         d2_stp;
logic [5:0]         d2_index;
logic [5:0]         d2_recognize_result;
logic               d2_recognize_result_step;
logic               d2_fix_16_step;
logic [15:0]        d2_no_distance_cnt;
logic               d2_no_distance_flag;
logic [5:0]         d2_max_index;
logic [15:0]        d2_max_value;


logic [3:0]         n_d2_stp;
logic [5:0]         n_d2_index;
logic [5:0]         n_d2_recognize_result;
logic               n_d2_recognize_result_step;
logic               n_d2_fix_16_step;
logic [15:0]        n_d2_no_distance_cnt;
logic               n_d2_no_distance_flag;

logic [15:0]        n_d2_distance_value;
logic               n_d2_distance_we;
logic [15:0]        n_low_distanse;
logic [15:0]        n_high_distanse;
logic [5:0]         n_d2_max_index;
logic [15:0]        n_d2_max_value;

always_comb begin   : pr_d2_comb

    n_d2_stp = d2_stp;
    n_d2_index = d2_index;
    n_d2_recognize_result = d2_recognize_result;
    n_d2_recognize_result_step = n_d2_recognize_result_step;
    n_d2_fix_16_step = d2_fix_16_step;
    n_d2_no_distance_cnt = d2_no_distance_cnt;
    n_d2_no_distance_flag = d2_no_distance_flag;
    n_d2_max_index = d2_max_index;
    n_d2_max_value = d2_max_value;
     
    n_d2_distance_value = '0;
    n_d2_distance_we    = '0;

    n_low_distanse = mem_distance_low[d2_index];
    n_high_distanse = mem_distance_high[d2_index];

    n_d2_recognize_result_step = '0;

    if( d1_16_step ) begin
        n_d2_fix_16_step = '1;
    end

    case( d2_stp ) 
    
    0: begin
        n_d2_distance_value = '0;
        n_d2_distance_we    = '1;
        n_d2_index = '0;
        n_d2_stp = 1;
    end

    1: begin
        n_d2_index++;
        n_d2_distance_value = '0;
        n_d2_distance_we    = '1;
        if( n_d2_index == 6'h00 )
            n_d2_stp = 2;
    end

    2: begin
        n_d2_no_distance_cnt = '0;
        n_d2_no_distance_flag = '1;
        n_d2_index = '1;
        if( d2_mic_we_z1 ) begin
            n_d2_stp = 3;
        end
    end

    3: begin


        if( d2_index==6'd37 ) begin

            n_d2_distance_value = d2_distance_collection[d2_index] + 1;

            if( d2_no_distance_flag ) begin
                n_d2_distance_we = 1;
            end

        end else begin

            if( d0_distanse >= n_low_distanse &&
                d0_distanse < n_high_distanse ) begin
        
            n_d2_distance_value = d2_distance_collection[d2_index] + 1;
            n_d2_distance_we = 1;
            n_d2_no_distance_flag = 0;
                
            end 
            
        end

        n_d2_index++;

        if( n_d2_index == 6'd38 ) begin
            if( d2_fix_16_step ) begin
                n_d2_stp = 4;
                n_d2_index = 1;
            end else begin 
                n_d2_stp = 2;
            end
        end

        n_d2_max_value = '0;
        n_d2_max_index = '0;

    end

    4: begin

        n_d2_fix_16_step = '0;

        if( d2_distance_collection[d2_index]>d2_max_value ) begin
            n_d2_max_index = d2_index;
            n_d2_max_value = d2_distance_collection[d2_index];
        end

        n_d2_index++;
        if( n_d2_index==6'd38 ) begin
            n_d2_stp = 5;
        end

        n_d2_distance_value = '0;
        n_d2_distance_we = 1;
        
    end

    5: begin

        n_d2_recognize_result = (d2_max_index==6'd38 ) ? '0 : d2_max_index;
        n_d2_recognize_result_step = '1;
        n_d2_stp = 2;
    end

    endcase

end

always_ff @(posedge clk) begin  : pr_d2_ff
    
    d2_mic_we_z0 <= #1 mic_we;
    d2_mic_we_z1 <= #1 d2_mic_we_z0;

    d2_index <= #1 n_d2_index;
    d2_recognize_result_step <= #1 n_d2_recognize_result_step;

    d2_no_distance_cnt <= #1 n_d2_no_distance_cnt;
    d2_max_index <= #1 n_d2_max_index;
    d2_max_value <= #1 n_d2_max_value;

    if( n_d2_distance_we )
        d2_distance_collection[d2_index] <= #1 n_d2_distance_value;

    if( d1_rstp ) begin

        d2_stp <= #1 '0;
        d2_recognize_result <= #1 '0;
        d2_fix_16_step <= #1 '0;
        d2_no_distance_flag <= #1 '0;
        
    end else begin

        d2_stp <= #1 n_d2_stp;
        d2_recognize_result <= #1 n_d2_recognize_result;
        d2_fix_16_step <= #1 n_d2_fix_16_step;
        d2_no_distance_flag <= #1 n_d2_no_distance_flag;
        
    end
end

endmodule
