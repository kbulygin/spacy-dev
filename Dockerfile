ARG IMAGE
FROM ${IMAGE}

# Install prerequisites (MeCab):
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  mecab=0.996-3.1 \
  unidic-mecab=2.1.2~dfsg-6 \
  libmecab-dev=0.996-3.1 \
  swig=3.0.10-1.1
RUN \
  if python --version 2>&1 | grep -q 'Python 3'; then \
    pip install mecab-python3==0.996.1; \
  fi
RUN pip install pymorphy2 pythainlp pyvi

WORKDIR /root/spaCy

# Clone the fork made with https://github.com/explosion/spaCy/fork:
RUN git clone https://github.com/kbulygin/spaCy.git .

# Make sure that the current revision is the expected one:
RUN git reset --hard c9a89bba507de9a78eb4d9c37f0d66033d9e2fd7

RUN pip install -r requirements.txt

# Since our changes are not likely to interfere with this building, let's do
# it early to avoid rebuilding:
RUN python setup.py build_ext --inplace

# Make actual changes:
COPY kbulygin.md .github/contributors/
COPY test_issue2901.py spacy/tests/regression/
COPY __init__.py spacy/lang/ja/

# To access the logs, run `make pytest.log` after **successful** building.
RUN ( py.test --slow spacy/tests 2>&1; echo "[exit $?]" ) | tee pytest.log

COPY commit.sh ./
