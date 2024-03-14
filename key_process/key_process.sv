module KeyProcess #(
    parameter SMP_INTV = 1_000_000,
    parameter KEY_NUM  = 1
) (
    input wire clk,
    input wire [KEY_NUM - 1 : 0] key,
    output logic [KEY_NUM - 1 : 0] key_en
);
  logic [$clog2(SMP_INTV) - 1 : 0] smp_cnt = '0;
  wire en_intv = (smp_cnt == SMP_INTV - 1);
  always_ff @(posedge clk) begin
    if (smp_cnt < SMP_INTV - 1) smp_cnt <= smp_cnt + 1'b1;
    else smp_cnt <= '0;
  end
  logic [KEY_NUM - 1 : 0] key_reg[2];
  initial begin
    for (integer i = 0; i < 2; i = i + 1) begin
      key_reg[i] <= '0;
    end
  end

  always_ff @(posedge clk) begin
    if (en_intv) key_reg[0] <= key;
    key_reg[1] <= key_reg[0];
  end
  assign key_en = ~key_reg[1] & key_reg[0];
endmodule
