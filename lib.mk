SHELL=bash

## Macros
assertEnv=@if [ -z $${$(strip $1)+x} ]; then >&2 echo "You need to define \$$$(strip $1)"; exit 1; fi
done=@echo "+$(1)"
