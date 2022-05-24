# Setup Instructions
1. Install the OpenShift GitOps Operator and grant it RBAC permissions to install the remaining resources.
   * `oc create -k bootstrap/`
2. Wait for the operator to start ArgoCD. This may take a few minutes. You can monitor progress by looking at the Pods in the openshift-gitops project.
