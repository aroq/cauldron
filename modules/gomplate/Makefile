gomplate:
	gomplate -d defines=$(DEFINES_FILE) \
		--exclude="$(TEMPLATES_PATH)/$(SERVICES_PATH)/*/charts" \
		--input-dir=$(TEMPLATES_PATH) \
		--output-dir=$(CAULDRON_PATH);
	find $(CAULDRON_PATH) -type f -iname "*.sh" -exec chmod +x {} \;

