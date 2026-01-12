#!/bin/sh
ip link set eth0 up
ip addr add 10.0.10.1/24 dev eth0
