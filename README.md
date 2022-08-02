This GitOps repository is used to deploy the infrastructure for running Ploigos based pipelines using GitHub Actions.

# Setup Instructions

## Prerequisites
You must have these tools installed to complete the setup:
- [OpenShift cli](https://docs.openshift.com/container-platform/4.7/cli_reference/openshift_cli/getting-started-cli.html) - Create applications and manage OpenShift Container Platform projects from a terminal.
- [Helm](https://helm.sh/docs/intro/install/) (version 3.6 or greater) - Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application.

## Install Steps
1. Login to openshift.
   * `oc login --token=<YOUR TOKEN> --server=<YOUR SERVER>` (Or username and password instead of token)
2. Install the OpenShift GitOps Operator and grant it RBAC permissions to install the remaining resources.
   * `oc create -f bootstrap/`
3. Wait for the operator to start ArgoCD. This may take a few minutes. You can monitor progress by looking at the Pods in the devsecops project.
4. Install applications using ArgoCD.
   * `oc create -f applications/`
5. If using an internal registry requiring authentication, run the following commands.
```bash
oc -n vault create secret docker-registry pull-secret --docker-server <your-container-registry> --docker-username <user> --docker-password <password>
oc -n vault secrets link vault-sa pull-secret --for=pull
oc -n vault secrets link vault-agent-injector pull-secret --for=pull
oc -n external-secrets create secret docker-registry pull-secret --docker-server <your-container-registry> --docker-username <user> --docker-password <password>
oc -n external-secrets secrets link external-secrets pull-secret --for=pull
oc -n external-secrets secrets link external-secrets-cert-controller pull-secret --for=pull
oc -n external-secrets secrets link external-secrets-webhook pull-secret --for=pull
oc -n github-runners create secret docker-registry pull-secret --docker-server <your-container-registry> --docker-username <user> --docker-password <password>
oc -n github-runners secrets link buildah-sa pull-secret --for=pull
```
6. Load secrets into vault by executing the following commands.
```bash
oc exec -n vault -it vault-0 -- vault kv put secret/github pat=<your-github-pat>
oc exec -n vault -it vault-0 -- vault kv put secret/registry0 host=registry.access.redhat.com \
   user=<your-username> password=<your-password>
oc exec -n vault -it vault-0 -- vault kv put secret/registry1 host=quay.io \
   user=<your-username> password=<your-password>
oc exec -n vault -it vault-0 -- vault kv put secret/registry2 host=<your-container-registry> \
   user=<your-username> password=<your-password>
oc exec -n vault -it vault-0 -- vault kv put secret/argocd username=<your-username> password=<your-password>
oc exec -n vault -it vault-0 -- vault kv put secret/git username=<your-username> password=<your-github-pat>

#Load in gpg key to var
export GPG_KEY=`cat << EOM
                                         -----BEGIN PGP PRIVATE KEY BLOCK-----

        <your-gpg-key>
        -----END PGP PRIVATE KEY BLOCK-----
EOM`

#Upload key to vault. Quotes around var required to maintain newlines and spacing
oc exec -n vault -it vault-0 -- vault kv put secret/podmansign sign-container-image-private-key="${GPG_KEY}"
```
6. Setup artifactory based on how to instructions below.

Note:
> Run the spring-petclinic pipeline to ensure that everything works by navigating to the [application workflow page](https://github.com/ploigos/spring-petclinic/actions/workflows/main.yaml). Click on the Run workflow dropdown, leave the main branch selected, and select Run workflow.

# Design

## Components
The table below lists the components that this repository deploys or uses.

| Component                                                                                                                         | Type            | Description                                                                                                                                                                                                                                                                                                                                                                          |
|-----------------------------------------------------------------------------------------------------------------------------------|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| infra-ops                                                                                                                         | Git Repository  | This GitOps repository. Defines what other components should be deployed and their configurations.                                                                                                                                                                                                                                                                                   | 
| [OpenShift GitOps](https://docs.openshift.com/container-platform/4.10/cicd/gitops/understanding-openshift-gitops.html)            | Operator        | [ArgoCD](https://argo-cd.readthedocs.io/en/stable/), packaged as an operator and deployed from Red Hat's operator catalog. [Adds multi-tenancy functionality](https://github.com/redhat-developer/gitops-operator#gitops-operator-vs-argo-cd-community-operator) not included in vanilla ArgoCD deployments. This documentation uses "OpenShift GitOps" and "ArgoCD" interchangably. |
| [External Secrets Operator](https://external-secrets.io/)                                                                         | Operator        | (Planned) An operator that creates Kubernetes Secrets based on references to an external secrets management solution (in our case Vault). References are stored in Git as ExternalSecret CRs.                                                                                                                                                                                        |
| [HashiCorp Vault](https://www.vaultproject.io/docs)                                                                               | K8s Deployment  | (Planned) A secret and encryption management solution, deployed as an ArgoCD Application that uses [HashiCorp's Helm chart](https://github.com/hashicorp/vault-helm).                                                                                                                                                                                                                |
| [JFrog Artifactory](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-HelmInstallation) | Container Repository | A repository for container images.                                                                                                                                                                                                                                                                                                                                                   |
| [ploigos-github-runner image](https://quay.io/repository/ploigos/ploigos-github-runner?tab=info)                                  | Container Image | A container image for self-hosting GitHub runner that usees the Ploigos Step Runner. Publicly available on Quay.io.                                                                                                                                                                                                                                                                  |
| [ploigos-github-runner source](https://github.com/ploigos/github-runners)                                                         | Git Repository  | Source code used to build the ploigos-github-runner image. The repository defines a GitHub Actions workflow that builds the image and pushes it to Quay.io.                                                                                                                                                                                                                          |
| GitHub Runner Deployment                                                                                                          | K8s Deployment  | A self-hosted GitHub Actions runner, running inside OpenShift. Uses the ploigos-github-runner container image. Executes CI/CD workflows on OpenShift. Connects to GitHub to receive events and workflow definitions. OpenShift GitOps deploys this.                                                                                                                                  |
| [Ploigos Step Runner (PSR)](https://github.com/ploigos/ploigos-step-runner)                                                       | Binary          | Packaged inside the ploigos-github-runner image. A CLI used to configure, invoke and process the results of tools and services used by CI/CD workflows.                                                                                                                                                                                                                              |
| [ploigos-github-workflows](https://github.com/ploigos-github-demo/ploigos-github-workflows)                                       | Git Repository  | Reusable GitHub Actions workflows based on the Ploigos Step Runner.                                                                                                                                                                                                                                                                                                                  |
| [java-github-example source](https://github.com/ploigos/java-github-example)                                                      | Git Repository  | Source code for a generic example application. Has a short GitHub actions workflow that calls the ploigos-github-workflow. Has configuration for the Ploigos Step Runner.                                                                                                                                                                                                            |
| java-github-example image                                                                                                         | Container Image | The workflow in the upstream java-github-example source repository publishes its image to Quay.io. New deployments of the example application must provide a place to push the image. This can be a free Quay.io repo.                                                                                                                                                               |
| [java-github-example-ops](https://github.com/ploigos/java-github-example-ops)                                                     | Git Repository  | The GitOps repository for java-github-example. Contains a helm chart tha is used to deploy the application. During the CI/CD workflow, PSR creates an ArgoCD Application CR referencing the chart. ArgoCD invokes helm when it syncs the Application.                                                                                                                                |
| [openshift-actions-runner-chart](https://github.com/ploigos/openshift-actions-runner-chart/)                                      | Git Repository  | Contains Helm chart that deploys the GitHub Actions Runner. An Application CR in this repository references it.                                                                                                                                                                                                                                                                      |


## GitOps Workflow
This repository is used to deploy infrastructure using a GitOps workflow. This diagram shows what happens when an
administrator follows the setup instructions. Step 1 is manual. Everything after that is automated.

![](docs/interaction-infrastructure-deployment.svg)

1. An administrator manually runs a command to deploy OpenShift GitOps and configure it with an ApplicationSet CR. (See the set up instructions in this documentation.)
2. When OpenShift GitOps (ArgoCD) starts, it continuously polls the Kubernetes API for the existence of ApplicationSet CRs. It detects the CR that was created in the previous step, and in response it begins to create several additional Kubernetes resources.
3. While ArgoCD is reconciling the ApplicationSet CR, it finds a reference to the infra-ops git repository embedded in the CR. OpenShift GitOps clones the repository and creates several ArgoCD Applications based on the contents of the components/ directory.
4. One of the Applications instructs ArgoCD to run the Helm chart in the openshift-actions-runner-chart with values specified in the infra-ops repository.
5. The Helm chart creates a Deployment for the GitHub Runner and some supporting kubernetes resources. This deployment:
   1. Has one long-running container, based on the ploigos-github-runner image.
   2. Includes the Ploigos Step Runner binary, which the runner will execute during CI/CD workflows.
   3. Has a volume for the working directories of running CI/CD workflows.
   4. Has a volume for a shared configuration file used by the PSR.
6. In response to another Application specified by the ApplicationSet, ArgoCD deploys the External Secrets operator. This is a controller process that responds to the creation of ExternalSecret CRs.
7. In response to another Application specified by the ApplicationSet, ArgoCD creates an ExternalSecret CR, which references secret values stored in Vault.
8. The External Secrets Operator continuously monitors for ExternalSecret CRs. It detects the ExternalSecret that ArgoCD created.
9. The External Secrets Operator responds by looking up the values of the secrets referenced in the ExternalSecret in Vault, and using those values to create a kubernetes Secret object. The Secret contains some of the configuration values for the PSR, but only the ones that are not specific to any one application.
10. The GitHub Runner Deployment references the Secret. OpenShift creates a Pod for the deployment, which remains in a Pending state until the Secret exists. When OpenShift detects that the Secret exists, OpenShift mounts the Secret as a volume in the Pod that has the GitHub Runner container.
11. When OpenShift finishes mounting volumes, it updates the status of the Pod to ImagePulling. It pulls the ploigos-github-runner image from Quay.io (we plan to support Artifactory in the future). This image was previously built from the code in the github-runners project.
12. When OpenShift finishes pulling images, it updates the status of the Pod to ContainerCreating. It starts a container based on the ploigos-github-runner image.
13. The entrypoint for the ploigos-github-image is a binary that knows how to communicate with GitHub, responding to events and executing workflows. The Runner begins by establishing a network connection with the GitHub Actions service. This could be GitHub.com or GitHub Enterprise.

## CI/CD Workflow
The infrastructure deployed using this repository is used as a platform for CI/CD workflows. This diagram shows how the 
various parts of the infrastructure interact when a CI/CD workflow is executed. 

![](docs/interaction-workflow-execution.svg)

1. A developer makes a change to the source code of the generic example application and pushes a commit to the java-github-example repository.
2. GitHub Actions detects the change as an event. It looks in the .github/workflows/ directory and finds a workflow definition that matches the event.
3. The java-github-example workflow definition references a shared workflow definition in the ploigos-github-workflow repository.
4. GitHub Actions consults its list of available GitHub Runners. It finds a self-hosted runner that previously connected to it. The runner is hosted on OpenShift. GitHub actions instructs the runner to execute the workflow based on the definitions in the java-github-example and ploigos-github-workflow repositories.
5. The workflow definition has many steps. Most of the steps tell the runner to execute the `psr` command. This command executes the Ploigos Step Runner. Each execution specifies the name of a step. The PSR handles the actual work done by the step (for example, building or pushing an image). The PSR might call additional tools to do the work (for example, running the buildah command).
6. Each time the PSR is executed, it reads its configuration from two places. The first place is a volume mount that has a configuration file, psr-shared.yml, which contains the contents of a Secret. It has values that are shared between all workflows, such as the authentication information for an enterprise container registry.
7. Each time the PSR is executed, it also reads configuration values from the application repository. Each application built by the PSR contains a file named psr.yml. This file has application-specific settings such as the name of the application and which tool should be used to run the unit tests (Maven or Tox).
8. Each time the PSR is executed, it performs some custom logic specific to the step. This might include executing another tool like buildah or Maven and/or communicating with an external service like Artifactory or Anchore.
9. Each time the PSR is executed, it writes the results of the step to a working directory. The last step publishes a report of the results.
10. Two of the steps build and push a new image of the application. Another step (not shown) creates or updates an ArgoCD Application which deploys the app to OpenShift.
11. After the workflow finishes, the GitHub Runner container exits (it's just a process, and has logic to do this). OpenShift detects this and starts a new container. This resets the state (filesystem) of the runner for the next run.

# How-To
* Use vault for secrets
  * Follow the [examples demo](examples/DEMO.md) 

* Set up of Artifactory after initial deployment 
  * Provide license key if prompted.
  * Add a docker registry called 'ploigos'. With the exception of docker tag retention, leave all defaults. Increase docker tag retention to the amount of tags you'd like to retain.
  * Add a new permission called 'ploigos' and give service account access to registry.

