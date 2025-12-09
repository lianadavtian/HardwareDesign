module sync_fifo#(
	parameter DATA_WIDTH	= 8,
	parameter FIFO_SIZE		= 8
)(
	input	logic						clk,
	input	logic						reset,
	input	logic						wr_en,
	input	logic						rd_en,
	input	logic [DATA_WIDTH - 1:0]	data_in,
	output	logic [DATA_WIDTH -1:0]		data_out,
	output	logic						full, 
	output	logic						empty,
	output	logic [$clog2(FIFO_SIZE):0] count
);

localparam BITCNT = $clog2(FIFO_SIZE);

logic [FIFO_SIZE - 1:0][DATA_WIDTH - 1:0]	fifo_;
logic [BITCNT-1:0]							read_ptr;
logic [BITCNT-1:0]							write_ptr;
logic is_full_r;
logic is_empty_r;

assign full		= is_full_r;
assign empty	= is_empty_r;

always_ff @(posedge clk) begin 
	if (reset) begin 
		data_out <= 'b0;
	end
	else if (rd_en && !empty) begin 
			data_out <= fifo_[read_ptr[BITCNT-1:0]];
	end
end

always_ff @(posedge clk) begin 
	if (!reset) begin 
		if (wr_en && !full) 
			fifo_[write_ptr[BITCNT-1:0]] <= data_in;
	end
end

always_ff @(posedge clk) begin 
	if (reset) begin 
		read_ptr <= '0;
		write_ptr <= '0;
	end 
	else begin 
		if (wr_en && !full)
			write_ptr <= write_ptr + 1;
		if (rd_en && !empty) 
			read_ptr <= read_ptr + 1;
	end
end

always_ff @(posedge clk) begin
	if (reset) begin 
		count <= '0;
	end
	else begin 
		count <= count + (wr_en && !full) - (rd_en && !empty);
	end
end

always_ff @(posedge clk) begin
	if (reset) begin
		is_full_r <= 1'b0;
	end
	else begin
		if (wr_en && !rd_en) begin
			if (write_ptr + 1'b1 == read_ptr)
				is_full_r <= 1'b1;
		end
		else if (rd_en)
			is_full_r <= 1'b0;
	end
end

always_ff @(posedge clk) begin
	if (reset) begin
		is_empty_r <= 1'b1;
	end
	else begin
	  if (rd_en && !wr_en) begin
		  if (read_ptr + 1'b1 == write_ptr)
			  is_empty_r <= 1'b1;
	  end
	  else if (wr_en)
		  is_empty_r <= 1'b0;
	end
end

endmodule : sync_fifo
