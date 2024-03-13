Open Points:
----------------------
- fix registry proxy caching images
- fix kubeconfig for user in harvester csi problem (proxy access for harvester CSI/CPI) - need engineering help, here
  -> why can't a downstream cluster not reach the rancher-vcluster? (Just via proxy)?
- file tune slides
- file tune attendee and instructur guide
- add further automation
- application with load balancer
- Add Windows Machine Image?
- Open issue: harvester CPI can not use proxy - so can not use rancher kubeconfig in CPI/CSI

Instructure Preparation
-----------------------

On a machine with internet connectivity:

git clone git@github.com:Martin-Weiss/terraform-cfl.git

-----------------------
cd 1-harvester
-----------------------
terraform init
cp terraform.tfvars.examlpe to terraform.tfvars
vi terraform.tfvars

> adjust variables to your requirements
- ssh key of your local user
- data center
- node count
- iPXE script source
- etc...

Add your equinix token to ../.metal_auth_token

echo -n "your <equnix token" > ../.metal_auth_token

Plan and apply:

terraform init
terraform plan
terraform apply

Wait - and document the output for harvester_ip, harvester_url (FQDN) and rancher_url (FQDN)

harveser_vip=145.40.94.20
harvester_url= <i.e. https://145.40.94.20/>
rancher_url= <i.e. https://rancher.145.40.94.20.nip.io

Hint: on a Mac modify the ../harvester-rke2.yaml 127.0.0.1 -> harvester_url IP manually

For testing - you can check with kubectl if all nodess are joined

export KUBECONFIG=../harvester-rke2.yaml
kubectl get nodes

-> wait until all three are joined as otherwise rancher-vcluster will not be running

-----------------------
cd ../2-rancher
-----------------------
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars

> adjust variables to your environment
- harveser VIP - from output of 1-harvester apply (IP in harvester_vip) i.e. 145.40.94.20
- password - this is the rancher bootstrap password you want to set i.e. PaSsWoRd12345!!

terraform init
terraform plan
terraform apply

Wait until rancher-vcluster is running

export KUBECONFIG=../harvester-rke2.yaml
kubectl get pods -n rancher-vcluster

-----------------------
cd ../3-harvester-rancher-integration
-----------------------
cat readme.md

Follow the instructions for the harvester <-> rancher integration: 

<SNIP>
Manual Steps at this Stage (automation is an open todo ;-))

- Login to Rancher on i.e. https://rancher.145.40.94.20.nip.io with the password you defined i.e. PaSsWoRd12345!!
- Create a Token for the User Admin - i.e. token-6xslt:sr28b26szbxprhw4kpdh5vzh766zsjl6fd8nmrjfrqnp87krh8wpzz
- Create Harvester Cluster with clustername "harvester" in Virtualization
- Copy Kubeconfig to Clipboard and save it to ../harvester-kubeconfig
- Copy Registration URL i.e. https://rancher.145.40.94.20.nip.io/v3/import/blgspbdlt5dq6cllj9ph8hv6fcnvl9d7rq67xlm6b7kbnv9bglt8d4_c-m-qqtvv7bb.yaml

echo -n '<rancher_api_url>' > ../.rancher_api_url
echo -n '<rancher_bearer_token>' > ../.rancher_bearer_token

- Login to Harvester as admin i.e. https://145.40.94.20/ with password "Suse12345678!!"
- Register Harvester to Rancher (advanced - settings - cluster-registration-url and add set URL from above and click on save)
</SNIP>

-----------------------
cd ../4-harvester-infra
-----------------------

cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply

-----------------------
cd ../5-harvester-dhcpd
-----------------------

terraform init
terraform plan
terraform apply

-----------------------
cd ../6-user-projects
-----------------------

cp terraform.tfvars.example terraform.tfvars

vi terraform.tfvars
- adjust password

terraform init
terraform plan
terraform apply

-----------------------
cd ../7-downstream-infra
-----------------------

cp terraform.tfvars.example terraform.tfvars

vi terraform.tfvars
- adjust image if needed

terraform init
terraform plan
terraform apply

-----------------------
cd ../8-downstream-cluster
-----------------------

cp terraform.tfvars.example terraform.tfvars

vi terraform.tfvars
- namespace
- image
- clustername
- vlan

Run the following to create a csi-kubeconfig:
bash create-csi-kubeconfig.sh

terraform init
terraform plan
terraform apply
