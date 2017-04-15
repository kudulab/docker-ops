# docker-ops

## Usage
Make your `releaserrc` file like this:
```
image_name="docker-registry.ai-traders.com/docker-ops-test"
image_dir="./image"
```

Make your `tasks` file like this:
```bash
#!/bin/bash

if [[ ! -f ./releaser ]];then
  wget http://http.archive.ai-traders.com/releaser/0.3.0/releaser || { echo "failed to wget releaser"; exit 1; }
fi
source ./releaser
if [[ ! -f ./docker-ops ]];then
  wget http://http.archive.ai-traders.com/docker-ops/0.1.1/docker-ops || { echo "failed to wget docker-ops"; exit 1; }
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
```

Now you can run:
```bash
./tasks build
./tasks publish
```

You can set `dryrun=true` to prevent `docker push` operations.
