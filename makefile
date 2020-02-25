.PHONY: test
test:
	# Set up variables.
	$(eval STD_OUT_LOG := ./zdevelop/tests/_reports/test_stdout.txt)
	$(eval STD_ERR_LOG := ./zdevelop/tests/_reports/test_stderr.txt)
	$(eval COVERAGE_LOG := ./zdevelop/tests/_reports/coverage.out)
	$(eval TEST_REPORT := ./zdevelop/tests/_reports/test_report.html)
	$(eval COVERAGE_REPORT := ./zdevelop/tests/_reports/coverage.html)
	# make the reports directory
	-mkdir ./zdevelop/tests/_reports
	# Clear the output files.
	echo > $(STD_OUT_LOG)
	echo > $(STD_ERR_LOG)
	# Run tests. I honestly don't quite understand the piping bullshit that has to
	# happen here to send stdout and stderr to tee separately ( in order to
	# both save and display them ), but the internet says this is the solution and it
	# works.
	-(\
		go test \
			-v \
			-failfast \
			-covermode=count \
			-coverprofile=$(COVERAGE_LOG) \
            -coverpkg=./... \
			./... \
			--minimum-coverage=0.85 \
        | tee "$(STD_OUT_LOG)" \
    ) 3>&1 1>&2 2>&3 \
        | tee "$(STD_ERR_LOG)"
    # Build Reports
	-go tool cover -html=$(COVERAGE_LOG)
	-go-test-html "$(STD_OUT_LOG)" "$(STD_ERR_LOG)" "$(TEST_REPORT)"
	# Open Reports
	-open "$(TEST_REPORT)"

.PHONY: lint
lint:
	-revive -config revive.toml ./...

.PHONY: format
format:
	-gofmt -s -w ./
	-gofmt -s -w ./zdevelop/tests

.PHONY: venv
venv:
ifeq ($(py), )
	$(eval PY_PATH := python3)
else
	$(eval PY_PATH := $(py))
endif
	$(eval VENV_PATH := $(shell $(PY_PATH) ./zdevelop/make_scripts/make_venv.py))
	@echo "venv created! To enter virtual env, run:"
	@echo ". ~/.bash_profile"
	@echo "then run:"
	@echo "$(VENV_PATH)"

.PHONY: install-dev
install-dev:
	pip install --upgrade pip
	pip install --no-cache-dir -e .[build,doc]

# Installs command line tools into global GOPATH.
.PHONY: install-globals
install-globals:
	$(eval CURRENT_DIR := $(shell pwd))
	cd ~/
	# Creates html report of tests.
	-go get -u github.com/ains/go-test-html
	# Creates API doc server.
	-go get -u golang.org/x/tools/cmd/godoc
	# Downloads module APIs from API server.
	-go get -u github.com/illuscio-dev/docmodule-go
	# swap back to the current directory.
	cd $(current_dir)

# Creates docs.
.PHONY: doc
doc:
	rm -rf ./zdocs/build
	mkdir ./zdocs/build
	# Rip API docs from godoc. This tools spins up a godoc server and downloads
	# module docs
	docmodule-go
	python setup.py build_sphinx -E
	sleep 1
	open ./zdocs/build/html/index.html
	# Remove Deleted files from git
	git add -u
	# Add any new files to git
	git add zdocs/*

.PHONY: name
name:
	$(eval PATH_NEW := $(shell python3 ./zdevelop/make_scripts/make_name.py $(n)))
	@echo "library renamed! to switch your current directory, use the following \
	command:\ncd '$(PATH_NEW)'"
