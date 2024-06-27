module PE #(
    parameter approxBits = 6
)(
    input clk,
    input rst_n,
    input signed [7:0] ifm_input0,
    input signed [7:0] ifm_input1,
    input signed [7:0] ifm_input2,
    input signed [7:0] ifm_input3,
    input signed [7:0] wgt_input0,
    input signed [7:0] wgt_input1,
    input signed [7:0] wgt_input2,
    input signed [7:0] wgt_input3,
    output reg signed [24:0] p_sum
);

reg signed [15:0] product [3:0];
reg signed [16:0] pp_sum [1:0];

wire signed [16:0] adderl0_output [1:0];
wire signed [17:0] adderl1_output;

integer i;
integer j;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // reset all registers to 0 when rst_n is low
        for(i = 0; i < 4; i = i + 1) 
        begin
            product[i] <= 0;
        end

        for(j = 0; j < 2; j = j + 1) 
        begin
            pp_sum[j] <= 0;
        end
        p_sum <= 0;
    end
    else begin // multiply and accumulate to achieve partial sum
        product[0] <= ifm_input0 * wgt_input0;
        product[1] <= ifm_input1 * wgt_input1;
        product[2] <= ifm_input2 * wgt_input2;
        product[3] <= ifm_input3 * wgt_input3;

        pp_sum[0] <= adderl0_output[0];
        pp_sum[1] <= adderl0_output[1];

        p_sum[17:0] <= adderl1_output;
        p_sum[18] <= adderl1_output[17];
        p_sum[19] <= adderl1_output[17];
        p_sum[20] <= adderl1_output[17];
        p_sum[21] <= adderl1_output[17];
        p_sum[22] <= adderl1_output[17];
        p_sum[23] <= adderl1_output[17];
        p_sum[24] <= adderl1_output[17];
    end
end

ADD_APPROX #(
    .bitWidth(16), 
    .approxBits(approxBits)
    ) 
ADD0_LAYER0 (
    .A(product[0]),
    .B(product[1]),
    .Cin(1'b0),
    .Sum(adderl0_output[0][15:0]),
    .Cout(adderl0_output[0][16])
);

ADD_APPROX #(
    .bitWidth(16), 
    .approxBits(approxBits)
    ) 
ADD1_LAYER0 (
    .A(product[2]),
    .B(product[3]),
    .Cin(1'b0),
    .Sum(adderl0_output[1][15:0]),
    .Cout(adderl0_output[1][16])
);

ADD_APPROX #(
    .bitWidth(17), 
    .approxBits(approxBits)
    ) 
ADD0_LAYER1 (
    .A(pp_sum[0]),
    .B(pp_sum[1]),
    .Cin(1'b0),
    .Sum(adderl1_output[16:0]),
    .Cout(adderl1_output[17])
);
endmodule