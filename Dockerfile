FROM node:latest AS build-dev

RUN mkdir -p /usr/src/mario-blog
WORKDIR /usr/src/mario-blog

COPY . .
RUN npm --registry=https://registry.npm.taobao.org install hexo-cli -g && npm install

RUN hexo clean && hexo generate

FROM nginx:latest
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /usr/share/nginx/html

COPY --from=build-env /usr/src/mario-blog/public /usr/share/nginx/html

EXPOSE 80