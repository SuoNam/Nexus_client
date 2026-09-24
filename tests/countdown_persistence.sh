#!/bin/sh
set -eu
source_dir=${1:?source directory required}
test_dir=$(mktemp -d /tmp/nexus-countdown-test.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
export XDG_CONFIG_HOME="$test_dir/config"
export QT_QPA_PLATFORM=offscreen
export QT_QUICK_BACKEND=software
g++ -fPIC "$source_dir/tests/countdown_persistence.cpp" -o "$test_dir/test" \
    $(pkg-config --cflags --libs Qt5Quick Qt5Test)
components="$source_dir/qml/components"
first='{"id":"first","label":"First","target":"2026-12-31T12:00:00","suffix":"Done"}'
second='{"id":"second","label":"Second","target":"2026-12-31T13:00:00","suffix":"Done"}'
"$test_dir/test" "$components" save "[$first,$second]"
"$test_dir/test" "$components" check "[$first,$second]"
"$test_dir/test" "$components" delete unused
"$test_dir/test" "$components" check "[$second]"
"$test_dir/test" "$components" delete unused
"$test_dir/test" "$components" check '[]'
"$test_dir/test" "$components" check '[]'
"$test_dir/test" "$components" save "[$first]"
"$test_dir/test" "$components" check "[$first]"
echo 'PASS: add, delete via button, delete all, repeated restart, immediate process termination'
