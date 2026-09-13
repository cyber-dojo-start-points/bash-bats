#!/usr/bin/env bats

source ./fizz_buzz.sh

@test "life the universe and everything" {
  local actual=$(fizz_buzz)
  [ "$actual" == "42" ]
}
