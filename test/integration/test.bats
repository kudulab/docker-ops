load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

ide_docker_image_dir="test/integration/test-files/ide-docker-image"
ide_docker_image_dir=$(readlink -f ${ide_docker_image_dir})

function clean_docker_images {
  tags=$(docker images docker-registry.ai-traders.com/docker-ops-test | awk '{print $2}' | tail -n +2)
  for tag in $tags ; do
    docker rmi "docker-registry.ai-traders.com/docker-ops-test:${tag}"
  done
}

@test "build returns 0" {
  clean_docker_images

  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && dryrun=true ./tasks build"
  assert_output --partial "docker build -t docker-registry.ai-traders.com/docker-ops-test"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/image/imagerc | grep 'export AIT_DOCKER_IMAGE_NAME=\"docker-registry.ai-traders.com/docker-ops-test\"'"
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/image/imagerc.json | grep '\"docker_image_name\":\"docker-registry.ai-traders.com/docker-ops-test\"'"
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/image/imagerc.yml | grep -- '---'"
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/image/imagerc.yml | grep 'docker_image_name: docker-registry.ai-traders.com/docker-ops-test'"
  assert_equal "$status" 0

  cd ${ide_docker_image_dir} && git reset --hard
  # do not rm .git directory, it is needed in publish test
  rm "${ide_docker_image_dir}/image/imagerc"*
}
@test "publish returns 0" {
  # do not rm .git directory, reuse it from build test
  run /bin/bash -c "cd ${ide_docker_image_dir} && git tag 0.1.1 && dryrun=true ./tasks publish"
  assert_output --partial "docker tag docker-registry.ai-traders.com/docker-ops-test"
  assert_output --partial "docker-registry.ai-traders.com/docker-ops-test:latest"
  assert_equal "$status" 0

  cd ${ide_docker_image_dir} && git reset --hard
  rm -rf "${ide_docker_image_dir}/.git"

  clean_docker_images
}
