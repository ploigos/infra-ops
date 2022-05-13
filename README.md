# Setup Instructions

1. 
    ```shell
    git clonehttps://github.com/redhat-actions/openshift-actions-runner-chart.git
    ``` 

2. Copy in values.yml from this repo
3. ```shell
    helm upgrade --set githubPat=[YOUR_PAT_GOES_HERE] github-runners .
    ```