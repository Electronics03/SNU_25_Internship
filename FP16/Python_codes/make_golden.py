##############################
### DATA_in -> DATA_golden ###
##############################

import numpy as np
from scipy.special import softmax

def process_data_for_golden(input_filename="DATA_in.txt", output_filename="DATA_golden.txt"):
    all_input_floats = []
    
    with open(input_filename, 'r') as infile:
        for line in infile:
            line = line.strip()
            # 주석 및 빈 줄 건너뛰기
            if not line or line.startswith('#'):
                continue
            
            # 쉼표로 분리하여 실수 데이터 파싱
            try:
                float_values = [float(x.strip()) for x in line.split(',') if x.strip()]
                all_input_floats.extend(float_values)
            except ValueError as e:
                print(f"Warning: Could not parse line '{line}'. Skipping. Error: {e}")
                continue

    golden_data = []
    # 64개씩 묶어서 Softmax 연산 수행
    # DATA_in.txt의 구조에 따라 16개의 test set만 처리하도록 제한 (이전 코드와 일관성 유지)
    num_sets_to_process = 16 
    data_per_set = 64

    for i in range(num_sets_to_process):
        start_idx = i * data_per_set
        end_idx = start_idx + data_per_set
        
        if end_idx > len(all_input_floats):
            print(f"Warning: Not enough data for {num_sets_to_process} sets. Processing {i} sets only.")
            break
            
        current_set = np.array(all_input_floats[start_idx:end_idx])
        
        # Softmax 연산 수행
        softmax_result = softmax(current_set)
        golden_data.extend(softmax_result.tolist())

    with open(output_filename, 'w') as outfile:
        # DATA_in 형식에 맞게 64개씩 묶어서 출력 (한 test set당 8줄에 8개씩)
        for set_idx in range(num_sets_to_process):
            for line_in_set in range(8):
                start_idx = (set_idx * data_per_set) + (line_in_set * 8)
                end_idx = start_idx + 8
                
                # IndexError 방지: 데이터가 충분하지 않으면 남은 데이터만 출력
                if start_idx >= len(golden_data):
                    break
                
                line_values = golden_data[start_idx:end_idx]
                outfile.write(", ".join([f"{val:.10f}" for val in line_values])) # 소수점 이하 정밀도 높게 출력
                outfile.write(",\n") # 각 줄 끝에 쉼표와 개행
            outfile.write("\n") # 각 test set 사이에 빈 줄 추가

# 함수 실행
process_data_for_golden()