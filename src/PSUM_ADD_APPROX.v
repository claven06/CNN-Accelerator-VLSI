///==------------------------------------------------------------------==///
/// Conv kernel: adder tree of psum module
///==------------------------------------------------------------------==///
/// Three stages pipelined adder tree
module PSUM_ADD #(
    parameter data_width = 25,
    parameter approx_bits = 6
) (
    input clk,
    input rst_n,
    input signed [data_width-1:0] pe0_data,
    input signed [data_width-1:0] pe1_data,
    input signed [data_width-1:0] pe2_data,
    input signed [data_width-1:0] pe3_data,
    input signed [data_width-1:0] fifo_data,
    output signed [data_width-1:0] out
);

    reg signed [data_width-1:0] psum0;
    reg signed [data_width-1:0] psum1;
    reg signed [data_width-1:0] psum2;
    reg signed [data_width-1:0] out_r;

    wire signed [data_width-1:0] adderl0_output [1:0];
    wire signed [data_width-1:0] adderl1_output;
    wire signed [data_width-1:0] adderl2_output;

    assign out = out_r;
    /// Adder tree
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            psum0 <= 0;
            psum1 <= 0;
            psum2 <= 0;
            out_r   <= 0;
        end else begin
            psum0 <= adderl0_output[0];
            psum1 <= adderl0_output[1];
            psum2 <= adderl1_output;
            out_r <= adderl2_output;
        end
    end

    ADD_APPROX #(
    .bitWidth(data_width), 
    .approxBits(approx_bits)
    ) 
    ADD0_LAYER0 (
        .A(pe0_data),
        .B(pe1_data),
        .Cin(1'b0),
        .Sum(adderl0_output[0])
    );

    ADD_APPROX #(
    .bitWidth(data_width), 
    .approxBits(approx_bits)
    ) 
    ADD1_LAYER0 (
        .A(pe2_data),
        .B(pe3_data),
        .Cin(1'b0),
        .Sum(adderl0_output[1]),
    );

    ADD_APPROX #(
    .bitWidth(data_width), 
    .approxBits(approx_bits)
    ) 
    ADD0_LAYER1 (
        .A(psum0),
        .B(psum1),
        .Cin(1'b0),
        .Sum(adderl1_output),
    );

    ADD_APPROX #(
    .bitWidth(data_width), 
    .approxBits(approx_bits)
    ) 
    ADD0_LAYER2 (
        .A(psum2),
        .B(fifo_data),
        .Cin(1'b0),
        .Sum(adderl2_output),
    );


endmodule
