#!/bin/bash

set -e

clear

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
    exit
  elif [[ ("${user_response^^}" =~ ^[Y]$) ]]; then
    echo ""
    echo "Before fix: "
    sed '1841q;d' AGKTier2/common/Source/AGKShader.cpp 
    echo ""
    sed -i '1841s/colorVarying = color/colorVarying = vec4(1.0, 1.0, 1.0, 1.0)/' AGKTier2/common/Source/AGKShader.cpp
    echo "After fix: "
    sed '1841q;d' AGKTier2/common/Source/AGKShader.cpp 
    echo ""
      
    # Let's rebuild AGKTier2
    cd AGKTier2
    make
    cd apps/interpreter_linux
    make
    
    ARCH=$(getconf LONG_BIT)
    AGK_PLAYER="LinuxPlayer"$ARCH
    
    cd build
    
    rm -f "PiPlayer"
    
    cp $AGK_PLAYER "PiPlayer"
    
    break
  fi
done

