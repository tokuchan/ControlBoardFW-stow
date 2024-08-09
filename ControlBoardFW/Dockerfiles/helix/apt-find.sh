#!/bin/bash

# Search for APT packages with specific keywords, presented in a nice table.

# Pull the first argument out as a search keyword
keyword="$1"
shift

apt search "$keyword" 2>/dev/null | awk 'NR >= 3 {print}' | awk '
/^[^ ]/ {pkg=$1; ver=$2; arch=$3};
/^[  ]/ && nextline=1 {nextline=0; printf("pkg %s\nver %s\narch %s\ndesc %s\n\n", pkg, ver, arch, $0)};
/^[ ]*$/ {nextline=1}' | mlr -i xtab -o pprint grep "$keyword" $@
