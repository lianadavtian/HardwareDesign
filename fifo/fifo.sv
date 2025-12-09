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
logic [BITCNT:0]							read_ptr;
logic [BITCNT:0]							write_ptr;
logic [DATA_WIDTH - 1:0]					data_out_reg;
logic [BITCNT:0]							count_reg;

assign data_out	= data_out_reg;
assign count	= count_reg;
assign full		= (write_ptr[BITCNT - 1:0] == read_ptr[BITCNT - 1:0]) && (write_ptr[BITCNT] != read_ptr[BITCNT]);
assign empty	= (write_ptr == read_ptr);

always_ff @(posedge clk) begin 
	if (reset) begin 
		data_out_reg <= 'b0;
	end
	else if (rd_en && !empty) begin 
			data_out_reg <= fifo_[read_ptr[BITCNT - 1:0]];
	end
end

always_ff @(posedge clk) begin 
	if (!reset) begin 
		if (wr_en && !full) 
			fifo_[write_ptr[BITCNT - 1:0]] <= data_in;
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
		count_reg <= '0;
	end
	else begin 
		if (rd_en && wr_en && !full && !empty) count_reg <= count_reg;
		else begin 
			if (rd_en && !empty) count_reg <= count_reg - 1;
			if (wr_en && !full) count_reg <= count_reg + 1;
		end
	end
end

endmodule : sync_fifo
