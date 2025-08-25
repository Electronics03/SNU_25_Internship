import serial
import time
import numpy as np

Q = 10
SCALE = 1 << Q
I16_MIN, I16_MAX = -32768, 32767
Q610_MIN, Q610_MAX = -32.0, (32.0 - 1.0 / SCALE)


def open_serial(port: str, baud: int = 115200, timeout: float = 1.0) -> serial.Serial:
    ser = serial.Serial(
        port=port,
        baudrate=baud,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        timeout=timeout,
        write_timeout=timeout,
        xonxoff=False,
        rtscts=False,
        dsrdtr=False,
    )

    time.sleep(2.0)
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    return ser


def send_exact(ser: serial.Serial, frame: bytes):
    ser.reset_input_buffer()
    ser.write(frame)
    ser.flush()
    return


def read_exact(ser: serial.Serial, N: int, deadline_s: float = 2.0) -> bytes:
    end_time_s = time.perf_counter() + deadline_s
    buffer = bytearray()

    while len(buffer) < N:
        chunk = ser.read(N - len(buffer))
        if chunk:
            buffer.extend(chunk)
        else:
            if time.perf_counter() > end_time_s:
                raise TimeoutError(
                    f"Error: timeout -> read_exact() [{len(buffer)}/{N}]"
                )
    return bytes(buffer)


def floats_to_q610_bytes(
    x64, *, endian: str = "little", mode: str = "saturate"
) -> bytes:

    x = np.asarray(x64, dtype=np.float64)
    if x.shape != (64,):
        raise ValueError("입력은 길이 64의 1차원 배열이어야 한다.")

    if mode == "strict":
        if np.any(x < Q610_MIN) or np.any(x > Q610_MAX):
            idx = int(np.where((x < Q610_MIN) | (x > Q610_MAX))[0][0])
            raise OverflowError(f"Q6.10 범위 초과(index={idx}, value={x[idx]:.6f})")

    scaled = np.rint(x * SCALE).astype(np.int32)

    scaled = np.clip(scaled, I16_MIN, I16_MAX).astype(np.int16)

    dtype = "<i2" if endian == "little" else ">i2"
    return scaled.astype(dtype, copy=False).tobytes()


def q610_bytes_to_floats(b: bytes, *, endian: str = "little") -> np.ndarray:
    if len(b) != 128:
        raise ValueError(f"입력 바이트 길이가 128이 아니다(len={len(b)})")
    dtype = "<i2" if endian == "little" else ">i2"
    i16 = np.frombuffer(b, dtype=dtype)
    return i16.astype(np.float64) / SCALE


def main():
    PORT = "COM6"
    BAUD = 256000
    ser = open_serial(PORT, BAUD)
    try:
        while True:
            frame = bytes(range(128))
            send_exact(ser, frame)
            resp = read_exact(ser, 128, deadline_s=5.0)
            print("받은 길이:", len(resp))
            print([f"0x{x:02X}" for x in resp])
            time.sleep(0.001)
    except TimeoutError as e:
        print("수신 타임아웃:", e)

    finally:
        ser.close()


if __name__ == "__main__":
    main()
