Crypto Auto Compiler
================

## Automatically compile cryptocoins

This is a very simple script to help automate the compiling of coins on your server. This has been built and tested on Ubuntu 16.04 only.

This script will install all dependicies needed. 

Usage is very simple, run the script and answer the questions.

The build is fully automated. It will clone the github in a folder using the supplied coin name.

It then detects what commands to use to compile the coin. 

I have not had a coin fail yet unless there is a development issue with the coin itself.

### Tested coins:

*  [GoaCoin](https://github.com/goacoincore/goacoin.git)

### Usage

    curl -Lo compiler.sh https://raw.githubusercontent.com/mladjom/cryptoautocompiler/master/compiler.sh

    bash compiler.sh

Happy compiling!
