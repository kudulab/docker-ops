load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

@test "docker_ops::create_imagerc" {
  rm -f /tmp/docker-ops-test/imagerc*
  run /bin/bash -c "source src/docker-ops && docker_ops::create_imagerc /tmp/docker-ops-test imagerc myimg mytag registry"
  assert_equal "$status" 0

  run cat /tmp/docker-ops-test/imagerc
  assert_output --partial "export AIT_DOCKER_REGISTRY=\"registry\""
  assert_output --partial "export AIT_DOCKER_IMAGE_SHORT_NAME=\"myimg\""
  assert_output --partial "export AIT_DOCKER_IMAGE_NAME=\"registry/myimg\""
  assert_output --partial "export AIT_DOCKER_IMAGE_TAG=\"mytag\""
  assert_output --partial "export AIT_DOCKER_IMAGE_URL=\"registry/myimg:mytag\""
  assert_equal "$status" 0

  run cat /tmp/docker-ops-test/imagerc.yml
  assert_output --partial "docker_registry: \"registry\""
  assert_output --partial "docker_image_short_name: \"myimg\""
  assert_output --partial "docker_image_name: \"registry/myimg\""
  assert_output --partial "docker_image_tag: \"mytag\""
  assert_output --partial "docker_image_url: \"registry/myimg:mytag\""
  assert_equal "$status" 0

  run cat /tmp/docker-ops-test/imagerc.json
  assert_output --partial "\"docker_registry\": \"registry\""
  assert_output --partial "\"docker_image_short_name\": \"myimg\""
  assert_output --partial "\"docker_image_name\": \"registry/myimg\""
  assert_output --partial "\"docker_image_tag\": \"mytag\""
  assert_output --partial "\"docker_image_url\": \"registry/myimg:mytag\""
  assert_equal "$status" 0
}
@test "docker_ops::create_imagerc - fails if an argument not set" {
  rm -f /tmp/docker-ops-test/imagerc*
  run /bin/bash -c "source src/docker-ops && docker_ops::create_imagerc /tmp/docker-ops-test imagerc myimg mytag"
  assert_output --partial "registry not set"
  assert_equal "$status" 1
}
@test "docker_ops::create_imagerc - fails if an argument set to empty string" {
  rm -f /tmp/docker-ops-test/imagerc*
  registry=""
  run /bin/bash -c "source src/docker-ops && docker_ops::create_imagerc /tmp/docker-ops-test imagerc myimg mytag ${registry}"
  assert_output --partial "registry not set"
  assert_equal "$status" 1
}
@test "docker_ops::create_imagerc - clean" {
  rm -f /tmp/docker-ops-test/imagerc*
}
@test "docker_ops::source_imagerc - fails if an argument not set" {
  run /bin/bash -c "source src/docker-ops && docker_ops::source_imagerc"
  assert_output --partial "image_dir not set"
  assert_equal "$status" 1
}
@test "docker_ops::source_imagerc" {
  echo "export AIT_DOCKER_REGISTRY=\"reg1\"" > imagerc-test
  echo "export AIT_DOCKER_IMAGE_SHORT_NAME=\"img1\"" >> imagerc-test
  echo "export AIT_DOCKER_IMAGE_NAME=\"reg1/img1\"" >> imagerc-test
  echo "export AIT_DOCKER_IMAGE_TAG=\"123.45.22\"" >> imagerc-test
  echo "export AIT_DOCKER_IMAGE_URL=\"reg1/img1:123.45.22\"" >> imagerc-test

  run /bin/bash -c "source src/docker-ops && docker_ops::source_imagerc . imagerc-test"
  assert_output --partial "Sourced: ./imagerc-test. Image is: reg1/img1:123.45.22"
  assert_equal "$status" 0
}
@test "source_imagerc - fails if an argument not set" {
  run /bin/bash -c "source src/docker-ops && source_imagerc"
  assert_output --partial "image_dir not set"
  assert_equal "$status" 1
}
@test "source_imagerc" {
  echo "export AIT_DOCKER_REGISTRY=\"reg1\"" > imagerc-test
  echo "export AIT_DOCKER_IMAGE_SHORT_NAME=\"img1\"" >> imagerc-test
  echo "export AIT_DOCKER_IMAGE_NAME=\"reg1/img1\"" >> imagerc-test
  echo "export AIT_DOCKER_IMAGE_TAG=\"123.45.22\"" >> imagerc-test
  echo "export AIT_DOCKER_IMAGE_URL=\"reg1/img1:123.45.22\"" >> imagerc-test

  run /bin/bash -c "source src/docker-ops && source_imagerc . imagerc-test"
  assert_output --partial "Sourced: ./imagerc-test. Image is: reg1/img1:123.45.22"
  assert_equal "$status" 0
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
