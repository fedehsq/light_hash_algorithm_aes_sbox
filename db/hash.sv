// typedef for the return type of a function to have an unpacked dimension
typedef reg [7:0] unpacked_arr [0:7];
parameter unpacked_arr para_1 = '{default:0};

module hash(
  input [7:0] m, // byte ASCII character
  input m_valid, // is a valid and stable char?
  input clk, // clock
  input reset_l, // low reset
  output reg hash_ready, // digest is ready to output
  output reg [63:0] out // result
);

// value "returned" until the result is computed
localparam NUL_CHAR = 8'h00;

localparam bit [7:0] s_box_lut [0:255] = '{
	8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5, 8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76,
	8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0, 8'had, 8'hd4, 8'ha2, 8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0,
	8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc, 8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,
	8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a, 8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75,
	8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0, 8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84,
	8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b, 8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58, 8'hcf,
	8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85, 8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8,
	8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d, 8'h38, 8'hf5, 8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2,
	8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17, 8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64, 8'h5d, 8'h19, 8'h73,
	8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88, 8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb,
	8'he0, 8'h32, 8'h3a, 8'h0a, 8'h49, 8'h06, 8'h24, 8'h5c, 8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79,
	8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9, 8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08,
	8'hba, 8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4, 8'hc6, 8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a,
	8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6, 8'h0e, 8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e,
	8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94, 8'h9b, 8'h1e, 8'h87, 8'he9, 8'hce, 8'h55, 8'h28, 8'hdf,
	8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf, 8'he6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16
};

// Digest will be copied into the output reg in the end of hash computation
reg [7:0] digest[0:7];
// Start of message: initial byte expected
reg [7:0] start = 8'b11111111;
// End of message: last byte expected
reg [7:0] finish = 8'b00000000;
// Counter of iteration done on the current char (byte)
reg [32:0] count;

// Index for accessing to the SBOX
reg [32:0] row;
reg [32:0] column;
reg [32:0] index;

// reg to make the circular left shift
reg [7:0] shifter;

// indicate if the byte is valid and then start to iterate
reg counter_enable = 1'b0;
reg next_byte = 1'b0;

// Initialize digest
function unpacked_arr restore_digest;
    restore_digest[0] = 8'h34;
	restore_digest[1] = 8'h55;
	restore_digest[2] = 8'h0F;
	restore_digest[3] = 8'h14;
	restore_digest[4] = 8'hDA;
	restore_digest[5] = 8'hC0;
	restore_digest[6] = 8'h2B;
	restore_digest[7] = 8'hEE;
endfunction

// hard left circular shift
function reg [7:0] shift_digest(input [7:0] shifter, input [3:0] j);
	case (j)
		0 : shift_digest = shifter;
		1 : shift_digest = {shifter[6:0], shifter[7]};
		2 : shift_digest = {shifter[5:0], shifter[7:6]};
		3 : shift_digest = {shifter[4:0], shifter[7:5]};
		4 : shift_digest = {shifter[3:0], shifter[7:4]};
		5 : shift_digest = {shifter[2:0], shifter[7:3]};
		6 : shift_digest = {shifter[1:0], shifter[7:2]};
		7 : shift_digest = {shifter[0:0], shifter[7:1]};
	endcase
endfunction

// copy the digest to the output
function [63:0] get_digest(input [7:0] digest[0:7]);
	get_digest[7:0] = digest[7];
	get_digest[15:8] = digest[6];
	get_digest[23:16] = digest[5];
	get_digest[31:24] = digest[4];
	get_digest[39:32] = digest[3];
	get_digest[47:40] = digest[2];
	get_digest[55:48] = digest[1];
	get_digest[63:56] = digest[0];
endfunction

// compute digest
function unpacked_arr update_digest(input [7:0] digest[0:7]);
    for (int j = 0; j < 8; j++) begin
        update_digest[j] = (digest[(j + 2) % 8] ^ m);
		shifter = update_digest[j];
		update_digest[j] = shift_digest(shifter, j);
        // 4 MSb and the 4 LSb of input byte as row and column of sbox lut to substitute it
        row = update_digest[j][7:4];
        column = update_digest[j][3:0];
        index = (row * 16) + column;
        update_digest[j] = s_box_lut[index];
	end
endfunction

always @(posedge clk or negedge reset_l) begin
	// reset (start)
	if (!reset_l) begin 
		digest <= restore_digest();
		// cannot pass next byte
		next_byte <= 1'b0;
		// restore the counter
		count <= 32'd0;
		// digest is not computed
		hash_ready <= 1'b0;
		out <= NUL_CHAR;
		counter_enable <= 1'b0;
	end
	// valid and stable char
	else if (m_valid) begin
		// restore counter
		count <= (m == start || m == finish) ? 0 : 1;
		// at next clock cycle, start to iterate over byte
		counter_enable <= 1'b1;
	end
	else if (counter_enable) begin
		// external loop, from 0 to 32 foreach char
		if (count == 0) begin 
			// the input is 'start' so pass next byte
			next_byte <= 1'b1;
		end
		if (count <= 32) begin
			case (m)
				// first fake byte of the message
				start : begin
					digest <= restore_digest();
					// digest not ready
					hash_ready <= 1'b0;
					out <= NUL_CHAR;
				end
				// last fake byte of the message
				finish : begin
					hash_ready <= 1'b1;
					out <= get_digest(digest);
					next_byte <= 1'b0;
					counter_enable <= 1'b0;
				end
				// other cases
				default : begin
					// hash the byte..
					digest <= update_digest(digest);
					// .. for 32 times in different clock cycle
					count <= count + 1;
				end
			endcase
		end
		// all 32 iteration done; go to next byte
		else begin
			// put to 0 and then to 1 in next iteration to wake up the tb
			next_byte <= 1'b0;
			count <= 32'd0;
			counter_enable <= 1'b0;
		end
	end	
	// 32 iterations are done, pass the next byte
	else
		next_byte <= 1'b1;
end
endmodule