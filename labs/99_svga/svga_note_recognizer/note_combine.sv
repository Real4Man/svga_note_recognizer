
`default_nettype none 

module note_combine
(
  
    input   wire                clk,
    input   wire                reset_p,

    // input wire                  d1_16_step,
    // input wire                  d1_8_step,
    // input wire                  d1_4_step,
    // input wire                  d1_2_step,
    // input wire                  d1_1_step,

    input wire [5:0]            d2_recognize_result,
    input wire                  d2_recognize_result_step,

    output wire [15:0][2:0]     d3_note_lenght, // длительность ноты: 0
                                                // 0 - неизвестно
                                                // 1 - 1/16
                                                // 2 - 1/8
                                                // 3 - 1/4
                                                // 4 - 1/2
                                                // 5 - 1/1
    output wire [15:0][5:0]     d3_note_index,  // 1-37: индекс ноты, 0 - нет ноты
    output wire                 d3_note_step
    
);

logic               rstp;

logic [3:0]         d3_stp;
logic [3:0]         d3_tack_cnt;
logic [15:0][2:0]   d3_current_lenght;
logic [15:0][5:0]   d3_current_index;
logic               d3_current_step;

logic [3:0]         n_d3_stp;
logic [3:0]         n_d3_tack_cnt;
logic [15:0][2:0]   n_current_lenght;
logic [15:0][5:0]   n_d3_current_index;
logic               n_d3_current_step;

assign d3_note_index = d3_current_index;
assign d3_note_step  = d3_current_step;

always_comb begin   : pr_d3_comb

    n_d3_stp = d3_stp;
    n_d3_tack_cnt = d3_tack_cnt;
    n_current_lenght = d3_current_lenght;
    n_d3_current_index = d3_current_index;

    n_d3_current_step  = 0;
    
    // case( d3_stp )

    // 0: begin
    //     n_d3_current_index[0] = d2_recognize_result;
    //     n_current_lenght[0] = 1;
    // end

    // 1: begin
    //     if( d3_current_index[0] == d2_recognize_result ) begin
    //         n_current_lenght[0] = 2;
    //     end else begin
            
    //     end

    // end

    //endcase

    if( d2_recognize_result_step ) begin

        if( 0==d3_tack_cnt )
            for( int ii=0; ii<16; ii++ )
                n_d3_current_index[ii] = '0;
                
        n_d3_current_index[d3_tack_cnt] = d2_recognize_result; 
        n_d3_current_step  = 1;
        n_d3_tack_cnt++;
    end

    n_d3_stp++;
end

always_ff @(posedge clk) begin  : pr_d3_ff

    rstp <= #1 reset_p;
    
    if( rstp ) begin

        d3_stp <= #1 '0;
        d3_tack_cnt <= #1 '0;
        d3_current_lenght <= #1 '0;
        d3_current_index <= #1 '0;
        d3_current_step  <= #1 '0;
        
    end else begin

        d3_stp <= #1 n_d3_stp;
        d3_tack_cnt <= #1 n_d3_tack_cnt;
        //d3_current_lenght <= #1 n_d3_current_lenght;
        d3_current_index <= #1 n_d3_current_index;
        d3_current_step  <= #1 n_d3_current_step;
        
    end
end




endmodule

`default_nettype wire