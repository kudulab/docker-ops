# docker-ops

Bash scripts to release docker images.

## Install
All the docker-ops functions are available after you install it.

### In current shell
If you want to run docker-ops in current shell:
```bash
docker_ops::loaded || eval "$(curl http://archive.ai-traders.com/docker-ops/0.1.0/docker-ops)"
```
 Do not use it in a script as it would always redownload the file.

### In a script

If you want to run docker-ops from a script:
```bash
if [[ ! -f ./docker-ops ]];then
  timeout 2 wget -O docker-ops --quiet http://http.archive.ai-traders.com/docker-ops/0.2.4/docker-ops || { echo "Cannot download docker-ops, ignoring"; rm -f ./docker-ops; }
fi
if [[ -f ./docker-ops ]];then
  source ./docker-ops
fi
```

### Validate that loaded

To validate that releaser functions are loaded use: `docker_ops::loaded` function
or any other docker-ops function.

### Dependencies
* Bash
* Docker

## Usage
Recommended usage for a project:
1. Provide `./tasks` file with bash `case` (switch). It will allow to run
 a limited amount of commands). Example:
```bash
#!/bin/bash

set -e
if [[ ! -f ./docker-ops ]];then
  timeout 2 wget -O docker-ops --quiet http://http.archive.ai-traders.com/docker-ops/0.3.0/docker-ops || { echo "Cannot download docker-ops, ignoring"; rm -f ./docker-ops; }
fi
if [[ -f ./docker-ops ]];then
  source ./docker-ops
fi
if [[ ! -f ./releaser ]];then
  timeout 2 wget -O releaser --quiet http://http.archive.ai-traders.com/releaser/1.0.8/releaser || { echo "Cannot download releaser, ignoring"; rm -f ./releaser; }
fi
if [[ -f ./releaser ]];then
  source ./releaser
  releaser_init
fi

image_dir="image"
imagerc_filename="imagerc"
image_registry="docker-registry.ai-traders.com"
image_name="myimg"

command="$1"
case "${command}" in
  build)
      image_tag=$(git rev-parse HEAD)
      # build image1 and push to a test registry1
      ( set -x; cd "${image_dir1}"; docker build -t "${image_name}:${image_tag}" .; )
      docker_ops::create_imagerc "${image_dir}" "${imagerc_filename}" "${image_name}" "${image_tag}" "${image_registry}"
      docker_ops::push_tmp "${image_name}" "${image_tag}" "${image_registry}"
      ;;
  test)
      docker_ops::ensure_temp_image "${image_dir}" "${imagerc_filename}"
      echo "Testing image: ${AIT_DOCKER_IMAGE_URL}"
      time bats --pretty "$(pwd)/test/integration/bats"
      ;;
  example)
      docker_ops::ensure_temp_image "${image_dir}" "${imagerc_filename}"
      echo "Testing image: ${AIT_DOCKER_IMAGE_URL}"
      docker run -ti --rm ${AIT_DOCKER_IMAGE_URL}
      ;;
  publish)
      version=$(get_last_version_from_changelog "${changelog_file}")
      # push production image1 to image_registry1
      docker_ops::push_production "${image_name}" "${version}" "${image_registry}" "${image_dir}"  "${imagerc_filename}"
      exit $?
      ;;
  *)
      echo "Invalid command: '${command}'"
      exit 1
      ;;
esac
set +e
```

Now you can run:
```bash
./tasks build
./tasks test
./tasks example
./tasks publish
```

### Docker-ops functions
The docker-ops functions should be documented in code, there is no sense to repeat it here.

You can set those environment variables:
  * `ops_docker_push=true` to include docker push after building docker image.
  * `RELEASER_LOG_LEVEL=debug` for more log messages.

## Development

### Lifecycle
1. In a feature branch:
 * you make changes
 * and run tests:
     * `./tasks itest`
1. You decide that your changes are ready and you:
 * merge into master branch
 * run locally:
   * `./tasks set_version` to set version in CHANGELOG and chart version files to
   the version from OVersion backend
   * e.g. `./tasks set_version 1.2.3` to set version in CHANGELOG and chart version
    files and in OVersion backend to 1.2.3
 * push to master onto private git server
1. CI server (GoCD) tests and releases.

Releaser uses itself, which is treated as true integration test.
