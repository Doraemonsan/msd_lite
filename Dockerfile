# 第一阶段：构建阶段
FROM alpine:latest AS builder

# 安装构建依赖
RUN apk update && apk add --no-cache build-base cmake cunit-dev libbsd-dev musl-dev

# 创建工作目录
WORKDIR /app

# 复制源代码
COPY . .

# 构建项目
RUN cmake ./ -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=1
RUN cmake --build ./ --config Release -j 4

# 更改配置文件
RUN sed -i "s|vlan777|eth0|g" /app/conf/msd_lite.conf

# 第二阶段：运行阶段
FROM alpine:latest

# 创建目录
RUN mkdir -p /usr/local/bin
RUN mkdir -p /etc

# 从构建阶段复制可执行文件和配置文件
COPY --from=builder /app/src/msd_lite /usr/local/bin/msd_lite
COPY --from=builder /app/conf/msd_lite.conf /etc/msd_lite.conf

# 设置容器启动命令
CMD ["/usr/local/bin/msd_lite", "-v", "-c", "/etc/msd_lite.conf"]