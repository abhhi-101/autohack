#!/bin/bash

#To cat all the nuclei files from your project-database for easy access.


cd ~/projects
for host in $(find . | grep nuclei);do cat $host; done
