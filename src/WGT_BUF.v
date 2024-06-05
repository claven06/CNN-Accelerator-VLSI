module WGT_BUF (
    input clk,
    input rst_n,
    input wgt_read,
    input signed [7:0] wgt_input,
    output signed [7:0] wgt_buf0,
    output signed [7:0] wgt_buf1,
    output signed [7:0] wgt_buf2,
    output signed [7:0] wgt_buf3
);

reg signed [7:0] wgt_buf [3:0];

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // reset all buffers to 0 when rst_n is low
        for(i = 0; i < 4; i = i + 1) begin
            wgt_buf[i] <= 0;
        end
    end
    else begin
        if(wgt_read) begin // shift buffer from input when wgt_read is high
            wgt_buf[3] <= wgt_buf[2];
            wgt_buf[2] <= wgt_buf[1];
            wgt_buf[1] <= wgt_buf[0];
            wgt_buf[0] <= wgt_input;
        end
        else begin // keep buffer value same when wgt_read is low
            wgt_buf[3] <= wgt_buf[3];
            wgt_buf[2] <= wgt_buf[2];
            wgt_buf[1] <= wgt_buf[1];
            wgt_buf[0] <= wgt_buf[0];
        end
    end
end

// connect buffer values to output ports
assign wgt_buf0 = wgt_buf[0];
assign wgt_buf1 = wgt_buf[1];
assign wgt_buf2 = wgt_buf[2];
assign wgt_buf3 = wgt_buf[3];
endmodule
