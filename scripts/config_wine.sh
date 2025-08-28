#!/bin/bash
# install vcruntime and other stuff , mostly for osu!
WINEPREFIX=$HOME/configs/wine32 winetricks corefonts gdiplus vcrun2015
WINEPREFIX=$HOME/configs/wine32 winetricks --force dotnet40
WINEPREFIX=$HOME/configs/wine32 winetricks dotnet48

