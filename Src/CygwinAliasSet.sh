#!/usr/bin/bash

#
# This script is to add chef command aliases to /etc/bash.bashrc.
# (for Cygwin)
#
# e.g.
# alias knife='/cygdrive/c/opscode/chefdk/embedded/bin/ruby C:/opscode/chefdk/bin/knife'
# alias chef-client='/cygdrive/c/opscode/chefdk/embedded/bin/ruby C:/opscode/chefdk/bin/chef-client'
# alias chef='/cygdrive/c/opscode/chefdk/embedded/bin/ruby C:/opscode/chefdk/bin/chef'
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

RUBY_PATH=$(dirname $(dirname $CHEF_PATH))/embedded/bin/ruby

if [ ! -f "$RUBY_PATH" ]; then
    echo -e "not found ruby..."
    exit
fi

BLOCK_START='##Chef_Aliases_Block_Start'
BLOCK_END='##Chef_Aliases_Block_End'
BASHRC=/etc/bash.bashrc

FIND_START=$(grep "$BLOCK_START" -n $BASHRC)
FIND_END=$(grep "$BLOCK_END" -n $BASHRC)

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

    EXCLUDE_CMD=("chef-zero")

    # chef standard
    find $(dirname $CHEF_PATH) -name '*.bat' | while read BAT; do
        CMD_PATH=$(convert_cyg2win $BAT)
        ALIAS=$(basename $CMD_PATH)

        for EXCLUDE in ${EXCLUDE_CMD[@]};do
            if [ "$ALIAS" = "$EXCLUDE" ]; then
                continue 2
            fi
        done

        echo "alias $ALIAS='$RUBY_PATH $CMD_PATH'"
    done

    ZERO_PATH=$(dirname $(dirname $CHEF_PATH))/embedded/bin/chef-zero

    # chef-zero batch copy for dos-prompt
    ZERO_ALT_BAT=$(dirname $0)/chef-zero.bat
    if [ -f "$ZERO_PATH" -a -f "$ZERO_ALT_BAT" ]; then
        cp $ZERO_ALT_BAT $(dirname $CHEF_PATH)/
    fi

    # chef-zero alias for cygwin
    if [ -f "$ZERO_PATH" ]; then
        CMD_PATH=$(convert_cyg2win $ZERO_PATH)
        ALIAS=chef-zero
        echo "alias $ALIAS='$RUBY_PATH $CMD_PATH'"
    fi

    echo $BLOCK_END
} >> $BASHRC
