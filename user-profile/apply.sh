#!/usr/bin/env bash
set -e

here=$(dirname "$0")
cd "$here"
nix-env -f . --set

