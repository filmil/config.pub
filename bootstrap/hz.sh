#! /usr/bin/env bash

#] # Hetzner setup

useradd
#!/bin/bash

# This script must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "PasswordAuthentication no" >> /etc/ssh/ssh_config.d/no_passwords

USERNAME="filmil"
ROOT_SSH_KEYS="/root/.ssh/authorized_keys"
USER_HOME="/home/$USERNAME"
USER_SSH_DIR="$USER_HOME/.ssh"
USER_SSH_KEYS="$USER_SSH_DIR/authorized_keys"

echo "Creating user '$USERNAME'..."
# Create the user with a home directory (-m) and set their default shell
useradd -m -s /bin/bash "$USERNAME"

if [ $? -ne 0 ]; then
    echo "Failed to create user '$USERNAME'. Does the user already exist?"
    exit 1
fi

echo "Please set the password for '$USERNAME':"
passwd "$USERNAME"

if [ $? -ne 0 ]; then
    echo "Failed to set password."
    # Decide if you want to exit here or continue.
    # For this script, we'll continue to set up SSH keys.
fi

echo "Attempting to add user '$USERNAME' to sudo group (sudo/wheel)..."
SUDO_GROUP=""
if getent group sudo >/dev/null 2>&1; then
    SUDO_GROUP="sudo"
elif getent group wheel >/dev/null 2>&1; then
    SUDO_GROUP="wheel"
fi

if [ -n "$SUDO_GROUP" ]; then
    usermod -aG "$SUDO_GROUP" "$USERNAME"
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to add user to '$SUDO_GROUP' group."
    else
        echo "Successfully added user '$USERNAME' to '$SUDO_GROUP' group."
    fi
else
    echo "Warning: Neither 'sudo' nor 'wheel' group found. Skipping sudo privileges."
fi


# Check if the root authorized_keys file exists
if [ ! -f "$ROOT_SSH_KEYS" ]; then
    echo "Warning: '$ROOT_SSH_KEYS' not found. Skipping SSH key copy."
    echo "User '$USERNAME' created successfully, but without SSH keys."
    exit 0
fi

echo "Copying root's SSH authorized_keys..."

# Create the .ssh directory for the new user
mkdir -p "$USER_SSH_DIR"
if [ $? -ne 0 ]; then
    echo "Failed to create directory '$USER_SSH_DIR'."
    exit 1
fi

# Copy the keys
cp "$ROOT_SSH_KEYS" "$USER_SSH_KEYS"
if [ $? -ne 0 ]; then
    echo "Failed to copy SSH keys."
    exit 1
fi

echo "Setting permissions for $USERNAME's .ssh directory..."

# Set correct ownership
chown -R "$USERNAME:$USERNAME" "$USER_SSH_DIR"
if [ $? -ne 0 ]; then
    echo "Failed to set ownership on '$USER_SSH_DIR'."
    exit 1
fi

# Set correct permissions
# 700 for the directory (drwx------)
chmod 700 "$USER_SSH_DIR"
# 600 for the file (-rw-------)
chmod 600 "$USER_SSH_KEYS"

if [ $? -ne 0 ]; then
    echo "Failed to set permissions on .ssh directory or authorized_keys file."
    exit 1
fi

echo "Successfully created user '$USERNAME' and copied SSH keys."
exit 0


# vim: set ft=bash
