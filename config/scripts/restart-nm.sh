#!/bin/bash

WIFI_INTERFACE=wlp0s20f3

nmcli device disconnect $WIFI_INTERFACE
nmcli device connect $WIFI_INTERFACE
