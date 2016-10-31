#!/bin/bash
sudo mongod &
R CMD Rserve
GEMPATH=$(gem path nano-lazar)
cd $GEMPATH
unicorn -c unicorn.rb -E production -D

exit 0
