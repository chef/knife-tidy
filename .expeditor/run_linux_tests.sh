#!/bin/bash
set -ue

export USER="root"
export LANG=C.UTF-8 LANGUAGE=C.UTF-8

echo "--- bundle install"
bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3

echo "--- rebuild ffi native extension if present"
if bundle list | grep -q 'ffi'; then
  echo "Rebuilding ffi from source..."
  bundle pristine ffi
else
  echo "ffi gem not found, skipping rebuild"
fi

echo "+++ bundle exec task"
bundle exec "$@"
