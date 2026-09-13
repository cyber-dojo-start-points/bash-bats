#!/usr/bin/env bats

source ./hiker.sh

@test "the answer is three digits long" {
  local actual=$(answer)
  [ "${#actual}" == "3" ]
}
