Manual Steps at this Stage (automation is an open todo ;-))

- Login to Rancher on i.e. https://rancher.145.40.94.20.nip.io with the password you defined i.e. PaSsWoRd12345!!
- Create a Token for the User Admin - i.e. token-6xslt:sr28b26szbxprhw4kpdh5vzh766zsjl6fd8nmrjfrqnp87krh8wpzz
- Create Harvester Cluster with clustername "harvester" in Virtualization
- Copy Kubeconfig to Clipboard and save it to ../harvester-kubeconfig
- Copy Registration URL i.e. https://rancher.145.40.94.20.nip.io/v3/import/blgspbdlt5dq6cllj9ph8hv6fcnvl9d7rq67xlm6b7kbnv9bglt8d4_c-m-qqtvv7bb.yaml

- Login to Harvester as admin i.e. https://145.40.94.20/ with password "Suse12345678!!"
- Register Harvester to Rancher (advanced - settings - cluster-registration-url and add set URL from above and click on save)

