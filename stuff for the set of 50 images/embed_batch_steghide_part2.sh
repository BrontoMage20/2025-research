#!/bin/bash



##makes temp directory for converted bmp files
#temp_dir="/home/brontomage20/steghide_temp_part2"
#mkdir -p "$temp_dir"
##check if temp_dir was made successfully
#if [ ! -d "$temp_dir" ]; then
#	echo "error: failed to create temporary directory"
#	exit 1
#fi


# Configuration variables
secret_file="/home/brontomage20/its_a_secret.txt"
passphrase="debug" #alternatively, choose another word from /home/brontomage20/Wordlists/wordlist_updated_no_num.txt
cover_dir="/home/brontomage20/Documents/image_set_2" #directory containing cover files
output_dir="/home/brontomage20/steghide_stegos_part2" #directory for output files

#create directory if it doesnt exist already
mkdir -p "$output_dir"

echo "starting steghide embedding process..."
echo "========"
echo "secret/message file: $secret_file"
echo "cover directory: $cover_dir"
echo "output directory: $output_dir"
echo "password: $passphrase"
echo ""

#counter for tracking progress
count=0
success=0
failed=0
total=$(ls "$cover_dir"/*.@jpg "$cover_dir"/*.jpeg 2>/dev/null | wc -l)

echo "found $total jpg files to process!"
echo ""

#track total time and count.
script_start=$(date +%s%N)
total_image_time=0

#loop through all .jpg files in the cover directory
for cover_file in "$cover_dir"/*.jpg "$cover_dir"/*.jpeg; do
	#check if the file exists (in case no .jpg files found)
	if [ ! -f "$cover_file" ]; then
		echo "no .jpg files found in directory; cannot convert to bmp if nothing is there"
		break
	fi

	#increment counter
	count=$((count + 1))

	#start timing
	START=$(date +%s%N)

	#get the base filename w/o path and extension
	# if [[ "$cover_file" == *.jpeg ]]; then
	# 	base_name=$(basename "$cover_file" .jpeg)
	# elif [[ "$cover_file" == *.jpg ]]; then
	# 	base_name=$(basename "$cover_file" .jpg)
	# fi
	base_name="${cover_file##*/}"; base_name="${base_name%.jp*g}"
	echo "[$count/$total] processing: $base_name"

#	#convert to bmp
#	bmp_cover="/home/brontomage20/steghide_temp_part2/${base_name}.bmp"
#	echo "-> converting jpg to bmp"
#	convert "$cover_file" "$bmp_cover"
#
#	if [ $? -ne 0 ]; then
#		echo "failed to convert $cover_file."
#		continue
#
#	fi
#	echo "Conversion successful!"

	#define output stego file
	if [[ "$cover_file" == *.jpeg ]]; then
		stego_file="${output_dir}/${base_name}_stego.jpeg"
	elif [[ "$cover_file" == *.jpg ]]; then
		stego_file="${output_dir}/${base_name}_stego.jpg"
	fi

	echo "==="
	echo "--> embedding $secret_file in $cover_file"

	#run steghide embed command
	# -ef: embed file (the secret message)
	# -cf: cover file (the image to hide data in)
	# -sf: stego file (the output file)
	# -p: passphrase (a word from the wordlist)
	# -f: force overwrite without prompting
	steghide embed -ef "$secret_file" -cf "$cover_file" -sf "$stego_file" -p "$passphrase" -f

	if [ $? -eq 0 ]; then
		echo "[*checkmark*] successfully created $stego_file"
		success=$((success + 1))
	else
		echo "failed to create $stego_file"
		failed=$((failed + 1))
	fi
	echo ""

	#calculate and display time
	END=$(date +%s%N)
	elapsed=$(((END - START) / 1000000))
	echo "Time taken: ${elapsed} milliseconds."
	echo "==="
	echo ""

	#update counters
	total_image_time=$((total_image_time + elapsed))
done

#calculate total time and average
script_end=$(date +%s%N)
total_time=$(((script_end - script_start) / 1000000))

if [ $count -gt 0 ]; then
	average_time=$((total_image_time / count))
else
	average_time=0
fi


echo "========"
echo "embedding complete!"
echo ""
echo "summary:"
echo "- total files processed: $count"
echo "- successful: $success"
echo "- failed: $failed"
echo ""
echo "time statistics:"
echo " - total embedding time: ${total_time} milli seconds ($((total_time / 60)) minutes/1000000)"
echo " - average embedding time per image: ${average_time} milliseconds"
echo ""
echo "output location: $output_dir"
