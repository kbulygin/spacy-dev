#!/bin/bash

set -ex

branch=issue_th
email=EMAIL
display_name=DISPLAY_NAME

# shellcheck disable=SC2016
message='Making `lang/th/test_tokenizer.py` pass by creating `ThaiTokenizer`'
# (Note: Unfortunately, both `explosion/spaCy#2901` and `#2901` led to a
# premature mention on the issue page.)

git checkout -b "$branch"
git add .

# For manual checking:
git diff --cached

git config --global user.email "$email"
git config --global user.name "$display_name"
git commit -a -m "$message"

git push origin +"$branch"
# (To abort, just press Ctrl-C or Ctrl-D on the username prompt.)
# To redo the previous push (https://stackoverflow.com/a/448929):
# git push origin +"$branch" --force
