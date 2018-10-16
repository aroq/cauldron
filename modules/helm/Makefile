helm/init/client:
	helm init --client-only

helm/delete/purge:
	helm status "${HELM_DELETE_RELEASE_NAME}"
	if [ $? -eq 0 ]; then
		helm delete --purge $(HELM_DELETE_RELEASE_NAME)
	else
		echo "Helm release:${HELM_DELETE_RELEASE_NAME} does not exists"
	fi
