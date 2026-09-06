#!/bin/bash

# Variables para evitar notificaciones duplicadas
notified_20=0
notified_10=0
notified_5=0

while true; do
  # Obtener estado y nivel de batería
  battery_status=$(acpi -b | grep -o 'Discharging\|Charging\|Full')
  battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')

  # Si está descargando (no enchufado)
  if [ "$battery_status" = "Discharging" ]; then
    # Notificación al llegar o bajar del 20%
    if [ "$battery_level" -le 20 ] && [ "$notified_20" -eq 0 ]; then
      notify-send -u critical "🔋 Batería 20%" "Por favor, conecta el cargador."
      notified_20=1
    fi

    # Notificación al llegar o bajar del 10%
    if [ "$battery_level" -le 10 ] && [ "$notified_10" -eq 0 ]; then
      notify-send -u critical "⚠️ Batería 10%" "¡Conecta el cargador ahora mismo!"
      notified_10=1
    fi

    # Notificación al llegar o bajar del 5%
    if [ "$battery_level" -le 5 ] && [ "$notified_5" -eq 0 ]; then
      notify-send -u critical "🚨 Batería 5%" "El sistema se apagará en breve."
      notified_5=1
    fi
  fi

  # Si está cargando o tiene más del 21%, reiniciamos las banderas
  if [ "$battery_status" != "Discharging" ] || [ "$battery_level" -gt 21 ]; then
    notified_20=0
    notified_10=0
    notified_5=0
  fi

  # Esperar 60 segundos antes de la siguiente comprobación
  sleep 60
done
