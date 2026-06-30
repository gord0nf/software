#!/bin/bash

MAJOR_VERSION=3

${APT:-apt} install -y python$MAJOR_VERSION python$MAJOR_VERSION-pip python$MAJOR_VERSION-venv ||
  ${APT:-apt} install -y python pip
