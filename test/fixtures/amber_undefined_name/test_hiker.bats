#!/usr/bin/env bats

source ./hiker.sh

@test "life the universe and everything" {
  local actual=$(ansewr)
  [ "$actual" == "42" ]
}
