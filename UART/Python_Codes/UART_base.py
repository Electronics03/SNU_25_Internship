import serial
import time


def open_serial(port: str, baud: int = 115200, timeout: float = 0.02) -> serial.Serial:
    """
    UART 포트를 연다. 보통 8-N-1 기본값을 쓴다.
    """
    ser = serial.Serial(
        port=port,
        baudrate=baud,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        timeout=timeout,  # read timeout
        write_timeout=timeout,  # write timeout
    )
    # 보드가 자동 리셋되는 경우 대비 약간 대기
    time.sleep(1.0)
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    return ser


def send_byte(ser: serial.Serial, value: int) -> int:
    """
    8비트 1바이트 전송. value는 0~255 정수.
    반환: 실제 전송한 바이트 수(항상 1 기대).
    """
    if not (0 <= value <= 255):
        raise ValueError("value는 0~255 범위여야 한다.")
    return ser.write(bytes([value]))


if __name__ == "__main__":
    PORT = "COM3"
    BAUD = 115200

    ser = open_serial(PORT, BAUD)
    try:
        while True:
            for v in range(128):
                send_byte(ser, v)

            resp = ser.read(128)
            print("받은 길이:", len(resp))
            print("앞 10개:", [f"0x{x:02X}" for x in resp[:128]])

    finally:
        ser.close()
