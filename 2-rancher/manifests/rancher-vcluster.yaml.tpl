apiVersion: harvesterhci.io/v1beta1
kind: Addon
metadata:
  name: rancher-vcluster
  namespace: rancher-vcluster
  labels:
    addon.harvesterhci.io/experimental: "true"
spec:
  enabled: true
  repo: https://charts.loft.sh
  version: "v0.19.0"
  chart: vcluster
  valuesContent: |-
    hostname: "${rancher-hostname}"
    rancherVersion: "v2.8.2"
    bootstrapPassword: "${rancher-password}"
    vcluster:
      image: rancher/k3s:v1.27.10-k3s2
    sync:
      ingresses:
        enabled: "true"
    init:
      manifestsTemplate: |-
        apiVersion: v1
        kind: Namespace
        metadata:
          name: cattle-system
        ---
        apiVersion: v1
        kind: Namespace
        metadata:
          name: cert-manager
          labels:
            certmanager.k8s.io/disable-validation: "true"
        ---
        apiVersion: helm.cattle.io/v1
        kind: HelmChart
        metadata:
          name: cert-manager
          namespace: kube-system
        spec:
          targetNamespace: cert-manager
          repo: https://charts.jetstack.io
          chart: cert-manager
          version: v1.5.1
          helmVersion: v3
          set:
            installCRDs: "true"
        ---
        apiVersion: helm.cattle.io/v1
        kind: HelmChart
        metadata:
          name: rancher
          namespace: kube-system
        spec:
          targetNamespace: cattle-system
          repo: https://releases.rancher.com/server-charts/stable/
          chart: rancher
          version: {{ .Values.rancherVersion }}
          set:
            ingress.tls.source: rancher
            hostname: {{ .Values.hostname }}
            replicas: 1
            global.cattle.psp.enabled: "false"
            bootstrapPassword: {{ .Values.bootstrapPassword | quote }}
          helmVersion: v3
