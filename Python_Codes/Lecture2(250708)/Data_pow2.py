def to_q4_12_bits(value):
    fixed = round(value * 4096)
    if fixed < 0:
        fixed = (fixed + 65536) & 0xFFFF
    return f"{fixed:016b}"


entries = {}

# [-4, -2] by 0.03125
v = -4
while v <= -2.00001:
    v_round = round(v, 8)
    entries[v_round] = to_q4_12_bits(v_round)
    v += 0.5

# [-2, 2] by 0.0625
v = -2
while v <= 2.00001:
    v_round = round(v, 8)
    entries[v_round] = to_q4_12_bits(v_round)
    v += 0.25

# [2, 3] by 0.125
v = 2
while v <= 3.00001:
    v_round = round(v, 8)
    entries[v_round] = to_q4_12_bits(v_round)
    v += 0.125

# Output
for real, bits in sorted(entries.items()):
    print(
        f"""in_pow2 = 16'b{bits};\n#10;\n$write("Input: ");\ndisplay_fixed(in_pow2);\n$write("-> Onput: ");\ndisplay_fixed(out_pow2);\n$write("\\n");\n"""
    )
