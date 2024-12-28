# 使用 Node.js 作為基礎鏡像
FROM node:18-alpine AS builder

# 設置工作目錄
WORKDIR /app

# 複製依賴文件並安裝依賴
COPY package.json package-lock.json ./
RUN npm install

# 複製應用程式代碼
COPY . .

# 构建 Next.js 应用
RUN npm run build

# 使用輕量的 Node.js 鏡像作為運行時環境
FROM node:18-alpine AS runner

# 設置生產模式
ENV NODE_ENV=production

# 設置工作目錄
WORKDIR /app

# 複製必要文件到運行時環境
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# 安裝生產依賴
RUN npm install --only=production

# 暴露端口
EXPOSE 3000

# 啟動應用
CMD ["npm", "start"]