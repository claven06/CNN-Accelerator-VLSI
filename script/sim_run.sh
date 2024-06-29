#!/bin/bash

# Remove the output file if it exists
output_file="accuracy_report.txt"
rm $output_file

# Go into data/8x8t directory
cd ../data/8x8t || exit

# Loop for 5 times for 5 sets of data
for i in {1..5}; do
    # Go into data/set$i directory
    cd set"$i" || exit

    # Copy the files to the parent directory
    cp ofm.txt ifm.txt weight.txt ..

    # Move to src directory to edit CONV_ACC.v file
    cd ../../../src || exit

    # Set the filename
    filename="CONV_ACC.v"

    cd ../script || exit
    echo "Dataset: Set $i" >> "$output_file"
    cd ../src || exit

    approx_bits=0
    while [ $approx_bits -le 16 ]; do
        # Set the new content
        new_content="    parameter approx_bits    = $approx_bits"

        # Give temporary file a name
        tmpfile="$filename.tmp"

        # Edit the specific line in the temporary file
        line_count=1
        while IFS= read -r line
        do
            if [[ $line_count -eq 9 ]]; then
                echo "$new_content" >> "$tmpfile"
            else
                echo "$line" >> "$tmpfile"
            fi
            line_count=$(( line_count + 1 ))
        done < "$filename"

        # Remove and rename the files
        rm "$filename"
        mv "$tmpfile" "$filename"

        cd ../script || exit
        ./build_cnn.sh
        echo -n "  Approx_Bits: $approx_bits, " >> "$output_file"
        ./mean_percentage_error.pl >> "$output_file"

        approx_bits=$(( approx_bits + 2 ))

        cd ../src || exit
    done

    cd ../data/8x8t || exit
done

# Reformat the output file in ascending order of approx bits
cd ../script || exit
./sort_accuracy.pl
rm "$output_file"
mv "$output_file.tmp" "$output_file"
