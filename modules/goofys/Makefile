# Mount s3 bucket with secrets into $SECRETS_MOUNT_POINT dir.
#

SECRETS_SOURCE_ID_RSA_FILE_NAME ?= id_rsa
SECRETS_TARGET_ID_RSA_FILE_NAME ?= id_rsa

goofys/mount:
ifdef SECRETS_MOUNT_POINT
ifeq ($(wildcard $(SECRETS_MOUNT_POINT)),)
	mkdir $(SECRETS_MOUNT_POINT);
	(nohup goofys -f --file-mode=0600 --sse $(SECRETS_BUCKET) ${SECRETS_MOUNT_POINT}) 2>&1 >>/var/log/goofys.log 2>&1 &
	sleep 5
	cp -fR ${SECRETS_DIR}/.ssh/$(SECRETS_SOURCE_ID_RSA_FILE_NAME) /root/.ssh/$(SECRETS_TARGET_ID_RSA_FILE_NAME)
else
	@echo "SECRETS_MOUNT_POINT already mounted"
endif
else
	@echo "No SECRETS_MOUNT_POINT defined"
endif
