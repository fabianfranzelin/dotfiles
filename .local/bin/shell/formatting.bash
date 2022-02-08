#!/usr/bin/env bash

# disabling warnings about unused variables
# shellcheck disable=SC2034

#------------------------------------------------------------------------------#
# formatting-settings

. "${__SHELL_LIB}/formatting.sh"

#------------------------------------------------------------------------------#
# shell-info

__USED_SHELL='bash'
__USERNAME='\u'
__HOSTNAME='\h'
__HOSTNAME_IP='\H'
__SHORT_PWD='\W'
__LONG_PWD='\w'
