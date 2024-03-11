module Accumulator #( parameter DW = 8 )(
    input wire clk, rst, en,
    input wire [DW - 1 : 0] d,
    output logic [DW - 1 : 0] acc
);
    always_ff@(posedge clk) begin
        if(rst) acc <= '0;
        else if(en) acc <= acc + d;
    end
endmodule

module AccuM #( parameter M = 100 )(
    input wire clk, rst, en,
    input wire [$clog2(M) - 1 : 0] d,
    output logic [$clog2(M) - 1 : 0] acc
);
    logic [$clog2(M) - 1 : 0] acc_next;
    always_comb begin
        acc_next = acc + d;
        if(acc_next >= M || acc_next < acc)
            acc_next -= M;
    end
    always_ff@(posedge clk) begin
        if(rst) acc <= '0;
        else if(en)    acc <= acc_next;
    end
endmodule
