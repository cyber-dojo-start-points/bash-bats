#!/bin/bash

source ./checksum.sh

answer()
{
  echo $((6 * $(checksum)))
}
