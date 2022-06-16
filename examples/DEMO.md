# Demo External Secrets and Vault Integration

## Prerequisites
You must have ran through the Setup Instructions within the [README](../README.md).

## Demo Steps
1. Add a secret to vault.
   * `oc exec -it vault-0 -- vault kv put secret/foo bar=<secret here>`
2. Add an Openshift secret that contains the token that will authenticate with Vault.
   * `oc create secret generic vault-secret --from-literal=token=<token here>`
3. Create External Secrets resources.
   * `oc create -f .`
4. Verify Openshift secret is created with value input in vault.
   * `oc get secret example-value -o jsonpath={'.data.password'} | base64 -d`