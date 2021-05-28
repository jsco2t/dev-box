
# inspiration for some of the items below from:
# https://www.digitalocean.com/community/questions/what-are-your-favorite-bash-aliases

# Help:
function helpme() {
  printf "Command 'c':                      Clear screen \n"
  printf "Command 'cl':                     Clear screen, list dirs \n"
  printf "Command 'whatsize [dirname]':     Reports the folder size \n"
  printf "Command 'whatsizes':              Reports folder sizes for folders in current dir \n"
  printf "Command 'recurse [command]'       Runs the same command on all subdirs\n"
  printf "Command 'myip'                    Reports ip addresses\n"
  printf "Command 'nanobk [file]'           Backs up file, opens orig in nano\n"
}

#
# dir helpers and aliases
#

# helpers for getting dir sizes
alias whatsize="du -sh "

function whatsizes() {
  for file in */ .*/ ; do
    dirname="$(basename "${file}")"
    if [ "$dirname" != "." ] && [ "$dirname" != ".." ] ; then whatsize $file ; fi
  done
}

# helpers for dir listing
alias l="ls -laF"

# helpers to get back home
alias home="cd ~"

#
# utility functions
#

# recurse():
#
# recurse helper function will run the supplied command on each
# subdir of the current directory.
#
# Example:
# recurse ls -l
#
# In chef - it's useful to go to the cookbook dir and then get status on git:
# recurse git status -s
#
# Based on:
# http://superuser.com/questions/608286/execute-a-command-in-all-subdirectories-bash
recurse() {
  shopt -s globstar
  origdir="$PWD"
  for i in **/; do
    cd "$i"
    echo -n "${PWD}: "
    eval "$@"
    echo
    cd "$origdir"
  done
}

# reports ip addresses
function myip() {
    extIp=$(dig +short myip.opendns.com @resolver1.opendns.com)

    printf "Wireless IP: \n"
    MY_IP=$(ifconfig en0 | awk '/inet/ { printf "%s \n", $2 } ' |
      sed -e s/addr://)
    printf "%s\n" ${MY_IP:-"Not connected"}

    echo ""
    echo "Ext IP: $extIp"
}

# open nano and make backup of original file.
function nanobk() {
    echo "You are making a copy of $1 before you open it. Press enter to continue."
    read nul
    cp $1 $1.bak
    nano $1
}

#
# screen/ui/prompt utilities
#

# clear the screen of your clutter
alias c="clear"
alias cl="clear;ls;pwd"

#
# helper for setting tab title
#
function set-title() {
    #echo -ne "\033]0;"$*"\007" # doesn't work in zsh

    # PATCHED below to override copy in .oh-my-zsh/lib/termsupport.sh
    export TERM_TITLE="$*"
}

function clear-title() {
  if [[ -n "$TERM_TITLE" ]]; then
    unset TERM_TITLE
  fi
}

# override oh-my-zsh handling:
function title {
  emulate -L zsh
  setopt prompt_subst

  [[ "$EMACS" == *term* ]] && return

  # if $2 is unset use $1 as default
  # if it is set and empty, leave it as is
  : ${2=$1}

  # jscott patch for custom title
  if [[ -n "$TERM_TITLE" && "$TERM_TITLE" != "" ]]; then
    print -Pn "\e]2;$2:q\a" # set window name
    print -Pn "\e]1;$TERM_TITLE:q\a" # set tab name
  else
    print -Pn "\e]2;$2:q\a" # set window name
    print -Pn "\e]1;$1:q\a" # set tab name
  fi
}

# custom tree commands (https://linux.die.net/man/1/tree), (brew install tree)
function lt {
  dir='.'
  level=2
  
  if [ "$1" != "" ]; then
    dir="$1"
  fi

  if [ "$2" != "" ]; then
    level="$2"
  fi
  
  tree -aphC "$dir" -L $level
}

function lta {
  dir='.'
  level=2
  
  if [ "$1" != "" ]; then
    dir="$1"
  fi

  if [ "$2" != "" ]; then
    level="$2"
  fi

  tree -aphDC "$dir" -L $level
}

function ltd {
  dir='.'
  level=2
  
  if [ "$1" != "" ]; then
    dir="$1"
  fi

  if [ "$2" != "" ]; then
    level="$2"
  fi

  tree -aDtC "$dir" -L $level
}