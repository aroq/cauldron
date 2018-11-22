# Test that we have necessary executables available
terraform/checkexec:
	EXECUTABLES = terraform
	K := $(foreach exec,$(EXECUTABLES),\
	$(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

terraform/init:
	cd $(CAULDRON_WORKDIR_PATH)/$(GCLOUD_CLUSTER_PATH)/terraform && terraform init;

terraform/plan:
	terraform plan;

terraform/apply:
	terraform apply -auto-approve;

terraform/destroy:
	"${CAULDRON_PATH}/modules/terraform/scripts/destroy.sh"
