#!/usr/bin/env bats

source ./hiker.sh

@test "life the universe and everything" {
  local actual=$(answer)
  [ "$actual" == "42" ]
}

@test "the checksum of the answer" {
  local actual=$(checksum)
  [ "$actual" == "0" ]
}
