// DUT: router
module router #(
    parameter int DATA_WIDTH = 10,     // [ADDR_W | DATA_W] (ex: 2 | 8)
    parameter int FIFO_DEPTH = 4
) (
    input  logic clk_i,
    input  logic rst_ni,

    // interfata de intrare
    input  logic                               valid_i,        // date valide la intrare
    input  logic [DATA_WIDTH-1:0]              data_i,         // [addr | data]
    output logic                               ready_o,        // pot primi la intrare

    // interfata de iesire
    output logic [FIFO_DEPTH-1:0]                                       valid_o,        // valid per canal
    output logic [FIFO_DEPTH-1:0][DATA_WIDTH-$clog2(FIFO_DEPTH)-1:0]    data_o,         // payload per canal
    input  logic [FIFO_DEPTH-1:0]                                       ready_i        // ready per canal la iesire
);

    localparam int ADDR_W = $clog2(FIFO_DEPTH);      // = 2 pentru 4 canale
    localparam int DATA_W = DATA_WIDTH - ADDR_W;     // = 8 in exemplu

    // FIFO: stocam pachetul complet [addr|data] ca sa stim canalul din varf
    // datele se transmit in functie de adresa din memorie 
    logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    logic [ADDR_W-1:0]     wr_cnt, rd_cnt;
    logic                  fifo_empty_o;
    logic                  fifo_full_o;

    // handshake intrare / iesire FIFO
    logic wr;
    logic rd;

    // -----------------------------
    // Instantiere FIFO manager
    // -----------------------------
    fifo_manager #(
        .FIFO_DEPTH(FIFO_DEPTH)
    ) fifo_inst (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .wr_i(wr),
        .rd_i(rd),
        .wr_cnt_o(wr_cnt),
        .rd_cnt_o(rd_cnt),
        .fifo_full_o(fifo_full_o),
        .fifo_empty_o(fifo_empty_o)
    );

    // Gata sa primesc la intrare cand FIFO nu e plin
    assign ready_o = ~fifo_full_o;

    // Scriere în FIFO cand am date si am loc
    assign wr = valid_i && ready_o;

    // Memorez pachetul complet [addr|data]
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            // nu curat memoria; e ok pentru un FIFO simplu
        end else if (valid_i && ready_o) begin
            fifo_mem[wr_cnt] <= data_i;
        end
    end

    // --------------------------------
    // Varful FIFO (head): addr & data
    // --------------------------------
    wire [DATA_WIDTH-1:0] head_pkt  = fifo_mem[rd_cnt];
    wire [ADDR_W-1:0]     head_addr = head_pkt[DATA_WIDTH-1 -: ADDR_W];
    wire [DATA_W-1:0]     head_data = head_pkt[DATA_W-1:0];

    // Citire din FIFO doar daca canalul vizat este gata si FIFO nu e gol
    assign rd = (~fifo_empty_o) && (
                  (head_addr == 2'd0 ? ready_i[0] :
                   head_addr == 2'd1 ? ready_i[1] :
                   head_addr == 2'd2 ? ready_i[2] :
                                        ready_i[3])
                );

    // -----------------------------
    // valid_o
    // -----------------------------
    always_comb begin
        valid_o = '0;
        if (~fifo_empty_o) begin
            case (head_addr)
                2'd0: valid_o[0] = 1'b1;
                2'd1: valid_o[1] = 1'b1;
                2'd2: valid_o[2] = 1'b1;
                2'd3: valid_o[3] = 1'b1;
                default: /* none */;
            endcase
        end
    end

    // -----------------------------
    // data_o – payload per canal
    // -----------------------------
    always_comb begin
        // implicit, zero pe toate canalele
        data_o[0] = '0;
        data_o[1] = '0;
        data_o[2] = '0;
        data_o[3] = '0;

        if(~fifo_empty_o && ready_i[head_addr]) begin
            case (head_addr)
                2'd0: data_o[0] = head_data;
                2'd1: data_o[1] = head_data;
                2'd2: data_o[2] = head_data;
                2'd3: data_o[3] = head_data;
                default:;
            endcase
        end

        
    end

endmodule
