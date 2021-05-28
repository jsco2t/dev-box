# Script used so that multiple instances of WSL bash consoles can share the same SSH agent.
# Once the agent is started and loads valid keys (and has pwd for those keys) then each additional
# bash instance will be able to use the SSH keys without having to re-auth/reload the keys.

env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ;
}

agent_load_env

# echo "$SSH_AUTH_SOCK"

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add ~/.ssh/id_gitlab
    ssh-add ~/.ssh/id_rsa
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add ~/.ssh/id_gitlab
    ssh-add ~/.ssh/id_rsa
fi

. "$env" >| /dev/null ;

unset env