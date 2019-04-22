# docker-ops

Bash scripts to release docker images.

## Install
All the docker-ops functions are available after you install it.

### In current shell
If you want to run docker-ops in current shell:
```bash
docker_ops::loaded || eval "$(curl https://github.com/kudulab/docker-ops/releases/download/${DOCKER_OPS_VERSION}/docker-ops)"
```
 Do not use it in a script as it would always redownload the file.

### In a script

If you want to run docker-ops from a script:
```bash
DOCKER_OPS_VERSION="2.0.0"
DOCKER_OPS_FILE="ops/docker-ops-${DOCKER_OPS_VERSION}"

mkdir -p ops
if [[ ! -f $DOCKER_OPS_FILE ]];then
  wget --quiet -O $DOCKER_OPS_FILE https://github.com/kudulab/docker-ops/releases/download/${DOCKER_OPS_VERSION}/docker-ops
fi
source $DOCKER_OPS_FILE
```

### Validate that loaded

To validate that releaser functions are loaded use: `docker_ops::loaded` function
or any other docker-ops function.

### Dependencies
* Bash
* Docker

## Usage
Recommended usage for a project:
Provide `./tasks` file with bash `case` (switch). It will allow to run
 a limited amount of commands).

At the top of file download supporting docker-ops script:
```bash
#!/bin/bash
set -e

DOCKER_OPS_VERSION="2.0.0"
DOCKER_OPS_FILE="ops/docker-ops-${DOCKER_OPS_VERSION}"

mkdir -p ops
if [[ ! -f $DOCKER_OPS_FILE ]];then
  wget --quiet -O $DOCKER_OPS_FILE https://github.com/kudulab/docker-ops/releases/download/${DOCKER_OPS_VERSION}/docker-ops
fi
source $DOCKER_OPS_FILE
```

Define basic information

```
image_dir="image"
imagerc_filename="imagerc"
image_registry="docker-registry.example.com"
image_name="myimg"
```

Tasks for building and testing the image could look like this:
```bash
command="$1"
case "${command}" in
  build)
      image_tag=$(git rev-parse HEAD)
      # build image and push to a test registry
      docker_ops::docker_build "${image_dir}" "${imagerc_filename}" "${image_name}" "${image_tag}" "${image_registry}"
      docker_ops::push "${image_dir}" "${imagerc_filename}"
      ;;
  test)
      docker_ops::ensure_pulled_image "${image_dir}" "${imagerc_filename}"
      echo "Testing image: ${KUDU_DOCKER_IMAGE_URL}"
      time bats --pretty "$(pwd)/test/integration/bats"
      ;;
  *)
      echo "Invalid command: '${command}'"
      exit 1
      ;;
esac
set +e
```


### Docker-ops functions
The docker-ops functions should be documented in code, there is no sense to repeat it here.

You can set these environment variables:
  * `DOCKER_OPS_LOG_LEVEL=debug` for more log messages.

#### Image URLs

There are 2 useful functions to create image references.
```sh
image_name="$(docker_ops::make_image_name $image_short_name $image_registry)"
```
Creates image name with registry but no tag.


```sh
image_url="$(docker_ops::make_image_url $image_short_name $image_tag $image_registry)"
```
Creates full url to the image - registry, name and tag.

When `image_registry=dockerhub` then image name prefix with registry is skipped.

## Development

### Lifecycle
1. In a feature branch:
  * you make changes
  * and run tests:
     * `./tasks itest`
1. You decide that your changes are ready and you:
  * merge into master branch
  * run locally:
    * `./tasks set_version` to set version in CHANGELOG while bumping patch version
    * e.g. `./tasks set_version 1.2.3` to set version in CHANGELOG
  * push to master onto private git server
1. CI server (GoCD) tests and releases.
