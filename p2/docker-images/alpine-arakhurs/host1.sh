#!/bin/sh
set -e
ip addr add 10.0.10.1/24 dev eth0
ip link set eth0 up