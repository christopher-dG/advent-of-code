#!/usr/bin/env sh

cd "$(dirname $0)/.."
export BENCHMARKS_RUNNER=TRUE
exec dune exec -- bench/main.exe -fork -run-without-cross-library-inlining "$@"
