#] # Bootstrapping script
#! /bin/sh

#] [![test](https://github.com/filmil/config.pub/actions/workflows/test.yml/badge.svg)](https://github.com/filmil/config.pub/actions/workflows/test.yml)
#]
#] Use the following easy script to start. This is a boostrap loader for my
#] config and dotfiles. It requires internet access. It must be public.
#]
#] It is also available at [bootstrap.sh](./bootstrap/bootstrap.sh)

sudo apt-get --assume-yes install wget && \
wget --output-document=stage_1.sh \
    wget https://hdlfactory.com/config/stage_1.sh
chmod u+x stage_1.sh && ./stage_1.sh

#] This script is set up so that it's easy to cut and paste from a web page.
#] It will do the bare minimum required to load the second stage.
#]
#] See [stage 1 documentation](./stage_1.sh.md) for stage 1 details.

