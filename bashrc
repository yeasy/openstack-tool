# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Enable bash automatical completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Some useful aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

#variables
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://192.168.122.100:5000/v2.0
