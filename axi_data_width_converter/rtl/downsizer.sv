module axi_data_width_downsizer #(
	parameter			DATA_WIDTH_FROM	= 64,
	parameter			DATA_WIDTH_TO	= 8,
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

localparam	COUNT = DATA_WIDTH_FROM / DATA_WIDTH_TO;

logic [DATA_WIDTH_FROM - 1:0]		data_in;
logic [DATA_WIDTH_FROM / 8 - 1:0]	data_in_keep;
logic								data_in_last;
logic [$clog2(COUNT):0]				counter;

assign s_axis_tready = counter == 0;
assign m_axis_tvalid = counter != 0;

//m_axis_tdata
always_comb begin
	m_axis_tdata = '0;
	if (counter != 0)
		m_axis_tdata = data_in[(COUNT - counter) * DATA_WIDTH_TO +: DATA_WIDTH_TO];
end

//m_axis_tkeep
always_comb begin
	m_axis_tkeep = '0;
	if (counter != 0)
		m_axis_tkeep = data_in_keep[(COUNT - counter) * (DATA_WIDTH_TO / 8) +: (DATA_WIDTH_TO / 8)];
end

//m_axis_tlast
always_comb begin
	m_axis_tlast = '0;
	if ('0 == data_in_keep[(COUNT - counter + 1) * DATA_WIDTH_TO / 8 +: (DATA_WIDTH_TO / 8)])
			m_axis_tlast = 1'b1;
	else begin
		if (counter != 0) begin
			if (counter == 1)
				m_axis_tlast = data_in_last;
			else 
				m_axis_tlast = '0;
		end
	end
end

//counter
always_ff @(posedge aclk) begin
	if (!areset_n)
		counter <= 0;
	else begin
		if ('0 == data_in_keep[(COUNT - counter + 1) * DATA_WIDTH_TO / 8 +: (DATA_WIDTH_TO / 8)])
			counter <= '0;
		else begin 
			if (s_axis_tready && s_axis_tvalid)
				counter <= COUNT;
			if (m_axis_tready && m_axis_tvalid)
				counter <= counter - 1;
		end
	end
end

//data_in_last
always_ff @(posedge aclk) begin
	if (!areset_n)
		data_in_last <= '0;
	else if (s_axis_tready && s_axis_tvalid)
		data_in_last <= s_axis_tlast;
end

//data_in_keep
always_ff @(posedge aclk) begin
	if (!areset_n)
		data_in_keep <= '0;
	else if (s_axis_tready && s_axis_tvalid)
		data_in_keep <= s_axis_tkeep;
end

//data_in
always_ff @(posedge aclk) begin
	if (!areset_n)
		data_in <= '0;
	else if (s_axis_tready && s_axis_tvalid)
		data_in <= s_axis_tdata;
end

//m_axis_tuser
always_ff @(posedge aclk) begin
	if (!areset_n)
		m_axis_tuser <= 'b0;
	else if (TUSER_EN)
		m_axis_tuser <= s_axis_tuser;
end

//m_axis_tid
always_ff @(posedge aclk) begin
	if (!areset_n)
		m_axis_tid <= 'b0;
	else if (TID_EN)
		m_axis_tid <= s_axis_tid;
end

//m_axis_tdest
always_ff @(posedge aclk) begin
	if (!areset_n) 
		m_axis_tdest <= 'b0;
	else if (TDEST_EN)
		m_axis_tdest <= s_axis_tdest;
end

endmodule : axi_data_width_downsizer
