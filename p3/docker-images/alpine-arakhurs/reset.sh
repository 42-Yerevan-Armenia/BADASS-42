#!/bin/bash
set -e

ip addr flush dev eth0
ip link set eth0 down
