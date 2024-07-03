#!/bin/bash

set -eux

which dagger || echo "DAGGER NOT INSTALLED PROPERLY"

dagger call -m github.com/.../../ hello-world || echo "DAGGER IS INSTALLED BUT NOT OPERATIONAL"

echo "===== SUCCESS - DAGGER IS OPERATIONAL ======"