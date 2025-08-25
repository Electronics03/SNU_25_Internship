import serial, time, numpy as np


# ---------------- UART helpers ----------------
def open_serial(port="COM6", baud=256000, timeout=1.0):
    ser = serial.Serial(
        port=port,
        baudrate=baud,
        bytesize=8,
        parity="N",
        stopbits=1,
        timeout=timeout,
        write_timeout=timeout,
        xonxoff=False,
        rtscts=False,
        dsrdtr=False,
    )
    time.sleep(2.0)  # Windows/USB CDC 안정화
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    return ser


def send_exact(ser, frame: bytes):
    ser.reset_input_buffer()
    ser.write(frame)
    ser.flush()


def read_exact(ser, n, deadline_s=5.0) -> bytes:
    end = time.perf_counter() + deadline_s
    buf = bytearray()
    while len(buf) < n:
        chunk = ser.read(n - len(buf))
        if chunk:
            buf.extend(chunk)
        elif time.perf_counter() > end:
            raise TimeoutError(f"timeout: [{len(buf)}/{n}]")
    return bytes(buf)


# ------------- (A) float32 <-> FP16 bytes -------------
def floats_to_fp16_bytes(x64, *, little_endian=True) -> bytes:
    x = np.asarray(x64, dtype=np.float32)
    if x.shape != (64,):
        raise ValueError("need shape (64,)")
    u16 = x.astype(np.float16).view(np.uint16)
    dt = np.dtype("<u2" if little_endian else ">u2")
    return u16.astype(dt, copy=False).tobytes()


def fp16_bytes_to_f32(b: bytes, *, little_endian=True) -> np.ndarray:
    if len(b) != 128:
        raise ValueError(f"expected 128B, got {len(b)}")
    dt = np.dtype("<u2" if little_endian else ">u2")
    u16 = np.frombuffer(b, dtype=dt)
    return u16.view(np.float16).astype(np.float32)


# ------------- (B) "워드 4개 문자열 × 16줄" -> 128B -------------
def build_frame_from_words16(
    rows, *, half_little_endian=True, word_order_msb_first=True
) -> bytes:
    if len(rows) != 16:
        raise ValueError("rows must be 16 lines (4×16b × 16 = 128B)")
    words16 = []
    for line in rows:
        toks = [t for t in line.replace(",", " ").split() if t]
        if len(toks) != 4:
            raise ValueError(f"each line needs 4 tokens: {line}")
        vals = [int(t, 16) & 0xFFFF for t in toks]
        words16.extend(vals if word_order_msb_first else vals[::-1])
    if len(words16) != 64:
        raise AssertionError("need 64 half-words")
    out = bytearray()
    for w in words16:
        if half_little_endian:
            out += bytes((w & 0xFF, (w >> 8) & 0xFF))  # LSB, MSB
        else:
            out += bytes(((w >> 8) & 0xFF, w & 0xFF))  # MSB, LSB
    return bytes(out)


# ---------------- Demo ----------------
def main():
    PORT, BAUD = "COM6", 256000
    ser = open_serial(PORT, BAUD)

    try:
        # ==== A) float32 테스트 ====
        x = np.ones(64, dtype=np.float32)  # 모두 1.0 → softmax는 대략 1/64
        tx = floats_to_fp16_bytes(x, little_endian=True)
        send_exact(ser, tx)
        rx = read_exact(ser, 128, deadline_s=5.0)
        y = fp16_bytes_to_f32(rx, little_endian=True)

        np.set_printoptions(precision=6, suppress=True)
        print("A) sum(y) ≈", float(np.sum(y)), "  y[:8]:", y[:8])
        print("A) TX[0:16]:", [f"0x{b:02X}" for b in tx[:16]])
        print("A) RX[0:16]:", [f"0x{b:02X}" for b in rx[:16]])

        # ==== B) 16줄 워드 입력 테스트 ====
        WORDS16_ROWS = [
            "BFC2 BCDB BA94 419E",
            "3370 B778 3B79 3DC8",
            "3C12 BE93 407E BB88",
            "B954 3EE9 3B67 C1B7",
            "C187 41C4 C1EC 3E55",
            "C072 B657 C0CC 40CB",
            "B3B1 BEBB 3FE8 BFAD",
            "B7C9 BF47 3C1B 35CF",
            "3AF3 3C99 3C92 BFF7",
            "4095 B75D 1192 B917",
            "BF5C BF55 4113 BFB1",
            "3A34 3030 B208 BB61",
            "4130 BFCF BC60 41E1",
            "A999 4085 BDF9 41F2",
            "3F89 BEF5 B961 B727",
            "3A91 C050 BD7E BF7C",
        ]
        tx2 = build_frame_from_words16(
            WORDS16_ROWS, half_little_endian=True, word_order_msb_first=True
        )
        send_exact(ser, tx2)
        rx2 = read_exact(ser, 128, deadline_s=5.0)
        y2 = fp16_bytes_to_f32(rx2, little_endian=True)

        print("B) sum(y2) ≈", float(np.sum(y2)), "  y2[:8]:", y2[:8])
        print("B) TX2[0:16]:", [f"0x{b:02X}" for b in tx2[:16]])
        print("B) RX2[0:16]:", [f"0x{b:02X}" for b in rx2[:16]])

    except TimeoutError as e:
        print("수신 타임아웃:", e)
    finally:
        ser.close()


if __name__ == "__main__":
    main()
