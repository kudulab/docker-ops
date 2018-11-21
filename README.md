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
  timeout 2 wget -O docker-ops --quiet http://http.archive.ai-traders.com/docker-ops/1.0.6/releaser || { echo "Cannot download docker-ops, ignoring"; rm -f ./docker-ops; }
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
  timeout 2 wget -O docker-ops --quiet http://http.archive.ai-traders.com/docker-ops/1.0.6/releaser || { echo "Cannot download docker-ops, ignoring"; rm -f ./docker-ops; }
fi
if [[ -f ./docker-ops ]];then
  source ./docker-ops
fi
if [[ ! -f ./releaser ]];then
  timeout 2 wget -O releaser --quiet http://http.archive.ai-traders.com/releaser/1.0.6/releaser || { echo "Cannot download releaser, ignoring"; rm -f ./releaser; }
fi
if [[ -f ./releaser ]];then
  source ./releaser
  releaser_init
fi

command="$1"
case "${command}" in
  build)
      docker_build "${image_dir}" "${imagerc_filename}" "${image_name}" "$2"
      exit $?
      ;;
  publish)
      source_imagerc "${image_dir}"  "${imagerc_filename}"
      production_image_tag="$(get_next_oversion)"
      docker_push "${AIT_DOCKER_IMAGE_NAME}" "${AIT_DOCKER_IMAGE_TAG}" "${production_image_tag}"
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
