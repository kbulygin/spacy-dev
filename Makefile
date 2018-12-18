IMAGE_PY2 = python@sha256:1bb98a04d037d9766110499d36bf2f3a2aa43965b4aa345da91f6de75f3816d8
# python:2.7.15 (Debian Stretch), Tue Dec 18 19:31:44 +05 2018

IMAGE_PY3 = python@sha256:a837aefef8f2553789bc70436621160af4da65d95b0fb02d5032557f887d0ca5
# python:3.7.1 (Debian Stretch), Sun Nov 11 17:29:43 +05 2018

.PHONY: all build-py2 build-py3 run

all: commit

# Note: Tags like `spacy-dev:py2` are not used to avoid accidental usage of
# `spacy-dev` (the tag `latest` is considered nondeterministic here).
build-py2:
	docker build --build-arg IMAGE=$(IMAGE_PY2) -t spacy-dev-py2 .
build-py3:
	docker build --build-arg IMAGE=$(IMAGE_PY3) -t spacy-dev-py3 .

pytest-%.log: build-%
	./get-asset.sh spacy-dev-$* /root/spaCy/pytest.log $@

commit: pytest-py2.log pytest-py3.log
	[ "`tail -n1 pytest-py2.log`" = '[exit 0]' ]
	[ "`tail -n1 pytest-py3.log`" = '[exit 0]' ]
	docker run --rm -it --name=spacy-dev-py3 spacy-dev-py3 ./commit.sh
