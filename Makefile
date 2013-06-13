docs: lib
	@node_modules/.bin/lidoc README.md lib/*.coffee models/*.coffee --output docs --github nordus/cowlamp-gateway

docs.deploy: docs
	@cd docs && \
  git init . && \
  git add . && \
  git commit -m "Update documentation"; \
  git push "git@github.com:nordus/cowlamp-gateway.git" master:gh-pages --force && \
  rm -rf .git

.PHONY: test docs docs.deploy