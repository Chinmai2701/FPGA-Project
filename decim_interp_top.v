`timescale 1ns / 1ps

module decim_interp_top (
    input  wire         clk,
    input  wire         rst_n,

    input  wire [15:0]  s_data,
    input  wire         s_valid,
    output wire         s_ready,


    output wire [15:0]  decim_data,
    output wire         decim_valid,

    output wire [191:0] interp_data,
    output wire         interp_valid
);

    wire [39:0]  decim_raw_tdata;
    wire         decim_raw_tvalid;

    wire [15:0]  decim_q115;
    wire         decim_q115_valid;

    wire [479:0] interp_raw_tdata;
    wire         interp_raw_tvalid;
    wire         interp_ready_int;


    deci fir_decim_inst (
        .aclk               (clk),
        .s_axis_data_tdata  (s_data),
        .s_axis_data_tvalid (s_valid),
        .s_axis_data_tready (s_ready),
        .m_axis_data_tdata  (decim_raw_tdata),
        .m_axis_data_tvalid (decim_raw_tvalid)
    );


    wire [36:0] decim_full;
    assign decim_full = decim_raw_tdata[36:0];

    wire decim_sign;
    assign decim_sign = decim_full[36];

    wire decim_ovf_pos;
    wire decim_ovf_neg;
    assign decim_ovf_pos = (~decim_sign) & (|decim_full[35:31]);
    assign decim_ovf_neg =   decim_sign  & (~(&decim_full[35:31]));

    assign decim_q115 = decim_ovf_pos ? 16'h7FFF :
                        decim_ovf_neg ? 16'h8000 :
                        decim_full[30:15];

    assign decim_q115_valid = decim_raw_tvalid;

    
    assign decim_data  = decim_q115;
    assign decim_valid = decim_q115_valid;

    inter fir_interp_inst (
        .aclk               (clk),
        .s_axis_data_tdata  (decim_q115),
        .s_axis_data_tvalid (decim_q115_valid),
        .s_axis_data_tready (interp_ready_int),
        .m_axis_data_tdata  (interp_raw_tdata),
        .m_axis_data_tvalid (interp_raw_tvalid)
    );

    genvar i;
    generate
        for (i = 0; i < 12; i = i + 1) begin : GEN_INTERP_PATH

            assign interp_data[i*16 +: 16] =
               
                ( (~interp_raw_tdata[i*40+38]) &
                  (|interp_raw_tdata[i*40+31 +: 7]) )
                    ? 16'h7FFF :
                
                ( interp_raw_tdata[i*40+38] &
                  (~(&interp_raw_tdata[i*40+31 +: 7])) )
                    ? 16'h8000 :

                interp_raw_tdata[i*40+15 +: 16];

        end
    endgenerate

    assign interp_valid = interp_raw_tvalid;

endmodule