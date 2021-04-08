# Readme

This repository contains templates for creating CD pipelines that execute deploys based off of [cepler](https://github.com/bodymindarts/cepler) managed config files.

The templates are rendered via mounting a directory containing 2 files (`cepler.yml` + `ci.yml`) and executing the docker image `bodymindarts/cepler-templates`.
```
docker run -v $(pwd)/examples/github-ytt-kapp:/workspace/inputs -it bodymindarts/cepler-templates:latest
name: cepler-deploy
"on":
- push
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        ref: main
        fetch-depth: 0
        persist-credentials: false
    - id: prepare-cepler
      uses: bodymindarts/cepler-action@main
      with:
        config_path: examples/github-ytt-kapp/cepler.yml
        environment: staging
        prepare: true
    - if: ${{ steps.prepare-cepler.outputs.needs_deploying == 'true' }}
      uses: k14s/setup-k14s-action@v1
      with:
        only: ytt, kapp
    - if: ${{ steps.prepare-cepler.outputs.needs_deploying == 'true' }}
      run: ytt -f examples/ytt-k8s > rendered.yml
    - if: ${{ steps.prepare-cepler.outputs.needs_deploying == 'true' }}
      run: cat rendered.yml
    - if: ${{ steps.prepare-cepler.outputs.needs_deploying == 'true' }}
      id: deploy-staging
      env:
        KAPP_KUBECONFIG_YAML: '{"apiVersion":"v1","clusters":[{"cluster":{"certificate-authority-data":"testflight.ca","server":"testflight.server"},"name":"staging"}],"contexts":[{"context":{"cluster":"staging","user":"staging-user"},"name":"staging"}],"current-context":"staging","kind":"Config","preferences":{},"users":[{"name":"staging-user","user":{"token":"token"}}]}'
      run: kapp -y deploy -f rendered.yml -a testflight
    - if: ${{ steps.deploy-staging.conclusion  == 'Success' }}
      name: cepler record
      uses: bodymindarts/cepler-action@main
      with:
        config_path: examples/github-ytt-kapp/cepler.yml
        environment: staging
        record: true
    - if: ${{ steps.deploy-staging.conclusion  == 'Success' }}
      name: Push changes
      uses: ad-m/github-push-action@master
      with:
        github_token: dummy
        branch: main
  deploy-production:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        ref: main
        fetch-depth: 0
        persist-credentials: false
    - id: prepare-cepler
      uses: bodymindarts/cepler-action@main
      with:
        config_path: examples/github-ytt-kapp/cepler.yml
        environment: production
        prepare: true
    - if: ${{ steps.prepare-cepler.outputs.needs_deploying == 'true' }}
      uses: k14s/setup-k14s-action@v1
      with:
        only: ytt, kapp
    - if: ${{ steps.prepare-cepler.outputs.needs_deploying == 'true' }}
      run: ytt -f examples/ytt-k8s > rendered.yml
    - if: ${{ steps.prepare-cepler.outputs.needs_deploying == 'true' }}
      run: cat rendered.yml
    - if: ${{ steps.prepare-cepler.outputs.needs_deploying == 'true' }}
      id: deploy-production
      env:
        KAPP_KUBECONFIG_YAML: '{"apiVersion":"v1","clusters":[{"cluster":{"certificate-authority-data":"staging.ca","server":"staging.server"},"name":"production"}],"contexts":[{"context":{"cluster":"production","user":"production-user"},"name":"production"}],"current-context":"production","kind":"Config","preferences":{},"users":[{"name":"production-user","user":{"token":"token"}}]}'
      run: kapp -y deploy -f rendered.yml -a staging
    - if: ${{ steps.deploy-production.conclusion  == 'Success' }}
      name: cepler record
      uses: bodymindarts/cepler-action@main
      with:
        config_path: examples/github-ytt-kapp/cepler.yml
        environment: production
        record: true
    - if: ${{ steps.deploy-production.conclusion  == 'Success' }}
      name: Push changes
      uses: ad-m/github-push-action@master
      with:
        github_token: dummy
        branch: main
```

## Configuration

The templates work by combining a `driver`, `processor` and `executor`.
Which of these to use are specified in the `ci.yml` file:
```
$ cat examples/github-ytt-kapp/ci.yml
cepler:
  config: examples/github-ytt-kapp/cepler.yml # Path to `cepler.yml` relative to the repo root.

driver:
  type: github                                # Driver type `github` and `concourse` supported
  repo:
    branch: main
    access_token: dummy

processor:
  type: ytt                                   # Processor type `ytt` supported
  files:
  - examples/ytt-k8s

executor:
  type: kapp                                  # Executor type `kapp` supported
  environments:                               # Environments key must contain the same environments as in `cepler.yml`
    staging:                                  # Creds for accessing the staging environment k8s
      app_name: testflight
      ca_cert: testflight.ca
      namespace: testflight
      server: testflight.server
      token: token
    production:
      app_name: staging
      ca_cert: staging.ca
      namespace: staging
      server: staging.server
      token: token
```

## Examples

Please have a look at the (examples)[./examples] for more information.
