module fifo_manager #(
    FIFO_DEPTH = 4
) (
    input  logic clk_i,
    input  logic rst_ni,

    input  logic wr_i, // semnal de scriere
    input  logic rd_i, // semnal de citire

    output logic [$clog2(FIFO_DEPTH)-1:0] wr_cnt_o, // pointer scriere
    output logic [$clog2(FIFO_DEPTH)-1:0] rd_cnt_o, // pointer citire
    output logic fifo_full_o, // semnal fifo plin
    output logic fifo_empty_o // semnal fifo gol
);

    localparam int CNT_W = $clog2(FIFO_DEPTH); // latimea contorului + 1 pentru un bit extra

    // contor pentru numarul de elemente din fifo (0 .. FIFO_DEPTH)
    logic [CNT_W:0] no_of_elements;  // numar de elemente curent in FIFO
    logic [CNT_W:0] no_of_elements_next; // numar de elemente urmator

    // ==========================
    // pointer scriere
    // ==========================
    always @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni)
            wr_cnt_o <= '0;
        else if (wr_i && !fifo_full_o) begin
            if (wr_cnt_o == FIFO_DEPTH-1)
                wr_cnt_o <= '0;
            else
                wr_cnt_o <= wr_cnt_o + 1'b1;
        end
    end

    // ==========================
    // pointer citire
    // ==========================
    always @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni)
            rd_cnt_o <= '0;
        else if (rd_i && !fifo_empty_o) begin
            if (rd_cnt_o == FIFO_DEPTH-1)
                rd_cnt_o <= '0;
            else
                rd_cnt_o <= rd_cnt_o + 1'b1;
        end
    end

    // ==========================
    // calcul next pentru no_of_elements
    // ==========================
    always @* begin // nu este cea mai eficienta metoda, din cauza faptului ca scade freventa de lucru  
        // scriem logica combinationala pentru no_of_elements_next fara intarzieri si fara latch-uri
        no_of_elements_next = no_of_elements;

        // doar scriere (si nu e deja plin)
        if (wr_i && !rd_i && !fifo_full_o)
            no_of_elements_next = no_of_elements + 1'b1;

        // doar citire (si nu e deja gol)
        else if (rd_i && !wr_i && !fifo_empty_o)
            no_of_elements_next = no_of_elements - 1'b1;

        // daca scriu si citesc in acelasi timp, count ramane la fel
    end

    // ==========================
    // full / empty din starea curenta
    // ==========================
    assign fifo_full_o  = (no_of_elements == FIFO_DEPTH);
    assign fifo_empty_o = (no_of_elements == 0);

    // ==========================
    // registru pentru no_of_elements
    // ==========================
    always @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni)
            no_of_elements <= '0;
        else
            no_of_elements <= no_of_elements_next; // preia valoarea calculata anterior cu intarziere de o perioada de clock
    end

endmodule
