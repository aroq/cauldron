export HELMFILE_FILE_PATH ?= helmfile.yaml
export HELMFILE_ENVIRONMENT ?= default
export HELMFILE_LOG_LEVEL ?= info

helmfile/sync/env:
	helmfile --file $(HELMFILE_FILE_PATH) --environment $(HELMFILE_ENVIRONMENT) --log-level $(HELMFILE_LOG_LEVEL) sync
