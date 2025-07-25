#!/bin/bash
set -ue

export USER="root"
export LANG=C.UTF-8 LANGUAGE=C.UTF-8

echo "--- bundle install"
bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3

# echo "--- fix missing libffi.so.6 if needed"
# if ! find /usr/lib /usr/lib64 /usr/lib/x86_64-linux-gnu -name "libffi.so.6" 2>/dev/null | grep -q libffi.so.6; then
#   ffi_so=$(find /usr/lib /usr/lib64 /usr/lib/x86_64-linux-gnu -type l \( -name 'libffi.so.7' -o -name 'libffi.so.8' \) 2>/dev/null | head -n1)
#   if [[ -n "$ffi_so" ]]; then
#     target_dir=$(dirname "$ffi_so")
#     echo "Creating symlink: $target_dir/libffi.so.6 -> $ffi_so"
#     ln -sf "$ffi_so" "$target_dir/libffi.so.6"
#   else
#     echo "No libffi.so.7 or .8 found, skipping symlink fix"
#   fi
# else
#   echo "libffi.so.6 already exists"
# fi

# echo "--- check libffi symlinks"
# ls -l /usr/lib/*/libffi.so* || true

# echo "--- verify ffi_c.so linkage"
# find vendor/bundle -name ffi_c.so -exec echo "ldd {}:" \; -exec ldd {} \; || true

echo "+++ bundle exec task"
bundle exec "$@"
