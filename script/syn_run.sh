#!/bin/bash

# Remove the output file if it exists
rm ./synthesis_summary.txt

# Move to src directory to edit CONV_ACC.v file
cd ../src || exit

# Create reports directory
mkdir ../rpt
# Clear reports directory
rm ../rpt/*

# Create reports directory
mkdir ../gen_rpt
# Clear reports directory
rm ../gen_rpt/*

# Set the filename
filename="CONV_ACC.v"

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
    echo "Done changing approx bits in $filename"

    # Use synthesized adders for the design
    new_filelist="../../approx_add/gen_rpt/approx_${approx_bits}_ADD_APPROX.syn.v"
    tmpfilelist="filelist_synth.f.tmp"

    line_count=1
    while IFS= read -r line
    do
        if [[ $line_count -eq 1 ]]; then
            echo "$new_filelist" >> "$tmpfilelist"
        else
            echo "$line" >> "$tmpfilelist"
        fi
        line_count=$(( line_count + 1 ))
    done < "filelist_synth.f"

    rm "filelist_synth"
    mv "$tmpfilelist" "filelist_synth"

    # Start synthesis
    echo "Initiating synthesis..."
    dc_shell -f synth.tcl | tee -i run.log
    echo "Synthesis done"

    # Directory containing the files
    dir="../rpt"

    echo "Renaming reports generated by Synopsys DC"

    # Loop through all files in the directory
    for file in "$dir"/*; do
        # Get the base name of the file (without the directory path)
        base_name=$(basename "$file")
        
        # Construct the new file name
        new_name="approx_${approx_bits}_${base_name}"
        
        # Move (rename) the file
        mv "$file" "$dir/$new_name"

        # Move the renamed file to the gen_rpt directory
        mv "$dir/$new_name" "../gen_rpt/$new_name"
    done

    echo "Done Iteration for approx_bits = $approx_bits"

    approx_bits=$(( approx_bits + 2 ))
    #approx_bits=$(( approx_bits + 16 ))
    cd ../src || exit
done

cd ../script
./report_extract.pl
