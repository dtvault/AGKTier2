#!/bin/bash

#=============================================
# Download AGKTier2 to create a PiPlayer for
# the Raspberry PI 4.
#=============================================
# Created by tboy
#=============================================
# By using this script you agree that if your
# Raspberry Pi goes *bang* it's your fault.
# ============================================
# Enjoy!
#=============================================

# Exit if a command fails
set -e

clear

echo "============================================"
echo -e "         \033[0;91mAppGameKit Pi 4 Edition\033[0m"
echo "============================================"
echo " This script attempts to help automate the  "
echo " process of installing and downloading all  "
echo " the packages and libraries required to get "
echo " AppGameKit running on your Pi 4.           "
echo "============================================"
echo ""
echo "Before we begin..."
echo ""
echo "I would like to perform a couple of checks"
echo "to make sure you have the required system"
echo "to continue..."
printf "\nDo you want to continue? [y/n]: "

while read user_response;
do
  if [[ ("${user_response^^}" =~ ^[N]$) ]]; then
    echo "See ya!"
    exit
  elif [[ ("${user_response^^}" =~ ^[Y]$) ]]; then
    printf "\nGreat! You have chosen to continue\n\n"
    break
  fi
done

OS_VERSION="cat /etc/os-release"
OS_OUTPUT=$($OS_VERSION)

PI_VERSION="cat /proc/cpuinfo"
PI_OUTPUT=$($PI_VERSION)

if [[ ("${PI_OUTPUT^^}" != *"RASPBERRY PI 4"*) ]]; then
  echo -e "================================================"
  echo -e "Sorry, You need a \033[0;91mRaspberry Pi 4\033[0m to continue... "
  echo -e "================================================"
  exit
else
  echo -e "============================================================="
  echo -e "Yippee! You have a \033[0;91mRaspberry Pi 4\033[0m, operation will continue..."
  echo -e "============================================================="
  echo ""
fi

if [[ ("${OS_OUTPUT^^}" != *"RASPBIAN"*) && ("${OS_OUTPUT^^}" != *"BUSTER"*) ]]; then
  echo -e "============================================================="
  echo -e "It appears that you're not running Raspbian (Buster)"
  echo -e "I have only tested this on a \033[0;91mPi 4\033[0m with Raspbian (Buster)"
  echo -e "============================================================="
  printf "\nDo you want to continue? [y/n] "
  
  while read user_response;
  do
    if [[ ("${user_response^^}" =~ ^[N]$) ]]; then
      echo "See ya!"
      exit
    elif [[ ("${user_response^^}" =~ ^[Y]$) ]]; then
      printf "\nGreat! You have chosen to continue"
      break
    fi
  done
 
  echo -e "============================================================="
else
  printf "Awesome! It appears that you have the required system to continue... Let's go!\n\n"
  sleep 3s
fi

CMD_GIT="git clone"
HOST_SOURCE="https://github.com"
HOST_GLFW="/glfw/glfw"
HOST_AGKTIER2="/TheGameCreators/AGKTier2"

# You should have some of the following installed already, but will check anyway.
COMMANDS=("git" "build-essential" "cmake" "libopenal-dev" "libcurl4-openssl-dev"
          "libpng-dev" "libjpeg-dev" "xorg-dev" "libglu1-mesa-dev" "libudev-dev")

printf "Checking for required programs...\n\n"

for FILES in ${COMMANDS[@]}
do
  if ! dpkg -s $FILES &> /dev/null; then
    echo ""
    echo -e "$FILES => \033[0;91mnot found\033[0m"
    echo ""
    echo "Installing $FILES now..."
    echo ""
    sudo apt-get --yes install $FILES
  else 
    echo -e "$FILES => \033[0;92mfound\033[0m"
  fi
done

HOST_AGKTIER2_SUBSTR=$(echo $HOST_AGKTIER2 | cut -d'/' -f 3)
if [ -d $HOST_AGKTIER2_SUBSTR ]; then
  echo ""
  echo $HOST_AGKTIER2_SUBSTR "folder already exists"
else
  echo "======================================"
  echo " Downloading AGKTier2 from repository "
  echo "======================================"
  $CMD_GIT $HOST_SOURCE$HOST_AGKTIER2
  
  echo ""
  echo "========================================="
  echo " When you run the LinuxPlayer, you may   "
  echo " experience a green overlay when running "
  echo " 3D examples due to a shader issue.      "
  echo "========================================="
  echo ""
  echo "==================================="
  echo "         AGKShader.cpp fix         "
  echo "==================================="
  echo " If you're certain the issue still "
  echo " exists and you will NOT overwrite "
  echo " any update, please continue...    "
  echo "==================================="
  printf "\nDo you want to apply the fix? [y/n]: "

  while read user_response;
  do
    if [[ ("${user_response^^}" =~ ^[N]$) ]]; then
      echo ""
      echo "=================================="
      echo " You can apply the fix later by   "
      echo " running agkshader-fix.sh         "
      echo "=================================="
      echo ""
      break
    elif [[ ("${user_response^^}" =~ ^[Y]$) ]]; then
      echo ""
      echo "Before fix: "
      sed '1841q;d' $HOST_AGKTIER2_SUBSTR/common/Source/AGKShader.cpp 
      echo ""
      sed -i '1841s/colorVarying = color/colorVarying = vec4(1.0, 1.0, 1.0, 1.0)/' $HOST_AGKTIER2_SUBSTR/common/Source/AGKShader.cpp
      echo "After fix: "
      sed '1841q;d' $HOST_AGKTIER2_SUBSTR/common/Source/AGKShader.cpp 
      echo ""
      break
    fi
  done
fi

HOST_GLFW_SUBSTR=$(echo $HOST_GLFW | cut -d'/' -f 3)
if [ -d $HOST_GLFW_SUBSTR ]; then
  echo $HOST_GLFW_SUBSTR "folder already exists"
else
  echo "=================================="
  echo " Downloading GLFW from repository "
  echo "=================================="
  $CMD_GIT $HOST_SOURCE$HOST_GLFW
fi

# We need to build GLFW first
cd $HOST_GLFW_SUBSTR
mkdir -p $HOST_GLFW_SUBSTR"-build"
cd $HOST_GLFW_SUBSTR"-build"
# Let's turn them all off to save some space
cmake .. -DGLFW_BUILD_DOCS=OFF -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF
# if you want a quicker build use: sudo make -j4 install 
sudo make install

cd ..
cd ..

# Let's build AGKTier2
cd $HOST_AGKTIER2_SUBSTR
make
cd apps/interpreter_linux
make

cd build

ARCH=$(getconf LONG_BIT)
AGK_PLAYER="LinuxPlayer"$ARCH

if ls $AGK_PLAYER 1> /dev/null 2>&1; then
  echo ""
  echo "================================="
  echo "        Congratulations!         "
  echo "================================="
  echo "You should have a working player "
  echo -e "for the \033[0;91mRaspberry Pi 4\033[0m."
  echo "================================="
  echo "copy PiPlayer to:                " 
  echo "AGKPi/Tier1/Compiler/interpreters"
  echo "================================="
  echo ""
  
  #Rename LinuxPlayer to PiPlayer
  cp $AGK_PLAYER "PiPlayer"
  
  ./$AGK_PLAYER
fi
