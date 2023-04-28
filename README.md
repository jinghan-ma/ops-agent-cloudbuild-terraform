# Ops Agent Terraform using CloudBuild

Provides a sample `cloudbuild.yaml` and terraform config for installing Ops Agent in Cloudbuild.

Note that, I was using a community cloud builder image found here: https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/terraform

You will have to clone the directory and build the builder first by `cd`ing to the directory and running `gcloud builds submit --config=cloudbuild.yaml`. This will add a terraform builder into your project.
