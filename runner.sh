#!/bin/sh
exec &> >(tee -a /config/runner.log)
find /config/ -name "*.ps1" -exec pwsh {} \;
