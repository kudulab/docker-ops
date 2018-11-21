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
