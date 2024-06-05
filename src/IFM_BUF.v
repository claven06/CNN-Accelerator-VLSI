module IFM_BUF (
    input clk,
    input rst_n,
    input ifm_read,
    input signed [7:0] ifm_input,
    output signed [7:0] ifm_buf0,
    output signed [7:0] ifm_buf1,
    output signed [7:0] ifm_buf2,
    output signed [7:0] ifm_buf3
);

reg signed [7:0] ifm_buf [3:0];

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // reset all buffers to 0 when rst_n is low
        for(i = 0; i < 4; i = i + 1) begin
            ifm_buf[i] <= 0;
        end
    end
    else begin
        if(ifm_read) begin // shift buffer from input when ifm_read is high
            ifm_buf[3] <= ifm_buf[2];
            ifm_buf[2] <= ifm_buf[1];
            ifm_buf[1] <= ifm_buf[0];
            ifm_buf[0] <= ifm_input;
        end
        else begin // keep buffer value same when ifm_read is low
            ifm_buf[3] <= ifm_buf[3];
            ifm_buf[2] <= ifm_buf[2];
            ifm_buf[1] <= ifm_buf[1];
            ifm_buf[0] <= ifm_buf[0];
        end
    end
end

// connect buffer values to output ports
assign ifm_buf0 = ifm_buf[0];
assign ifm_buf1 = ifm_buf[1];
assign ifm_buf2 = ifm_buf[2];
assign ifm_buf3 = ifm_buf[3];
endmodule
