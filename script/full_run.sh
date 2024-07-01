#!/bin/bash

# Remove log file
rm ./sim_run.log
rm ./syn_run.log
rm ./post_sim_run.log

./sim_run.sh > sim_run.log
./syn_run.sh > syn_run.log
./post_sim_run.sh > post_sim_run.log
