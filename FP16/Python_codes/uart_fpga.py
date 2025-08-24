############################
### Host -> FPGA -> Host ###
############################

import serial
import time
import sys
import os  # Added for file existence check

# --- Serial Port Configuration ---
SERIAL_PORT = "COM6"  # Change to your serial port (e.g., 'COM7' or '/dev/ttyUSB0')
BAUD_RATE = 115200  # Must match the baud rate of your FPGA's UART module

# --- Data Transfer Settings ---
# NUM_TEST_SETS and NUM_DATA_PER_SET are determined by the COE file content.
# Initialized to 0 as they will be read from the file.
NUM_TEST_SETS = 0
NUM_DATA_PER_SET = (
    64  # Number of 16-bit FP data per test set (fixed by COE file format)
)

# --- COE File Paths ---
COE_FILE_PATH = "softmax_input.coe"  # Name of the uploaded COE file
OUTPUT_COE_FILE_PATH = (
    "softmax_output.coe"  # Name of the COE file to save received data
)

# --- Delay Settings (seconds) ---
# Short delay after sending each byte (gives FPGA time to process each byte)
DELAY_AFTER_BYTE_SEND = 0.001
# Delay after all test sets are sent, waiting for FPGA computation to complete.
# This value should be long enough for the actual FPGA computation time, depending on
# NUM_TEST_SETS and NUM_DATA_PER_SET.
DELAY_FOR_ALL_COMPUTATION = (
    0.05  # Example value, adjust according to actual FPGA computation time
)


# --- Function to read data from COE file ---
def read_coe_data(file_path):
    data = []
    print(f"Attempting to read COE file '{file_path}'...")
    if not os.path.exists(file_path):
        print(
            f"Error: COE file '{file_path}' not found. Please ensure the file is in the script's execution path."
        )
        sys.exit(1)

    try:
        with open(file_path, "r") as f:
            lines = f.readlines()
            parsing_data_vector = False  # Flag to start parsing data after 'memory_initialization_vector='
            for line_num, raw_line in enumerate(lines):
                line = raw_line.strip()

                if line.startswith("memory_initialization_vector="):
                    parsing_data_vector = True
                    # This line is a header, so skip it for data parsing
                    continue

                if parsing_data_vector:
                    if line.endswith(";"):
                        # If ends with a semicolon, it's the end of data, remove semicolon and stop parsing
                        line = line.replace(";", "")

                    # Split by comma and remove empty strings from parts
                    parts = [p.strip() for p in line.split(",") if p.strip()]

                    for part in parts:
                        if part:  # Process only if not an empty string
                            # Each entry in the COE file is 64-bit (16 hex digits), so split into 4x 16-bit values
                            if len(part) == 16:  # 64-bit data (16 hex digits)
                                # Reverse the order of 16-bit values within each 64-bit block (read from rightmost).
                                # Example: "ABCD1234EFGH5678" -> parse 5678, then EFGH, then 1234, then ABCD
                                for i in range(3, -1, -1):  # i loops 3, 2, 1, 0
                                    start_index = i * 4
                                    end_index = start_index + 4
                                    hex_16bit = part[start_index:end_index]
                                    try:
                                        data.append(int(hex_16bit, 16))
                                    except ValueError:
                                        print(
                                            f"Warning: Invalid hexadecimal value '{hex_16bit}' found in '{part}'. Skipping this value."
                                        )
                            else:
                                print(
                                    f"Warning: Unexpected length of hexadecimal string: '{part}'. Expected 16 digits. Skipping this value."
                                )

                    if raw_line.strip().endswith(
                        ";"
                    ):  # If original line ends with semicolon, assume end of data
                        break
        print(f"COE file read complete. Read {len(data)} 16-bit data points.")
    except (
        FileNotFoundError
    ):  # Already handled by os.path.exists, so unlikely to occur here
        pass
    except Exception as e:
        print(f"Error: An unexpected error occurred while reading the COE file: {e}")
        sys.exit(1)
    return data


# --- Function to save received data to COE file format ---
def save_to_coe_file(file_path, data_list, radix=16):
    """
    Saves a list of received 16-bit integers to a COE file format.
    Each 64-bit block (16 hex digits) consists of 4x 16-bit values.
    When saving, the first received 16-bit value is placed at the rightmost (LSB) of the 64-bit block.
    """
    print(f"\nSaving received data to COE file '{file_path}'...")
    try:
        with open(file_path, "w") as f:
            f.write(f"memory_initialization_radix={radix};\n")
            f.write("memory_initialization_vector=\n")

            num_16bit_per_64bit_block = 4
            for i in range(0, len(data_list), num_16bit_per_64bit_block):
                block_16bit_data = data_list[i : i + num_16bit_per_64bit_block]

                hex_block_string = ""
                # COE file typically lists hex values from MSB to LSB.
                # If Python list [val0, val1, val2, val3] represents 16-bit values
                # and val0 is the LSB of the 64-bit block, then
                # the 64-bit hex string should be "HEX_VAL3HEX_VAL2HEX_VAL1HEX_VAL0".
                # Therefore, iterate in reverse order of block_16bit_data.
                for val_16bit in reversed(block_16bit_data):
                    hex_block_string += f"{val_16bit:04X}"

                # Add comma and newline for all but the last block; semicolon and newline for the last.
                if i + num_16bit_per_64bit_block < len(data_list):
                    f.write(f"{hex_block_string},\n")
                else:
                    f.write(f"{hex_block_string};\n")
        print(f"Successfully saved received data to '{file_path}'.")
    except Exception as e:
        print(f"Error: An error occurred while saving COE file '{file_path}': {e}")
        sys.exit(1)


print(f"--- UART Communication Script (Test Set Transfer & Result Reception) ---")
print(f"Serial Port: {SERIAL_PORT}")
print(f"Baud Rate: {BAUD_RATE} bps")
print(f"COE File Path: {COE_FILE_PATH}")
print("-" * 30)

try:
    # Read all 16-bit data from the COE file
    all_coe_data = read_coe_data(COE_FILE_PATH)

    # Calculate NUM_TEST_SETS from the read data
    if len(all_coe_data) % NUM_DATA_PER_SET != 0:
        print(
            f"Warning: Total data points in COE file ({len(all_coe_data)}) is not a multiple of {NUM_DATA_PER_SET}. Potential data loss or incorrect test set calculation."
        )
    NUM_TEST_SETS = len(all_coe_data) // NUM_DATA_PER_SET

    if NUM_TEST_SETS == 0:
        print("Error: No valid test set data found in the COE file. Exiting program.")
        sys.exit(1)

    print(
        f"Read {len(all_coe_data)} 16-bit data points ({NUM_TEST_SETS} test sets) from COE file."
    )
    print(f"Total Number of Test Sets: {NUM_TEST_SETS}")
    print(f"Number of 16-bit FP Data per Test Set: {NUM_DATA_PER_SET}")
    print("-" * 30)

    # Create and configure serial port object
    ser = serial.Serial(
        port=SERIAL_PORT,
        baudrate=BAUD_RATE,
        bytesize=serial.EIGHTBITS,  # 8 data bits
        parity=serial.PARITY_NONE,  # No parity
        stopbits=serial.STOPBITS_ONE,  # 1 stop bit
        timeout=max(
            10, DELAY_FOR_ALL_COMPUTATION + 5
        ),  # Read timeout, set sufficiently long
        write_timeout=10,  # Write timeout
    )

    print(f"Success: Serial port '{SERIAL_PORT}' opened at {BAUD_RATE} bps.")
    time.sleep(0.5)  # Give the port time to fully open

    # 1. Send total number of test sets to FPGA
    print(f"\n--- [Step 1/3] Sending Number of Test Sets ---")
    try:
        byte_to_send_num_sets = bytes([NUM_TEST_SETS])
        bytes_sent = ser.write(byte_to_send_num_sets)
        print(f"  Sent Number of Test Sets: {NUM_TEST_SETS} (0x{NUM_TEST_SETS:02X})")
        print(f"  Success: {bytes_sent} byte(s) sent.")
        time.sleep(DELAY_AFTER_BYTE_SEND)  # Short delay
    except serial.SerialTimeoutException:
        print(f"Error: Timeout occurred while sending number of test sets.")
        raise
    except Exception as write_e:
        print(
            f"Error: An unexpected error occurred while sending number of test sets: {write_e}"
        )
        raise

    # 2. Sequentially send all 16-bit FP data for all test sets
    print(
        f"\n--- [Step 2/3] Starting Data Transfer for All Test Sets ({NUM_TEST_SETS} sets) ---"
    )
    total_sent_bytes_count = 0

    for i in range(NUM_TEST_SETS):
        current_test_set_data = all_coe_data[
            i * NUM_DATA_PER_SET : (i + 1) * NUM_DATA_PER_SET
        ]

        test_set_hex_preview = []
        for j, data_16bit in enumerate(current_test_set_data):
            high_byte = (data_16bit >> 8) & 0xFF
            low_byte = data_16bit & 0xFF

            try:
                # Send Low Byte (LSB first)
                bytes_sent = ser.write(bytes([low_byte]))
                total_sent_bytes_count += bytes_sent
                # time.sleep(DELAY_AFTER_BYTE_SEND)

                # Send High Byte (MSB second)
                bytes_sent = ser.write(bytes([high_byte]))
                total_sent_bytes_count += bytes_sent
                # time.sleep(DELAY_AFTER_BYTE_SEND)

                test_set_hex_preview.append(
                    f"{data_16bit:04X}"
                )  # Store 16-bit data as full HEX for preview

            except serial.SerialTimeoutException:
                print(f"Error: Timeout while sending data {j+1} in Test Set {i+1}.")
                raise
            except Exception as write_e:
                print(
                    f"Error: An error occurred while sending data {j+1} in Test Set {i+1}: {write_e}"
                )
                raise

        # Print message after a test set is fully sent
        print(f"  Test Set {i+1}/{NUM_TEST_SETS} sent. Data Preview (16-bit HEX):")
        print(
            f"    {' '.join(test_set_hex_preview[:5])} ... {' '.join(test_set_hex_preview[-5:])}"
            if len(test_set_hex_preview) > 10
            else f"    {' '.join(test_set_hex_preview)}"
        )

    print(
        f"\n Success: All {NUM_DATA_PER_SET * NUM_TEST_SETS} 16-bit FP data points ({total_sent_bytes_count} bytes) from {NUM_TEST_SETS} test sets transferred."
    )

    print(
        f"Waiting for FPGA computation to complete... ({DELAY_FOR_ALL_COMPUTATION} seconds)"
    )
    time.sleep(DELAY_FOR_ALL_COMPUTATION)  # Wait for all FPGA computations to finish

    # 3. Receive all result data from FPGA
    print(f"\n--- [Step 3/3] Waiting to Receive All Test Set Results ---")
    received_all_results_bytes = []
    expected_total_receive_bytes = NUM_TEST_SETS * NUM_DATA_PER_SET * 2

    total_received_bytes = 0

    while total_received_bytes < expected_total_receive_bytes:
        try:
            bytes_to_read = expected_total_receive_bytes - total_received_bytes
            received_chunk = ser.read(bytes_to_read)

            if not received_chunk:
                print(
                    f"Warning: No more data received from FPGA. (Timeout or premature termination)"
                )
                break

            total_received_bytes += len(received_chunk)

            for byte_val in received_chunk:
                received_all_results_bytes.append(byte_val)

        except Exception as read_e:
            print(f"Error: An error occurred while receiving FPGA results: {read_e}")
            break

    print(f"Success: Total {total_received_bytes} bytes received from all test sets.")

    # Reconstruct 16-bit values from received bytes
    reconstructed_all_data = []
    if len(received_all_results_bytes) % 2 != 0:
        print("Warning: Total number of received bytes is odd. Potential data loss.")

    for k in range(0, len(received_all_results_bytes), 2):
        if k + 1 < len(received_all_results_bytes):
            # Assuming reception is LSB, then MSB order.
            # So, received_all_results_bytes[k] is LSB, received_all_results_bytes[k+1] is MSB.
            low_byte = received_all_results_bytes[k]
            high_byte = received_all_results_bytes[k + 1]

            # Reconstruct 16-bit value (MSB << 8 | LSB)
            reconstructed_value = (high_byte << 8) | low_byte
            reconstructed_all_data.append(reconstructed_value)
        else:
            print(f"Warning: Last byte could not be paired. (Index {k})")

    print(
        f"\n--- Reconstructed 16-bit FP Data ({len(reconstructed_all_data)} points) ---"
    )
    expected_total_16bit_data = NUM_TEST_SETS * NUM_DATA_PER_SET
    if len(reconstructed_all_data) != expected_total_16bit_data:
        print(
            f"Warning: Reconstructed {len(reconstructed_all_data)} data points, but expected {expected_total_16bit_data}."
        )

    # Output received data per test set
    for i in range(NUM_TEST_SETS):
        start_idx = i * NUM_DATA_PER_SET
        end_idx = start_idx + NUM_DATA_PER_SET
        current_received_test_set = reconstructed_all_data[start_idx:end_idx]

        print(f"\n  [Test Set {i+1}/{NUM_TEST_SETS} Results (16-bit HEX)]")
        # If there's a lot of data, show only a portion and use '...' to indicate omission
        if len(current_received_test_set) > 10:
            print(
                f"    {' '.join([f'{d:04X}' for d in current_received_test_set[:5]])} ... {' '.join([f'{d:04X}' for d in current_received_test_set[-5:]])}"
            )
        else:
            print(f"    {' '.join([f'{d:04X}' for d in current_received_test_set])}")

    # Save received data to COE file
    save_to_coe_file(OUTPUT_COE_FILE_PATH, reconstructed_all_data)

except serial.SerialException as e:
    print(
        f"Critical Error: An error occurred while opening or communicating with the serial port: {e}",
        file=sys.stderr,
    )
    print(f"Please check the following:", file=sys.stderr)
    print(f"1. Ensure the port name '{SERIAL_PORT}' is correct.", file=sys.stderr)
    print(
        f"2. Confirm that the port is not in use by another program.", file=sys.stderr
    )
    print(
        f"3. Verify that your USB-UART converter driver is correctly installed and the device is connected.",
        file=sys.stderr,
    )
except Exception as e:
    print(f"An unexpected critical error occurred: {e}", file=sys.stderr)
finally:
    # Close the serial port if it's open
    if "ser" in locals() and ser.is_open:
        ser.close()
        print("Serial port closed.")
