#!/bin/bash
set -ue

export USER="root"
export LANG=C.UTF-8 LANGUAGE=C.UTF-8

echo "--- STEP 0: Platform details ---"
uname -a
cat /etc/os-release || true
file /bin/bash || true

echo "--- STEP 1: Checking available libffi libraries ---"
find / -type f -name "libffi.so*" 2>/dev/null | sort || true

echo "--- STEP 2: Bundle install ---"
bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3

echo "--- STEP 3: Checking installed ffi gem version ---"
bundle list | grep ffi || true

echo "--- STEP 4: Finding and inspecting ffi_c.so ---"
find vendor/bundle -name ffi_c.so | while read -r ffi_c; do
  echo "Inspecting: $ffi_c"
  ldd "$ffi_c" || echo "ldd failed for $ffi_c"
done

echo "--- STEP 4.1: Detailed shared object dependencies ---"
find vendor/bundle -name ffi_c.so | while read -r ffi_c; do
  echo "Dependencies for $ffi_c"
  readelf -d "$ffi_c" | grep NEEDED || echo "readelf failed for $ffi_c"
done

echo "--- STEP 5: Ruby info ---"
ruby -v
ruby -e 'puts RUBY_PLATFORM'

echo "--- STEP 6: Run task ---"
bundle exec "$@"
