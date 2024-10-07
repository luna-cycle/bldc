# VESC UART Communication

Communication with the VESC can be achieved over several interfaces. UART, USB and Bluetooth interfaces share the same base protocol. This document provides an overview of the UART protocol used by VESC motor controllers, focusing on packet structure, command IDs, data formats, along with a couple of examples.


## 1. Packet Structure
Communication over UART with the VESC uses a specific packet structure to ensure data integrity and synchronization between the sender and receiver. Each packet consists of several components:

 1. Start byte(s)
 2. Length
 3. Payload (command and data)
 4. CRC checksum
 5. Stop byte

### 1.1 Start Bytes
The start byte indicates the beginning of a new packet. There are three possible start bytes, depending on the length of the payload:

 * **0x02:** Indicates that the payload length is represented by one byte (up to 255 bytes).
 * **0x03:** Indicates that the payload length is represented by two bytes (up to 65535 bytes).
 * **0x04:** Indicates that the payload length is represented by three bytes (up to 16,777,215 bytes).

### 1.2 Length Encoding
The length of the payload is encoded immediately after the start byte(s):

 * **Single-byte length:** If the start byte is 0x02, the next byte represents the payload length (1 byte).
 * **Two-byte length:** If the start byte is 0x03, the next two bytes represent the payload length (big-endian).
 * **Three-byte length:** If the start byte is 0x04, the next three bytes represent the payload length (big-endian).

Example:

* Start byte 0x02, Length byte 0x10: Payload length is 16 bytes.
* Start byte 0x03, Length bytes 0x01 0x00: Payload length is 256 bytes.

### 1.3 Payload
The payload contains the command ID and any associated data. The first byte of the payload is always the command ID, followed by any parameters or data required for that command.

### 1.4 CRC Checksum
A 16-bit CRC checksum is used to verify the integrity of the packet. The CRC is calculated over the payload data and is appended after the payload.

* The CRC is calculated using the CRC-16-CCITT standard.
* The two CRC bytes are sent in big-endian order (most significant byte first).

### 1.5 Stop Byte
The packet ends with a stop byte:

 * **0x03:** Indicates the end of the packet.

### Summary of the Packet Structure:

| [Start Byte(s)] | [Length] | [Payload (Command ID + Data)] | [CRC High Byte] | [CRC Low Byte] | [Stop Byte] |
|-|-|-|-|-|-|

| Start Byte  | Length  |   Payload   |      CRC       | Stop Byte |
|-------------|---------|-------------|----------------|-----------|
|    0x02     | 1 Byte  | N Bytes     | 2 Bytes (MSB & LSB) |    0x03   |
|    0x03     | 2 Bytes |             |                |           |
|    0x04     | 3 Bytes |             |                |           |

## 2. Command IDs
Command IDs are used to specify the action or request being sent to or from the VESC. The following are some common command IDs:

* **0x00**: COMM_FW_VERSION
* **0x01**: COMM_JUMP_TO_BOOTLOADER
* **0x02**: COMM_ERASE_NEW_APP
* **0x03**: COMM_WRITE_NEW_APP_DATA
* **0x04**: COMM_GET_VALUES
* **0x05**: COMM_SET_DUTY
* **0x06**: COMM_SET_CURRENT
* **0x07**: COMM_SET_CURRENT_BRAKE
* **0x08**: COMM_SET_RPM
* **0x09**: COMM_SET_POS
* **0x0A**: COMM_SET_HANDBRAKE
* ...: (See commands.c for additional available commands)

## 3. Data Encoding
Data within the payload is encoded to ensure efficient transmission and accurate reconstruction on the receiving end.

### 3.1 Integer and Floating-Point Encoding
**Integers:** Typically transmitted in big-endian format. The number of bytes depends on the size of the integer (e.g., 2 bytes for 16-bit integers, 4 bytes for 32-bit integers).

**Floating-Point Numbers:** Sometimes scaled and converted to integers to reduce packet size, but also sometimes sent as raw 4 bites, see [this](http://stackoverflow.com/questions/40416682/portable-way-to-serialize-float-as-32-bit-integer)

## 4. Examples

A couple of examples are present below. Note that full code is available for [VESC Tool UI (C++)](https://github.com/vedderb/vesc_tool/blob/master/commands.cpp) and for [VESC firmware (C)](https://github.com/vedderb/bldc/blob/master/comm/commands.c) protocol parsers.

### 4.1 Throttle command

To send a throttle command as phase current setpoint, this is the packet structure needed:

| [Start Byte(s)] | [Length] | Payload (Command ID)    | Payload                     | [CRC High Byte] | [CRC Low Byte] | [Stop Byte] |
|-----------------|----------|-------------------------|-----------------------------|-----------------|----------------|-------------|
| 0x02            |        5 | 0x06 (COMM_SET_CURRENT) | Current setpoint in mAmps   | CRC_HI          | CRC_LO         | 0x03        |

#### 4.1.1 Choose the desired Motor Current Value:

Let's say we want to drive 10 Amps through the motor.

#### 4.1.2 Construct the packet:

Since the payload length is 5 bytes, we can use a single-byte length encoding.

* **Start Byte:** 0x02.

* **Command ID:** 0x06 (COMM_SET_CURRENT).

* **Data:** 10000 (Scaled current value as a 32-bit big-endian integer.)

* **Payload Length:** 1 (Command ID) + 4 (Current Value) = 5 bytes.

* **Length:** 0x05.

* **CRC:** Compute the CRC-16-CCITT over the payload data. Check util/crc.c for sample code.

* **End Byte:** 0x03.

### 4.2 Firmware update
Updating the VESC firmware over UART involves a specific sequence of commands. The firmware update requires erasing the application area, writing the new firmware data and launching the bootloader. The memory area used to temporarily store the new vesc firmware is located on the second half STM32 flash memory map.

**STM32 Flash Memory Map**
| Current VESC firmware (~500kB) | Memory reserved for incoming VESC firmware (~500kB) | Bootloader code |
|-|-|-|


#### 4.2.1 Erase Application Area

Erase the area of flash memory where the new firmware will be written. The start address is 4 bytes (32-bit unsigned integer).

Example:

| [Start Byte(s)] | [Length] | Payload (Command ID)      | Payload                   | [CRC High Byte] | [CRC Low Byte] | [Stop Byte] |
|-----------------|----------|---------------------------|---------------------------|-----------------|----------------|-------------|
| 0x02            |        5 | 0x02 (COMM_ERASE_NEW_APP) | Start Address (4 bytes)   | CRC_HI          | CRC_LO         | 0x03        |


Response: The VESC will respond with COMM_ERASE_NEW_APP (0x02) and a status byte indicating success (1) or failure (0).

#### 4.2.2 Write New Firmware Data

The new firmware is sent in chunks using the COMM_WRITE_NEW_APP_DATA (0x03) command.

* Send: COMM_WRITE_NEW_APP_DATA (0x03) followed by the offset and data chunk.

| [Start Byte(s)] | [Length]       | Payload (Command ID)           | Payload (Offset)          | Payload (Firmware Chunk) | [CRC High Byte] | [CRC Low Byte] | [Stop Byte] |
|-----------------|----------------|--------------------------------|---------------------------|--------------------------|-----------------|----------------|-------------|
| 0x02            | 5 + chunk_size | 0x03 (COMM_WRITE_NEW_APP_DATA) | Offset (4 bytes)          | Firmware Data Chunk      | CRC_HI          | CRC_LO         | 0x03        |

* Process:

The firmware file is split into manageable chunks.
Each chunk is sent sequentially, starting from offset 0.
The offset indicates where in the flash memory the data should be written.
Response: After each chunk, the VESC responds with COMM_WRITE_NEW_APP_DATA (0x03) and a status byte indicating success (1) or failure (0), along with the offset.

#### 4.2.3 Jump to Bootloader

After all chunks have been sent, the bootloader will check that the image CRC is correct, and if it is, will move the new application to the start of the address map, overwriting the old application.
If the CRC is correct, it will proceed to erase the temporary application image and reboot the system. The new app will be executed.


| [Start Byte(s)] | [Length] | Payload (Command ID)           | [CRC High Byte] | [CRC Low Byte] | [Stop Byte] |
|-----------------|----------|--------------------------------|-----------------|----------------|-------------|
| 0x02            |        1 | 0x01 (COMM_JUMP_TO_BOOTLOADER) | CRC_HI          | CRC_LO         | 0x03        |

