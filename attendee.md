Attendee Instructions
-----------------------

Install git-utils (git client), terraform, osc, kubectl, gsed and jq (on mac)

git clone git@github.com:Martin-Weiss/terraform-cfl.git

- Login to Rancher on i.e. https://rancher.145.40.94.20.nip.io with the password for your user i.e. Suse12345678!!
- Create a Token for your User - i.e. token-6xslt:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Document rancher_api_url

-----------------------
Create Account and Image in Open Build Service - and let it build
-----------------------

Access https://build.opensuse.org/
Create a user and login

Go to https://build.opensuse.org/image_templates and Build an image

Adjust Software  - enable profile "cloud", add packages cloud-init and iptables
Save / Save
Check "Building"
Click on images / repositories and ensure "Publish" is enabled

Adjust config.sh and Minimal.kiwi (example see git repo in the path "obs-image")
Rebuild

Get the URL to the image from the images - go to download repository

Hint: in case you do not want to do this - use the image https://download.opensuse.org/repositories/home:/mweiss2:/branches:/SUSE:/Templates:/Images:/SLE-15-SP5/images/SLES15-SP5-Minimal-VM.x86_64-Cloud-Build5.2.qcow2
 
-----------------------
cd 9a-user-infra
-----------------------

cp -av terraform.tfvars.example terraform.tfvars

vi terraform.tfvars
- adjust rancher_api_url
- adjust namespace (should be identical to your user)
- adjust rancher_bearer_token
- adjust image name (should be identical to your user)

terraform init
terraform plan
terraform apply

-----------------------
cd ../9b-user-downstream-cluster
-----------------------
WORKAROUND FOR PROXY PROBLEM in the lab:
- copy the harvester-kubeconfig from the instructur to ../harvester-kubeconfig!!

cp -av terraform.tfvars.example terraform.tfvars

vi terraform.tfvars
- adjust rancher_api_url
- adjust rancher_bearer_token
- adjust namespace (should be identical to your user)
- adjust cluster name (use the same name as your username)
- adjust the VLAN to the one you want to use (vlan-1000, vlan-1001, vlan-1002 or vlan-1003)

create csi-kubeconfig via the following command:

bash create-csi-kubeconfig.sh

terraform init
terraform plan
terraform apply

-----------------------
Deploy and access monitoring in your downstream cluster
-----------------------

Login to rancher
Deploy monitoring via apps
- enable persistent storage with prometheus and select retention 5 GiB and set size 10G using harvester storage class

Check if you can access grafana dashboard 
