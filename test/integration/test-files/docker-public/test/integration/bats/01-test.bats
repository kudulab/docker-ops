load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

docker_image="${KUDU_DOCKER_IMAGE_URL}"
docker_container="docker-ops-test"

@test "initialize tests" {
  if [[ "${docker_container}" == "" ]]; then
    echo "fail! docker_container not set"
    return 1
  fi
  docker stop ${docker_container} >/dev/null 2>&1 || true
  docker rm ${docker_container} >/dev/null 2>&1 || true
}
@test "main test" {
  run docker run --rm --name ${docker_container} "${docker_image}"
  assert_output --partial "hello from the image"
  assert_equal "$status" 0

  # container was removed
  run /bin/bash -c "docker inspect --format='{{.State.Status}}' ${docker_container}"
  assert_output --partial "Error: No such object"
  assert_equal "$status" 1
}
