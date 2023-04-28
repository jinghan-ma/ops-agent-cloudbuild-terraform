provider "google" {
  project     =  "oss-terraform-jinghanma"
  region      = "us-central1"
}

resource "google_project" "codelab_project" {
  project_id      = "oss-terraform-jinghanma"
  name            = "oss-terraform-jinghanma"
  billing_account = "************"

  # This is the ID for /experimental, see go/experimental-folder.
  # In particular, please accept go/experimental-folder#tos.
  # If you are not eligible for creating a project, ask a fellow engineer
  # and see go/terraform-codelab#import-existing-project for importing it.
  folder_id = "********"

  lifecycle {
    # Stop any terraform plan which would destroy this GCP project.
    prevent_destroy = true
  }
}

# Grants your team permission to view this GCP project.
resource "google_project_iam_member" "codelab_iam_member" {
  project = google_project.codelab_project.project_id
  role    = "roles/viewer"

  member = "group:sdi-diagnostics-dev@google.com"
}

# Enable the Compute Engine API.
resource "google_project_service" "codelab_compute_service" {
  project = google_project.codelab_project.project_id
  service = "compute.googleapis.com"
}

resource "google_compute_instance" "vm_instance_public" {
  name         = "rhel-8"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  tags         = ["rhel"]
  project      = google_project.codelab_project.project_id
  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
  boot_disk {
    initialize_params {
      image = "rhel-cloud/rhel-8"
    }
  }
}

module "rhel_agent_policy" {
  source     = "terraform-google-modules/cloud-operations/google//modules/agent-policy"
  version    = "0.2.4"

  project_id = google_project.codelab_project.project_id
  policy_id  = "rhel-ops-agents-policy"
  agent_rules = [
    {
      type               = "ops-agent"
      version            = "latest"
      package_state      = "installed"
      enable_autoupgrade = true
    },
  ]
  group_labels = [
    {
      ops-agent  = "true"
    }
  ]
    os_types = [
    {
      short_name = "rhel"
      version    = "8"
    }
  ]
}
