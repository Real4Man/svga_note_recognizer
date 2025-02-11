
package tb_02_pkg;



    // virtual     axi_stream_if   #( .bytes ( n ) )  _st0;
    // virtual     axi_stream_if   #( .bytes ( n ) )  _st1;

    virtual     tb_02_if    _s;

    int                 _cnt_wr=0;
    int                 _cnt_rd=0;
    int                 _cnt_ok=0;  
    int                 _cnt_error=0;

    localparam integer  freq_100_C  = 26163,
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


    task tb_02_init;
    
    endtask

    task tb_02_prepare;

        #1us;
        @(posedge _s.clk);
        _s.reset_p <= #1 0;
        #1us;


    endtask

    task tb_02_seq_01;

        for( int ii=1; ii<37; ii++ ) begin
            @(posedge _s.clk);
            _s.d2_recognize_result <= #1 ii;
            _s.d2_recognize_result_step <= #1 '1;
            @(posedge _s.clk);
            _s.d2_recognize_result_step <= #1 '0;

            repeat (200) @(posedge _s.clk);
        end

    endtask


endpackage    