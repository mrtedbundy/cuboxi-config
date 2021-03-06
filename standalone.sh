#!/bin/sh
# Part of cuboi-config http://github.com/kicker22004/cuboxi-config
#
# See LICENSE file for copyright and license details

INTERACTIVE=True
ASK_TO_REBOOT=0

calc_wt_size() {
  # NOTE: it's tempting to redirect stderr to /dev/null, so supress error
  # output from tput. However in this case, tput detects neither stdout or
  # stderr is a tty and so only gives default 80, 24 values
  WT_HEIGHT=17
  WT_WIDTH=$(tput cols)

  if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
    WT_WIDTH=80
  fi
  if [ "$WT_WIDTH" -gt 178 ]; then
    WT_WIDTH=120
  fi
  WT_MENU_HEIGHT=$(($WT_HEIGHT-8))
}

SRC=standalone

do_standalone() {
 whiptail --fb --yesno "Standalone Installer" 20 60 2 \
    --yes-button Yes --no-button No
  RET=$?
  if [ $RET -eq 0 ]; then
  (echo 123; echo 123; echo) | adduser cubox
  touch /home/cubox/.dmrc
  mkdir /usr/src/installers
  cp $SRC/cuboxi-config_standalone /usr/bin/cuboxi-config
  cp $SRC/motd /etc/init.d/
  cp $SRC/bootsplash /etc/init.d/
  cp One_Click_Installers/Minecraft_MineOs_WebUI/Auto_MineOs_Install /usr/bin/Minecraft_UI
  cp One_Click_Installers/Owncloud/Owncloud-install /usr/bin/
  cp One_Click_Installers/Owncloud/default /usr/src/installers/
  cp One_Click_Installers/Owncloud/php.ini /usr/src/installers/
  chmod +x /usr/bin/cuboxi-config
  chmod +x /etc/init.d/bootsplash
  chmod +x /etc/init.d/motd
  chmod +x /usr/bin/Minecraft_UI
  chmod +x /usr/bin/Owncloud-install  
  update-rc.d motd defaults
  update-rc.d bootsplash default
  apt-get update
  apt-get install -y build-essential
PCT=0
(
while test $PCT != 100;
do
PCT=`expr $PCT + 1`;
echo $PCT;
sleep .020;
done; ) | whiptail --fb --title "Installing.." --gauge "Copying files and permissions, Please Wait.." 20 60 1
  cd ..
  rm -rf cuboxi-config
 whiptail --fb --msgbox "Please Reboot To Complete The Install." 20 60 1
 else
  return
  fi
  ASK_TO_REBOOT=1
}

do_finish() {
  if [ $ASK_TO_REBOOT -eq 1 ]; then
    whiptail --fb --yesno "Would you like to reboot now?" 20 60 2
    if [ $? -eq 0 ]; then # yes
      sync
      reboot
    fi
  fi
  exit 0
}

#
# Interactive use loop
#
calc_wt_size
while true; do
  FUN=$(whiptail --fb --title "Cubox-i Software Configuration Tool (cuboxi-config)" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
    "1 Standalone installer" "This will install cuboxi-config on your debian image" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    do_finish
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1\ *) do_standalone ;;
      *) whiptail --fb --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --fb --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
  cd $HOME
done
