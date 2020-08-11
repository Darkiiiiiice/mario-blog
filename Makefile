
CONTAINER_TAG = mario-blog
PROJECT_PORT = 80
CONTAINER_PORT = 9001

TARGET_DIR = target
IMAGES_DIR = images


CONFIG = conf.dev.toml

.PHONY: clean_docker
.IGNOER: clean_docker


docker_init:
	mkdir -p ./$(TARGET_DIR)/$(IMAGES_DIR)

docker_build:
	docker build -t $(CONTAINER_TAG) --rm .

docker: docker_clean docker_init docker_build
	docker run -d --name $(CONTAINER_TAG) -p $(CONTAINER_PORT):$(PROJECT_PORT) $(CONTAINER_TAG)
	# sudo docker rmi `sudo docker images | grep '<none>' | awk '{ print $3 }' | sed ':a;N;s/\n/ /g;ba'`
	docker image prune -f

docker_clean:
	-docker stop $(CONTAINER_TAG)
	-docker rm $(CONTAINER_TAG)
	-docker rmi $(CONTAINER_TAG)
	-docker image prune -f
	-rm -f ./$(TARGET_DIR)/$(IMAGES_DIR)/$(CONTAINER_TAG).tar

docker_deploy:
	-docker save -o ./$(TARGET_DIR)/$(IMAGES_DIR)/$(CONTAINER_TAG).tar $(CONTAINER_TAG)
	-sudo chmod 644 ./$(TARGET_DIR)/$(IMAGES_DIR)/$(CONTAINER_TAG).tar
	scp ./$(TARGET_DIR)/$(IMAGES_DIR)/$(CONTAINER_TAG).tar $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_IMAGES_DIR)
	ssh $(REMOTE_USER)@$(REMOTE_HOST) 'sh $(REMOTE_SCRIPTS_DIR)/$(REMOTE_SCRIPT) $(CONTAINER_TAG) $(REMOTE_IMAGES_DIR)$(CONTAINER_TAG).tar $(CONTAINER_PORT) $(PROJECT_PORT) $(CONFIG)'