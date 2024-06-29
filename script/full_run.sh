#!/bin/bash

# Remove log file
rm ./sim_run.log
rm ./syn_run.log

# Remove reports
rm ./

./sim_run.sh > sim_run.log
./syn_run.sh > syn_run.log