docman/init: global/init git/identity/set
	rm -fR .build
	docman init .build $(CI_REPOSITORY_URL) -s --branch=config

docman/build: docman/init
	cd .build && docman deploy git_target master branch $(CI_COMMIT_REF_NAME)

docman/build/local/stable: docman/init
	ENV="prod" cd .build && docman build local stable

docman/build/local/development: docman/init
	ENV="prod" cd .build && docman build local development

.PHONY : bump/stable/next
bump/stable/next:
	docman bump stable -n

