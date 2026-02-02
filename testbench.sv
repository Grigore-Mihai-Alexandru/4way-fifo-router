`timescale 1ns/1ns

module testbench;

    // ==============================
    // parametri locali pentru test
    // ==============================
    localparam DATA_WIDTH = 10;
    localparam FIFO_DEPTH = 4;
    localparam ADDR_W     = $clog2(FIFO_DEPTH);
    localparam DATA_W     = DATA_WIDTH - ADDR_W;

    // ==============================
    // semnale pentru DUT
    // ==============================
    logic clk_i;
    logic rst_ni;

    logic                       valid_i;
    logic [DATA_WIDTH-1:0]      data_i;
    logic [FIFO_DEPTH-1:0]      ready_i;
    logic [FIFO_DEPTH-1:0]      valid_o;
    logic                       ready_o;
    logic [FIFO_DEPTH-1:0][DATA_W-1:0] data_o;
    logic                       fifo_full_o;

    // ==============================
    // instantiere DUT
    // ==============================
    router #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .valid_i(valid_i),
        .ready_i(ready_i),
        .data_i(data_i),
        .valid_o(valid_o),
        .ready_o(ready_o),
        .data_o(data_o)
    );

    // ==============================
    // Clock generator
    // ==============================
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;   // 10ns perioada (100 MHz)
    end

    // ==============================
    // Reset generator
    // ==============================
    initial begin
        rst_ni = 0;
        valid_i = 0;
        data_i = '0;
        ready_i = '0;
        #20;            // tinem reset activ 20ns
        rst_ni = 1;
        $display("[%0t] Reset dezactivat", $time);
    end

    // ==============================
    // Stimuli pentru intrare
    // ==============================
    initial begin
        // asteptam resetul
        @(posedge rst_ni);
        @(posedge clk_i);

        // trimitem 4 pachete catre canalele 0,1,2,3
        repeat (2) @(posedge clk_i);
        send_packet(2'd0, 8'hA1);
        send_packet(2'd1, 8'hB2);
        send_packet(2'd2, 8'hC3);
        send_packet(2'd3, 8'hD4);
        send_packet(2'd0, 8'h11);
        send_packet(2'd1, 8'h22);
        send_packet(2'd2, 8'h33);
        send_packet(2'd3, 8'h44);
        send_packet(2'd0, 8'hA1);
        send_packet(2'd1, 8'hB2);
        send_packet(2'd2, 8'hC3);
        send_packet(2'd3, 8'hD4);
        send_packet(2'd0, 8'h11);
        send_packet(2'd1, 8'h22);
        send_packet(2'd2, 8'h33);
        send_packet(2'd3, 8'h44);

        repeat (10) @(posedge clk_i);
        send_packet(2'd0, 8'hA1);
        send_packet(2'd1, 8'hB2);
        send_packet(2'd2, 8'hC3);
        send_packet(2'd3, 8'hD4);
        send_packet(2'd0, 8'h11);
        send_packet(2'd1, 8'h22);
        send_packet(2'd2, 8'h33);
        send_packet(2'd3, 8'h44);

        repeat (10) @(posedge clk_i);
        send_packet(2'd2, 8'h77);
        send_packet(2'd3, 8'h88);
        send_packet(2'd1, 8'h99);
        send_packet(2'd0, 8'hAA);

    end 


    // secventa de generare aleatoare a semnalelor ready_i
    initial begin
        ready_i = '0;
        @(posedge rst_ni);   // astept resetul sa fie dezactivat
        forever begin
            @(posedge clk_i);
            ready_i <= $urandom % 16;  // genereaza un numar aleator intre 0 si 15 (4 biti)
        end
    end
    
    // secventa de testare manuala a semnalelor ready_i
    // initial begin
    //     // dupa ce le trimitem, activam ready_i pe fiecare canal, pe rand
    //     repeat (5) @(posedge clk_i);
    //     $display("[%0t] Activez ready pentru canalul 0", $time);
    //     ready_i[0] = 1;  #20 ready_i[0] = 0;

    //     repeat (3) @(posedge clk_i);
    //     $display("[%0t] Activez ready pentru canalul 1", $time);
    //     ready_i[1] = 1;  #20 ready_i[1] = 0;

    //     repeat (3) @(posedge clk_i);
    //     $display("[%0t] Activez ready pentru canalul 2", $time);
    //     ready_i[2] = 1;  #20 ready_i[2] = 0;

    //     repeat (3) @(posedge clk_i);
    //     $display("[%0t] Activez ready pentru canalul 3", $time);
    //     ready_i[3] = 1;  #20 ready_i[3] = 0;

    //     repeat (100) @(posedge clk_i);
    //     $display("[%0t] Sfarsit simulare", $time);
    //     $stop;
    // end

    // ==============================
    // Task: trimite un pachet nou
    // ==============================
    task send_packet(input [ADDR_W-1:0] addr, input [DATA_W-1:0] payload);
    begin
        data_i  <= {addr, payload};
        valid_i <= 1;

        // astept pana cand routerul zice ready_o = 1
        do begin
            @(posedge clk_i);
        end while (!ready_o);

        // @(posedge clk_i);
        valid_i <= 0;
        data_i  <= '0;
    end
    endtask

endmodule


