# docker-public

An example of docker image that can be released on github and pushed to docker hub.

## Development

### Dependencies
* Bash
* Docker daemon
* Bats

### Lifecycle for public contributors
1. Make your changes in a feature branch.
2. Build docker image:
```
./tasks build_public
```
3. Test:
```
./tasks test_public
```
4. Run docker container interactively:
```
./tasks example_public
```
5. If necessary, create a Pull Request.

### Lifecycle for AI-Traders
1. Make your changes in a feature branch.
2. Build docker image:
```
./tasks build
```
3. Test:
```
./tasks test
```
4. Run docker container interactively:
```
./tasks example
```
5. Ensure proper version is set in CHANGELOG:
```
# no args
./tasks set_version
# custom version set
./tasks set_version 1.2.3
```
6. Merge the feature branch onto master and push to git.
7. CI server (GoCD) will build, test, release and publish.
