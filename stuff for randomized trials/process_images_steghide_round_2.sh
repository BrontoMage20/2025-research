#!/bin/bash

#configuration variables
passphrase="debug" #password used during embedding
stego_dir="/home/brontomage20/steghide_stegos_round_2" #directory containing stego files
output_dir="/home/brontomage20/steghide_extracted_round_2" #directory for extracted files

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

# Gather all JPG/JPEG stego files.
files=()
while IFS= read -r -d '' file; do
	files+=("$file")
done < <(find "$stego_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0)

total=${#files[@]}

if [ "$total" -eq 0 ]; then
	echo "No .jpg or .jpeg stego files found in directory: $stego_dir"
	exit 1
fi

echo "found $total stego files to process"
echo ""

# Generate a random seed and allow reuse of a previous seed.
seed=$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')
echo "Generated random seed: $seed"
read -rp "Enter seed to reuse or press Enter to keep this seed: " seed_input
if [[ "$seed_input" =~ ^[0-9]+$ ]]; then
	seed="$seed_input"
elif [ -n "$seed_input" ]; then
	echo "Invalid seed entered, using generated seed."
fi
echo "Using seed: $seed"

mapfile -d '' -t files < <(printf '%s\0' "${files[@]}" | python3 -c '
import sys, random
random.seed(int(sys.argv[1]))
data = [x for x in sys.stdin.buffer.read().split(b"\0") if x]
random.shuffle(data)
sys.stdout.buffer.write(b"\0".join(data))
' "$seed")

#track total time and count
script_start=$(date +%s%N)
image_count="$count"
total_image_time=0

#loop through all .jpg files in the stego directory
for stego_file in "${files[@]}"; do
	#check if the file exists
	if [ ! -f "$stego_file" ]; then
		echo "no .jpg or files found in stego directory."
		break
	fi

	#increment counter
	count=$((count + 1))

	#start timing this iteration
	START=$(date +%s%N)

	#get the base filename
	# if [[ "$stego_file" == *.jpeg ]]; then
	# 	base_name=$(basename "$stego_file" .jpeg)
	# elif [[ "$stego_file" == *.jpg ]]; then
	# 	base_name=$(basename "$stego_file" .jpg)
	# fi
	base_name="${stego_file##*/}"; base_name="${base_name%.jp*g}"

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
	END=$(date +%s%N)
	elapsed=$(((END - START) / 1000000))
	echo "time taken: ${elapsed} milliseconds"
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
echo " - total files processed: $total"
echo " - successful: $success"
echo " - failed: $failed"
echo ""
echo "time statistics:"
echo " - total processing time: ${total_time} milliseconds ($((total_time / 60)) minutes/1000000"
echo " - average time per image: ${average_time} milliseconds"
echo ""
echo "output directory: $output_dir"
echo "========
