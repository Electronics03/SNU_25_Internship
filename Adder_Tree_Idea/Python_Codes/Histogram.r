# 데이터 읽기
lengths <- scan("sst2_token_lengths.txt", what = integer(), quiet = TRUE)

# PDF 출력 시작
cairo_pdf("sst2_token_histogram.pdf", family = "Times New Roman", width = 6, height = 4)

par(mar = c(4.1, 4.1, 1, 1), family = "Times New Roman")  # 아래, 왼쪽 넓게 / 위, 오른쪽 좁게


# 히스토그램 그리기
hist(
    lengths,
    breaks = seq(0, max(lengths) + 5, by = 2), # 2 단위 구간
    col = "gray",
    border = "black",
    main = NULL,
    xlab = expression("Token length ("<=" 64)"),
    ylab = "Number of sentences",
    family = "Times New Roman"
)

grid(nx = NA, ny = NULL, col = "lightgray", lty = "dotted")

# PDF 장치 닫기
dev.off()

cat("PDF 파일 저장 완료: sst2_token_histogram.pdf\n")
