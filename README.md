# FPGA_HSM
Author: Neil Chulani

Contact: neil22@me.com
## FPGA Implementation of a Hardware Security Module

The goal of this project is to write implement an HSM from scratch on an FPGA. The HSM will (hopefully) be able to perform on device encryption/decryption, as well as firmware signing and image verification. A simple RTOS will be run on an MCU, which will connect to the HSM and use it for all cryptographic operations.

## Features

- FPGA HSM stores all cryptographic keys
- FPGA HSM can perform AES-256 Encryption and Decryption
- FPGA HSM can perform image signing and verification using SHA-256
- MCU runs a RTOS that interacts with the FPGA HSM to perform secure boot and other cryptographic processes

> This implementation is being devleoped using a Kintex 7 KC705 Development board, and is still very much a work in progress.
