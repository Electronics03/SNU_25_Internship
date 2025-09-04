import sys
import re


def main():
    # Throughput 규칙
    def get_throughput(L):
        if L <= 16:
            return 4
        elif L <= 32:
            return 2
        else:
            return 1

    lengths = []
    throughputs = []

    print("Paste the log (end with Ctrl+D or Ctrl+Z):")
    for line in sys.stdin:
        match = re.search(r"L=\s*(\d+)", line)
        if match:
            L = int(match.group(1))
            tp = get_throughput(L)
            lengths.append(L)
            throughputs.append(tp)

    if throughputs:
        avg_tp = sum(throughputs) / len(throughputs)
        print(f"\nProcessed {len(throughputs)} entries.")
        print(f"Average throughput: {avg_tp:.2f} data per clock")
    else:
        print("No valid entries found.")


if __name__ == "__main__":
    main()
