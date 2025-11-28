module fifo_top#(
	parameter DATA_WIDTH = 8
)(
	input	logic							ACLK,
	input	logic							ARESETn,
	output	logic							s_axis_tready,
	input	logic							s_axis_tvalid,
	input	logic [DATA_WIDTH - 1:0]		s_axis_tdata,
	input	logic [DATA_WIDTH / 8 - 1 : 0]	s_axis_tkeep,
	input	logic							s_axis_tlast,
	input	logic							m_axis_tready,
	output	logic							m_axis_tvalid,
	output	logic [DATA_WIDTH - 1:0]		m_axis_tdata,
	output	logic [DATA_WIDTH / 8 - 1:0]	m_axis_tkeep,
	output	logic							m_axis_tlast
);

localparam FIFO_SIZE = 8;
localparam FIFO_DATA_WIDTH = DATA_WIDTH + (DATA_WIDTH / 8) + 1;

logic							full;
logic							empty;
logic [$clog2(FIFO_SIZE):0]		count;
logic [FIFO_DATA_WIDTH - 1:0]	data_out;
logic [FIFO_DATA_WIDTH - 1:0]	data_in;

sync_fifo#(.DATA_WIDTH(FIFO_DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE)) fifo(
			.clk(ACLK),
			.reset(!ARESETn),
			.wr_en(wr_en),
			.rd_en(rd_en),
			.data_in(data_in),
			.data_out(data_out),
			.full(full),
			.empty(empty),
			.count(count)
);

assign s_axis_tready	= !full;
assign m_axis_tvalid	= !empty;
assign rd_en			= m_axis_tready && m_axis_tvalid;
assign wr_en			= s_axis_tready && s_axis_tvalid;
assign data_in			= {s_axis_tdata, s_axis_tkeep , s_axis_tlast};
`
assign {m_axis_tdata, m_axis_tkeep, m_axis_tlast} = data_out;

endmodule : fifo_top
