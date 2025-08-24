########################################
### softmax_output(FP16) -> DATA_out ###
########################################

import struct

def fp16_hex_to_float(fp16_hex):
    fp16_int = int(fp16_hex, 16)

    sign = (fp16_int >> 15) & 0x01
    exponent = (fp16_int >> 10) & 0x1F
    mantissa = fp16_int & 0x3FF

    if exponent == 0:
        if mantissa == 0:
            return -0.0 if sign else 0.0  # Zero
        else:
            # Denormalized numbers
            exponent = -14
            # (1 << 10) is implicit leading 1 for normal numbers,
            # for denormalized numbers, it's 0.
            # We add 1 for the implicit leading 1 when converting to float exponent.
            # For denormalized numbers, the bias is 15.
            # so real exponent is 1-15 = -14
            # (mantissa / 2**10) is the fraction part
            val = (mantissa / float(1 << 10)) * (2.0**exponent)
    elif exponent == 0x1F:
        if mantissa == 0:
            return float('-inf') if sign else float('inf') # Infinity
        else:
            return float('nan') # NaN
    else:
        # Normalized numbers
        exponent -= 15 # Remove bias
        val = (1 + mantissa / float(1 << 10)) * (2.0**exponent)

    return -val if sign else val

def process_softmax_output(input_filename="softmax_output.coe", output_filename="DATA_out.txt"):
    with open(input_filename, 'r') as infile:
        lines = infile.readlines()

    fp16_hex_data = []
    # COFF 파일에서 실제 데이터만 추출
    data_started = False
    for line in lines:
        line = line.strip()
        if line.startswith("memory_initialization_vector="):
            data_started = True
            # 데이터 시작 부분의 "memory_initialization_vector=" 제거
            line = line.replace("memory_initialization_vector=", "")
            if line.endswith(","): # 뒤에 쉼표가 있을 수 있으므로 제거
                line = line[:-1]
            if line.endswith(";"): # 뒤에 세미콜론이 있을 수 있으므로 제거
                line = line[:-1]

        if data_started:
            if line.startswith("memory_initialization_radix="): # Skip radix line if data_started is already true
                continue

            # 쉼표와 세미콜론을 기준으로 데이터 분리
            parts = [p.strip() for p in line.replace(";", "").split(',') if p.strip()]

            # 각 부분을 4개의 FP16 16진수 문자열로 분리
            for part in parts:
                for i in range(0, len(part), 4):
                    fp16_hex_data.append(part[i:i+4])

    all_float_data = []
    for fp16_hex in fp16_hex_data:
        all_float_data.append(fp16_hex_to_float(fp16_hex))

    with open(output_filename, 'w') as outfile:
        # DATA_in 형식에 맞게 64개씩 묶어서 출력 (한 test set당 8줄에 8개씩)
        # 총 16 test set * 64 float/set = 1024 floats
        for set_idx in range(16): # 16개의 test set
            for line_in_set in range(8): # 각 test set당 8줄
                start_idx = (set_idx * 64) + (line_in_set * 8)
                end_idx = start_idx + 8

                # IndexError 방지: 데이터가 충분하지 않으면 남은 데이터만 출력
                if start_idx >= len(all_float_data):
                    break

                # 소수점 10자리까지 출력하도록 수정
                line_data = [f"{val:.10f}" for val in all_float_data[start_idx:end_idx]]
                outfile.write(", ".join(line_data))
                outfile.write(",\n") # 각 줄 끝에 쉼표와 개행
            outfile.write("\n") # 각 test set 사이에 빈 줄 추가

# 함수 실행
process_softmax_output()