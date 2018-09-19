# export CAULDRON_PATH = $(shell 'pwd')/cauldron-harness
export CAULDRON_PATH ?= $(shell until [ -d "cauldron-harness" ] || [ "`pwd`" == '/' ]; do cd ..; done; pwd)/cauldron-harness

# Identify calling Makefile and put into CAULDRON_MAKEFILE_PATH.
LAST_WORD_INDEX = $(words $(MAKEFILE_LIST))
BEFORE_LAST := $(word $(shell echo $(LAST_WORD_INDEX) - 1 | bc),$(MAKEFILE_LIST))
CAULDRON_MAKEFILE_PATH := $(abspath $(BEFORE_LAST))

include $(CAULDRON_PATH)/Makefile.defines
include $(CAULDRON_PATH)/modules/*/Makefile*

# CI_REPOSITORY_URL is defined in Gitlab runner.
export CI_REPOSITORY_URL ?= $(shell git config --get remote.origin.url)

self/%:
	@:

init:    global/all/before self/all/before self/init/before    self/init    self/init/after    self/all/after global/all/after
plan:    global/all/before self/all/before self/plan/before    self/plan    self/plan/after    self/all/after global/all/after
apply:   global/all/before self/all/before self/apply/before   self/apply   self/apply/after   self/all/after global/all/after
destroy: global/all/before self/all/before self/destroy/before self/destroy self/destroy/after self/all/after global/all/after
state:   global/all/before self/all/before self/state/before   self/state   self/state/after   self/all/after global/all/after

global/init: goofys/mount

global/all/before:
	@echo ""
	@echo "--- Start $(CAULDRON_MAKEFILE_PATH) ---"

global/all/after:
	@echo "--- End $(CAULDRON_MAKEFILE_PATH) ---"

cauldron/workdir/clean:
	@echo "Clean cauldron"
	rm -fR $(CAULDRON_WORKDIR_PATH)

.PHONY : self/all/before
self/all/before: global/init cauldron/workdir/clean uniconf gomplate

.PHONY : self/plan
self/plan:
	$(MAKE) -C $(CAULDRON_WORKDIR_PATH) plan

.PHONY : self/apply
self/apply:
	$(MAKE) -C $(CAULDRON_WORKDIR_PATH) apply

.PHONY : self/destroy
self/destroy:
	$(MAKE) -C $(CAULDRON_WORKDIR_PATH) destroy

.PHONY : self/state
self/state:
	$(MAKE) -C $(CAULDRON_WORKDIR_PATH) state

.PHONY : noinit/plan
noinit/plan: global/init
	# TODO: Refactor this copy procedure (remove it).
	cp -f ${SECRETS_DIR}/gce.account.json .
	$(MAKE) -C $(CAULDRON_WORKDIR_PATH) plan

.PHONY : noinit/apply
noinit/apply: global/init
	# TODO: Refactor this copy procedure (remove it).
	cp -f ${SECRETS_DIR}/gce.account.json .
	$(MAKE) -C $(CAULDRON_WORKDIR_PATH) apply

.PHONY : noinit/destroy
noinit/destroy: global/init
	# TODO: Refactor this copy procedure (remove it).
	cp -f ${SECRETS_DIR}/gce.account.json .
	$(MAKE) -C $(CAULDRON_WORKDIR_PATH) destroy

.PHONY : noinit/state
noinit/state: global/init
	# TODO: Refactor this copy procedure (remove it).
	cp -f ${SECRETS_DIR}/gce.account.json .
	$(MAKE) -C $(CAULDRON_WORKDIR_PATH) state
