export APPLY_SCRIPT  = apply.sh
export STATE_SCRIPT  = state.sh
export IMPORT_SCRIPT = import.sh

utils/apply/script:
	scripts/$(APPLY_SCRIPT)

utils/state/script:
	scripts/$(STATE_SCRIPT)

utils/import/script:
	scripts/$(IMPORT_SCRIPT)

utils/plan/script:
	@echo "The following script will be executed:"
	@echo "--- Start of the script -------"
	@cat scripts/$(APPLY_SCRIPT)
	@echo "--- End of the script -------"
