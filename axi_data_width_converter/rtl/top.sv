module axi_data_width_converter_top #(
	parameter		SLAVE_DATA_WIDTH	= 8,
	parameter		MASTER_DATA_WIDTH	= 64,
	parameter byte	TID_WIDTH			= 1, 
	parameter byte	TDEST_WIDTH			= 1,
	parameter byte	TUSER_WIDTH			= 1,
	parameter bit	TID_EN				= 0,
	parameter bit	TDEST_EN			= 0,
	parameter bit	TUSER_EN			= 0
)(
	input logic aclk,
	input logic areset_n,

	output	logic								s_axis_tready,
	input	logic								s_axis_tvalid,
	input	logic [SLAVE_DATA_WIDTH - 1:0]		s_axis_tdata,
	input	logic [SLAVE_DATA_WIDTH / 8 - 1:0]	s_axis_tkeep,
	input	logic								s_axis_tlast,
	input	logic [TID_WIDTH - 1:0]				s_axis_tid,
	input	logic [TDEST_WIDTH - 1:0]			s_axis_tdest,
	input	logic [TUSER_WIDTH - 1:0]			s_axis_tuser,

	input	logic								m_axis_tready,
	output	logic								m_axis_tvalid,
	output	logic [MASTER_DATA_WIDTH - 1:0]		m_axis_tdata,
	output	logic [MASTER_DATA_WIDTH / 8 - 1:0]	m_axis_tkeep,
	output	logic								m_axis_tlast,
	output	logic [TID_WIDTH - 1:0]				m_axis_tid,
	output	logic [TDEST_WIDTH - 1:0]			m_axis_tdest,
	output	logic [TUSER_WIDTH - 1:0]			m_axis_tuser
);

logic [SLAVE_DATA_WIDTH - 1:0]		reg_s_axis_tdata;
logic [SLAVE_DATA_WIDTH / 8 - 1:0]	reg_s_axis_tkeep;
logic [MASTER_DATA_WIDTH - 1:0]		reg_m_axis_tdata;
logic [MASTER_DATA_WIDTH / 8 - 1:0] reg_m_axis_tkeep;
logic reg_m_axis_tvalid;
logic reg_m_axis_tready;
logic reg_m_axis_tlast;
logic reg_s_axis_tready;
logic reg_s_axis_tvalid;
logic reg_s_axis_tlast;

assign s_axis_tready = reg_s_axis_tready || !reg_s_axis_tvalid;
assign m_axis_tvalid = reg_m_axis_tvalid;
assign reg_m_axis_tready = m_axis_tready;

always_ff @(posedge aclk) begin
	if (!areset_n) begin 
		reg_s_axis_tvalid <= 'b0;
		reg_s_axis_tdata <= 'b0;
		reg_s_axis_tkeep <= 'b0;
		reg_s_axis_tlast <= 'b0;
	end
	else if (s_axis_tready) begin 
		reg_s_axis_tvalid <= s_axis_tvalid;
		reg_s_axis_tdata <= s_axis_tdata;
		reg_s_axis_tkeep <= s_axis_tkeep;
		reg_s_axis_tlast <= s_axis_tlast;
	end
end

always_ff @(posedge aclk) begin
	if (!areset_n) begin
		m_axis_tdata <= 'b0;
		m_axis_tkeep <= 'b0;
		m_axis_tlast <= 'b0;
	end
	else if (m_axis_tvalid && m_axis_tready) begin 
		m_axis_tdata <= reg_m_axis_tdata;
		m_axis_tkeep <= reg_m_axis_tkeep;
		m_axis_tlast <= reg_m_axis_tlast;
	end
end

generate 
	if (SLAVE_DATA_WIDTH > MASTER_DATA_WIDTH)
		axi_data_width_downsizer #(
			.DATA_WIDTH_FROM(SLAVE_DATA_WIDTH),
			.DATA_WITH_TO(MASTER_DATA_WIDTH),
			.TID_WIDTH(TID_WIDTH),
			.TDEST_WIDTH(TDEST_WIDTH),
			.TUSER_WIDTH(TUSER_WIDTH),
			.TID_EN(TID_EN),
			.TDEST_EN(TDEST_EN),
			.TUSER_EN(TUSER_EN)
		) downsizer(
			.aclk(aclk),
			.areset_n(areset_n),
			
			.s_axis_tid(s_axis_tid),
			.s_axis_tdest(s_axis_tdest),
			.s_axis_tuser(s_axis_tuser),
			.m_axis_tid(m_axis_tid),
			.m_axis_tdest(m_axis_tdest),
			.m_axis_tuser(m_axis_tuser),
			
			.s_axis_ready(reg_s_axis_tready),
			.s_axis_tvalid(reg_s_axis_tvalid),
			.s_axis_tkeep(reg_s_axis_tkeep),
			.s_axis_data(reg_s_axis_tdata),
			.s_axis_tlast(reg_s_axis_tlast),

			.m_axis_tready(reg_m_axis_tready),
			.m_axis_tvalid(reg_m_axis_tvalid),
			.m_axis_tdata(reg_m_axis_tdata),
			.m_axis_tkeep(reg_m_axis_tkeep),
			.m_axis_tlast(reg_m_axis_tlast)
		);
	else if (SLAVE_DATA_WIDTH < MASTER_DATA_WIDTH) 
		axi_data_width_upsizer #(
			.DATA_WIDTH_FROM(SLAVE_DATA_WIDTH),
			.DATA_WIDTH_TO(MASTER_DATA_WIDTH),
			.TID_WIDTH(TID_WIDTH),
			.TDEST_WIDTH(TDEST_WIDTH),
			.TUSER_WIDTH(TUSER_WIDTH),
			.TID_EN(TID_EN),
			.TDEST_EN(TDEST_EN),
			.TUSER_EN(TUSER_EN)
		) upsizer(
			.aclk(aclk),
			.areset_n(areset_n),

			.s_axis_tid(s_axis_tid),
			.s_axis_tdest(s_axis_tdest),
			.s_axis_tuser(s_axis_tuser),
			.m_axis_tid(m_axis_tid),
			.m_axis_tdest(m_axis_tdest),
			.m_axis_tuser(m_axis_tuser),
			

			.s_axis_tready(reg_s_axis_tready),
			.s_axis_tvalid(reg_s_axis_tvalid),
			.s_axis_tdata(reg_s_axis_tdata),
			.s_axis_tkeep(reg_s_axis_tkeep),
			.s_axis_tlast(reg_s_axis_tlast),

			.m_axis_tready(reg_m_axis_tready),
			.m_axis_tvalid(reg_m_axis_tvalid),
			.m_axis_tdata(reg_m_axis_tdata),
			.m_axis_tkeep(reg_m_axis_tkeep),
			.m_axis_tlast(reg_m_axis_tlast)
		);
	else
	begin
		axi_data_stream_passtrough #(
			.DATA_WIDTH_FROM(SLAVE_DATA_WIDTH),
			.DATA_WIDTH_TO(MASTER_DATA_WIDTH),
			.TID_WIDTH(TID_WIDTH),
			.TDEST_WIDTH(TDEST_WIDTH),
			.TUSER_WIDTH(TUSER_WIDTH),
			.TID_EN(TID_EN),
			.TDEST_EN(TDEST_EN),
			.TUSER_EN(TUSER_EN)
		) passtrough(
			.aclk(aclk),
			.areset_n(areset_n),

			.s_axis_tid(s_axis_tid),
			.s_axis_tdest(s_axis_tdest),
			.s_axis_tuser(s_axis_tuser),
			.m_axis_tid(m_axis_tid),
			.m_axis_tdest(m_axis_tdest),
			.m_axis_tuser(m_axis_tuser),
			

			.s_axis_tready(reg_s_axis_tready),
			.s_axis_tvalid(reg_s_axis_tvalid),
			.s_axis_tdata(reg_s_axis_tdata),
			.s_axis_tkeep(reg_s_axis_tkeep),
			.s_axis_tlast(reg_s_axis_tlast),

			.m_axis_tready(reg_m_axis_tready),
			.m_axis_tvalid(reg_m_axis_tvalid),
			.m_axis_tdata(reg_m_axis_tdata),
			.m_axis_tkeep(reg_m_axis_tkeep),
			.m_axis_tlast(reg_m_axis_tlast)
		);

	end
endgenerate 

endmodule : axi_data_width_converter_top
