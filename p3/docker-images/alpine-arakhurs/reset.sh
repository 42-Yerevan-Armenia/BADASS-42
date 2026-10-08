#!/bin/sh
set -eu

ip addr flush dev eth0
ip link set eth0 down
