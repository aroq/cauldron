export HELMFILE_FILE_PATH ?= helmfile.yaml
export HELMFILE_ENVIRONMENT ?= default

helmfile/sync/env:
	helmfile --file $(HELMFILE_FILE_PATH) --environment $(HELMFILE_ENVIRONMENT) sync
