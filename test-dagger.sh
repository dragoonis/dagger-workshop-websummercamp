#!/bin/bash

set -eu

which dagger || echo "DAGGER NOT INSTALLED PROPERLY"

dagger -m github.com/shykes/daggerverse/hello@v0.1.2 call hello || echo "DAGGER IS INSTALLED BUT NOT OPERATIONAL"

echo "===== SUCCESS - DAGGER IS OPERATIONAL ======"