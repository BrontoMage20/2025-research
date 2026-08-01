#!/bin/bash

#configuration variables
passphrase="debug" #password used during embedding
stego_dir="/home/brontomage20/steghide_stegos_part2" #directory containing stego files
output_dir="/home/brontomage20/steghide_extracted_part2" #directory for extracted files

#create output directory if it doesnt exist
mkdir -p "$output_dir"

echo "starting steghide extraction process..."
echo "========"
echo "stego directory: $stego_dir"
echo "output directory: $output_dir"
echo "password: $passphrase"
echo ""

#counter for tracking progress
count=0
success=0
failed=0
total=$(ls "$stego_dir"/*.jpg 2>/dev/null | wc -l)

echo "found $total stego files to process"
echo ""

#track total time and count
script_start=$(date +%s)
image_count="$count"
total_image_time=0

#loop through all .jpg files in the stego directory
for stego_file in "$stego_dir"/*.jpg; do
	#check if the file exists
	if [ ! -f "$stego_file" ]; then
		echo "no .jpg files found in stego directory."
		break
	fi

	#increment counter
	count=$((count + 1))

	#start timing this iteration
	START=$(date +%s)

	#get the base filename
	base_name=$(basename "$stego_file" .jpg)

	#define output file for extracted data
	extracted_file="$output_dir/${base_name}_extracted.txt"

	echo "[$count/$total] extracting from: $base_name"
	echo "--------"

	# run steghide extract command
	# -sf: stego file (file containing hidden data)
	# -xf: extract file (where to save extracted data)
	# -p: passphrase
	# -f: force overwrite without prompting
	steghide extract -sf "$stego_file" -xf "$extracted_file" -p "$passphrase" -f

	if [ $? -eq 0 ]; then
		echo "[*checkmark*] successfully extracted to $extracted_file"
		success=$((success + 1))
	else
		echo "failed to extract from $stego_file"
		failed=$((failed + 1))
	fi

	echo ""

	echo "==="
	#calculate and display time
	END=$(date +%s)
	elapsed=$((END - START))
	echo "time taken: ${elapsed} seconds"
	echo "==="
	echo ""

	#update counters
	image_count="$count"
	total_image_time=$((total_image_time + elapsed))
done

#calculate total time and average
script_end=$(date +%s)
total_time=$((script_end - script_start))

if [ $image_count -gt 0 ]; then
	average_time=$((total_image_time / image_count))
else
	average_time=0
fi

echo "========"
echo "extraction complete!"
echo ""
echo "summary:"
echo " - total files processed: $total"
echo " - successful: $success"
echo " - failed: $failed"
echo ""
echo "time statistics:"
echo " - total processing time: ${total_time} seconds ($((total_time / 60)) minutes"
echo " - average time per image: ${average_time} seconds"
echo ""
echo "output directory: $output_dir"
echo "========