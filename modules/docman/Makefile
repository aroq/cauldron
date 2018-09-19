docman/init: global/init git/identity/set
	docman init .build $(CI_REPOSITORY_URL) -s --branch=config

docman/build: docman/init
	echo "_______________________________"
	echo "_______________________________"
	echo "_______________________________"
	echo $(CAULDRON_PATH)
	echo $(MAKEFILE_ROOT_PATH)
	echo $(TEMPLATES_PATH)
	echo "_______________________________"
	echo "_______________________________"
	echo "_______________________________"
	cd .build && docman deploy git_target master branch $(CI_COMMIT_REF_NAME)
