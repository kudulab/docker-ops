load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

repo_dir="test/integration/test-files/docker-private-complex"
repo_dir=$(readlink -f ${repo_dir})
docker_image_name1="docker-ops-private1"
docker_image_name2="docker-ops-private2"
docker_registry1="docker-registry1.ai-traders.com"

function clean_docker_images {
  tags=$(docker images docker-registry1.ai-traders.com/${docker_image_name1} | awk '{print $2}' | tail -n +2)
  for tag in $tags ; do
    docker rmi "docker-registry1.ai-traders.com/${docker_image_name1}:${tag}"
  done
  tags=$(docker images docker-registry1.ai-traders.com/${docker_image_name2} | awk '{print $2}' | tail -n +2)
  for tag in $tags ; do
    docker rmi "docker-registry1.ai-traders.com/${docker_image_name2}:${tag}"
  done
  tags=$(docker images docker-registry2.ai-traders.com/${docker_image_name2} | awk '{print $2}' | tail -n +2)
  for tag in $tags ; do
    docker rmi "docker-registry2.ai-traders.com/${docker_image_name2}:${tag}"
  done
}

@test "setup - once before all tests" {
  clean_docker_images
}

@test "./tasks build" {
  rm -rf "${repo_dir}/.git" ${repo_dir}/image1/imagerc*  ${repo_dir}/image2/imagerc*
  run /bin/bash -c "cd ${repo_dir} && git init && git add --all && git commit -m first && dryrun=true ./tasks build"
  assert_output --partial "docker build -t ${docker_registry1}/${docker_image_name1}"
  assert_output --partial "docker build -t ${docker_registry1}/${docker_image_name2}"
  assert_equal "$status" 0

  run cat ${repo_dir}/image1/imagerc1
  assert_output --partial "export KUDU_DOCKER_REGISTRY=\"docker-registry1.ai-traders.com\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_SHORT_NAME=\"${docker_image_name1}\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_NAME=\"docker-registry1.ai-traders.com/${docker_image_name1}\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_TAG="
  assert_output --partial "export KUDU_DOCKER_IMAGE_URL=\"docker-registry1.ai-traders.com/${docker_image_name1}:"
  assert_equal "$status" 0

  run cat ${repo_dir}/image1/imagerc1.yml
  assert_output --partial "docker_registry: \"docker-registry1.ai-traders.com\""
  assert_output --partial "docker_image_short_name: \"${docker_image_name1}\""
  assert_output --partial "docker_image_name: \"docker-registry1.ai-traders.com/${docker_image_name1}\""
  assert_output --partial "docker_image_tag:"
  assert_output --partial "docker_image_url: \"docker-registry1.ai-traders.com/${docker_image_name1}:"
  assert_equal "$status" 0

  run cat ${repo_dir}/image1/imagerc1.json
  assert_output --partial "\"docker_registry\": \"docker-registry1.ai-traders.com\""
  assert_output --partial "\"docker_image_short_name\": \"${docker_image_name1}\""
  assert_output --partial "\"docker_image_name\": \"docker-registry1.ai-traders.com/${docker_image_name1}\""
  assert_output --partial "\"docker_image_tag\":"
  assert_output --partial "\"docker_image_url\": \"docker-registry1.ai-traders.com/${docker_image_name1}:"
  assert_equal "$status" 0

  run cat ${repo_dir}/image2/imagerc2
  assert_output --partial "export KUDU_DOCKER_REGISTRY=\"docker-registry1.ai-traders.com\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_SHORT_NAME=\"${docker_image_name2}\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_NAME=\"docker-registry1.ai-traders.com/${docker_image_name2}\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_TAG="
  assert_output --partial "export KUDU_DOCKER_IMAGE_URL=\"docker-registry1.ai-traders.com/${docker_image_name2}:"
  assert_equal "$status" 0

  run cat ${repo_dir}/image2/imagerc2.yml
  assert_output --partial "docker_registry: \"docker-registry1.ai-traders.com\""
  assert_output --partial "docker_image_short_name: \"${docker_image_name2}\""
  assert_output --partial "docker_image_name: \"docker-registry1.ai-traders.com/${docker_image_name2}\""
  assert_output --partial "docker_image_tag:"
  assert_output --partial "docker_image_url: \"docker-registry1.ai-traders.com/${docker_image_name2}:"
  assert_equal "$status" 0

  run cat ${repo_dir}/image2/imagerc2.json
  assert_output --partial "\"docker_registry\": \"docker-registry1.ai-traders.com\""
  assert_output --partial "\"docker_image_short_name\": \"${docker_image_name2}\""
  assert_output --partial "\"docker_image_name\": \"docker-registry1.ai-traders.com/${docker_image_name2}\""
  assert_output --partial "\"docker_image_tag\":"
  assert_output --partial "\"docker_image_url\": \"docker-registry1.ai-traders.com/${docker_image_name2}:"
  assert_equal "$status" 0

  # do not rm .git directory or imagerc* files, we need to keep the docker tag
}
@test "./tasks test" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks test"
  assert_output --partial "Testing image: docker-registry1.ai-traders.com/docker-ops-private1:"
  assert_output --partial "Testing image: docker-registry1.ai-traders.com/docker-ops-private2:"
  assert_output --partial "2 tests, 0 failures"
  assert_equal "$status" 0

  # do not rm .git directory or imagerc* files, we need to keep the docker tag
}
@test "./tasks example" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks example"
  assert_output --partial "Testing image: docker-registry1.ai-traders.com/docker-ops-private1:"
  assert_output --partial "Testing image: docker-registry1.ai-traders.com/docker-ops-private2:"
  assert_output --partial "hello from the image"
  assert_output --partial "bye from the image"
  assert_equal "$status" 0

  # do not rm .git directory or imagerc* files, we need to keep the docker tag
}
@test "./tasks verify_version" {
  run /bin/bash -c "cd ${repo_dir} && ./tasks verify_version"
  assert_equal "$status" 0
}
@test "./tasks publish" {
  run /bin/bash -c "cd ${repo_dir} && dryrun=true ./tasks publish"
  assert_output --partial "docker tag docker-registry1.ai-traders.com/${docker_image_name1}:"
  assert_output --partial "docker-registry1.ai-traders.com/${docker_image_name1}:0.1.0"
  assert_output --partial "docker-registry1.ai-traders.com/${docker_image_name1}:latest"
  assert_output --partial "Not running push, dryrun=true"
  assert_output --partial "docker tag docker-registry1.ai-traders.com/${docker_image_name2}:"
  assert_output --partial "docker-registry2.ai-traders.com/${docker_image_name2}:0.1.0"
  assert_output --partial "docker-registry2.ai-traders.com/${docker_image_name2}:latest"
  assert_equal "$status" 0

  run /bin/bash -c "docker images \"docker-registry1.ai-traders.com/${docker_image_name1}\" | awk '{print $2}' | grep latest"
  assert_equal "$status" 0

  run /bin/bash -c "docker images \"docker-registry1.ai-traders.com/${docker_image_name1}\" | awk '{print $2}' | grep '0.1.0'"
  assert_equal "$status" 0

  run /bin/bash -c "docker images \"docker-registry2.ai-traders.com/${docker_image_name2}\" | awk '{print $2}' | grep latest"
  assert_equal "$status" 0

  run /bin/bash -c "docker images \"docker-registry2.ai-traders.com/${docker_image_name2}\" | awk '{print $2}' | grep '0.1.0'"
  assert_equal "$status" 0
}
@test "clean" {
  cd ${repo_dir} && git reset --hard
  rm -rf "${repo_dir}/.git" ${repo_dir}/image1/imagerc1* ${repo_dir}/image2/imagerc2*
  clean_docker_images
}
