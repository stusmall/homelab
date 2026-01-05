This is a set up for my home server.  Feel free to look around for ideas, but this probably isn't useful for anyone but me

To run:
* Clone the repo anywhere on the target machine
* Run bootstrap.sh
* Generate a key goto https://panel.dreamhost.com/?tree=home.api and for permissions select `dns-*`
* After rebuilding and switching into the new config, it will prompt for the dreamhost API key
* Join tailscale to the tailnet with `tailscale up --auth-key=$KEY`


------------------

Bootstrapping argoCD

helm install apps-argocd argo/argo-cd --namespace argocd  --create-namespace
kubectl apply -f helm/templates/argocd.yaml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl -n argocd delete secrets argocd-initial-admin-secret
kubectl port-forward -n argocd services/apps-argocd-server 8080:443
argocd login --insecure  localhost:8080
argocd account update-password
argocd app create apps   --dest-server https://kubernetes.default.svc     --repo https://github.com/stusmall/homelab.git     --path helm
argocd app sync apps
