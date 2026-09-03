#!/bin/bash
# Ejecuta swayidle
swayidle -w \
  timeout 180 'brightnessctl -c backlight set 30%' \
  timeout 300 'brightnessctl -c backlight set 10% && niri msg action power-off-monitors' \
  timeout 600 'systemctl suspend' \
  resume 'niri msg action power-on-monitors && brightnessctl -c backlight set 50%' \
  lock 'brightnessctl -c backlight set 10% && niri msg action power-off-monitors' \
  unlock 'niri msg action power-on-monitors && brightnessctl -c backlight set 50%' \
  before-sleep 'niri msg action power-off-monitors'
