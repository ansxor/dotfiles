#!/bin/bash

mkdir -p ~/.local/share/nwg-look/gsettings
cp ~/.local/share/light-mode.d/gsettings ~/.local/share/nwg-look/gsettings
nwg-look -a
