# coding: utf8
from __future__ import unicode_literals

from .tokenizer_exceptions import TOKENIZER_EXCEPTIONS
from .tag_map import TAG_MAP
from .stop_words import STOP_WORDS

from ...tokens import Doc
from ...language import Language
from ...attrs import LANG


class ThaiTokenizer(object):
    def __init__(self, cls, nlp=None):
        try:
            from pythainlp.tokenize import word_tokenize
        except ImportError:
            raise ImportError(
                "The Thai tokenizer requires the PyThaiNLP library: "
                "https://github.com/PyThaiNLP/pythainlp")

        self.word_tokenize = word_tokenize
        self.vocab = nlp.vocab if nlp is not None else cls.create_vocab(nlp)

    def __call__(self, text):
        words = list(self.word_tokenize(text, "newmm"))
        spaces = [False] * len(words)
        return Doc(self.vocab, words=words, spaces=spaces)

    # add dummy methods for to_bytes, from_bytes, to_disk and from_disk to
    # allow serialization (see #1557)
    def to_bytes(self, **exclude):
        return b''

    def from_bytes(self, _bytes_data, **exclude):
        return self

    def to_disk(self, _path, **exclude):
        return None

    def from_disk(self, _path, **exclude):
        return self


class ThaiDefaults(Language.Defaults):
    lex_attr_getters = dict(Language.Defaults.lex_attr_getters)
    lex_attr_getters[LANG] = lambda text: 'th'
    tokenizer_exceptions = dict(TOKENIZER_EXCEPTIONS)
    tag_map = TAG_MAP
    stop_words = STOP_WORDS

    @classmethod
    def create_tokenizer(cls, nlp=None):
        return ThaiTokenizer(cls, nlp)


class Thai(Language):
    lang = 'th'
    Defaults = ThaiDefaults

    def make_doc(self, text):
        return self.tokenizer(text)


__all__ = ['Thai']
