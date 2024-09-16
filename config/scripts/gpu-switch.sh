#!/bin/bash

GPU_MODE=$(optimus-manager --print-mode | awk '{print $5}')

case "$GPU_MODE" in
    "integrated")
        yes | optimus-manager --switch hybrid
        ;;
    *)
        yes | optimus-manager --switch integrated
        ;;
esac
