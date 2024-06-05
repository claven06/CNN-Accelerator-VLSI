module PE_FSM (
    input clk,
    input rst_n,
    input start_conv,
    input start_again,
    input [1:0] cfg_ci,
    input [1:0] cfg_co,
    output reg ifm_read,
    output reg wgt_read,
    output reg p_valid_output,
    output reg last_chanel_output,
    output reg end_conv
);

reg [5:0] ci;
reg [5:0] co;

reg [5:0] cnt1;
reg [8:0] cnt2;
reg [4:0] cnt3;

reg [2:0] current_state;
reg [2:0] next_state;

reg p_valid;
reg last_chanel;
reg [2:0] p_valid_i;
reg [2:0] last_chanel_i;

parameter [2:0]
    IDLE = 3'b000,
    S1 = 3'b001,
    S2 = 3'b010,
    FINISH = 3'b100;

parameter[6:0] tile_length =  16;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ci <= 0;
        co <= 0;
    end else if(start_conv) begin 
        // cfg_ci and cfg_co are added by 1 and multiplied by 8 (shift left by 3)
        // since cfg_ci = `CI = 0 in top module testbench, ci in PE_FSM will be (0+1)*8 = 8
        // cfg_co is the same as cfg_ci, so co will be 8 as well
        ci <= ((cfg_ci + 6'b000001) << 3);
        co <= ((cfg_co + 6'b000001) << 3);
    end
end

always @(current_state or start_conv or start_again or cnt1 or cnt2) begin
    next_state = 3'bx;
    case(current_state)
        IDLE: begin
            if(start_again)
                next_state = S1;
            else if(start_again && cnt2 == 0 && cnt3 == 0)
                next_state = FINISH;
            else 
                next_state = IDLE;
        end
        S1: begin
            next_state = (cnt1 == 4) ? S2 : S1;
        end
        S2: begin
            if(cnt2 == 0 && cnt1 == 0)
                next_state = IDLE;
            else if(cnt1 == 0)
                next_state = S1;
            else
                next_state = S2;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt1 <= 0;
        cnt2 <= 0;
        cnt3 <= 0;
    end
    else begin
        if(next_state == IDLE)
            cnt1 <= 0;
        else begin // during states S1, S2, FINISH
            if (cnt1 == tile_length + 2) // if cnt1 = 18, restart cnt1 at 0
                cnt1 <= 0;
            else      
                cnt1 <= cnt1 + 1;
            
            if(cnt1 == 0) begin // cnt2 only starts counting when cnt1 = 0     
                if(cnt2 == ci-1)  // if cnt2 = 7, restart cnt2 at 0
                    cnt2 <= 0;
                else
                    cnt2 <= cnt2 + 1;
                
                if(cnt2 == 0) begin // cnt3 only starts counting when cnt2 = 0
                    if(cnt3 == co*15-1) // if cnt3 = 127, restart cnt3 at 0
                        cnt3 <= 0;
                    else
                        cnt3 <= cnt3 + 1;
                end
                else 
                    cnt3 <= cnt3;
            end
            else
                cnt2 <= cnt2;
        end
    end
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {ifm_read, wgt_read, p_valid, last_chanel, end_conv} <= 5'b00000;
    end
    else begin
        {ifm_read, wgt_read, p_valid, last_chanel, end_conv} <= 5'b00000;
        case(next_state)
            IDLE: begin
                {ifm_read, wgt_read, p_valid, last_chanel, end_conv} <= 5'b00000;
            end
            S1: begin
                {ifm_read, wgt_read, end_conv} <= 3'b110;
                p_valid <= (cnt1 < 3) ? 0 : 1;
                last_chanel <= (cnt1 == 3 && cnt2 == 0) ? 1 : 0; 
            end
            S2: begin
                {ifm_read, wgt_read, p_valid, end_conv} <= 4'b1010; 
                last_chanel <= (cnt2 == 0) ? 1 : 0;               
            end
            FINISH: begin
                {ifm_read, wgt_read, p_valid, last_chanel, end_conv} <= 5'b00001;
            end           
            default: begin
                {ifm_read, wgt_read, p_valid, last_chanel, end_conv} <= 5'b00000;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p_valid_output     <= 0;
        p_valid_i[2]       <= 0;
        p_valid_i[1]       <= 0;
        p_valid_i[0]       <= 0;

        last_chanel_output <= 0; 
        last_chanel_i[2]   <= 0;
        last_chanel_i[1]   <= 0;
        last_chanel_i[0]   <= 0;
    end else begin
        p_valid_output     <= p_valid_i[2];
        p_valid_i[2]       <= p_valid_i[1];
        p_valid_i[1]       <= p_valid_i[0];
        p_valid_i[0]       <= p_valid;

        last_chanel_output <= last_chanel_i[2]; 
        last_chanel_i[2]   <= last_chanel_i[1];
        last_chanel_i[1]   <= last_chanel_i[0];
        last_chanel_i[0]   <= last_chanel;
    end
end
endmodule
