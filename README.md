# Custom Cloud Workstation Building Pipeline

This repo contains:

- `./image` - the Dockerfile, Cloud Build pipeline definition and necessary assets to build a custom Cloud Workstation image
- `./infra` - the Terraform automation to create the necessary infrastructure to make the automated build possible
- `./run_pipeline.bash` - a script to manually trigger the Cloud Build pipeline so a new version of the workstation image can be built

## Manually build a new version

To manually build a new version of the workstation, run the Cloud Build pipeline in `./image/cloudbuild.yaml` using the ready made script `build-pipeline.bash`:

```bash
./run_pipeline.bash
```

## Building upon changes

Any change made to the `./image` directory will trigger a new build of the workstation image when pushed to the git repository.
