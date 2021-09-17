# Light Hash algorithm (AES S-box based) #

The project consists in the development of a hardware module for the calculation of a custom hash function.

## Project specification ##

The hash algorithm generates a 64-bit digest formed by the concatenation of 8 bytes 𝐻[𝑖], from 𝐻[0] up to 𝐻[7], being 𝐻[0] the most significant byte. \
For each message the 𝐻[𝑖] variables are initialized with the following values:

```verilog
H[0] = 8'h34;
H[1] = 8'h55;
H[2] = 8'h0f;
H[3] = 8'h14;
H[4] = 8'hDA;
H[5] = 8'hC0;
H[6] = 8'h2B;
H[7] = 8'hEE;
```

For each byte 𝑀 of the input message (i.e. the 8-bit ASCII code of a message character) the hash module performs the following operation:

```verilog
for (i = 0; i < 32; i++)
    for (j = 0; j < 8; j++)
        H[i] = S((H[(i + 2) mod 8] ⊕ m ) << i)
```

where:

* **mod n** is the modulo operator by **n**.
* **⊕** is the XOR operator.
* **X << n** is the left circular shift by **n** bits.
* **S( )** is the **S-BOX** transformation of AES algorithm, that works over a byte.

## Additional design specifications ##

* The stream cipher shall have an asynchronous active-low reset port;
* The input message byte *𝑀* can be any 8-bit ASCII character;
* The  stream  cipher  shall  feature  an  input  port  which  has  to  be  asserted  when  providing  the input message byte **𝑀** (M_valid port): **1’b1**, when input character is valid and stable, **1’b0**, otherwise.

The following waveform is expected at input interface of hash module:
![Input](https://github.com/fedehsq/light_hash_algorithm_aes_sbox/blob/master/screen/input.png)

* The stream cipher shall feature an output port which is asserted when the generated output *digest* (or hash value) is available at the corresponding output port (hash_ready port): **1’b1**, when output digestis valid and stable, **1’b0**, otherwise. \
This flag shall be kept to logic 1 until a new message digest computation  is  performed.

The  following  waveform  is  expected  at  the  output  interface  of hash module:
![Output](https://github.com/fedehsq/light_hash_algorithm_aes_sbox/blob/master/screen/output.png)

* For the  AES  S-box  function  implement  the  LUT  version. \
Below it is reported the S-box of AES algorithm, in hexadecimal format: it works on a byte, using the 4 MSb and the 4 LSb of input byte, respectively, as row and column coordinates to substitute it.

```verilog
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
```

* Design logic resources to perform the assignment of all the variables 𝐻[𝑖]in the same clock cycle.
* Logic resources (and maybe dedicated ports) are required tosignal the beginning and the end of a message (by bytes): this is required to initialize the variables 𝐻[𝑖] and to trigger the last operation of the hash algorithm (thus to allow the module to signal when the digest is available at the output).
* Develop testbench with messages of different length and check  that  the same message  generates the same hash value.

## Implementation ##

[Link to more details!](https://github.com/fedehsq/light_hash_algorithm_aes_sbox/blob/master/light_hash)
