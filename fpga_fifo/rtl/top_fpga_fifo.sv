module top_fpga_fifo(
	input logic clk,
	input logic reset,
	input logic wr_en,
	input logic rd_en,
	input [3:0] data_in,
	output [3:0] data_in_out,
	output logic [6:0] seg_out,
	output logic en0,
	output logic en1,
	output logic en2,
	output logic en3,
	output logic full,
	output logic empty
);

logic [6:0] seg_0;
logic [6:0] seg_1;
logic [6:0] seg_3;
logic [2:0] toggle;
logic [3:0] fifo_count;
logic [3:0] digit0;
logic [3:0] digit1;
logic		wr_en_del;
logic		rd_en_del;
logic [3:0] data_out;
int			counter;
int			maxcount = 200000;

sync_fifo fifo(
		.clk(clk),
		.reset(reset),
		.wr_en(wr_en_),
		.rd_en(rd_en_),
		.data_in(data_in),
		.data_out(data_out),
		.full(full),
		.empty(empty),
		.count(fifo_count)
);

dec_to_7_seg seg0(.seven_seg(seg_0),
			.dec(digit0));
dec_to_7_seg seg1(.seven_seg(seg_1),
			.dec(digit1));
dec_to_7_seg seg3(.seven_seg(seg_3),
			.dec(fifo_count));

assign wr_en_		= wr_en & ~wr_en_del;
assign rd_en_		= rd_en & ~rd_en_del;
assign data_in_out	= data_in;

always_comb begin 
	en0 = toggle[0];
	en1 = toggle[1];
	en2 = 1;
	en3 = toggle[2];
end

always_comb begin 
	if (data_out < 10) begin 
		digit0 = data_out;
		digit1 = 'b0;
	end
	else begin 
		digit0 = data_out - 'd10;
		digit1 = 'b0001;
	end
end

always_comb begin
	if (!toggle[0])
		seg_out = seg_0;
	else if (!toggle[1])
		seg_out = seg_1;
	else 
		seg_out = seg_3;
end

always_ff @(posedge clk) begin 
	if (reset || counter == maxcount) begin 
		counter <= 'b0;		
	end
	else 
		counter <= counter + 1;
end

always_ff @(posedge clk) begin 
	if (reset) begin 
		toggle <= 'b110;
	end
	else begin 
		if (counter == maxcount)
			toggle <= {toggle[1:0], toggle[2]};
	end
end

always_ff @(posedge clk) begin 
	if (reset) begin
		wr_en_del <= 'b0;
	end
	else begin
		wr_en_del <= wr_en;
	end
end 

always_ff @(posedge clk) begin 
	if(reset) begin
		rd_en_del <= 'b0;
	end
	else begin
		rd_en_del <= rd_en;
	end
end

endmodule : top_fpga_fifo
