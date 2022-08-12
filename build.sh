#!/bin/bash

docker build . --tag agda-mini:2.5.3 --build-arg AGDA_VERSION=2.5.3 --build-arg GHC_VERSION=8.0.2
docker build . --tag agda-mini:2.6.1 --build-arg AGDA_VERSION=2.6.1
docker build . --tag agda-mini:2.6.2.1 --build-arg AGDA_VERSION=2.6.2.1
docker build . --tag agda-mini:2.6.2.2 --build-arg AGDA_VERSION=2.6.2.2
docker build . --tag agda-mini:2.6.2.1-1.7.1 --build-arg AGDA_VERSION=2.6.2.1 --build-arg STDLIB_VERSION=1.7.1 --file stdlib.Dockerfile
docker build . --tag agda-mini:2.6.2.2-1.7.1 --build-arg AGDA_VERSION=2.6.2.2 --build-arg STDLIB_VERSION=1.7.1 --file stdlib.Dockerfile
