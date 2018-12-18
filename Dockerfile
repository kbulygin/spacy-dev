FROM python@sha256:a837aefef8f2553789bc70436621160af4da65d95b0fb02d5032557f887d0ca5
# python:3.7.1 (Debian Stretch), Sun Nov 11 17:29:43 +05 2018

# Install prerequisites (MeCab):
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  mecab=0.996-3.1 \
  unidic-mecab=2.1.2~dfsg-6 \
  libmecab-dev=0.996-3.1 \
  swig=3.0.10-1.1
RUN pip install mecab-python3==0.996.1

WORKDIR /root/spaCy

# Clone the fork made with https://github.com/explosion/spaCy/fork:
RUN git clone https://github.com/kbulygin/spaCy.git .

# Make sure that the current revision is the expected one:
RUN git reset --hard c9a89bba507de9a78eb4d9c37f0d66033d9e2fd7

RUN pip install -r requirements.txt

RUN python setup.py build_ext --inplace

# Make changes to the file tree:
COPY kbulygin.md .github/contributors/
COPY test_issue2901.py spacy/tests/regression/
COPY __init__.py spacy/lang/ja/

RUN py.test -x --slow spacy/tests 2>&1 | tee pytest.log

RUN git checkout -b issue2901
RUN git add .

# For manual checking:
RUN git diff --cached

RUN git config --global user.email kirill.bulygin@gmail.com
RUN git config --global user.name kbulygin

# Make a commit. (Note: Unfortunately, both `#2901` and `explosion/spaCy#2901`
# lead to a premature mention on the issue page.)
RUN git commit -a -m 'Fix the first `nlp` call for `ja` (closes #2901)'

# Then run the container and execute this manually:
#
# $ git push origin +issue2901
#
# Or this (to redo the previous push, see https://stackoverflow.com/a/448929):
#
# $ git push origin +issue2901 --force
