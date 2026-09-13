#!/usr/bin/env bats

source ./hiker.sh

@test "life the universe and everything" {
  local actual=$(answer)
  [ "$actual" == "42" ]
}

@test "the answer is two digits long" {
  local actual=$(answer)
  [ "${#actual}" == "3" ]
}

@test "the answer is not the question" {
  local actual=$(answer)
  [ "$actual" == "6 * 7" ]
}
