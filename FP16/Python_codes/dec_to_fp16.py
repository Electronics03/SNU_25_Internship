############################
### Host -> FPGA -> Host ###
############################

import serial
import time
import numpy as np

# ============================
# UART 설정
# ============================
SERIAL_PORT = "COM6"  # PC에서 보이는 UART 포트
BAUD_RATE = 115200  # FPGA UART와 동일하게 설정
TIMEOUT_S = 2.0  # 수신 대기 시간


# ============================
# FP16 변환 함수
# ============================
def floats_to_fp16_bytes(x64, *, endian: str = "little") -> bytes:
    """
    float64 배열 -> IEEE-754 FP16 바이트 스트림 변환
    """
    x = np.asarray(x64, dtype=np.float16)  # FP16 변환
    dtype = "<f2" if endian == "little" else ">f2"
    return x.astype(dtype, copy=False).tobytes()


def fp16_bytes_to_floats(b: bytes, *, endian: str = "little") -> np.ndarray:
    """
    FP16 바이트 스트림 -> float64 배열 변환
    """
    if len(b) % 2 != 0:
        raise ValueError(f"입력 바이트 길이가 2의 배수가 아님 (len={len(b)})")
    dtype = "<f2" if endian == "little" else ">f2"
    return np.frombuffer(b, dtype=dtype).astype(np.float64)


# ============================
# UART 유틸 함수
# ============================
def open_serial(port: str, baud: int = 115200, timeout: float = 1.0) -> serial.Serial:
    ser = serial.Serial(
        port=port,
        baudrate=baud,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        timeout=timeout,
        write_timeout=timeout,
    )
    time.sleep(2.0)  # 포트 초기화 대기
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    return ser


def send_exact(ser: serial.Serial, frame: bytes):
    ser.reset_input_buffer()
    ser.write(frame)
    ser.flush()


def read_exact(ser: serial.Serial, N: int, deadline_s: float = 2.0) -> bytes:
    """
    N 바이트를 정확히 수신 (timeout 발생 시 예외)
    """
    end_time_s = time.perf_counter() + deadline_s
    buffer = bytearray()

    while len(buffer) < N:
        chunk = ser.read(N - len(buffer))
        if chunk:
            buffer.extend(chunk)
        else:
            if time.perf_counter() > end_time_s:
                raise TimeoutError(f"수신 타임아웃: {len(buffer)}/{N} 바이트 수신 완료")
    return bytes(buffer)


# ============================
# 메인 루프
# ============================
def main():
    ser = open_serial(SERIAL_PORT, BAUD_RATE, timeout=TIMEOUT_S)
    try:
        while True:
            # -------------------------
            # 1. 테스트용 입력 데이터 생성
            # -------------------------
            # 예: -1.0 ~ +1.0 사이 균일 분포 64개
            test_data = np.linspace(-1.0, 1.0, 64, dtype=np.float64)

            # FP16 변환 → 128바이트
            frame = floats_to_fp16_bytes(test_data, endian="little")

            print("\n[전송 데이터 64개 float]")
            print(test_data[:10], "...")  # 앞 10개 미리보기

            # -------------------------
            # 2. FPGA로 전송
            # -------------------------
            send_exact(ser, frame)

            # -------------------------
            # 3. FPGA에서 수신 (128B = 64 FP16 값)
            # -------------------------
            resp = read_exact(ser, 128, deadline_s=5.0)

            # -------------------------
            # 4. 수신 데이터 변환
            # -------------------------
            floats_out = fp16_bytes_to_floats(resp, endian="little")

            print("[수신 데이터 64개 float]")
            print(floats_out[:10], "...")  # 앞 10개 미리보기
            print("수신 길이:", len(resp), "bytes")

            time.sleep(0.5)  # 주기적 전송 간격

    except TimeoutError as e:
        print("수신 타임아웃:", e)

    finally:
        ser.close()
        print("Serial port closed.")


if __name__ == "__main__":
    main()
