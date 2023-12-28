`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Personal
// Engineer: Neil Chulani
// 
// Create Date: 12/17/2023 06:09:48 PM
// Project Name: FPGA_HSM
// Target Devices: Kintex 7 KC705 Development Board
// Description: Modules for AES-256 encryption and decryption
// 
// Revision: 1.0
//////////////////////////////////////////////////////////////////////////////////


module AES_Encrypt(
        input logic [127:0] plaintext,
        input logic [255:0] key,
        output logic [127:0] ciphertext
    );
    
    logic [(128*15) - 1:0] fullkeys;
    logic [127:0] states [14:0];
    logic [127:0] afterSubBytes;
    logic [127:0] afterShiftRows;
    
    keyExpansion ke_inst(key, fullkeys);
    addRoundKey ark_inst(plaintext, fullkeys[((128*15)-1)-:128], states[0] );
    
    genvar i;
    generate
        for (i = 1; i < 14; i = i + 1) begin : loop
            encryptRound er_inst(states[i - 1], fullkeys[(((128*15)-1)-128*i)-:128], states[i]);
        end
    endgenerate
    
    subBytes sb_inst(states[13], afterSubBytes);
    shiftRows sr_inst(afterSubBytes, afterShiftRows);
    addRoundKey ark_inst2(afterShiftRows, fullkeys[127:0], states[14]);
    assign ciphertext = states[14]; 
endmodule

module AES_Decrypt (
	input logic [127:0] ciphertext,
	input logic [255:0] key,
	output logic [127:0] plaintext
);

	logic [(128*15)-1 :0] fullkeys;
    logic [127:0] states [14:0];
    logic [127:0] afterSubBytes;
    logic [127:0] afterShiftRows;
    
    keyExpansion ke_inst(key, fullkeys);
    addRoundKey ark_inst(ciphertext, fullkeys[127:0], states[0]);
    
    genvar i;
    generate
    	for (i = 1; i < 14; i = i + 1) begin : loop
    		decryptRound dr(states[i-1], fullkeys[i*128+:128], states[i]);
    	end
    endgenerate
	inverseShiftRows sr(states[13], afterShiftRows);
	inverseSubBytes sb(afterShiftRows, afterSubBytes);
	addRoundKey ark_inst2(afterSubBytes, fullkeys[((128*15)-1)-:128], states[14]);
	assign plaintext = states[14];  
endmodule


module keyExpansion (
    input logic [0:255] key,
    output logic [0:(128*15) - 1] fullkeys
);
    logic [0:31] temp, r, rot, x, rconv, new_key;
    
    integer i;
    always_comb begin
        fullkeys = key;
        for (i = 8; i < 4*(15); i = i + 1) begin
            temp = fullkeys[(128 * (15) - 32) +:32];
            if (i % 8 == 0) begin
                rot = rotword(temp);
                x = subwordx(rot);
                rconv = rconx (i/8);
                temp = x ^ rconv;
            end
            else if (i % 8 == 4) begin
                temp = subwordx(temp);
            end
            new_key = (fullkeys[(128*15)-(8*32)+:32] ^ temp);
            fullkeys = fullkeys << 32;
            fullkeys = {fullkeys[0:(128*15 - 32) -  1], new_key};
        end
    end
    
    function [0:31] rotword;
        input [0:31] x;
        begin
            rotword = {x[8:31], x[0:7]};
        end
    endfunction
    
    function [0:31] subwordx;
        input [0:31] a; 
        begin
            subwordx[0:7]=c(a[0:7]);
            subwordx[8:15]=c(a[8:15]);
            subwordx[16:23]=c(a[16:23]);
            subwordx[24:31]=c(a[24:31]);
        end
    endfunction
    
    function [7:0] c (input [7:0] a );
        begin
            case (a)
                8'h00: c=8'h63;
                8'h01: c=8'h7c;
                8'h02: c=8'h77;
                8'h03: c=8'h7b;
                8'h04: c=8'hf2;
                8'h05: c=8'h6b;
                8'h06: c=8'h6f;
                8'h07: c=8'hc5;
                8'h08: c=8'h30;
                8'h09: c=8'h01;
                8'h0a: c=8'h67;
                8'h0b: c=8'h2b;
                8'h0c: c=8'hfe;
                8'h0d: c=8'hd7;
                8'h0e: c=8'hab;
                8'h0f: c=8'h76;
                8'h10: c=8'hca;
                8'h11: c=8'h82;
                8'h12: c=8'hc9;
                8'h13: c=8'h7d;
                8'h14: c=8'hfa;
                8'h15: c=8'h59;
                8'h16: c=8'h47;
                8'h17: c=8'hf0;
                8'h18: c=8'had;
                8'h19: c=8'hd4;
                8'h1a: c=8'ha2;
                8'h1b: c=8'haf;
                8'h1c: c=8'h9c;
                8'h1d: c=8'ha4;
                8'h1e: c=8'h72;
                8'h1f: c=8'hc0;
                8'h20: c=8'hb7;
                8'h21: c=8'hfd;
                8'h22: c=8'h93;
                8'h23: c=8'h26;
                8'h24: c=8'h36;
                8'h25: c=8'h3f;
                8'h26: c=8'hf7;
                8'h27: c=8'hcc;
                8'h28: c=8'h34;
                8'h29: c=8'ha5;
                8'h2a: c=8'he5;
                8'h2b: c=8'hf1;
                8'h2c: c=8'h71;
                8'h2d: c=8'hd8;
                8'h2e: c=8'h31;
                8'h2f: c=8'h15;
                8'h30: c=8'h04;
                8'h31: c=8'hc7;
                8'h32: c=8'h23;
                8'h33: c=8'hc3;
                8'h34: c=8'h18;
                8'h35: c=8'h96;
                8'h36: c=8'h05;
                8'h37: c=8'h9a;
                8'h38: c=8'h07;
                8'h39: c=8'h12;
                8'h3a: c=8'h80;
                8'h3b: c=8'he2;
                8'h3c: c=8'heb;
                8'h3d: c=8'h27;
                8'h3e: c=8'hb2;
                8'h3f: c=8'h75;
                8'h40: c=8'h09;
                8'h41: c=8'h83;
                8'h42: c=8'h2c;
                8'h43: c=8'h1a;
                8'h44: c=8'h1b;
                8'h45: c=8'h6e;
                8'h46: c=8'h5a;
                8'h47: c=8'ha0;
                8'h48: c=8'h52;
                8'h49: c=8'h3b;
                8'h4a: c=8'hd6;
                8'h4b: c=8'hb3;
                8'h4c: c=8'h29;
                8'h4d: c=8'he3;
                8'h4e: c=8'h2f;
                8'h4f: c=8'h84;
                8'h50: c=8'h53;
                8'h51: c=8'hd1;
                8'h52: c=8'h00;
                8'h53: c=8'hed;
                8'h54: c=8'h20;
                8'h55: c=8'hfc;
                8'h56: c=8'hb1;
                8'h57: c=8'h5b;
                8'h58: c=8'h6a;
                8'h59: c=8'hcb;
                8'h5a: c=8'hbe;
                8'h5b: c=8'h39;
                8'h5c: c=8'h4a;
                8'h5d: c=8'h4c;
                8'h5e: c=8'h58;
                8'h5f: c=8'hcf;
                8'h60: c=8'hd0;
                8'h61: c=8'hef;
                8'h62: c=8'haa;
                8'h63: c=8'hfb;
                8'h64: c=8'h43;
                8'h65: c=8'h4d;
                8'h66: c=8'h33;
                8'h67: c=8'h85;
                8'h68: c=8'h45;
                8'h69: c=8'hf9;
                8'h6a: c=8'h02;
                8'h6b: c=8'h7f;
                8'h6c: c=8'h50;
                8'h6d: c=8'h3c;
                8'h6e: c=8'h9f;
                8'h6f: c=8'ha8;
                8'h70: c=8'h51;
                8'h71: c=8'ha3;
                8'h72: c=8'h40;
                8'h73: c=8'h8f;
                8'h74: c=8'h92;
                8'h75: c=8'h9d;
                8'h76: c=8'h38;
                8'h77: c=8'hf5;
                8'h78: c=8'hbc;
                8'h79: c=8'hb6;
                8'h7a: c=8'hda;
                8'h7b: c=8'h21;
                8'h7c: c=8'h10;
                8'h7d: c=8'hff;
                8'h7e: c=8'hf3;
                8'h7f: c=8'hd2;
                8'h80: c=8'hcd;
                8'h81: c=8'h0c;
                8'h82: c=8'h13;
                8'h83: c=8'hec;
                8'h84: c=8'h5f;
                8'h85: c=8'h97;
                8'h86: c=8'h44;
                8'h87: c=8'h17;
                8'h88: c=8'hc4;
                8'h89: c=8'ha7;
                8'h8a: c=8'h7e;
                8'h8b: c=8'h3d;
                8'h8c: c=8'h64;
                8'h8d: c=8'h5d;
                8'h8e: c=8'h19;
                8'h8f: c=8'h73;
                8'h90: c=8'h60;
                8'h91: c=8'h81;
                8'h92: c=8'h4f;
                8'h93: c=8'hdc;
                8'h94: c=8'h22;
                8'h95: c=8'h2a;
                8'h96: c=8'h90;
                8'h97: c=8'h88;
                8'h98: c=8'h46;
                8'h99: c=8'hee;
                8'h9a: c=8'hb8;
                8'h9b: c=8'h14;
                8'h9c: c=8'hde;
                8'h9d: c=8'h5e;
                8'h9e: c=8'h0b;
                8'h9f: c=8'hdb;
                8'ha0: c=8'he0;
                8'ha1: c=8'h32;
                8'ha2: c=8'h3a;
                8'ha3: c=8'h0a;
                8'ha4: c=8'h49;
                8'ha5: c=8'h06;
                8'ha6: c=8'h24;
                8'ha7: c=8'h5c;
                8'ha8: c=8'hc2;
                8'ha9: c=8'hd3;
                8'haa: c=8'hac;
                8'hab: c=8'h62;
                8'hac: c=8'h91;
                8'had: c=8'h95;
                8'hae: c=8'he4;
                8'haf: c=8'h79;
                8'hb0: c=8'he7;
                8'hb1: c=8'hc8;
                8'hb2: c=8'h37;
                8'hb3: c=8'h6d;
                8'hb4: c=8'h8d;
                8'hb5: c=8'hd5;
                8'hb6: c=8'h4e;
                8'hb7: c=8'ha9;
                8'hb8: c=8'h6c;
                8'hb9: c=8'h56;
                8'hba: c=8'hf4;
                8'hbb: c=8'hea;
                8'hbc: c=8'h65;
                8'hbd: c=8'h7a;
                8'hbe: c=8'hae;
                8'hbf: c=8'h08;
                8'hc0: c=8'hba;
                8'hc1: c=8'h78;
                8'hc2: c=8'h25;
                8'hc3: c=8'h2e;
                8'hc4: c=8'h1c;
                8'hc5: c=8'ha6;
                8'hc6: c=8'hb4;
                8'hc7: c=8'hc6;
                8'hc8: c=8'he8;
                8'hc9: c=8'hdd;
                8'hca: c=8'h74;
                8'hcb: c=8'h1f;
                8'hcc: c=8'h4b;
                8'hcd: c=8'hbd;
                8'hce: c=8'h8b;
                8'hcf: c=8'h8a;
                8'hd0: c=8'h70;
                8'hd1: c=8'h3e;
                8'hd2: c=8'hb5;
                8'hd3: c=8'h66;
                8'hd4: c=8'h48;
                8'hd5: c=8'h03;
                8'hd6: c=8'hf6;
                8'hd7: c=8'h0e;
                8'hd8: c=8'h61;
                8'hd9: c=8'h35;
                8'hda: c=8'h57;
                8'hdb: c=8'hb9;
                8'hdc: c=8'h86;
                8'hdd: c=8'hc1;
                8'hde: c=8'h1d;
                8'hdf: c=8'h9e;
                8'he0: c=8'he1;
                8'he1: c=8'hf8;
                8'he2: c=8'h98;
                8'he3: c=8'h11;
                8'he4: c=8'h69;
                8'he5: c=8'hd9;
                8'he6: c=8'h8e;
                8'he7: c=8'h94;
                8'he8: c=8'h9b;
                8'he9: c=8'h1e;
                8'hea: c=8'h87;
                8'heb: c=8'he9;
                8'hec: c=8'hce;
                8'hed: c=8'h55;
                8'hee: c=8'h28;
                8'hef: c=8'hdf;
                8'hf0: c=8'h8c;
                8'hf1: c=8'ha1;
                8'hf2: c=8'h89;
                8'hf3: c=8'h0d;
                8'hf4: c=8'hbf;
                8'hf5: c=8'he6;
                8'hf6: c=8'h42;
                8'hf7: c=8'h68;
                8'hf8: c=8'h41;
                8'hf9: c=8'h99;
                8'hfa: c=8'h2d;
                8'hfb: c=8'h0f;
                8'hfc: c=8'hb0;
                8'hfd: c=8'h54;
                8'hfe: c=8'hbb;
                8'hff: c=8'h16;
            endcase
        end
    endfunction
    
    function [0:31] rconx;
        input [0:31] r;
        begin
            case (r)
                4'h1: rconx=32'h01000000;
                4'h2: rconx=32'h02000000;
                4'h3: rconx=32'h04000000;
                4'h4: rconx=32'h08000000;
                4'h5: rconx=32'h10000000;
                4'h6: rconx=32'h20000000;
                4'h7: rconx=32'h40000000;
                4'h8: rconx=32'h80000000;
                4'h9: rconx=32'h1b000000;
                4'ha: rconx=32'h36000000;
                default: rconx=32'h00000000;
            endcase
        end
    endfunction
endmodule

module addRoundKey (
    input logic [127:0] in,
    input logic [127:0] key,
    output logic [127:0] out
);
    assign out = key ^ in;
endmodule

module encryptRound (
	input logic [127:0] in,
	input logic [127:0] key,
	output logic [127:0] out
);
	logic [127:0] afterSubBytes, afterShiftRows, afterMixColumns, afterAddRoundKey;
	
	subBytes sB(in, afterSubBytes);
	shiftRows sR(afterSubBytes, afterShiftRows);
	mixColumns mC(afterShiftRows, afterMixColumns);
	addRoundKey aRK(afterMixColumns, key, out);
endmodule

module decryptRound (
	input logic [127:0] in,
	input logic [127:0] key,
	output logic [127:0] out
);
	logic [127:0] afterSubBytes, afterShiftRows, afterMixColumns, afterAddRoundKey;
	
	inverseShiftRows iSR(in, afterShiftRows);
	inverseSubBytes iSB(afterShiftRows, afterSubBytes);
	addRoundKey aRK(afterSubBytes, key, afterAddRoundKey);
	inverseMixColumns iMC(afterAddRoundKey, out);
endmodule

module subBytes (
	input logic [127:0] in,
	output logic [127:0] out
);
	genvar i;
	generate
		for (i = 0; i < 128; i = i + 8) begin : sub_Bytes
			sbox sB(in[i +:8], out[i +:8]);
		end
	endgenerate
endmodule
	
module inverseSubBytes (
	input logic [127:0] in,
	output logic [127:0] out
);
	genvar i;
	generate
		for (i = 0; i < 128; i = i + 8) begin : sub_Bytes
			inverseSbox s(in[i +:8], out[i +:8]);
		end
	endgenerate
endmodule

module sbox (
	input logic [7:0] a,
	output logic [7:0] c
);
	always_comb begin
		case (a)
			8'h00: c=8'h63;
			8'h01: c=8'h7c;
			8'h02: c=8'h77;
			8'h03: c=8'h7b;
			8'h04: c=8'hf2;
			8'h05: c=8'h6b;
			8'h06: c=8'h6f;
			8'h07: c=8'hc5;
			8'h08: c=8'h30;
			8'h09: c=8'h01;
			8'h0a: c=8'h67;
			8'h0b: c=8'h2b;
			8'h0c: c=8'hfe;
			8'h0d: c=8'hd7;
			8'h0e: c=8'hab;
			8'h0f: c=8'h76;
			8'h10: c=8'hca;
			8'h11: c=8'h82;
			8'h12: c=8'hc9;
			8'h13: c=8'h7d;
			8'h14: c=8'hfa;
			8'h15: c=8'h59;
			8'h16: c=8'h47;
			8'h17: c=8'hf0;
			8'h18: c=8'had;
			8'h19: c=8'hd4;
			8'h1a: c=8'ha2;
			8'h1b: c=8'haf;
			8'h1c: c=8'h9c;
			8'h1d: c=8'ha4;
			8'h1e: c=8'h72;
			8'h1f: c=8'hc0;
			8'h20: c=8'hb7;
			8'h21: c=8'hfd;
			8'h22: c=8'h93;
			8'h23: c=8'h26;
			8'h24: c=8'h36;
			8'h25: c=8'h3f;
			8'h26: c=8'hf7;
			8'h27: c=8'hcc;
			8'h28: c=8'h34;
			8'h29: c=8'ha5;
			8'h2a: c=8'he5;
			8'h2b: c=8'hf1;
			8'h2c: c=8'h71;
			8'h2d: c=8'hd8;
			8'h2e: c=8'h31;
			8'h2f: c=8'h15;
			8'h30: c=8'h04;
			8'h31: c=8'hc7;
			8'h32: c=8'h23;
			8'h33: c=8'hc3;
			8'h34: c=8'h18;
			8'h35: c=8'h96;
			8'h36: c=8'h05;
			8'h37: c=8'h9a;
			8'h38: c=8'h07;
			8'h39: c=8'h12;
			8'h3a: c=8'h80;
			8'h3b: c=8'he2;
			8'h3c: c=8'heb;
			8'h3d: c=8'h27;
			8'h3e: c=8'hb2;
			8'h3f: c=8'h75;
			8'h40: c=8'h09;
			8'h41: c=8'h83;
			8'h42: c=8'h2c;
			8'h43: c=8'h1a;
			8'h44: c=8'h1b;
			8'h45: c=8'h6e;
			8'h46: c=8'h5a;
			8'h47: c=8'ha0;
			8'h48: c=8'h52;
			8'h49: c=8'h3b;
			8'h4a: c=8'hd6;
			8'h4b: c=8'hb3;
			8'h4c: c=8'h29;
			8'h4d: c=8'he3;
			8'h4e: c=8'h2f;
			8'h4f: c=8'h84;
			8'h50: c=8'h53;
			8'h51: c=8'hd1;
			8'h52: c=8'h00;
			8'h53: c=8'hed;
			8'h54: c=8'h20;
			8'h55: c=8'hfc;
			8'h56: c=8'hb1;
			8'h57: c=8'h5b;
			8'h58: c=8'h6a;
			8'h59: c=8'hcb;
			8'h5a: c=8'hbe;
			8'h5b: c=8'h39;
			8'h5c: c=8'h4a;
			8'h5d: c=8'h4c;
			8'h5e: c=8'h58;
			8'h5f: c=8'hcf;
			8'h60: c=8'hd0;
			8'h61: c=8'hef;
			8'h62: c=8'haa;
			8'h63: c=8'hfb;
			8'h64: c=8'h43;
			8'h65: c=8'h4d;
			8'h66: c=8'h33;
			8'h67: c=8'h85;
			8'h68: c=8'h45;
			8'h69: c=8'hf9;
			8'h6a: c=8'h02;
			8'h6b: c=8'h7f;
			8'h6c: c=8'h50;
			8'h6d: c=8'h3c;
			8'h6e: c=8'h9f;
			8'h6f: c=8'ha8;
			8'h70: c=8'h51;
			8'h71: c=8'ha3;
			8'h72: c=8'h40;
			8'h73: c=8'h8f;
			8'h74: c=8'h92;
			8'h75: c=8'h9d;
			8'h76: c=8'h38;
			8'h77: c=8'hf5;
			8'h78: c=8'hbc;
			8'h79: c=8'hb6;
			8'h7a: c=8'hda;
			8'h7b: c=8'h21;
			8'h7c: c=8'h10;
			8'h7d: c=8'hff;
			8'h7e: c=8'hf3;
			8'h7f: c=8'hd2;
			8'h80: c=8'hcd;
			8'h81: c=8'h0c;
			8'h82: c=8'h13;
			8'h83: c=8'hec;
			8'h84: c=8'h5f;
			8'h85: c=8'h97;
			8'h86: c=8'h44;
			8'h87: c=8'h17;
			8'h88: c=8'hc4;
			8'h89: c=8'ha7;
			8'h8a: c=8'h7e;
			8'h8b: c=8'h3d;
			8'h8c: c=8'h64;
			8'h8d: c=8'h5d;
			8'h8e: c=8'h19;
			8'h8f: c=8'h73;
			8'h90: c=8'h60;
			8'h91: c=8'h81;
			8'h92: c=8'h4f;
			8'h93: c=8'hdc;
			8'h94: c=8'h22;
			8'h95: c=8'h2a;
			8'h96: c=8'h90;
			8'h97: c=8'h88;
			8'h98: c=8'h46;
			8'h99: c=8'hee;
			8'h9a: c=8'hb8;
			8'h9b: c=8'h14;
			8'h9c: c=8'hde;
			8'h9d: c=8'h5e;
			8'h9e: c=8'h0b;
			8'h9f: c=8'hdb;
			8'ha0: c=8'he0;
			8'ha1: c=8'h32;
			8'ha2: c=8'h3a;
			8'ha3: c=8'h0a;
			8'ha4: c=8'h49;
			8'ha5: c=8'h06;
			8'ha6: c=8'h24;
			8'ha7: c=8'h5c;
			8'ha8: c=8'hc2;
			8'ha9: c=8'hd3;
			8'haa: c=8'hac;
			8'hab: c=8'h62;
			8'hac: c=8'h91;
			8'had: c=8'h95;
			8'hae: c=8'he4;
			8'haf: c=8'h79;
			8'hb0: c=8'he7;
			8'hb1: c=8'hc8;
			8'hb2: c=8'h37;
			8'hb3: c=8'h6d;
			8'hb4: c=8'h8d;
			8'hb5: c=8'hd5;
			8'hb6: c=8'h4e;
			8'hb7: c=8'ha9;
			8'hb8: c=8'h6c;
			8'hb9: c=8'h56;
			8'hba: c=8'hf4;
			8'hbb: c=8'hea;
			8'hbc: c=8'h65;
			8'hbd: c=8'h7a;
			8'hbe: c=8'hae;
			8'hbf: c=8'h08;
			8'hc0: c=8'hba;
			8'hc1: c=8'h78;
			8'hc2: c=8'h25;
			8'hc3: c=8'h2e;
			8'hc4: c=8'h1c;
			8'hc5: c=8'ha6;
			8'hc6: c=8'hb4;
			8'hc7: c=8'hc6;
			8'hc8: c=8'he8;
			8'hc9: c=8'hdd;
			8'hca: c=8'h74;
			8'hcb: c=8'h1f;
			8'hcc: c=8'h4b;
			8'hcd: c=8'hbd;
			8'hce: c=8'h8b;
			8'hcf: c=8'h8a;
			8'hd0: c=8'h70;
			8'hd1: c=8'h3e;
			8'hd2: c=8'hb5;
			8'hd3: c=8'h66;
			8'hd4: c=8'h48;
			8'hd5: c=8'h03;
			8'hd6: c=8'hf6;
			8'hd7: c=8'h0e;
			8'hd8: c=8'h61;
			8'hd9: c=8'h35;
			8'hda: c=8'h57;
			8'hdb: c=8'hb9;
			8'hdc: c=8'h86;
			8'hdd: c=8'hc1;
			8'hde: c=8'h1d;
			8'hdf: c=8'h9e;
			8'he0: c=8'he1;
			8'he1: c=8'hf8;
			8'he2: c=8'h98;
			8'he3: c=8'h11;
			8'he4: c=8'h69;
			8'he5: c=8'hd9;
			8'he6: c=8'h8e;
			8'he7: c=8'h94;
			8'he8: c=8'h9b;
			8'he9: c=8'h1e;
			8'hea: c=8'h87;
			8'heb: c=8'he9;
			8'hec: c=8'hce;
			8'hed: c=8'h55;
			8'hee: c=8'h28;
			8'hef: c=8'hdf;
			8'hf0: c=8'h8c;
			8'hf1: c=8'ha1;
			8'hf2: c=8'h89;
			8'hf3: c=8'h0d;
			8'hf4: c=8'hbf;
			8'hf5: c=8'he6;
			8'hf6: c=8'h42;
			8'hf7: c=8'h68;
			8'hf8: c=8'h41;
			8'hf9: c=8'h99;
			8'hfa: c=8'h2d;
			8'hfb: c=8'h0f;
			8'hfc: c=8'hb0;
			8'hfd: c=8'h54;
			8'hfe: c=8'hbb;
			8'hff: c=8'h16;
		endcase
	end
endmodule

module shiftRows (
	input logic [0:127] in,
	output logic [0:127] shifted
);	
	// First row (r = 0) is not shifted
	assign shifted[0+:8] = in[0+:8];
	assign shifted[32+:8] = in[32+:8];
	assign shifted[64+:8] = in[64+:8];
	assign shifted[96+:8] = in[96+:8];
	
	// Second row (r = 1) is cyclically left shifted by 1 offset
	assign shifted[8+:8] = in[40+:8];
	assign shifted[40+:8] = in[72+:8];
	assign shifted[72+:8] = in[104+:8];
	assign shifted[104+:8] = in[8+:8];
	
	// Third row (r = 2) is cyclically left shifted by 2 offsets
	assign shifted[16+:8] = in[80+:8];
	assign shifted[48+:8] = in[112+:8];
	assign shifted[80+:8] = in[16+:8];
	assign shifted[112+:8] = in[48+:8];
	
	// Fourth row (r = 3) is cyclically left shifted by 3 offsets
	assign shifted[24+:8] = in[120+:8];
	assign shifted[56+:8] = in[24+:8];
	assign shifted[88+:8] = in[56+:8];
	assign shifted[120+:8] = in[88+:8];
endmodule

module mixColumns(
	input logic [127:0] state_in,
	output logic [127:0] state_out
);

	function [7:0] mb2; //multiply by 2
		input [7:0] x;
		begin 
			if (x[7] == 1) mb2 = ((x << 1) ^ 8'h1b);
			else mb2 = x << 1; 
		end 	
	endfunction

	function [7:0] mb3; //multiply by 3
		input [7:0] x;
		begin 
			mb3 = mb2(x) ^ x;
		end 
	endfunction

	genvar i;
	generate 
		for(i = 0; i < 4; i = i + 1) begin : m_col
			assign state_out[(i*32 + 24)+:8]= mb2(state_in[(i*32 + 24)+:8]) ^ mb3(state_in[(i*32 + 16)+:8]) ^ state_in[(i*32 + 8)+:8] ^ state_in[i*32+:8];
			assign state_out[(i*32 + 16)+:8]= state_in[(i*32 + 24)+:8] ^ mb2(state_in[(i*32 + 16)+:8]) ^ mb3(state_in[(i*32 + 8)+:8]) ^ state_in[i*32+:8];
			assign state_out[(i*32 + 8)+:8]= state_in[(i*32 + 24)+:8] ^ state_in[(i*32 + 16)+:8] ^ mb2(state_in[(i*32 + 8)+:8]) ^ mb3(state_in[i*32+:8]);
			assign state_out[i*32+:8]= mb3(state_in[(i*32 + 24)+:8]) ^ state_in[(i*32 + 16)+:8] ^ state_in[(i*32 + 8)+:8] ^ mb2(state_in[i*32+:8]);	
		end
	endgenerate
endmodule


module inverseMixColumns(
	input logic [127:0] state_in,
	output logic [127:0] state_out
);
	function [7:0] multiply;
		input [7:0] x;
		input integer n;
		integer i;
		begin
			for (i = 0; i < n; i = i + 1) begin
				if (x[7] == 1) x = ((x << 1) ^ 8'h1b);
				else x = x << 1;
			end
			multiply = x;
		end
	endfunction
	
	function [7:0] mb0e;
		input [7:0] x;
		begin
			mb0e = multiply(x,3) ^ multiply(x,2) ^ multiply(x,1);
		end
	endfunction
	
	function [7:0] mb0d;
		input [7:0] x;
		begin
			mb0d = multiply(x,3) ^ multiply(x,2) ^ x;
		end
	endfunction
	
	function [7:0] mb0b;
		input [7:0] x;
		begin
			mb0b = multiply(x,3) ^ multiply(x,1) ^ x;
		end
	endfunction
	
	function [7:0] mb09;
		input [7:0] x;
		begin
			mb09 = multiply (x,3) ^ x;
		end
	endfunction
	
	genvar i;
	generate 
		for (i = 0; i < 4; i = i + 1) begin : m_col
			assign state_out[(i*32 + 24)+:8]= mb0e(state_in[(i*32 + 24)+:8]) ^ mb0b(state_in[(i*32 + 16)+:8]) ^ mb0d(state_in[(i*32 + 8)+:8]) ^ mb09(state_in[i*32+:8]);
			assign state_out[(i*32 + 16)+:8]= mb09(state_in[(i*32 + 24)+:8]) ^ mb0e(state_in[(i*32 + 16)+:8]) ^ mb0b(state_in[(i*32 + 8)+:8]) ^ mb0d(state_in[i*32+:8]);
			assign state_out[(i*32 + 8)+:8]= mb0d(state_in[(i*32 + 24)+:8]) ^ mb09(state_in[(i*32 + 16)+:8]) ^ mb0e(state_in[(i*32 + 8)+:8]) ^ mb0b(state_in[i*32+:8]);
   			assign state_out[i*32+:8]= mb0b(state_in[(i*32 + 24)+:8]) ^ mb0d(state_in[(i*32 + 16)+:8]) ^ mb09(state_in[(i*32 + 8)+:8]) ^ mb0e(state_in[i*32+:8]);
   		end
   	endgenerate
endmodule