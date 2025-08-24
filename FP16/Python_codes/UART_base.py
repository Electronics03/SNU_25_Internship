############################
### Host -> FPGA -> Host ###
### 64 x FP16 (128 bytes) ###
############################

import serial
import time
import numpy as np

# ===== UART 기본 설정 =====
PORT = "COM6"
BAUD = 115200
READ_TIMEOUT_S = 5.0
WRITE_TIMEOUT_S = 5.0

# ===== 프로토콜 파라미터 =====
N_ELEMS = 64  # 64개 half -> 128바이트
ENDIAN = "little"  # LSB-first 전송 (FPGA가 LSB 먼저 받는 경우)
SEND_NUMSETS_HEADER = False  # True면 전송 전에 1바이트로 세트 개수 보냄
NUM_SETS_TO_SEND = 1  # 헤더를 보낼 때 세트 개수 값


# ===== 유틸: 포트 열기/닫기/전송/수신 =====
def open_serial(
    port: str,
    baud: int = 115200,
    read_timeout: float = READ_TIMEOUT_S,
    write_timeout: float = WRITE_TIMEOUT_S,
) -> serial.Serial:
    ser = serial.Serial(
        port=port,
        baudrate=baud,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        timeout=read_timeout,
        write_timeout=write_timeout,
        xonxoff=False,
        rtscts=False,
        dsrdtr=False,
    )
    # 보드 리셋/포트 오픈 안정화 대기
    time.sleep(0.5)
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    return ser


def send_exact(ser: serial.Serial, frame: bytes) -> None:
    # 필요시 입력 버퍼 비워서 에코/잔여 데이터가 혼입되지 않게 함
    ser.reset_input_buffer()
    ser.write(frame)
    ser.flush()


def read_exact(ser: serial.Serial, nbytes: int, deadline_s: float) -> bytes:
    end_t = time.perf_counter() + deadline_s
    buf = bytearray()
    while len(buf) < nbytes:
        chunk = ser.read(nbytes - len(buf))
        if chunk:
            buf.extend(chunk)
        else:
            if time.perf_counter() > end_t:
                raise TimeoutError(f"read_exact timeout: {len(buf)}/{nbytes} bytes")
    return bytes(buf)


# ===== FP16 <-> bytes 변환 =====
def floats_to_fp16_bytes(x64, *, endian: str = "little", strict: bool = False) -> bytes:
    """
    x64: 길이 64의 실수 배열 -> 128바이트 (FP16)로 직렬화
    endian='little'이면 각 16b 워드는 LSB->MSB 순으로 바이트화됨.
    strict=True면 |x|>65504, NaN/Inf 존재 시 에러.
    """
    x = np.asarray(x64, dtype=np.float32)
    if x.shape != (64,):
        raise ValueError("입력은 길이 64의 1차원 배열이어야 한다.")

    if strict:
        if not np.all(np.isfinite(x)):
            bad = np.where(~np.isfinite(x))[0][0]
            raise ValueError(f"NaN/Inf 포함(index={bad})")
        if np.any(np.abs(x) > 65504.0):
            bad = np.where(np.abs(x) > 65504.0)[0][0]
            raise OverflowError(f"FP16 표현 범위 초과(index={bad}, value={x[bad]})")

    half = x.astype(np.float16)
    dt = "<f2" if endian == "little" else ">f2"
    return half.astype(dt, copy=False).tobytes()


def fp16_bytes_to_floats(b: bytes, *, endian: str = "little") -> np.ndarray:
    """
    128바이트(64 x FP16)를 받아 float64 배열(길이 64)로 반환
    """
    if len(b) != 128:
        raise ValueError(f"입력 바이트 길이가 128이 아니다(len={len(b)})")
    dt = "<f2" if endian == "little" else ">f2"
    return np.frombuffer(b, dtype=dt).astype(np.float64)


# ===== 한 세트 송수신 =====
def send_one_fp16_set(
    ser: serial.Serial,
    vec64,
    *,
    endian: str = "little",
    send_header: bool = False,
    header_count: int = 1,
    rx_deadline_s: float = 2.0,
) -> np.ndarray:
    """
    vec64: 길이 64 실수 배열 (float) -> 64 x FP16 로 전송
    send_header=True면 전송 전에 1바이트로 header_count를 보냄
    수신도 128바이트(=64 x FP16)로 가정
    """
    frame = floats_to_fp16_bytes(vec64, endian=endian)

    # (선택) 헤더 전송: 테스트셋 개수 등
    if send_header:
        if not (0 <= header_count <= 255):
            raise ValueError("header_count는 0~255 범위여야 한다.")
        send_exact(ser, bytes([header_count]))

    # 본문(128바이트) 전송
    send_exact(ser, frame)

    # 결과 수신(128바이트)
    resp = read_exact(ser, 128, deadline_s=rx_deadline_s)
    return fp16_bytes_to_floats(resp, endian=endian)


# ===== 데모 메인 =====
def main():
    ser = open_serial(PORT, BAUD)
    try:
        # 예시 입력: -4.0 ~ +4.0 사이 균등분포 64개
        tx_vec = np.linspace(-4.0, 4.0, 64, dtype=np.float32)

        # 필요 시 헤더 1바이트(세트 개수) 먼저 전송
        rx_vec = send_one_fp16_set(
            ser,
            tx_vec,
            endian=ENDIAN,
            send_header=SEND_NUMSETS_HEADER,
            header_count=NUM_SETS_TO_SEND,
            rx_deadline_s=READ_TIMEOUT_S,
        )

        # 전송/수신 확인 출력
        print("[TX first 8] :", np.array2string(tx_vec[:8], precision=6))
        print("[RX first 8] :", np.array2string(rx_vec[:8], precision=6))
        print(f"RX length   : {len(rx_vec)} (expect 64)")

        # 원하면 HEX 프리뷰 (각 원소 16비트 워드 기반)
        tx_bytes = floats_to_fp16_bytes(tx_vec, endian=ENDIAN)
        rx_bytes = floats_to_fp16_bytes(rx_vec.astype(np.float32), endian=ENDIAN)

        def words_hex(b):
            u16 = np.frombuffer(b, dtype=("<u2" if ENDIAN == "little" else ">u2"))
            return " ".join(f"{w:04X}" for w in u16[:8])

        print("[TX HEX 8]  :", words_hex(tx_bytes))
        print("[RX HEX 8]  :", words_hex(rx_bytes))

    except TimeoutError as e:
        print("수신 타임아웃:", e)
    finally:
        ser.close()
        print("Serial port closed.")


if __name__ == "__main__":
    main()
