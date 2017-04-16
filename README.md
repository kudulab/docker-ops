# docker-ops

Bash scripts to release docker images.

## Install
All the docker-ops functions are available after you install it.

### In current shell
If you want to run releaser in current shell:
```bash
docker_ops_loaded || eval "$(curl http://archive.ai-traders.com/docker-ops/0.1.3/docker-ops)"
```
 Do not use it in a script as it would always redownload the file.

### In a script

If you want to run docker-ops from a script:
```bash
if [[ ! -f ./docker-ops ]];then
  wget http://archive.ai-traders.com/docker-ops/0.1.3/docker-ops || { echo "failed to wget docker-ops"; exit 1; }
fi
source docker-ops
```

### Validate that loaded

To validate that releaser functions are loaded use: `docker_ops_loaded` function
or any other docker-ops function.

### Dependencies
* Bash
* Docker

## Usage
Recommended usage for a project:
1. Provide `./releaserrc` file to set variables (this is optional). Example:
```
image_name="docker-registry.ai-traders.com/docker-ops-test"
image_dir="./image"
```
1. Provide `./tasks` file with bash `case` (switch). It will allow to run
 a limited amount of commands). Example:
```bash
#!/bin/bash

set -e
if [[ ! -f ./releaser ]];then
  wget http://http.archive.ai-traders.com/releaser/0.3.1/releaser
fi
source ./releaser
if [[ ! -f ./docker-ops ]];then
  wget http://http.archive.ai-traders.com/docker-ops/0.1.3/docker-ops
fi
source ./docker-ops
# This must go as last in order to let user variables override default values
releaser_init

command="$1"
case "${command}" in
  build)
      docker_build "${image_dir}" "${imagerc_filename}" "${image_name}" "$2"
      exit $?
      ;;
  publish)
      source_imagerc "${image_dir}"  "${imagerc_filename}"
      production_image_tag="$(get_next_version)"
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
  * `dryrun=true` to avoid docker push.
  * `RELEASER_LOG_LEVEL=debug` for more log messages.
