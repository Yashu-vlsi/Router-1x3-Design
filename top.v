module top(
    input clock,
    input resetn,
    input pkt_valid,
    input read_enb_0,
    input read_enb_1,
    input read_enb_2,
    input [7:0] data_in,
    output [7:0] data_out_0,
    output [7:0] data_out_1,
    output [7:0] data_out_2,
    output vld_out_0,
    output vld_out_1,
    output vld_out_2,
    output err,
    output busy
);

    wire [7:0] d_in;
    wire we0, we1, we2;
    wire soft_reset_0, soft_reset_1, soft_reset_2;
    wire fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg;
    wire parity_done, low_packet_valid, write_enb_reg;
    wire empty_0, empty_1, empty_2, full_0, full_1, full_2;

    // Instantiate the FIFO modules
    fifo_router fifo0 (
        .clk(clock),
        .rstn(resetn),
        .we(we0),
        .re(read_enb_0),
        .soft_rst(soft_reset_0),
        .d(d_in),
        .lfd_state(lfd_state),
        .empty(empty_0),
        .full(full_0),
        .d_out(data_out_0)
    );

    fifo_router fifo1 (
        .clk(clock),
        .rstn(resetn),
        .we(we1),
        .re(read_enb_1),
        .soft_rst(soft_reset_1),
        .d(d_in),
        .lfd_state(lfd_state),
        .empty(empty_1),
        .full(full_1),
        .d_out(data_out_1)
    );

    fifo_router fifo2 (
        .clk(clock),
        .rstn(resetn),
        .we(we2),
        .re(read_enb_2),
        .soft_rst(soft_reset_2),
        .d(d_in),
        .lfd_state(lfd_state),
        .empty(empty_2),
        .full(full_2),
        .d_out(data_out_2)
    );

    // Instantiate the Register module
    register r1 (
        .clk(clock),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .data_in(data_in),
        .fifo_full(fifo_full),
        .detect_add(detect_add),
        .ld_state(ld_state),
        .lfd_state(lfd_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .rst_int_reg(rst_int_reg),
        .err(err),
        .parity_done(parity_done),
        .low_packet_valid(low_packet_valid),
        .dout(d_in)
    );

    // Instantiate the FSM module
    fsm fsmm (
        .clock(clock),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .data_in(data_in[1:0]),
        .fifo_full(fifo_full),
        .fifo_empty_0(empty_0),
        .fifo_empty_1(empty_1),
        .fifo_empty_2(empty_2),
        .soft_reset_0(soft_reset_0),
        .soft_reset_1(soft_reset_1),
        .soft_reset_2(soft_reset_2),
        .parity_done(parity_done),
        .low_packet_valid(low_packet_valid),
        .write_enb_reg(write_enb_reg),
        .detect_add(detect_add),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .lfd_state(lfd_state),
        .full_state(full_state),
        .rst_int_reg(rst_int_reg),
        .busy(busy)
    );

    // Instantiate the Router Sync module
    router_sync sync1 (
        .clk(clock),
        .rst(resetn),
        .detect_add(detect_add),
        .we_reg(write_enb_reg),
        .re0(read_enb_0),
        .re1(read_enb_1),
        .re2(read_enb_2),
        .empty0(empty_0),
        .empty1(empty_1),
        .empty2(empty_2),
        .full0(full_0),
        .full1(full_1),
        .full2(full_2),
        .din(data_in[1:0]),
        .we({we2, we1, we0}),
        .fifo_full(fifo_full),
        .sr0(soft_reset_0),
        .sr1(soft_reset_1),
        .sr2(soft_reset_2),
        .vout0(vld_out_0),
        .vout1(vld_out_1),
        .vout2(vld_out_2)
    );

endmodule
				
