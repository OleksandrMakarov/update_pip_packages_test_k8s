#!/bin/bash

{
    update-pip-packages -v
    update-pip-packages --version
    update-pip-packages -h
    update-pip-packages --help
    update-pip-packages --app
    update-pip-packages --pip
} &>"/hostPath/ubuntu_$(date +%d%m%Y_%H%M%S).log"
