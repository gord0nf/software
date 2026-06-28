#!/bin/bash

${APT:-apt} install -y \
  sway swayidle swaylock \
  wl-clipboard libglib2.0-bin \
  brightnessctl brightness-udev \
  playerctl
