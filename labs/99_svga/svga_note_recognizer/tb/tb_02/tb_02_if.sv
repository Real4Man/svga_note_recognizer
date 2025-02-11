// import ex_types_pkg::*;
// import connect_pkg::*;


interface tb_02_if(  input wire clk );


    logic                   reset_p;
    logic [5:0]             d2_recognize_result;
    logic                   d2_recognize_result_step;
    logic [15:0][2:0]       d3_note_lenght; // длительность ноты: 0
                                            // 0 - неизвестно
                                            // 1 - 1/16
                                            // 2 - 1/8
                                            // 3 - 1/4
                                            // 4 - 1/2
                                            // 5 - 1/1
    logic [15:0][5:0]       d3_note_index;  // 1-37: индекс ноты, 0 - нет ноты
    logic                   d3_note_step;


    task init;

        reset_p <= '1;

        d2_recognize_result <= '0;
        d2_recognize_result_step <= '0;


    endtask
    
endinterface //tb_02_if


