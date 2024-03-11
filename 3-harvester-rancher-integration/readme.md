Manual Steps at this Stage (automation is an open todo ;-))

- Login to Rancher
- Create Harvester Cluster in Virtualization
- Copy Registration URL
- Create a Token for the User Admin

- Login to Harvester
- Register Harvester to Rancher (edit config and add copied URL)
- Go to Rancher and get Kubeconfig
- Store the Kubeconfig in ../harvester-kubeconfig

- Adjust terraform.tfvars in following terraform projects based on above (Rancher URL, Baerer Token)
