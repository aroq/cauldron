docman/init: global/init git/identity/set
	docman init .build $(CI_REPOSITORY_URL) -s --branch=config

docman/build: docman/init
	cd .build && docman deploy git_target master branch $(CI_COMMIT_REF_NAME)

docman/build/local/stable: docman/init
	ENV="prod" cd .build && docman build local stable

.PHONY : bump/stable/next
bump/stable/next:
	docman bump stable -n

