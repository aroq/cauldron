export CAULDRON_PATH ?= $(shell until [ -d "cauldron-harness" ] || [ "`pwd`" == '/' ]; do cd ..; done; pwd)/cauldron-harness

# Identify calling Makefile and put it into CAULDRON_MAKEFILE_PATH env var.
LAST_WORD_INDEX = $(words $(MAKEFILE_LIST))
BEFORE_LAST := $(word $(shell echo $(LAST_WORD_INDEX) - 1 | bc),$(MAKEFILE_LIST))
CAULDRON_MAKEFILE_PATH := $(abspath $(BEFORE_LAST))

include $(CAULDRON_PATH)/Makefile.defines
include $(CAULDRON_PATH)/modules/*/Makefile*

# CI_REPOSITORY_URL is defined in Gitlab runner.
export CI_REPOSITORY_URL ?= $(shell git config --get remote.origin.url)

.PHONY : self/%
self/%:
	@:

.PHONY : %/before
%/before:
	@:

.PHONY : %/after
%/after:
	@:

.PHONY : init plan apply destroy state
init:    global/all/before all/before init/before    self/init    init/after    all/after global/all/after
plan:    global/all/before all/before plan/before    self/plan    plan/after    all/after global/all/after
apply:   global/all/before all/before apply/before   self/apply   apply/after   all/after global/all/after
destroy: global/all/before all/before destroy/before self/destroy destroy/after all/after global/all/after
state:   global/all/before all/before state/before   self/state   state/after   all/after global/all/after

.PHONY : global/init
global/init: goofys/mount

.PHONY : global/all/before
global/all/before:
	@echo ""
	@echo "--- Start $(CAULDRON_MAKEFILE_PATH) ---"

.PHONY : global/all/after
global/all/after:
	@echo "--- End $(CAULDRON_MAKEFILE_PATH) ---"

.PHONY : cauldron/workdir/clean
cauldron/workdir/clean:
	@echo "Clean cauldron"
	rm -fR $(CAULDRON_WORKDIR_PATH)

.PHONY : local/apply/prod
local/apply/prod: docman/build/local/stable
	# TODO: Find a better way to retrieve dependencies.
	cp -fR $(MAKEFILE_ROOT_PATH)/.build/master/templates $(MAKEFILE_ROOT_PATH)
	ENV="prod" $(MAKE) apply

.PHONY : local/apply/dev
local/apply/dev: docman/build/local/development
	# TODO: Find a better way to retrieve dependencies.
	cp -fR $(MAKEFILE_ROOT_PATH)/.build/master/templates $(MAKEFILE_ROOT_PATH)
	$(MAKE) apply

.PHONY : local/state/prod
local/state/prod: docman/build/local/stable
	# TODO: Find a better way to retrieve dependencies.
	cp -fR $(MAKEFILE_ROOT_PATH)/.build/master/templates $(MAKEFILE_ROOT_PATH)
	ENV="prod" $(MAKE) state

.PHONY : local/plan/prod
local/plan/prod: docman/build/local/stable
	# TODO: Find a better way to retrieve dependencies.
	cp -fR $(MAKEFILE_ROOT_PATH)/.build/master/templates $(MAKEFILE_ROOT_PATH)
	ENV="prod" $(MAKE) plan
