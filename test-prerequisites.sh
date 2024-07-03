#!/bin/bash
set -eu

# @todo - download ascii art package locally, for this file.

# RETVAL=`which docker && which docker-compose && which make`
# @todo - check the exit code if it's 1 or 0 then do an echo


which docker || echo "DOCKER IS MISSING"
which docker-compose || echo "DOCKER COMPOSE IS MISING"
which make || echo "MAKE IS MISSING"

echo "======= ALL CHECKS COMPLETE ======"

