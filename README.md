# Setup Instructions

## Installing the GitHub Runner
1. 
    ```shell
    git clone https://github.com/redhat-actions/openshift-actions-runner-chart.git
    ``` 

2. Copy in values.yml from this repo
3. ```shell
    helm upgrade --set githubPat=[YOUR_PAT_GOES_HERE] github-runners .
    ```

## Installing ArgoCD
1. Install the OpenShift GitOps Operator and grant it RBAC permissions to install the remaining resources.
   * `oc create -k bootstrap/`
2. Wait for the operator to start ArgoCD. This may take a few minutes. You can monitor progress by looking at the Pods in the openshift-gitops project.
