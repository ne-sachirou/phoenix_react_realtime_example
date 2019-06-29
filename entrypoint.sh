#!/bin/sh -eux
# shellcheck shell=dash
if test "$(stat /.dockerenv > /dev/null || echo $?)" ; then
  : "Outside Docker"
  mix "do" deps.get, compile
else
  : "Inside Docker"
  rsync -au /tmp/_build /tmp/deps .
  mkdir -p /tmp/apps/example_web/assets/node_modules
  rsync -au /tmp/example_web_node_modules/ /tmp/apps/example_web/assets/node_modules
  mix "do" deps.get, compile
fi
(cd apps/example_web/assets && npm install)
elixir --name example@127.0.0.1 --cookie example -S mix phx.server
