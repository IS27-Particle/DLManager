#!/bin/sh
find /config/ -name "*.ps1" -exec pwsh {} \;
