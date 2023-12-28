`timescale 1ns / 1ps

module AES_Encrypt_Decrypt_TB();
	
	logic [127:0] plaintext, ciphertext, encryptedText, decryptedText;
	logic [255:0] key;
	
	AES_Encrypt encryptor(plaintext, key, encryptedText);
	AES_Decrypt decryptor(ciphertext, key, decryptedText);
	
	initial begin
		plaintext = 128'h00112233445566778899aabbccddeeff;
		ciphertext = 128'h8ea2b7ca516745bfeafc49904b496089;
        key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        #10;
        $display("Expected Ciphertext: %h", ciphertext);
        $display("Actual Ciphertext  : %h", encryptedText);
        $display("Expected Plaintext: %h", plaintext);
        $display("Actual Plaintext  : %h", decryptedText);
       	if (ciphertext == encryptedText && plaintext == decryptedText) begin
       		$display("Both encryption and decryption were successful");
       	end else if (ciphertext == encryptedText) begin
       		$display("Encryption was successful, but decryption was not");
       	end else if (plaintext == decryptedText) begin
       		$display("Decryption was successful, but encryption was not");
       	end else begin
       		$display("Neither encryption nor decryption were successful");
       	end
       	$finish;
	end
endmodule

module AES_Encrypt_TB();

    logic [127:0] plaintext;
    logic [255:0] key;
    logic [127:0] ciphertext;
    
    // Instantiate AES_Encrypt module
    AES_Encrypt dut(
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext)
    );
    
    // Initial values for plaintext and key
    initial begin
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        #10; // Add delay before checking the result
        $display("Expected Ciphertext: 8ea2b7ca516745bfeafc49904b496089");
        $display("Actual Ciphertext  : %h", ciphertext);
        if (ciphertext == 128'h8ea2b7ca516745bfeafc49904b496089) begin
            $display("Successful: Ciphertext matches the expected value!");
        end else begin
            $display("Unsuccessful: Ciphertext does not match the expected value.");
        end
        $finish; // Finish simulation
    end
endmodule

module AES_Decrypt_TB();

    logic [127:0] ciphertext;
    logic [255:0] key;
    logic [127:0] plaintext;
    
    AES_Decrypt dut(
        .ciphertext(ciphertext),
        .key(key),
        .plaintext(plaintext)
    );

	initial begin
		ciphertext = 128'h8ea2b7ca516745bfeafc49904b496089;
		key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
		#10;
		$display("Expected Plaintext: 00112233445566778899aabbccddeeff");
		$display("Actual Plaintext  : %h", plaintext);
		if (plaintext == 128'h00112233445566778899aabbccddeeff) begin
			$display("Successful: Plaintext matches the expected value!");
		end else begin
			$display("Unsuccessful: Plaintext does not match the expected value.");
		end
		$finish;
	end
endmodule

