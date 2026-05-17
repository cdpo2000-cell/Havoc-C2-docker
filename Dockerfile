FROM golang:1.21-bookworm

# 1. 安裝 MinGW、NASM 與必要編譯工具 ( 新增 nasm)
RUN apt-get update && apt-get install -y \
    mingw-w64 \
    nasm \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. 複製主機上下載好的 Havoc 專案
COPY ./Havoc /app

# 建立預設目錄
RUN mkdir -p /app/data /app/profiles

# 3. 設定 Go 代理伺服器
ENV GOPROXY=https://goproxy.io,direct

# 4. 前往 teamserver 目錄編譯
WORKDIR /app/teamserver
RUN go mod download
RUN go build -o /app/havoc-backend main.go

# 5. 回到根目錄運行
WORKDIR /app

EXPOSE 40056 80 443

ENTRYPOINT ["./havoc-backend", "server", "--profile", "/app/profiles/havoc.yaotl", "--debug"]