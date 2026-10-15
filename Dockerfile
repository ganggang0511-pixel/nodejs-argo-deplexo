# Deplexo 适配版 Dockerfile（基于原仓库 Dockerfile 修改）
#
# 为什么改：Deplexo 运行时根文件系统只读，且 /tmp 与 /data 两个可写目录都禁执行。
# 原项目启动时下载 xray/cloudflared 二进制并就地执行，在 Deplexo 上跑不起来。
# 改法：构建时把二进制烘进镜像（/app/bin，只读可执行），
#       配置文件/订阅/sub.txt/boot.log 等写文件改到持久卷 /data/run。
# 兼容性：不设 BIN_DIR/WEB_NAME/BOT_NAME 环境变量时，行为与原版完全一致，
#         放回其他 PaaS 照样用。

FROM node:alpine3.22

WORKDIR /app

COPY index.js index.html package.json ./

EXPOSE 3000/tcp

ARG TARGETARCH
RUN apk update && apk upgrade && \
    apk add --no-cache openssl curl gcompat iproute2 coreutils bash && \
    mkdir -p /app/bin && \
    case "${TARGETARCH:-amd64}" in \
      arm64) MIRROR="https://arm64.ssss.nyc.mn" ;; \
      *)     MIRROR="https://amd64.ssss.nyc.mn" ;; \
    esac && \
    curl -fsSL --retry 3 -o /app/bin/web "$MIRROR/web" && \
    curl -fsSL --retry 3 -o /app/bin/bot "$MIRROR/bot" && \
    chmod +x /app/bin/web /app/bin/bot && \
    chmod +x index.js && \
    npm install

# 二进制固定名（与 index.js 中 WEB_NAME/BOT_NAME 对应），写文件目录指向持久卷
ENV BIN_DIR=/app/bin \
    WEB_NAME=web \
    BOT_NAME=bot \
    FILE_PATH=/data/run \
    PORT=3000

CMD ["node", "index.js"]
