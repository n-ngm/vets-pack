#!/usr/bin/bash

#
# This script is to add chef command aliases to /etc/bash.bashrc.
# (for Cygwin)
#
# e.g.
# alias knife='C:/opscode/chefdk/bin/knife'
# alias chef-client='C:/opscode/chefdk/bin/chef-client'
# alias chef='C:/opscode/chefdk/bin/chef'
#

if [ ! -f /Cygwin.bat ]; then
    echo -e "\e[1;31mthis script is for cygwin only.\e[0m"
    exit
fi

CHEF_PATH=$(which chef)

if [ ! $? = 0 ]; then
    echo 'chefdk may not be installed...'
    exit
fi

BLOCK_START='##Chef_Aliases_Block_Start'
BLOCK_END='##Chef_Aliases_Block_End'
BASHRC=/etc/bash.bashrc

FIND_START=$(grep -e "$BLOCK_START" -n $BASHRC)
FIND_END=$(grep -e "$BLOCK_END" -n $BASHRC)

# delete block
if [ ! -z "$FIND_START" -a ! -z "$FIND_END" ]; then
    LINE_START=$(echo -n $FIND_START | awk -F: '{print $1}')
    LINE_END=$(  echo -n $FIND_END   | awk -F: '{print $1}')
    sed -i "${LINE_START},${LINE_END}d" $BASHRC
fi

# convert function
#  using: convert_cyg2win /cygdrive/c/opscode/chefdk/bin/chef.bat
convert_cyg2win ()
{
    local CMD=${1%%.bat}             # => /cygdrive/c/opscode/chefdk/bin/chef
    local CMD_WIN=$(cygpath -w $CMD) # => C:\opscode\chefdk\bin\chef
    local CMD_CNV=${CMD_WIN//\\//}   # => C:/opscode/chefdk/bin/chef
    echo "$CMD_CNV"
    return 0
}

# add block
{
    echo $BLOCK_START

    # chef standard
    find $(dirname $CHEF_PATH) -name '*.bat' | while read BAT; do
        CMD_PATH=$(convert_cyg2win $BAT)
        ALIAS=$(basename $CMD_PATH)
        echo "alias $ALIAS='${CMD_PATH}'";
    done;

    # chef-zero
    CMD_PATH=$(convert_cyg2win $(which chef-zero))
    echo "alias chef-zero='${CMD_PATH}'";

    echo $BLOCK_END
} >> $BASHRC
