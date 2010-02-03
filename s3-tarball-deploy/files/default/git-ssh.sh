# Wrapper script for Git to use our deploy key
ssh -i /tmp/deploy_key.pub $1 $2
