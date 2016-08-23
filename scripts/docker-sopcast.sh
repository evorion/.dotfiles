#!/usr/bin/env bash

usage() {
    cat <<EOM
Usage:
$(basename "$0") <sopcast-url>
EOM
    exit 1
}

find_empty_port() {
  local find_empty_port="
import socket
s=socket.socket()
s.bind(('', 0))
print(s.getsockname()[1])
s.close()
"
  local empty_port=$(python -c "$find_empty_port")
  echo "$empty_port"
}

is_container_running() {
  local container_id=$1
  docker inspect -f "{{.State.Running}}" "$container_id"
}

main() {
  if [[ $# != 1 ]]; then
    usage
  fi

  local sopcast_url=$1
  local empty_port=$(find_empty_port)
  local container_id=$(docker run -d \
    -p "$empty_port:$empty_port" \
    danihodovic/sopcast "$sopcast_url" "$empty_port")

  for _ in $(seq 1 40); do
    if [[ $(is_container_running "$container_id") = 'false' ]]; then
      echo 'Container no longer running. Stream sucks'
      exit 1
    else
      echo 'Waiting for stream to start...'
    fi
    sleep 0.5
  done

  if [ "$(is_container_running "$container_id")" = 'true' ]; then
    cvlc http://localhost:"$empty_port"/tv.asf &>/dev/null & disown
  else
    echo 'Container failed to start. The stream probably sucks'
    exit 1
  fi
}

main "$@"
