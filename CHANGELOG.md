### 2.1.1 (2025-Apr-23)

* fix github release

### 2.1.0 (2025-Apr-23)

* add an option to set docker platform while building a docker image (https://docs.docker.com/reference/cli/docker/buildx/build/#platform)

### 2.0.1 (2019-Apr-23)

 * updated readme
 * updated releaser to 2.1.0

### 2.0.0 (2019-Apr-21)

Rewrites and updates for public release
 * prefix in variables to `KUDU_` from `AIT_`
 * default registry is public on dockerhub. Therefore no prefix before image name.
 * resign from `ops_docker_push=true`, instead build and push are separate ops

### 0.3.3 (2019-Feb-02)

* use releaser 1.1.0

### 0.3.2 (2019-Feb-02)

* safer bash options: `set -Eeuo pipefail`
* set default value to dryrun to allow running with `set -u`

### 0.3.1 (2019-Feb-01)

* make functions docker_ops::push_production and docker_ops::create_imagerc
 take arguments in the same order

### 0.3.0 (2019-Jan-30)

* add new functions which names start with `docker_ops::`
* make it easy (add example) to use docker-ops with public images #17129
* no more oversion in docker images

### 0.2.4 (2018-Nov-21)

* fix logging functions' names to be unique even when docker-ops, releaser and
 other helpers are sourced

### 0.2.3 (2017-Jul-06)

* improved `source_imagerc` function to make validations

### 0.2.2 (2017-May-03)

* \#11010 use releaser 1.0.0 with renamed functions

### 0.2.1 (2017-Apr-26)
### 0.2.0 (2017-Apr-25)

* by default do not push docker image on build. Settable with `ops_docker_push`

### 0.1.3 (2017-Apr-16)

* do not set `set -e` in docker-ops main file
* better readme

### 0.1.2 (2017-Apr-15)

* respect docker_build_options variable in docker_build function

### 0.1.1 (2017-Apr-15)

* \#10892 support custom imagerc filename

### 0.1.0 (15-04-2017)

Initial release
