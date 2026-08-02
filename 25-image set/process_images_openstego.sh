#!/bin/bash

#This is currently a copy of the code for steghide. Make sure to edit it!

#configuration variables
password="debug" #password used for embedding
stego_dir="/home/brontomage20/openstego_stegos" #directory containing the stego files
output_dir="/home/brontomage20/openstego_extracted" #directory for extracted files

#create directory if it doesnt exist
mkdir -p "$output_dir"

echo "starting openstego extraction process..."
echo "========"
echo "stego directory: $stego_dir"
echo "output directory: $output_dir"
echo "password: $password"
echo ""

#counter for tracking progress
count=0
success=0
failed=0
total=$(ls "$stego_dir"/*.bmp 2>/dev/null | wc -l)

echo "found $total stego files to process"
echo ""

#track total time and count
script_start=$(date +%s%N)
image_count="$count"
total_image_time=0

#loop through all .bmp files in the stego directory
for stego_file in "$stego_dir"/*.bmp; do
	#check if the file exists
	if [ ! -f "$stego_file" ]; then
		echo "no .bmp files found in stego directory."
		break
	fi

	#increment counter
	count=$((count + 1))

	#start timing
	START=$(date +%s%N)

	#get the base filename
	base_name=$(basename "$stego_file" .bmp)

	#define output file for extracted data
	extract_file="$output_dir/${base_name}_extracted.txt"

	echo "[$count/$total] extracting from $stego_file"
	echo "--------"

	# Run openstego extract command and capture output
	# 2>&1 redirects standard error to standard output
	output=$(openstego extract -sf "$stego_file" -xd "$output_dir" -p "$password" -f 2>&1)
	return_code=$?
	if [ $return_code -eq 0 ]; then
		echo "[*checkmark*] successfully extracted. Output directory: $output_dir"
   		# Print only a success message, the actual file name depends on what was embedded
        	success=$((success + 1))
    	else
        	echo "failed to extract from $stego_file (Return Code: $return_code)"
        	echo "OpenStego Output (Likely the README/Error):"
        	echo "---"
        	echo "$output" # Print the captured output for inspection
        	echo "---"
        	failed=$((failed + 1))
    	fi

	echo ""

	# run openstego extract command
	# -sf: stego file (file containing hidden data)
	# -xf: extract file (where to save extracted data)
	# -xd: extract directory (where to save the extract file to)
	# -p: password
	# -f: force overwrite without prompting
		#this may or may not work

#	java -jar /home/brontomage20/openstego-0.8.6/lib/openstego.jar extract -sf "$stego_file" -xd "$output_dir" -p "$password" -f
#		#note: please check this command to make sure it works; this may be the wrong format
#	
#	if [ $? -eq 0 ]; then
#		echo "[*checkmark*] successfully extracted to $extract_file"
#		success=$((success + 1))
#	else
#		echo "failed to extract from $stego_file"
#		failed=$((failed + 1))
#	fi
#
#	echo ""

	#calculate and display time
	END=$(date +%s%N)
	elapsed=$(((END - START) / 1000000))
	echo "time taken: ${elapsed} milliseconds."
	echo "==="
	echo ""

	#update counters
	image_count="$count"
	total_image_time=$((total_image_time + elapsed))
done

#calculate total time and average
script_end=$(date +%s%N)
total_time=$(((script_end - script_start) / 1000000))

if [ $image_count -gt 0 ]; then
	average_time=$((total_image_time / image_count))
else
	average_time=0
fi

echo "========"
echo "extraction complete!"
echo ""
echo "summary:"
echo " - total files processed: $count"
echo " - successful: $success"
echo " - failed: $failed"
echo ""
echo "time statistics:"
#echo " - total processing time: ${total_time} seconds ($((total_time / 60)) minutes)"
echo " - total processing time: ${total_image_time} milliseconds ($((total_image_time / 60)) minutes/1000000)"
echo " - average time per image: ${average_time} milliseconds"
echo ""
echo "output location: $output_dir"
echo "========"
