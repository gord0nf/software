#!/bin/bash

${APT:-apt} install -y --ignore-missing wget openssh ca-certificates
${APT:-apt} install -y bash curl unzip tar grep
