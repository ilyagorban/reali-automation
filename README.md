# configuration

exposed python-app: http://a48beea503e8d4918a57f37cc15ae635-1268060900.us-east-1.elb.amazonaws.com/

## Created repo and their purpose

- `python-app` (dockerfile + CI automation): `git@github.com:ilyagorban/python-app.git`
- `reali-automation` (terragrunt/terraform + overall readme): `git@github.com:ilyagorban/reali-automation.git`
- `reali-argo-app` (GitOps CD config for ArgoCD): `git@github.com:ilyagorban/reali-argo-app.git`

## Configuration of python-app repo

- add dockerhub credentials to repo secrets
- enable GitHub Actions
- add github token with permissions to update `reali-argo-app` repo

## AWS role/user

- configure user credentials in profile `test`
- configure `test` profile to be default: `export AWS_PROFILE=test`

## asdf (tools installation)

```
brew install asdf
asdf plugin-add terragrunt https://github.com/lotia/asdf-terragrunt.git
asdf plugin-add terraform https://github.com/Banno/asdf-hashicorp.git
```

from the root folder of `reali-automation`: `asdf install`

## Terragrunt

### Plan

- run from `vpc` and `eks` folder: `terragrunt run-all plan --terragrunt-source-update --terragrunt-non-interactive`
- you cannot get correct result for dependency `eks` prior to `apply` in `vpc` folder

### Apply

- or run only from eks folder: `terragrunt run-all apply --terragrunt-source-update --terragrunt-non-interactive --terragrunt-include-external-dependencies`
- or run sequentially (first from `vpc` and then from `eks`): `terragrunt run-all apply --terragrunt-source-update --terragrunt-non-interactive`

## Switch to the new EKS cluster

`aws eks update-kubeconfig --name reali-ilyagorban --region us-east-1 --profile test`

## argocd cli installation

`brew install argocd`

## argocd installation

```
kubectl create namespace argocd
kubectl apply -n argocd -f ./argocd/argocd-install.yaml
```

## argocd configuration

- expose on localhost the argocd-server service: `sudo kubectl port-forward svc/argocd-server 8080:80 -n argocd`
- access to http://localhost:8080 (in production of course it should be secured through internal loadbalancer + vpn access)
- get initial password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- from command line (user: `admin` password from previous step): `argocd login localhost:8080`

## create argocd application for deployment of pre-built image

- create repo `reali-argo-app` (for simplicity - public, in other case it will require to create a security token to be notified on changes)
- the following should be done only once for initial configuration (configuration of App-of-apps)

```
argocd app create apps \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo https://github.com/ilyagorban/reali-argo-app.git \
    --path apps
argocd app sync apps
```

## local test for deployed

`sudo kubectl port-forward svc/helm-python-app 8081:80 -n application`

## finally deployed python-app

http://a48beea503e8d4918a57f37cc15ae635-1268060900.us-east-1.elb.amazonaws.com/

## Things for production

- vpn
- remove public access / add private endpoint
- ci/cd for terragrunt
- move eks node groups values to terragrunt
- put tf-module to separate repo (for versioning different from terragrunt)
- create `make` file for deployments
- helm requires additional repo + chartmuseum

## Next things to do

- github actions for CI -> push image with commit sha to ghcr.io + new commit with new image version to ArgoCD that should trigger the kustomize deployment
- argocd application
