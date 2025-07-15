# Cloud Build Trigger for Automated Packer Builds

This project provisions all necessary Google Cloud resources to establish a Cloud Build trigger that initiates an automated build process for a Packer repository on every push to the main branch in GitHub. The solution ensures secure integration between Google Cloud Build and GitHub using a GitHub App installation and manages all permissions required for build operations.

## Purpose

The Terraform configuration in this repository creates and configures the following:
- Service accounts and required IAM roles for Cloud Build and Packer operations (IAM Module)
- Secure access to secrets required for authentication with GitHub (Cloudbuild Module)
- Cloud Build V2 connection to GitHub using a GitHub App installation (Cloudbuild Module)
- Registration of the Packer repository with Cloud Build (Cloudbuild Module)
- Registration of the Webapp repository with Cloud Build (Cloudbuild Module)
- Cloud Build trigger that runs on pushes to the main packer image branch (Cloudbuild Module)
- Cloud Build trigger that runs on pushes to the main webapp branch (Cloudbuild Module)

## Prerequisites

Before deploying this Terraform configuration, ensure you have the following:
- A Google Cloud project with billing enabled
- A GitHub repository intended for Packer builds
- A GitHub App installed in your organization and its installation ID available
- A secret in Google Secret Manager containing the GitHub OAuth token for Cloud Build

## Required Variables

Define the following variables in your `terraform.tfvars` or as environment variables:

| Variable                     | Description                                                         |
|------------------------------|---------------------------------------------------------------------|
| `project_id`                 | The GCP project ID where resources are created                      |
| `connection_name`            | Name for the Cloud Build GitHub connection                          |
| `packer_remote_uri`          | HTTPS URI of the Packer GitHub repository                           |
| `webapp_remote_uri`          | HTTPS URI of the webapp repository (used in substitutions)          |
| `webapp_git_sha`             | Git commit SHA for the webapp repository                            |
| `build_region`               | GCP region for Cloud Build resources                                |
| `build_zone`                 | GCP zone used in build substitutions (Packer builds)                |
| `github_app_installation_id` | The GitHub App installation ID                                      |
| `gh_connect_secret_id`       | Secret Manager secret ID for GitHub OAuth token                     |
| `gh_connect_secret_name`     | Name of the Secret Manager secret containing the OAuth token        |

## Usage

1. Clone this repository to your local machine.
2. Define all required variables in a `terraform.tfvars` file.
3. Initialize Terraform:

   ```
   terraform init -backend-config=backend.tfbackend
   ```

4. Review the execution plan:

   ```
   terraform plan
   ```

5. Apply the configuration:

   ```
   terraform apply
   ```

After successful deployment, every push to the `main` branch of the specified Packer GitHub repository will trigger a Cloud Build process in your GCP project.

## Notes

- Ensure that the GitHub App has sufficient permissions on the repository and that the OAuth token stored in Secret Manager is valid.
- Adjust IAM roles and permissions as required to comply with your organization’s security policies.
- The configuration assumes use of Google Cloud Build V2 and GitHub App-based authentication.

## Utility Scripts

### scripts/cleanup_images.sh

This script manages Google Compute Engine images by retaining only the latest image in a specified image family and deleting all older images. This helps prevent unnecessary disk usage and clutter from outdated images.

**Functionality:**
- Identifies the latest image in the configured image family for the project.
- Lists all other images belonging to the family.
- Deletes each image that is not the latest.

**Usage:**
```
bash scripts/cleanup_images.sh
```
Modify the `FAMILY` and `PROJECT` variables in the script to match your environment if needed.

---

### scripts/set_gcp_credentials.sh

This script sets up a temporary Google Cloud credentials file by retrieving a service account key from a password manager using the `pass` utility. The temporary credentials file is automatically deleted when the session ends.

**Functionality:**
- Creates a temporary file for the service account credentials.
- Reads the key from the password manager and writes it to the file.
- Sets file permissions to restrict access.
- Registers a cleanup step to remove the file upon session exit.

**Usage:**
```
source scripts/set_gcp_credentials.sh
```
This command exports the `GOOGLE_APPLICATION_CREDENTIALS` environment variable for your shell session. Ensure you have the password manager set up and the appropriate secret stored.


## License

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
