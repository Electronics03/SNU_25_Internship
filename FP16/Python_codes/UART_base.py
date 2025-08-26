import serial
import time
import numpy as np


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
    time.sleep(2.0)
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
