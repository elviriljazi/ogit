#!/bin/sh
#---------------------------------------------
#   ogit
#
#   Utility script to open a URL in the registered default application.
#
#   Refer to the usage() function below for usage.
#
#---------------------------------------------

manualpage() {

  cat <<_MANUALPAGE

ogit - opens URL in the user's preferred application


ogit { --help | --version }

Description

ogit opens URL in the user's preferred application. If a URL is
provided the URL will be opened in the user's preferred web browser.

ogit is for use inside a desktop session only. It is not recommended to use
ogit as root.

Options

--help
    Show this manual page.
--version
    Show the ogit version information.

Examples

ogit -l
Shows the list of all repositories from configurations.

ogit -l add
Shows the list and add new repository

ogit 0 branch-1.0.0 branch-2.0.1
Opens the GitHub URL that compare branches e.g. 'https://github.com/username/repository/compare/branch-1.0.0...branch-2.0.1'

ogit /tmp/foobar.png

Opens the PNG image file /tmp/foobar.png in the user's default image viewing
application.

_MANUALPAGE
}
config() {

  cat <<_CONFIG

sudo ogit config - use root privileges to config this application


_CONFIG
}
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  manualpage
fi
if [ "$1" = "config" ]; then
fi
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
else
  read -p "Enter username: " username
  echo $username >/usr/bin/ogitfiles/userdetails
  read -p "Enter number of repos " reponr
  printf '%b' '\0' >/usr/bin/ogitfiles/repo.lst
  for i in $(seq 0 $(($reponr - 1))); do
    read -p "Enter repo $i : " repo
    echo $repo >>/usr/bin/ogitfiles/repo.lst
  done
fi
if [ "$1" = "-install" ]; then
  chmod 755 ogit
  sudo cp ogit /usr/bin
  sudo mkdir /usr/bin/ogitfiles/
fi
if [ "$1" = "-l" ] || [ "$1" = "-list" ]; then
  n=0
  while read i; do
    echo "$n : $i"
    n=$((n + 1))
  done </usr/bin/ogitfiles/repo.lst
elif [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]; then
  n=0
  while read i; do
    if [ $n = $1 ]; then
      repo=$i
    fi
    n=$((n + 1))
  done </usr/bin/ogitfiles/repo.lst
  n=0
  while read i; do
    if [ $n = "0" ]; then
      user=$i
    fi
    n=$((n + 1))
  done </usr/bin/ogitfiles/userdetails
  USER=$user
  REPO=$repo
  BASE=$2
  COMPARE=$3
  xdg-open "https://github.com/$USER/$REPO/compare/$BASE...$COMPARE"
fi
if [ "$1" = "-l" ] && [ "$2" = "add" ]; then
  read -p "Enter repo name: " re
  echo $repo >>/usr/bin/ogitfiles/repo.lst
fi
if [ "$1" = "-l" ] && [ "$2" = "rm" ] && [ "$3" != "" ]; then
  read -p "Enter repo name: " REPO
fi
if [ "$1" = "--version" ] || [ "$1" = "-V" ]; then
  echo "v1.0"
fi
