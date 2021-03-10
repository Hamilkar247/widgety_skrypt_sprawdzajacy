#!/bin/bash

function readConfig
{
  echo "zczytuje zmienne z config_screenshot.json"
  #jeśli niedziala upewnij się że jest zainstalowany sudo apt-get install jq
  timeToSleep="$(jq '.timeToCheckScreenshot' config_screenshot.json)"
  if [[ "$timeToSleep" == "" ]]
    then
      timeToSleep=240
      echo "ahjo nie ma zmiennej timeToSleep"
      exit
  fi
}

readConfig
var_nofound=0
while true
do
  echo "sprawdzam czy plik working_screeshot.txt istnieje"
  if [[ -f "/tmp/working_screenshot.txt" ]]
    then
      echo "usuwam plik working_screenshot.txt"
      rm "/tmp/working_screenshot.txt"
      var_nofound=0
  else
    echo "nie znalazłem pliku"
    var_nofound="$(( var_nofound+1 ))"
  fi
  echo "var_nofound=$var_nofound"
  if [[ "$var_nofound" -eq "3" ]]; #is a greater than or equal
    then
      echo "nie znaleziono pliku po raz trzeci pliku"
      var_nofound=$(( var_nofound+1 ))
      echo "Wykonuje systemctl start i stop na serwisie"
      systemctl stop screenshot.service
      systemctl start screenshot.service
  fi

  #sprawdzam czy zmieniły się dane w config_screenshot.json
  readConfig
  sleep "$timeToSleep" #czas w sekundach
done
