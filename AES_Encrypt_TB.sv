`timescale 1ns / 1ps


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

