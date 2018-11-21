load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

ide_docker_image_dir="test/integration/test-files/ide-docker-image"
ide_docker_image_dir=$(readlink -f ${ide_docker_image_dir})
custom_imagerc="test/integration/test-files/custom-imagerc"
custom_imagerc=$(readlink -f ${custom_imagerc})

function clean_docker_images {
  tags=$(docker images docker-registry.ai-traders.com/docker-ops-test | awk '{print $2}' | tail -n +2)
  for tag in $tags ; do
    docker rmi "docker-registry.ai-traders.com/docker-ops-test:${tag}"
  done
  tags=$(docker images docker-registry.ai-traders.com/docker-ops-test-custom-imagerc | awk '{print $2}' | tail -n +2)
  for tag in $tags ; do
    docker rmi "docker-registry.ai-traders.com/docker-ops-test-custom-imagerc:${tag}"
  done
}

@test "logging works" {
  run /bin/bash -c "source src/docker-ops && docker_ops::log_info 'dummy message'"
  assert_output --partial "DOCKER-OPS info: dummy message"
  assert_equal "$status" 0
  run /bin/bash -c "source src/docker-ops && docker_ops::log_warn 'dummy message'"
  assert_output --partial "DOCKER-OPS warn: dummy message"
  assert_equal "$status" 0
  run /bin/bash -c "source src/docker-ops && docker_ops::log_error 'dummy message'"
  assert_output --partial "DOCKER-OPS error: dummy message"
  assert_equal "$status" 0
  run /bin/bash -c "source src/docker-ops && RELEASER_LOG_LEVEL=debug docker_ops::log_debug 'dummy message'"
  assert_output --partial "DOCKER-OPS debug: dummy message"
  assert_equal "$status" 0
}

@test "setup - once before all tests" {
  clean_docker_images
}

@test "build returns 0 with dryrun" {
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && dryrun=true ./tasks build"
  # those will be visible on bats failure
  echo "status = ${status}"
  echo "output = ${output}"
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

  # do not rm .git directory or imagerc* files, they are needed in publish test
}

@test "build respects custom imagerc file" {
  rm -rf "${custom_imagerc}/.git"
  run /bin/bash -c "cd ${custom_imagerc} && git init && git add --all && git commit -m first && dryrun=true ./tasks build"
  # those will be visible on bats failure
  echo "status = ${status}"
  echo "output = ${output}"
  assert_output --partial "docker build -t docker-registry.ai-traders.com/docker-ops-test-custom-imagerc"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${custom_imagerc}/image/myimagerc | grep 'export AIT_DOCKER_IMAGE_NAME=\"docker-registry.ai-traders.com/docker-ops-test-custom-imagerc\"'"
  assert_equal "$status" 0
  run /bin/bash -c "cat ${custom_imagerc}/image/myimagerc.json | grep '\"docker_image_name\":\"docker-registry.ai-traders.com/docker-ops-test-custom-imagerc\"'"
  assert_equal "$status" 0
  run /bin/bash -c "cat ${custom_imagerc}/image/myimagerc.yml | grep -- '---'"
  assert_equal "$status" 0
  run /bin/bash -c "cat ${custom_imagerc}/image/myimagerc.yml | grep 'docker_image_name: docker-registry.ai-traders.com/docker-ops-test-custom-imagerc'"
  assert_equal "$status" 0

  cd ${custom_imagerc} && git reset --hard
  rm -rf "${custom_imagerc}/.git"
  rm "${custom_imagerc}/image/myimagerc"*
}
@test "publish returns 0 with dryrun" {
  # do not rm .git directory, reuse it from build test
  run /bin/bash -c "cd ${ide_docker_image_dir} && dryrun=true ./tasks publish"
  # those will be visible on bats failure
  echo "status = ${status}"
  echo "output = ${output}"
  assert_output --partial "docker tag -f docker-registry.ai-traders.com/docker-ops-test"
  assert_output --partial "docker-registry.ai-traders.com/docker-ops-test:latest"
  assert_equal "$status" 0

  run /bin/bash -c "docker images \"docker-registry.ai-traders.com/docker-ops-test\" | awk '{print $2}' | grep latest"
  echo "status = ${status}"
  echo "output = ${output}"
  assert_equal "$status" 0

  run /bin/bash -c "docker images \"docker-registry.ai-traders.com/docker-ops-test\" | awk '{print $2}' | grep '0.1.0'"
  echo "status = ${status}"
  echo "output = ${output}"
  assert_equal "$status" 0

  cd ${ide_docker_image_dir} && git reset --hard
  rm -rf "${ide_docker_image_dir}/.git"
  rm "${ide_docker_image_dir}/image/imagerc"*
}
@test "teardown - once after all tests" {
  clean_docker_images
}
