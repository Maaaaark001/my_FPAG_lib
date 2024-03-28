`ifndef __FIR_SV__
`define __FIR_SV__

module FIR #(
    parameter DW = 10,
    parameter TAPS = 8,
    parameter COEF[TAPS] = '{TAPS{0.124}}
)(
    input wire clk, rst, en,
    input wire signed [DW-1 : 0] in,    // Q1.9
    output logic signed [DW-1 : 0] out  // Q1.9
);
    localparam N = TAPS - 1;
    logic signed [DW-1 : 0] coef[TAPS];
    logic signed [DW-1 : 0] prod[TAPS];
    logic signed [DW-1 : 0] delay[TAPS];
    //`DEF_FP_MUL(mul, 1, DW-1, 1, DW-1, DW-1); //Q1.9 * Q1.9 -> Q1.9
    generate
        for(genvar t = 0; t < TAPS; t++) begin
            assign coef[t] = COEF[t] * 2.0**(DW-1.0);
            assign prod[t] = //mul(in, coef[t]);
                ( (2*DW)'(in) * (2*DW)'(coef[t]) ) >>> (DW-1);

        end
    endgenerate
    generate
        for(genvar t = 0; t < TAPS; t++) begin
            always_ff@(posedge clk) begin
                if(rst) delay[t] <= '0;
                else if(en) begin
                    if(t == 0) delay[0] <= prod[N - t];
                    else delay[t] <= prod[N - t] + delay[t - 1];
                end
            end
        end
    endgenerate
    assign out = delay[N];
endmodule

`endif
