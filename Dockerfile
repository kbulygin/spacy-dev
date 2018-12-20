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
  if python --version 2>&1 | grep -q 'Python 2'; then \
    pip install pythainlp==1.6.0.7; \
  else \
    pip install pythainlp==1.7.1 mecab-python3==0.996.1; \
  fi
RUN pip install pymorphy2==0.8 pyvi==0.0.9.1

WORKDIR /root/spaCy

# Clone the fork made with https://github.com/explosion/spaCy/fork:
RUN git clone https://github.com/kbulygin/spaCy.git .

# Make sure that the current revision is the expected one:
RUN git reset --hard 42771a3d01ffa37ae86f9f6b95119b6fb7babbb6

RUN pip install -r requirements.txt

# Since our changes are not likely to interfere with this building, let's do
# it early to avoid rebuilding:
RUN python setup.py build_ext --inplace

# Make actual changes:
COPY changes/ja.py spacy/lang/ja/__init__.py
COPY changes/th.py spacy/lang/th/__init__.py
# COPY changes/ru_test_lemmatizer.py spacy/tests/lang/ru/test_lemmatizer.py

# To access the logs, run `make pytest.log` after **successful** building.
RUN ( py.test --slow spacy/tests 2>&1; echo "[exit $?]" ) | tee pytest.log

COPY commit.sh /root
