import serial, sys, time

port, baud, dur = 'COM3', 115200, 8.0
try:
    s = serial.Serial(port, baud, timeout=1)
except Exception as e:
    print(f"[serial open failed] {e}")
    sys.exit(1)
s.reset_input_buffer()
end = time.time() + dur
while time.time() < end:
    data = s.read(4096)
    if data:
        sys.stdout.write(data.decode('utf-8', errors='replace'))
        sys.stdout.flush()
s.close()
print("\n---end---")
