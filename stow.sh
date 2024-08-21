#!/bin/bash
# Perform the _action_ of GNU Stow, by symlinking the ControlBoardFW directory's contents into the target.

# We require this script's location, so we know where to link FROM
source=${BASH_SOURCE[0]}
while test -L "$source"; do # Resolve source until the file is no longer a symlink
  directory=$( cd -P "$(dirname "$source" )" > /dev/null 2>&1 && pwd )
  source=$(readlink "$source")
  [[ $source != /* ]] && source=$directory/$source # if $source was a relative symlink, resolve it relative to the path where the symlink was located.
done
from_source=$( cd -P "$(dirname "$source" )" > /dev/null 2>&1 && pwd )/ControlBoardFW

to_target=$(pwd)

# Now, we just freshen up symlinks. It's not an error if a symlink already exists. We just clobber it.
function freshen_link {
  test -L $to_target/$1 && rm $to_target/$1 > /dev/null 2>&1
  ln -s "$from_source/$1" "$to_target/$1"
}

freshen_link Makefile
freshen_link Dockerfiles
freshen_link install_yocto_dependencies.sh
