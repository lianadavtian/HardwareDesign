module axi_data_width_upsizer #(
	parameter		DATA_WIDTH_FROM		= 8,
	parameter		DATA_WIDTH_TO		= 64,
	parameter byte  TID_WIDTH			= 1,
	parameter byte	TDEST_WIDTH			= 1,
	parameter byte	TUSER_WIDTH			= 1,
	parameter bit	TID_EN				= 0,
	parameter bit	TDEST_EN			= 0,
	parameter bit	TUSER_EN			= 0
)(
	input logic								aclk,
	input logic								areset_n,

	output logic		    					s_axis_tready,
	input logic									s_axis_tvalid,
	input logic		[DATA_WIDTH_FROM - 1:0]		s_axis_tdata,
	input logic		[DATA_WIDTH_FROM / 8 - 1:0] s_axis_tkeep,
	input logic									s_axis_tlast,
	input logic		[TID_WIDTH - 1:0]			s_axis_tid,
	input logic		[TDEST_WIDTH - 1:0]			s_axis_tdest,
	input logic		[TUSER_WIDTH - 1:0]			s_axis_tuser,

	input logic									m_axis_tready,
	output logic								m_axis_tvalid,
	output logic	[DATA_WIDTH_TO - 1:0]		m_axis_tdata,
	output logic	[DATA_WIDTH_TO / 8 - 1:0]	m_axis_tkeep,
	output logic								m_axis_tlast,
	output logic	[TID_WIDTH - 1:0]			m_axis_tid,
	output logic	[TDEST_WIDTH - 1:0]			m_axis_tdest,
	output logic	[TUSER_WIDTH - 1:0]			m_axis_tuser
);

localparam COUNT = DATA_WIDTH_TO / DATA_WIDTH_FROM;

logic [DATA_WIDTH_TO - 1:0]		data_out;
logic [DATA_WIDTH_TO / 8 - 1:0] data_out_keep;
logic							data_out_last;
logic [$clog2(COUNT):0]			counter;


assign m_axis_tlast = data_out_last;
assign s_axis_tready = !(((counter == COUNT) || data_out_last) && !m_axis_tready);

//data_out
always_ff @(posedge aclk) begin
	if (!areset_n) 
		data_out <= '0;
	else if (s_axis_tready && s_axis_tvalid)
		data_out[counter * DATA_WIDTH_FROM +: DATA_WIDTH_FROM] <= s_axis_tdata;
end

//data_out_keep 
always_ff @(posedge aclk) begin
	if (!areset_n)
		data_out_keep <= '0;
	else if (s_axis_tready && s_axis_tvalid)
		data_out_keep[counter * (DATA_WIDTH_FROM / 8) +: (DATA_WIDTH_FROM / 8)] <= s_axis_tkeep;
end

//data_out_last
always_ff @(posedge aclk) begin
	if (!areset_n)
		data_out_last <= 1'b0;
	else if (s_axis_tready && s_axis_tvalid)
		data_out_last <= s_axis_tlast;
end

//m_axis_tvalid
always_comb begin
	m_axis_tvalid = 1'b0;
	if (counter == COUNT)
		m_axis_tvalid = 1'b1;
	else if (data_out_last)
		m_axis_tvalid  = 1'b1;
	else 
		m_axis_tvalid = 1'b0;
end

//m_axis_tdata
always_comb begin
	m_axis_tdata = '0;
	if (counter == COUNT) 
		m_axis_tdata = data_out;
	else if (data_out_last) begin
		m_axis_tdata = data_out;
		for (int i = 0; i < DATA_WIDTH_TO / DATA_WIDTH_FROM; ++i) begin 
			if (i >= counter)
				m_axis_tdata[i * DATA_WIDTH_FROM +: DATA_WIDTH_FROM] = '0;
		end
	end
end

//m_axis_tkeep
always_comb begin
	m_axis_tkeep = 'b0;
	if (counter == COUNT)
		m_axis_tkeep = data_out_keep;
	else if (data_out_last) begin
		m_axis_tkeep = data_out_keep;
		for (int i = 0; i < DATA_WIDTH_TO / DATA_WIDTH_FROM; ++i) begin 
			if (i >= counter)
				m_axis_tkeep[i * (DATA_WIDTH_FROM / 8) +: (DATA_WIDTH_FROM / 8)] = 'b0;
		end
	end
end

//counter
always_ff @(posedge aclk) begin
	if (!areset_n)
		counter <= '0;
	else begin
		if (counter == COUNT && m_axis_tready) begin
			if (s_axis_tready && s_axis_tvalid)
				counter <= 'b1;
			else
				counter <= '0;
		end
		else if (data_out_last && m_axis_tready) begin
			if (s_axis_tready && s_axis_tvalid)
				counter <= 'b1;
			else
				counter <= '0;
		end
		else begin 
			if (s_axis_tready && s_axis_tvalid) 
				counter <= counter + 1;
		end
	end
end

//m_axis_tuser
always_ff @(posedge aclk) begin
	if (!areset_n)
		m_axis_tuser <= '0;
	else if (TUSER_EN)
		m_axis_tuser <= s_axis_tuser;
end

// m_axis_tid
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

endmodule : axi_data_width_upsizer
