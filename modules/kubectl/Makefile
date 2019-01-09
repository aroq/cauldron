utils/apply/kubectl/config:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl apply -R -f config/;

utils/delete/kubectl/config:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl delete -f config/;

kubectl/rs/rescale:
	"${CAULDRON_PATH}/modules/kubectl/scripts/rs/rescale.sh"
