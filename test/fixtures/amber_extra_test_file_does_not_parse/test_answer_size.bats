#!/usr/bin/env bats

source ./hiker.sh

@test "the answer is two digits long" {
  local actual=$(answer
  [ "${#actual}" == "2" ]
}
