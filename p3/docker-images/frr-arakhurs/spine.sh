#!/bin/bash
ip link set eth0 up
ip addr add 192.168.0.1/24 dev eth0
