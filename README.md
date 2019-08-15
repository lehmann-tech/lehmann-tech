Run `export GOOGLE_CLOUD_KEYFILE_JSON=/Users/theneva/Desktop/lehmann-tech-c15117a8949c.json`, then `terraform apply`

## manual steps (so far)

1. create project
2. enable billing, enable Compute/Kubernetes API
3. create terraform service account user, grant permissions
4. grant roles to kubernetes engine service account (Cloud KMS CryptoKey Encrypter/Decrypter, Service Account User)


- create DNS records (zone, then record set)
- deploy manually managed TLS certs
