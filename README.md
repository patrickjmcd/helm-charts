## Welcome to patrickjmcd Helm Catalog

## Usage

```Shell
helm repo add patrickjmcd https://patrickjmcd.github.io/helm-charts
```

-   do not forget to add a VPC for volumes.

## Helmfile Sample

```yaml
repositories:
  - name: patrickjmcd
    url: https://patrickjmcd.github.io/helm-charts

releases:
  - name: xavier-emby
    namespace: xavier
    chart: patrickjmcd/emby
    version: 0.2.0
    values:
          - image:
              tag: 3.6.0.2
          - ingress:
            enabled: true
            hosts:
              - emby.patrickjmcd.org
            tls:
              - hosts:
                  - emby.patrickjmcd.org
                secretName: emby-patrickjmcd.org

  - name: xavier-sftp
    namespace: xavier
    chart: patrickjmcd/sftp
    version: 0.2.0
    values:
        - image:
            tag: latest
            args: "foo:password:1000"
        - volumeMounts:
          - name: myvolume
            mountPath: "/home/foo"
```

## Adding a new chart

1. Build the charts & repo

```Shell
helm lint <new-chart-folder>
helm package <new-chart-folder>
helm repo index --url https://patrickjmcd.github.io/helm-charts .
```

2. Push to github
