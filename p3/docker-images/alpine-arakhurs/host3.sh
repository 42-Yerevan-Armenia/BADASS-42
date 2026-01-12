#!/bin/sh
ip link set eth0 up
ip addr add 10.0.10.3/24 dev eth0
