module dec_to_7_seg(
	output	logic [6:0] seven_seg,
	input	logic [3:0] dec
);

logic [6:0] seg_out;

assign seven_seg = ~seg_out;

always_ff @(dec) begin 
	case(dec)
		'h0		:	seg_out <= 7'b0111111;
		'h1		:	seg_out <= 7'b0000110;
		'h2		:	seg_out <= 7'b1011011;
		'h3		:	seg_out <= 7'b1001111;
		'h4		:	seg_out <= 7'b1100110;
		'h5		:	seg_out <= 7'b1101101;
		'h6		:	seg_out <= 7'b1111101;
		'h7		:	seg_out <= 7'b0000111;
		'h8		:	seg_out <= 7'b1111111;
		'h9		:	seg_out <= 7'b1101111;
		default :	seg_out <= 7'bxxxxxxx;
	endcase
end

endmodule : dec_to_7_seg
