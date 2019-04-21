load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

@test "docker_ops::create_imagerc when private registry" {
  rm -f /tmp/docker-ops-test/imagerc*
  run /bin/bash -c "source src/docker-ops && docker_ops::create_imagerc /tmp/docker-ops-test imagerc myimg mytag registry"
  assert_equal "$status" 0

  run cat /tmp/docker-ops-test/imagerc
  assert_output --partial "export KUDU_DOCKER_REGISTRY=\"registry\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_SHORT_NAME=\"myimg\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_NAME=\"registry/myimg\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_TAG=\"mytag\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_URL=\"registry/myimg:mytag\""
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

@test "docker_ops::create_imagerc when public registry" {
  rm -f /tmp/docker-ops-test/imagerc*
  run /bin/bash -c "source src/docker-ops && docker_ops::create_imagerc /tmp/docker-ops-test imagerc myimg mytag"
  assert_equal "$status" 0

  run cat /tmp/docker-ops-test/imagerc
  assert_output --partial "export KUDU_DOCKER_REGISTRY=\"dockerhub\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_SHORT_NAME=\"myimg\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_NAME=\"myimg\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_TAG=\"mytag\""
  assert_output --partial "export KUDU_DOCKER_IMAGE_URL=\"myimg:mytag\""
  assert_equal "$status" 0

  run cat /tmp/docker-ops-test/imagerc.yml
  assert_output --partial "docker_registry: \"dockerhub\""
  assert_output --partial "docker_image_short_name: \"myimg\""
  assert_output --partial "docker_image_name: \"myimg\""
  assert_output --partial "docker_image_tag: \"mytag\""
  assert_output --partial "docker_image_url: \"myimg:mytag\""
  assert_equal "$status" 0

  run cat /tmp/docker-ops-test/imagerc.json
  assert_output --partial "\"docker_registry\": \"dockerhub\""
  assert_output --partial "\"docker_image_short_name\": \"myimg\""
  assert_output --partial "\"docker_image_name\": \"myimg\""
  assert_output --partial "\"docker_image_tag\": \"mytag\""
  assert_output --partial "\"docker_image_url\": \"myimg:mytag\""
  assert_equal "$status" 0
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
  echo "export KUDU_DOCKER_REGISTRY=\"reg1\"" > imagerc-test
  echo "export KUDU_DOCKER_IMAGE_SHORT_NAME=\"img1\"" >> imagerc-test
  echo "export KUDU_DOCKER_IMAGE_NAME=\"reg1/img1\"" >> imagerc-test
  echo "export KUDU_DOCKER_IMAGE_TAG=\"123.45.22\"" >> imagerc-test
  echo "export KUDU_DOCKER_IMAGE_URL=\"reg1/img1:123.45.22\"" >> imagerc-test

  run /bin/bash -c "source src/docker-ops && docker_ops::source_imagerc . imagerc-test"
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
  run /bin/bash -c "source src/docker-ops && DOCKER_OPS_LOG_LEVEL=debug docker_ops::log_debug 'dummy message'"
  assert_output --partial "DOCKER-OPS debug: dummy message"
  assert_equal "$status" 0
}
