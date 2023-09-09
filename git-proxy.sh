#!/usr/bin/env sh
ssh -p GIT_SSH_PORT -o StrictHostKeyChecking=no git@GIT_SSH_HOST "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
