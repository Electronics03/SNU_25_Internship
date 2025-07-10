def to_q4_12_bits(value):
    fixed = round(value * 4096)
    if fixed < 0:
        fixed = (fixed + 65536) & 0xFFFF
    return f"{fixed:016b}"


entries = {}

# [0, 0.125] by 0.015625
v = 0.0
while v <= 0.12501:
    v_round = round(v, 8)
    entries[v_round] = to_q4_12_bits(v_round)
    v += 0.015625

# [0.125, 0.25] by 0.03125
v = 0.125
while v <= 0.25001:
    v_round = round(v, 8)
    entries[v_round] = to_q4_12_bits(v_round)
    v += 0.03125

# [0.25, 0.5] by 0.0625
v = 0.25
while v <= 0.50001:
    v_round = round(v, 8)
    entries[v_round] = to_q4_12_bits(v_round)
    v += 0.0625

# [0.5, 1] by 0.125
v = 0.5
while v <= 1.00001:
    v_round = round(v, 8)
    entries[v_round] = to_q4_12_bits(v_round)
    v += 0.125

# [1, 5] by 0.25
v = 1.0
while v <= 5.00001:
    v_round = round(v, 8)
    entries[v_round] = to_q4_12_bits(v_round)
    v += 0.25

# Output
for real, bits in sorted(entries.items()):
    print(
        f"""in_log2 = 16'b{bits};\n#10;\n$write("Input: ");\ndisplay_fixed(in_log2);\n$write("-> Onput: ");\ndisplay_fixed(out_log2);\n$write("\\n");\n"""
    )
