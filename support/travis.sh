#/bin/sh
set -e
set -x

mkdir ~/.yard
bundle exec yard config -a autoload_plugins yard-doctest
