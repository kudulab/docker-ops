# docker-ops

Bash functions to support release cycle of docker images.

## Why and features

 * `docker-ops` is a single file, versioned and released after testing the functions
 * Any project can quickly and easily reference the functions by downloading a specific release from github
 * The `docker-ops` file is easy to review and hack with, there is no magic framework to learn, just plain bash and docker commands. When something does not fit your needs, it is easy to fall back to writing your own script.
 * It works on nearly any setup because of minimal dependencies

Use the functions as you like, but the primary goal is to support following **lifecycle of docker images**:
1. Build image from source code and tag it with the git sha256 of the origin commit. Push this image to docker registry. We call it the *temp* image.
   * Supporting function is `docker_ops::docker_build`.
   * `docker_ops::docker_build` produces 3 [`imagerc` files](#imagerc-files), each has the same data in different format (JSON, YAML, bash). It contains critical information about the built image - the docker registry, image name, image tag.
2. Pull the *temp* image (if not available locally) with `docker_ops::ensure_pulled_image`. Test the image to ensure desired level of quality. Use the right tools for the job, `docker-ops` has nothing to do with this step.
3. Release the code by git tagging the repository with a semantic version. (This is handled by the [releaser](https://github.com/kudulab/releaser))
4. Publish the image by tagging the previously built image with a semantic version and pushing the new tag to docker registry.

A full-blown example of this lifecycle can be found in:
 * [docker-terraform-dojo](https://github.com/kudulab/docker-terraform-dojo)
 * [docker-hugo-dojo](https://github.com/kudulab/docker-hugo-dojo)

### Imagerc files

Imagerc is a unambiguous reference to the docker image. It is produced in 3 formats for compatibility with any tools.

Terms and content of the imagerc:
 * The **docker registry** is the prefix before docker image name, except for `dockerhub` case when it should be skipped in image name. `docker-ops` handles this case.
 * **Image short name** is the path after docker registry url, without the image tag
 * **Image name** is the docker registry and short name
 * **Image tag** is the part after `:` in the docker image url
 * **Image url** is the full unambiguous reference to the docker image

`imagerc` is meant to be sourced by bash. Example content:
```bash
export KUDU_DOCKER_REGISTRY="dockerhub"
export KUDU_DOCKER_IMAGE_SHORT_NAME="kudulab/hugo-dojo"
export KUDU_DOCKER_IMAGE_NAME="kudulab/hugo-dojo"
export KUDU_DOCKER_IMAGE_TAG="77db9e541c4eac7fa751ae56672c706613effba4"
export KUDU_DOCKER_IMAGE_URL="kudulab/hugo-dojo:77db9e541c4eac7fa751ae56672c706613effba4"
```

`imagerc.json` - Example content:
```json
{
"docker_registry": "dockerhub",
"docker_image_short_name": "kudulab/hugo-dojo",
"docker_image_name": "kudulab/hugo-dojo",
"docker_image_tag": "77db9e541c4eac7fa751ae56672c706613effba4",
"docker_image_url": "kudulab/hugo-dojo:77db9e541c4eac7fa751ae56672c706613effba4"
}
```

`imagerc.yml` - Example content:
```yaml
---
docker_registry: "dockerhub"
docker_image_short_name: "kudulab/hugo-dojo"
docker_image_name: "kudulab/hugo-dojo"
docker_image_tag: "77db9e541c4eac7fa751ae56672c706613effba4"
docker_image_url: "kudulab/hugo-dojo:77db9e541c4eac7fa751ae56672c706613effba4"
```

## Install
All the docker-ops functions are available after sourcing it.

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

### In current shell
If you want to run docker-ops in current shell:
```bash
docker_ops::loaded || eval "$(curl https://github.com/kudulab/docker-ops/releases/download/${DOCKER_OPS_VERSION}/docker-ops)"
```
 Do not use it in a script as it would always redownload the file.


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

Define basic information about the image

```bash
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

## License

Copyright 2019 Ewa Czechowska, Tomasz Sętkowski

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
