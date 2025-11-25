module axi_data_stream_passtrough #(
	parameter	byte	DATA_WIDTH_FROM = 64,
	parameter	byte	DATA_WIDTH_TO	= 64,
	parameter	byte	TID_WIDTH		= 1,
	parameter	byte	TDEST_WIDTH		= 1,
	parameter	byte	TUSER_WIDTH		= 1,
	parameter	bit		TID_EN			= 0,
	parameter	bit		TDEST_EN		= 0,
	parameter	bit		TUSER_EN		= 0
)(
	input logic aclk,
	input logic areset_n,
	
	output	logic								s_axis_tready,
	input	logic								s_axis_tvalid,
	input	logic [DATA_WIDTH_FROM - 1:0]		s_axis_tdata,
	input	logic [DATA_WIDTH_FROM / 8 - 1:0]	s_axis_tkeep,
	input	logic								s_axis_tlast,
	input	logic [TID_WIDTH - 1:0]				s_axis_tid,
	input	logic [TDEST_WIDTH - 1:0]			s_axis_tdest,
	input	logic [TUSER_WIDTH - 1:0]			s_axis_tuser,


	input	logic								m_axis_tready,
	output	logic								m_axis_tvalid,
	output	logic [DATA_WIDTH_TO - 1:0]			m_axis_tdata,
	output	logic [DATA_WIDTH_TO / 8 - 1:0]		m_axis_tkeep,
	output	logic								m_axis_tlast,
	output	logic [TID_WIDTH - 1:0]				m_axis_tid,
	output	logic [TDEST_WIDTH - 1:0]			m_axis_tdest,
	output	logic [TUSER_WIDTH - 1:0]			m_axis_tuser
);

always_ff @(posedge aclk) begin
	if (!areset_n)
		m_axis_tuser <= 'b0;
	else if (TUSER_EN)
		m_axis_tuser <= s_axis_tuser;
end

always_ff @(posedge aclk) begin
	if (!areset_n)
		m_axis_tid <= 'b0;
	else if (TID_EN)
		m_axis_tid <= s_axis_tid;
end

always_ff @(posedge aclk) begin
	if (!areset_n)
		m_axis_tdest <= 'b0;
	else if (TDEST_EN)
		m_axis_tdest <= s_axis_tdest;
end

always_ff @(posedge aclk) begin 
	if(!areset_n) begin 
		m_axis_tvalid <= 1'b0;
	end
	else begin
		m_axis_tvalid <= s_axis_tvalid;
	end
end

always_ff @(posedge aclk) begin 
	if(!areset_n) begin 
		s_axis_tready <= 'b1;
	end
	else begin
		s_axis_tready <= m_axis_tready;
	end
end

always_ff @(posedge aclk) begin 
	if(!areset_n) begin 
		m_axis_tdata <= 'b0;
	end
	else begin
		m_axis_tdata <= s_axis_tdata;
	end
end

always_ff @(posedge aclk) begin 
	if(!areset_n) begin 
		m_axis_tkeep <= 'b0;
	end
	else begin
		m_axis_tkeep <= s_axis_tdata;
	end
end

always_ff @(posedge aclk) begin 
	if(!areset_n) begin 
		m_axis_tlast <= 'b0;
	end
	else begin
		m_axis_tlast <= s_axis_tlast;
	end
end

endmodule : axi_data_stream_passtrough
