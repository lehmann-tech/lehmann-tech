# Important files

1. `main.tf` contains the Terraform provisioning config, which does everything except what's listed under "manual steps (so far)" (apply with `terraform apply`)
2. `blog.yaml` contains the k8s deployment, service, and pod disruption budget for the blog (apply with `kubectl apply -f blog.yaml`)
3. `ingress.yaml` contains the k8s ingress pointing to the global static IP address provisioned by Terraform (apply with `kubectl apply -f ingress.yaml`)
4. `blog/` is a direct copy of the webapp found at https://github.com/theneva/lehmann-tech, and has not been touched in this repo. Visit it at http://34.96.95.14/

# Test

1. Download the JSON keyfile for the `terraform` service account
2. Move it somewhere nice
3. Stick its location in the environment, for example: `export GOOGLE_CLOUD_KEYFILE_JSON=/Users/theneva/Desktop/lehmann-tech-c15117a8949c.json`
4. Run `terraform apply` (install it with `brew install terraform`)
5. Apply the Kubernetes resources with `kubectl apply -f blog.yaml` and `kubectl apply -f ingress.yaml`

## manual steps (so far)

1. create project
2. enable billing, enable Compute/Kubernetes API
3. create terraform service account user, grant permissions
4. grant roles to kubernetes engine service account (Cloud KMS CryptoKey Encrypter/Decrypter, Service Account User)


- create DNS records (zone, then record set)
- deploy manually managed TLS certs
