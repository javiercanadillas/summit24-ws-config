# My custom Cloud Workstations image

The idea is to get this repo synced with Cloud Source Repositories (in a repo called `javiercm-main-dev/javiercm-custom-cw-image`) and have a Cloud Build trigger to build the image and push it to Artifact Registry, where the image will be used deploy a custom Cloud Workstatation running Code OSS + Microsoft VSCode Marketplace extensions like Copilot.

I'm using the already created Cloud Workstations Cluster named `main-cluster`, with a config named `main-config` and a custom image named `main-image`.

## Quick steps - Manually build a new version

To manually build a new version of the workstation, run the Cloud Build pipeline in `./image/cloudbuild.yaml` using the ready made script `build-pipeline.bash`:

```bash
./run_pipeline.bash
```

The script will take some time to run. Once finished, there should be a new Workstation Container Image in Artifact Registry tagged as `latest` (`europe-west1-docker.pkg.dev/javiercm-main-dev/custom-cw-images/custom-ws-image:latest`), which is the tag that the workstation configuration (called `custom-test`) is using. 

Go to the Workstation Configuration, stop the workstation, and start it again. It should pick up the new container image.

## Configuration of the whole thing (WIP)

These are the steps I followed to get this working:

Create a Cloud Source Repository to hold the custom image config:
```bash
gcloud source repos create custom-cw-image
```

Create a workstations service account:
```bash
gcloud iam service-accounts create custom-cw-runner-sa --description="Cloud Workstation main config service account"
```

Grant the permissions to the Cloud Workstation runner account:
```bash
roles_list=( 'roles/workstations.operationViewer' 'roles/workstations.workstationCreator' 'roles/artifactregistry.reader' 'roles/iap.tunnelResourceAccessor' 'roles/artifactregistry.admin' 'roles/storage.objectUser' 'roles/logging.logWriter' )
for role in "${roles_list[@]}"; do
gcloud projects add-iam-policy-binding javiercm-main-dev --member="serviceAccount:custom-cw-runner-sa@javiercm-main-dev.iam.gserviceaccount.com" --role="$role" --condition=None
done
```

Update the existing Workstation Config to use the new service account:
```bash
gcloud workstations configs update main-config \
  --service-account=custom-cw-runner-sa@javiercm-main-dev.iam.gserviceaccount.com \
  --cluster=main-cluster \
  --region=europe-west1
```

Create the CB Service Account:
```bash
gcloud iam service-accounts create custom-cw-cb-sa --description="Cloud Workstation custom image creation Cloud Build pipeline"
```

Grant the permission to CB SA to manage workstations configs: 
```bash
roles_list=( 'roles/workstations.admin' 'roles/artifactregistry.admin' 'roles/storage.objectUser' 'roles/logging.logWriter' )
for role in "${roles_list[@]}"; do
  gcloud projects add-iam-policy-binding javiercm-main-dev \
    --member="serviceAccount:custom-cw-cb-sa@javiercm-main-dev.iam.gserviceaccount.com" \
    --role="$role" --condition=None
done
```

Create an Artifact Registry repo to hold the workstations images:
```bash
gcloud artifacts repositories create custom-cw-images \
  --repository-format=docker \
  --location=europe-west1 \
  --description="Custom Cloud Workstations images"
```

Create a trigger:
```bash
CUSTOM_CW_IMAGE_REPO_NAME="custom-cw-images"
gcloud beta builds triggers create cloud-source-repositories \
  --region=europe-west1 \
  --repo="$CUSTOM_CW_IMAGE_REPO_NAME" \
  --branch-pattern=main \
  --build-config=cloudbuild.yaml \
  --service-account=projects/javiercm-main-dev/serviceAccounts/custom-cw-cb-sa@javiercm-main-dev.iam.gserviceaccount.com \
  --substitutions=_CW_CONFIG_NAME="main-config",_ARTIFACT_REGISTRY_BASE_URL="europe-west1-docker.pkg.dev/javiercm-main-dev/$CUSTOM_CW_IMAGE_REPO_NAME",_IMAGE_NAME="custom-codeoss-cw"
```

Test the pipeline running from your local Mac on your Argolis project:

```bash
bash -x run_pipeline.bash
```


# To Do
- Do `image/scripts/install` installation scripts to separate installation of instructions and other things into atomic scripts.
- Package `bash_prompt` into a separate GitHub repo so I can pull the dependency each time I need a bash_promt for any of my machines. The script should consider if I'm running a workstation so it doesn't use UTF-8 characters in the prompt that don't render properly inside the Code OSS integrated terminal.

# New Instructions

## Set up the infrastructure

Set the required environment variables and create the `terraform.tfvars` file:

```bash
cd infra
cp terraform.tfvars.dist terraform.tfvars
export GCP_PROJECT_ID="your-project-id"
export GCP_USER_EMAIL="your GCP user email"
envsubst < terraform.tfvars.dist > terraform.tfvars
```

Run the Terraform infrastructure provisioning:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Check the outputs of the Terraform provisioning and set the environment variables accordingly:

```bash
export CSR_REPO_NAME="$(terraform output csr_repo_name)"
export IMAGE_REGISTRY_URL="$(terraform output image_registry_url)"
export WS_IMAGE_NAME="$(terraform output ws_image_name)"
export WS_CONFIG_ID="$(terraform output ws_config_id)"
envsubst < terraform.env.dist > terraform.env
source terraform.env
```

## Set up the Google Source Repository as remote

Make sure you have the `gcloud` CLI tool installed and configured with the right project, and that you're logged in with the right user:

```bash
gcloud config set project $GCP_PROJECT_ID
gcloud auth login
```

Then, configure Git to use the gcloud cli as credential helper:
```bash
git config --global credential.'https://source.developers.google.com'.helper gcloud.sh
```

Finally, add the Google Source Repository as a remote:
```bash
git remote add google "https://source.developers.google.com/p/${GCP_PROJECT_ID}/r/${CSR_REPO_NAME}"
```

Add the changes and push to the remote:
```bash
git add .
git commit -m "Initial commit"
git push google main
```
