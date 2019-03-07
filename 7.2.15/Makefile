#
# Standard version level Makefile used to build a Docker container for Gearbox - https://github.com/gearboxworks/gearbox/
#


# Determine whether we use "nodeJS" or "JQ".
JSONCMD := $(shell jq -r '.organization' ./container.json)
ifneq ($(JSONCMD),)
define GetFromPkg
$(shell jq -r ".$(1)" ./container.json)
endef

define rawJSON
$(shell jq -Mc -r '' ./container.json)
endef

else
JSONCMD := $(shell node -p "require('./container.json').organization")
ifneq ($(JSONCMD),)
define GetFromPkg
$(shell node -p "require('./container.json').$(1)")
endef

define rawJSON
$(shell node -p "require('./container.json')")
endef

else
$(shell )

endif
endif

# Set global variables from container file.
ORGANIZATION		:= $(call GetFromPkg,organization)
NAME		:= $(call GetFromPkg,name)
VERSION		:= $(call GetFromPkg,version)
MAJORVERSION	:= $(call GetFromPkg,majorversion)
LATEST		:= $(call GetFromPkg,latest)
CLASS		:= $(call GetFromPkg,class)
NETWORK		:= $(call GetFromPkg,network)
PORTS		:= $(call GetFromPkg,ports)
VOLUMES		:= $(call GetFromPkg,volumes)
RESTART		:= $(call GetFromPkg,restart)
ARGS		:= $(call GetFromPkg,args)
ENV		:= $(call GetFromPkg,env)

OLDNAME		:= $(NAME)
ifeq ($(BUILD_TYPE),base)
DOCKERFILE	:= DockerfileBase
BUILD_ARGS	:= --build-arg BUILD_TYPE="$(BUILD_TYPE)"
NAME		:= $(NAME)-$(BUILD_TYPE)
endif

ifeq ($(BUILD_TYPE),full)
DOCKERFILE	:= DockerfileRuntime
BUILD_ARGS	:= --squash
NAME		:= $(NAME)
endif

ifeq ($(BUILD_TYPE),)
DOCKERFILE	:= DockerfileTarball
BUILD_ARGS	:= 
NAME		:= $(NAME)
endif

IMAGE_NAME	?= $(ORGANIZATION)/$(NAME)
CONTAINER_NAME	?= $(NAME)-$(VERSION)
CONTAINER_JSON	?= '$(call rawJSON)'


LOGFILE := $(NAME)-$(shell date +'%Y%m%d-%H%M%S').log


.PHONY: build push release clean list inspect test create shell run start stop rm

################################################################################
# Image related commands.
default: all

all:
	@echo "info-base	- Generate PHP info from base container image."
	@echo "clean-base	- Clean base container image."
	@echo "build-base	- Build base container image."
	@echo "push-base	- Push base container image to DockerHub."
	@echo ""
	@echo "info		- Generate PHP info from runtime container image."
	@echo "clean		- Clean runtime container image."
	@echo "build		- Generate runtime container image from base container image."
	@echo "push		- Push runtime container image to DockerHub."
	@echo ""
	@echo "build-full	- Generate runtime container image without base reference."
	@echo ""
	@echo "Process:"
	@echo "	make clean-base"
	@echo "	make build-base"
	@echo "	make clean"
	@echo "	make build"


################################################################################
info-base: $(DOCKERFILE)
	@make info BUILD_TYPE="base"

clean-base: $(DOCKERFILE)
	@make clean BUILD_TYPE="base"

build-base: $(DOCKERFILE)
	@make build BUILD_TYPE="base"

push-base: $(DOCKERFILE)
	@make push BUILD_TYPE="base"


################################################################################
info-full: $(DOCKERFILE)
	@make info BUILD_TYPE="full"

clean-full: $(DOCKERFILE)
	@make clean BUILD_TYPE="full"

build-full: $(DOCKERFILE)
	@make build BUILD_TYPE="full"

push-full: $(DOCKERFILE)
	@make push BUILD_TYPE="full"


################################################################################
info:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	-docker run --rm -it $(IMAGE_NAME):$(VERSION) php -m > $(NAME)-modules.txt
	-docker run --rm -it $(IMAGE_NAME):$(VERSION) php -i > $(NAME)-info.txt
endif


################################################################################
build: DockerfileTarball
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	script -r -t 10 logs/$(LOGFILE) docker build -t $(IMAGE_NAME):$(VERSION) --label container.json='$(call rawJSON)' --label container.organization="$(ORGANIZATION)" --label container.name="$(NAME)" --label container.version="$(VERSION)" --label container.majorversion="$(MAJORVERSION)" --label container.latest="$(LATEST)" --label container.class="$(CLASS)" --label container.network="$(NETWORK)" --label container.ports="$(PORTS)" --label container.volumes="$(VOLUMES)" --label container.restart="$(RESTART)" --label container.args="$(ARGS)" --label container.env="$(ENV)" --build-arg $(ENV)="$(VERSION)" $(BUILD_ARGS) -f $(DOCKERFILE) .
	@echo "Gearbox: Log file saved to \"logs/$(LOGFILE)\""
ifneq ($(MAJORVERSION),)
	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):$(MAJORVERSION)
endif
	-docker run --rm -it $(IMAGE_NAME):$(VERSION) php -m > $(NAME)-modules.txt
	-docker run --rm -it $(IMAGE_NAME):$(VERSION) php -i > $(NAME)-info.txt
endif


################################################################################
push:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	docker push $(IMAGE_NAME):$(VERSION)
ifneq ($(MAJORVERSION),)
	docker push $(IMAGE_NAME):$(MAJORVERSION)
endif
endif


################################################################################
release: build
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	@make clean-base
	@make build-base
	@make clean
	@make build
	@make push
endif


################################################################################
clean:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	-docker image rm -f $(IMAGE_NAME):$(VERSION)
ifneq ($(MAJORVERSION),)
	-docker image rm -f $(IMAGE_NAME):$(MAJORVERSION)
endif
	-rm -f php-base-info.txt php-base-modules.txt php-info.txt php-modules.txt build/output/$(NAME)-$(VERSION).tar
endif


################################################################################
list:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	-docker image ls $(IMAGE_NAME):$(VERSION)
ifneq ($(MAJORVERSION),)
	-docker image ls $(IMAGE_NAME):$(MAJORVERSION)
endif
endif


################################################################################
inspect:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	docker image inspect $(IMAGE_NAME):$(VERSION)
endif


################################################################################
test:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	make -k stop; make -k rm
	make -k clean; make -k build; make -k create; make -k start
endif


################################################################################
# Container related commands.

create:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	docker create   --name $(CONTAINER_NAME) $(RESTART)  $(NETWORK) $(PORTS) $(ARGS) $(VOLUMES) $(IMAGE_NAME):$(VERSION)
endif


################################################################################
shell:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	docker run --rm --name $(CONTAINER_NAME)-shell -i -t $(NETWORK) $(PORTS) $(ARGS) $(VOLUMES) $(IMAGE_NAME):$(VERSION) /bin/bash -l
endif


################################################################################
run:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	docker run --rm --name $(CONTAINER_NAME)             $(NETWORK) $(PORTS) $(ARGS) $(VOLUMES) $(IMAGE_NAME):$(VERSION)
endif


################################################################################
start:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	docker start $(CONTAINER_NAME)
endif


################################################################################
stop:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	docker stop $(CONTAINER_NAME)
endif


################################################################################
rm:
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
else
	docker container rm -f $(CONTAINER_NAME)
endif


################################################################################

