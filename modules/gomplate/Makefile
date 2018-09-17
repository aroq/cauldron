gomplate:
	# TODO: Refactor this copy procedure (remove it).
	cp -f ${SECRETS_DIR}/gce.account.json .;

	cp -fR $(TEMPLATES_PATH)/. $(CAULDRON_WORKDIR_PATH);

	gomplate -d defines=$(DEFINES_FILE) \
		--exclude="$(TEMPLATES_PATH)/$(SERVICES_PATH)/*/charts" \
		--exclude="$(TEMPLATES_PATH)/$(SERVICES_PATH)/*/helmfile/helmfile.*" \
		--input-dir=$(TEMPLATES_PATH) \
		--output-dir=$(CAULDRON_WORKDIR_PATH);
	find $(CAULDRON_WORKDIR_PATH) -type f -iname "*.sh" -exec chmod +x {} \;
