# 데이터 정의
x_log_data <- c(
  0.000977, 0.001953, 0.003906, 0.007812,
  0.015625, 0.031250, 0.062500, 0.125000,
  0.250000, 0.500000, 1.000000, 2.000000,
  4.000000, 8.000000, 16.000000, 31.999023
)

y_log_approx <- c(
  -10, -9, -8, -7,
  -6, -5, -4, -3,
  -2, -1, 0, 1,
  2, 3, 4, 4.999023
)

# 참값 생성
x_log_true <- seq(0.000977, 32, length.out = 1000)  # 0은 log 불가 → 작은 값 사용
y_log_true <- log2(x_log_true)

# PDF 장치 열기 (IEEE 단일 컬럼: 3.46 inch 폭, 높이 적당히 2.5 inch)
cairo_pdf("log2_approx_comparison.pdf", family = "Times New Roman", width = 6, height = 3.5)


# 여백 조정 (위, 오른쪽 최소화)
par(mar = c(3, 3, 1, 1), mgp = c(1.8, 0.6, 0), family = "Times New Roman")

# 그래프 그리기
plot(
    x_log_true, y_log_true, type = "l", col = "gray", lwd = 1.5,
    xlab = "Input x", ylab = expression(log[2](x)), main = "", family = "Times New Roman"
)
lines(x_log_data, y_log_approx, type = "o", col = "black", lwd = 1.5, pch = 20)
grid()

# 범례 추가 (작게)
legend("bottomright",
       legend = c(
         expression("True " * log[2](x)),
         expression("PWL " * log[2](x) * " approx")
       ),
       col = c("gray", "black"),
       lty = c(1, 1),
       pch = c(NA, 16),
       lwd = 1.5,
       cex = 1,
       bty = "n"
)
dev.off()
cat("PDF 파일 저장 완료: log2_approx_comparison.pdf\n")
