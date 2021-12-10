#!/bin/bash

cd ~/projects
for host in $(find . | grep nuclei);do cat $host; done
