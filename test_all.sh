#!/bin/bash

prefix_path=`dirname $0`
for i in {1..100}; do
  $prefix_path/test.sh
done
