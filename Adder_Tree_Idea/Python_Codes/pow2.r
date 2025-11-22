# 데이터 정의
x_pow_data <- c(
  -31.999023, -11.000000, -10.000000, -9.000000,
  -8.000000, -7.000000, -6.000000, -5.000000,
  -4.000000, -3.000000, -2.000000, -1.000000,
   0.000000,  1.000000,  2.000000,  3.000000,
   4.000000,  4.999023
)

y_pow_approx <- c(
  0.000000, 0.000000, 0.000977, 0.001953,
  0.003906, 0.007812, 0.015625, 0.031250,
  0.062500, 0.125000, 0.250000, 0.500000,
  1.000000, 2.000000, 4.000000, 8.000000,
  16.00000, 31.98437
)

# 참값 생성
x_pow_true <- seq(-32, 5, length.out = 1000)
y_pow_true <- 2^x_pow_true

# PDF 장치 열기 (IEEE 단일 컬럼 폭: 3.46 in ≈ 8.8 cm, 높이 2.5 in 권장)
cairo_pdf("pow2_approx_comparison.pdf", family = "Times New Roman", width = 6, height = 3.5)

# 여백 조정
par(mar = c(3, 3, 1, 1), mgp = c(1.8, 0.6, 0), family = "Times New Roman")

# 그래프 그리기 (참값: 회색 선)
plot(
  x_pow_true, y_pow_true, type = "l", col = "gray", lwd = 1.5,
  xlab = "Input x", ylab = expression(2^x), main = ""
)

# 근사값: 검정 점선 + 원 마커
lines(x_pow_data, y_pow_approx, type = "o", col = "black", lwd = 1.5, pch = 20)

# 격자 추가
grid()

# 범례 추가
legend("topleft", 
       legend = c(
         expression("True " * 2^x),
         expression("PWL " * 2^x * " approx")
       ),
       col = c("gray", "black"),
       lty = c(1, 1),
       pch = c(NA, 16),
       lwd = 1.5,
       cex = 1,
       bty = "n"
)

dev.off()
cat("PDF 파일 저장 완료: pow2_approx_comparison.pdf\n")
