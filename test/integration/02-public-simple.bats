load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

repo_dir="test/integration/test-files/docker-public"
repo_dir=$(readlink -f ${repo_dir})
docker_image_name="docker-ops-public"

function clean_docker_images {
  tags=$(docker images ${docker_image_name} | awk '{print $2}' | tail -n +2)
  for tag in $tags ; do
    docker rmi "${docker_image_name}:${tag}"
  done
}

@test "setup - once before all tests" {
  rm -rf "${repo_dir}/.git" ${repo_dir}/image/imagerc*
  clean_docker_images
}

@test "./tasks build_public" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks build_public"
  assert_output --partial "docker build -t ${docker_image_name}:temp ."
  assert_output --partial "Successfully built"
  assert_equal "$status" 0
}
@test "./tasks build" {
  rm -rf "${repo_dir}/.git" ${repo_dir}/image/imagerc*
  run /bin/bash -c "cd ${repo_dir} && git init && git add --all && git commit -m first && ./tasks build"
  assert_output --partial "docker build -t ${docker_image_name}"
  assert_output --partial "Successfully built"
  assert_equal "$status" 0

  run cat ${repo_dir}/image/imagerc
  assert_output --partial "export KUDU_DOCKER_REGISTRY=\"dockerhub\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_SHORT_NAME=\"${docker_image_name}\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_NAME=\"${docker_image_name}\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_TAG="
  assert_output --partial "export KUDU_DOCKER_IMAGE_URL=\"${docker_image_name}:"
  assert_equal "$status" 0

  run cat ${repo_dir}/image/imagerc.yml
  assert_output --partial "docker_registry: \"dockerhub\""
  assert_output --partial "docker_image_short_name: \"${docker_image_name}\""
  assert_output --partial "docker_image_name: \"${docker_image_name}\""
  assert_output --partial "docker_image_tag:"
  assert_output --partial "docker_image_url: \"${docker_image_name}:"
  assert_equal "$status" 0

  run cat ${repo_dir}/image/imagerc.json
  assert_output --partial "\"docker_registry\": \"dockerhub\""
  assert_output --partial "\"docker_image_short_name\": \"${docker_image_name}\""
  assert_output --partial "\"docker_image_name\": \"${docker_image_name}\""
  assert_output --partial "\"docker_image_tag\":"
  assert_output --partial "\"docker_image_url\": \"${docker_image_name}:"
  assert_equal "$status" 0

  # do not rm .git directory or imagerc* files, we need the docker tag kept
}
@test "./tasks test_public" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks test_public"
  assert_output --partial "Testing image: ${docker_image_name}:temp"
  assert_output --partial "2 tests, 0 failures"
  assert_equal "$status" 0

  # do not rm .git directory or imagerc* files, we need the docker tag kept
}
@test "./tasks test" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks test"
  assert_output --partial "Testing image: ${docker_image_name}:"
  assert_output --partial "2 tests, 0 failures"
  assert_equal "$status" 0

  # do not rm .git directory or imagerc* files, we need the docker tag kept
}
@test "./tasks example_public" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks example_public"
  assert_output --partial "Testing image: ${docker_image_name}:temp"
  assert_output --partial "hello from the image"
  assert_equal "$status" 0

  # do not rm .git directory or imagerc* files, we need the docker tag kept
}
@test "./tasks example" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks example"
  assert_output --partial "Testing image: ${docker_image_name}:"
  assert_output --partial "hello from the image"
  assert_equal "$status" 0

  # do not rm .git directory or imagerc* files, we need the docker tag kept
}
@test "./tasks verify_version" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks verify_version"
  assert_equal "$status" 0
}
@test "./tasks publish" {
  run /bin/bash -c "cd ${repo_dir} && dryrun=true ./tasks publish"
  assert_output --partial "docker tag ${docker_image_name}:"
  assert_output --partial "${docker_image_name}:0.1.0"
  assert_output --partial "${docker_image_name}:latest"
  assert_equal "$status" 0

  run /bin/bash -c "docker images \"${docker_image_name}\" | awk '{print $2}' | grep latest"
  assert_equal "$status" 0

  run /bin/bash -c "docker images \"${docker_image_name}\" | awk '{print $2}' | grep '0.1.0'"
  assert_equal "$status" 0
}
@test "clean" {
  cd ${repo_dir} && git reset --hard
  rm -rf "${repo_dir}/.git" ${repo_dir}/image/imagerc*
  clean_docker_images
}
