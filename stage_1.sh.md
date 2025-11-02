```sh
#! /usr/bin/env bash

```
# filmil's configuration files

The environment file (default: `.env` in current dir) contains secrets that
you need to prepopulate.

e.g.
```bash
GH_PUBLIC_KEY="..."
INSTALLDIR="..." # default: ${HOME}.
SSH_PASSPHRASE=""
CONFIG_TEST_PRINT=""
```

----

First, load the environment file. This must be created or we fail the
installation. Use the environment file to specify install variables.

```sh
ENVFILE="${ENVFILE:-.env}"
if [[ ! -f "${ENVFILE}" ]]; then
    echo "ERROR: missing environment file ${ENVFILE}. It must exist to proceed."
    exit 1
fi
source "${ENVFILE}"

```
I'm always wondering if I should print these or not. Install is noisy as it
is.

```sh
echo "INFO:"
echo "INFO:"
echo "INFO:"
echo "INFO: Install stage 1"
echo "INFO:"
echo "INFO:"
echo "INFO:"

```
Ensure that a failing subcommand fails the script. We don't want to fail
silently.

```sh
set -e pipefail

```
Use `INSTALLDIR="some/dir/of/your/choice"` to redirect the installation. This
is mostly useful for tests.

```sh
INSTALLDIR="${INSTALLDIR:-${HOME}}"
if [[ -f "${INSTALLDIR}/.block_config" ]]; then
    echo "ERROR: installation is blocked, remove ${INSTALLDIR}/.block_config to proceed"
    exit 1
fi
mkdir -p "${INSTALLDIR}"

```
Most defaults are computed based off of `INSTALLDIR`.

```sh
MACHINE="${MACHINE:-$(uname -a)}"
CONFIGDIR="${INSTALLDIR}/.config"


if [[ ${CONFIG_TEST_PRINT:-} != "" ]]; then
    echo "WARNING: Read from test config: ${CONFIG_TEST_PRINT}"
fi

```
Verbose logging for the rest, so that we can check the terminal spew to know
how far along we are.

```sh
set -x

```
Install the minimum scriptage. We need `ssh `to generate keys, and `wget` to
download the github cli. Github cli is used to access the configuration repo
which is where "stage 2" is located.

```sh
sudo apt-get update && sudo apt-get --assume-yes install ssh wget
GH_BINARY_DEB="https://github.com/cli/cli/releases/download/v2.82.1/gh_2.82.1_linux_amd64.deb"
TMP_DIR="$(mktemp --tmpdir -d config.stage_1.d-XXXXXXX)"
echo "INFO: Using temporary dir: ${TMP_DIR}"
cd "${TMP_DIR}"

```
Download the Github cli DEB package. This should work on all my Ubuntus.

```sh
(
    wget --output-document=gh.deb "${GH_BINARY_DEB}"
    sudo dpkg -i gh.deb
)

```
Generate SSH key for this machine.

```sh
(
    KEYFILE="ed25519"
    echo "INFO: Creating ${INSTALLDIR}/.ssh"
    cd "${INSTALLDIR}"
    mkdir -p .ssh
    chmod go-rwx .ssh
    cd .ssh
    if [[ "${SSH_SKIP_KEYGEN}" != "yes" ]]; then
        rm -f "${KEYFILE}" "${KEYFILE}.pub"
        ssh-keygen -t ed25519 -N "${SSH_PASSPHRASE:-}" -f "${KEYFILE}"
    fi
    cat <<EOF > "${INSTALLDIR}/.ssh/config"
Host github.com
    Hostname github.com
    IdentityFile ~/.ssh/${KEYFILE}
EOF

    if [[ "${GH_SKIP_KEY_UPLOAD:-}" != "yes" ]]; then
        gh auth login \
            --hostname github.com \
            -p ssh
        gh ssh-key add ed25519.pub --title "${MACHINE}"
    fi
)

```
Finally, install the rest of the software and stop, for now.

```sh
(
    echo "INFO: Loading stage 2"
    mkdir -p "${CONFIGDIR}"
    cd "${CONFIGDIR}"
    sudo apt-get install apt make git puppet stow cmake ssh
    git clone git@github.com:filmil/config filmil@gmail.com

    echo "INFO: Loaded stage 2 - proceed manually"
)

```
A modeline at the end to help vim.

```sh
# vim: set ft=bash
```
