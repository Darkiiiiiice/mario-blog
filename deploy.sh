docker stop mario-blog
docker rm mario-blog
docker rmi registry.cn-chengdu.aliyuncs.com/mariomang/mario-blog:latest 
docker login --username=$1 registry.cn-chengdu.aliyuncs.com -p $2
docker run -d --name mario-blog -p 9001:80 registry.cn-chengdu.aliyuncs.com/mariomang/mario-blog:latest 