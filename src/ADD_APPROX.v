module ADD_APPROX #(
    parameter bitWidth = 16, parameter approxBits = 6
)(
    input signed [bitWidth-1:0] A,
    input signed [bitWidth-1:0] B,
    input signed Cin,
    output signed [bitWidth-1:0] Sum,
    output signed Cout
);

    wire [bitWidth:0] carry_internal;

    // Approximate adder instances for the first approxBits bits
    genvar i;
    generate
        for (i = 0; i < approxBits; i = i + 1) begin : approx
            AdderIMPACTThirdApproxOneBit approxInstances (
                .A(A[i]),
                .B(B[i]),
                .Sum(Sum[i]),
                .Cin(carry_internal[i]),
                .Cout(carry_internal[i+1])
            );
        end
    endgenerate

    // Accurate adder instances for the remaining bits
    generate
        for (i = approxBits; i < bitWidth; i = i + 1) begin : accurate
            AdderAccurateOneBit accurateInstances (
                .A(A[i]),
                .B(B[i]),
                .Sum(Sum[i]),
                .Cin(carry_internal[i]),
                .Cout(carry_internal[i+1])
            );
        end
    endgenerate

    // Initialize carry_internal
    assign carry_internal[0] = Cin;
    assign Cout = (A[bitWidth-1] == B[bitWidth-1]) ? A[bitWidth-1] : Sum[bitWidth-1];

endmodule

module AdderIMPACTThirdApproxOneBit (
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout
);

    assign Cout = A;
    assign Sum = B;

endmodule

module AdderAccurateOneBit (
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout
);

    wire axorb;

    assign axorb = A ^ B;
    assign Sum = axorb ^ Cin;
    assign Cout = (axorb & Cin) | (A & B);

endmodule
