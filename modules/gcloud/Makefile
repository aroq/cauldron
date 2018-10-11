INFRASTRUCTURE_GCLOUD_PROJECT_ADMIN_SA_KEY_FILENAME ?= $(GCLOUD_PROJECT_NAME)-admin-sa.json

gcloud/setup:
	gcloud config set project $(GCLOUD_PROJECT_NAME);
	gcloud auth activate-service-account --key-file=$(SECRETS_DIR)/$(INFRASTRUCTURE_GCLOUD_PROJECT_ADMIN_SA_KEY_FILENAME);

gcloud/get-credentials:
	gcloud container clusters get-credentials $(GCLOUD_CLUSTER_NAME) --zone $(GCLOUD_CLUSTER_ZONE) --project $(GCLOUD_PROJECT_NAME);
