module tb;
	// ----- INPUT ------
	// byte ASCII character: random initial value
  	reg [7:0] m = 8'b10101101;
	// set to 1 when a valid message starts
	reg m_valid = 1'b0;
	// clock
	reg clk = 1'b0;  
	// reset
	reg reset_l = 1'b0;

	// ---- OUTPUT ----
	// set when digest is ready
	wire hash_ready;
	// digest computed
	wire[63:0] out;
	
	hash tb_hash(
		.m(m),
		.m_valid(m_valid),
		.clk(clk),
		.reset_l(reset_l),
		.hash_ready(hash_ready),
		.out(out)
	);
	
	always #10 clk = !clk;
		
	initial begin 
		@(posedge clk) reset_l = 1'b1;
	end
	
	// ------ TEST WITH GIVEN INPUT AND EXPECTED OUTPUT ------
	// file pointer of tv file
	int fp;
	// char read from tb file
	string char;
	// given digest in string format
	string expected_digest;
	// calculated digest in string format (convert hx to string)
	string string_out;
	// indicate if message is finished, start to read expected digest
	int read_digest = 0;
	// push back each char of digest
	reg [7:0] expected_digest_queue[$];
	
	initial begin   
		// ----------------- TEST VECTOR 1 -----------------
		// Message starts
		fork
			@(posedge clk) m_valid = 1'b1;
			@(posedge clk) m = 8'b11111111;
		join
		@(posedge clk) m_valid = 1'b0;
		wait(!tb_hash.next_byte) @(posedge clk);
		fp = $fopen("C:/Users/feffe/Desktop/light_hash/modelsim/reference_tv/tv_1.txt", "r");
		while ($fscanf(fp, "%c", char) == 1) begin			
			case (char)
				// Message ends
				"\n": begin
					fork
						@(posedge clk) m_valid = 1'b1;
						@(posedge clk) m = 8'b00000000;
					join
					@(posedge clk) m_valid = 1'b0;
					wait(!tb_hash.next_byte) @(posedge clk);
					// start to read digest
					read_digest = 1;
				end
				default : begin
					// Read the char of the given digest from tb file
					if (read_digest) begin
						expected_digest_queue.push_back(int'(char));
					end
					// Read the char of message to hash
					else begin
						// Iterate over message
						fork
							@(posedge clk) m_valid = 1'b1;
							@(posedge clk) m = int'(char);
						join
						@(posedge clk) m_valid = 1'b0;
						wait(!tb_hash.next_byte) @(posedge clk);
					end
				end
			endcase
		end
		$fclose(fp);
		@(posedge clk);
		expected_digest = string '(expected_digest_queue);
		string_out = $sformatf("%0h", out);
		if (expected_digest == string_out) begin
			$display("Test vector 1: Ok!");
		end
		else begin
			$display("Test vector 1: No!");
		end
		@(posedge clk);
		expected_digest_queue = {};
		expected_digest = "";
		read_digest = 0;

		// ----------------- TEST VECTOR 2 -----------------
		// Message starts
		fork
			@(posedge clk) m_valid = 1'b1;
			@(posedge clk) m = 8'b11111111;
		join
		@(posedge clk) m_valid = 1'b0;
		fp = $fopen("C:/Users/feffe/Desktop/light_hash/modelsim/reference_tv/tv_2.txt", "r");
		while ($fscanf(fp, "%c", char) == 1) begin			
			case (char)
				// Message ends
				"\n": begin
					fork
						@(posedge clk) m_valid = 1'b1;
						@(posedge clk) m = 8'b00000000;
					join
					@(posedge clk) m_valid = 1'b0;
					wait(!tb_hash.next_byte) @(posedge clk);
					// start to read digest
					read_digest = 1;
				end
				default : begin
					if (read_digest) begin
						expected_digest_queue.push_back(int'(char));
					end
					else begin
						// Iterate over message
						fork
							@(posedge clk) m_valid = 1'b1;
							@(posedge clk) m = int'(char);
						join
						@(posedge clk) m_valid = 1'b0;
						wait(!tb_hash.next_byte) @(posedge clk);
					end
				end
			endcase
		end
		$fclose(fp);
		@(posedge clk);
		expected_digest = string '(expected_digest_queue);
		string_out = $sformatf("%0h", out);
		if (expected_digest == string_out) begin
			$display("Test vector 2: Ok!");
		end
		else begin
			$display("Test vector 2: No!");
		end
		@(posedge clk);
		expected_digest = "";
		expected_digest_queue = {};
		read_digest = 0;

		// ----------------- TEST VECTOR 3 -----------------
		// Message starts
		fork
			@(posedge clk) m_valid = 1'b1;
			@(posedge clk) m = 8'b11111111;
		join
		@(posedge clk) m_valid = 1'b0;
		fp = $fopen("C:/Users/feffe/Desktop/light_hash/modelsim/reference_tv/tv_3.txt", "r");
		while ($fscanf(fp, "%c", char) == 1) begin			
			case (char)
				// Message ends
				"\n": begin
					fork
						@(posedge clk) m_valid = 1'b1;
						@(posedge clk) m = 8'b00000000;
					join
					@(posedge clk) m_valid = 1'b0;
					wait(!tb_hash.next_byte) @(posedge clk);
					// start to read digest
					read_digest = 1;
				end
				default : begin
					if (read_digest) begin
						expected_digest_queue.push_back(int'(char));
					end
					else begin
						// Iterate over message
						fork
							@(posedge clk) m_valid = 1'b1;
							@(posedge clk) m = int'(char);
						join
						@(posedge clk) m_valid = 1'b0;
						wait(!tb_hash.next_byte) @(posedge clk);
					end
				end
			endcase
		end
		$fclose(fp);
		@(posedge clk);
		expected_digest = string '(expected_digest_queue);
		string_out = $sformatf("%0h", out);
		if (expected_digest == string_out) begin
			$display("Test vector 3: Ok!");
		end
		else begin
			$display("Test vector 3: No!");
		end
		@(posedge clk);
		expected_digest_queue = {};
		expected_digest = "";
		read_digest = 0;

	// ------ VARIABLE TO TEST HASH PROPERTIES ------
		string s0 = "Hello";
		string s1 = "Hello";
		string s2 = "World123456789";
		string s3 = "World123456780";
		for (int i = 0; i < 4; i++) begin
			fork
				@(posedge clk) m_valid = 1'b1;
				@(posedge clk) m = 8'b11111111;
			join
			@(posedge clk) m_valid = 1'b0;
			case (i)
				0 : foreach(s0[j]) begin
						fork
							@(posedge clk) m_valid = 1'b1;
							@(posedge clk) m = s0[j];
						join
						@(posedge clk) m_valid = 1'b0;
						wait(!tb_hash.next_byte) @(posedge clk);
					end
				1 : foreach(s1[j]) begin
						fork
							@(posedge clk) m_valid = 1'b1;
							@(posedge clk) m = s1[j];
						join
						@(posedge clk) m_valid = 1'b0;
						wait(!tb_hash.next_byte) @(posedge clk);
					end
				2 : foreach(s2[j]) begin
						fork
							@(posedge clk) m_valid = 1'b1;
							@(posedge clk) m = s2[j];
						join
						@(posedge clk) m_valid = 1'b0;
						wait(!tb_hash.next_byte) @(posedge clk);
					end
				3 : foreach(s3[j]) begin
						fork
							@(posedge clk) m_valid = 1'b1;
							@(posedge clk) m = s3[j];
						join
						@(posedge clk) m_valid = 1'b0;
						wait(!tb_hash.next_byte) @(posedge clk);
					end		
			endcase
			fork
				@(posedge clk) m_valid = 1'b1;
				@(posedge clk) m = 8'b00000000;
			join
			@(posedge clk) m_valid = 1'b0;
		end
		@(posedge clk);
		@(posedge clk) $stop;	
	end
endmodule		