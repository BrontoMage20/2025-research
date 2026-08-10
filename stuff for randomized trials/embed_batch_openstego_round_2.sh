#!/usr/bin/env bash

# Makes the directory for the stego images
mkdir -p /home/brontomage20/openstego_stegos_round_2


# Create a temporary directory for converted bmp files
temp_dir="/home/brontomage20/openstego_temp_round_2"

mkdir -p "$temp_dir"

# Check if the temp directory was created successfully
if [ ! -d "$temp_dir" ]; then
	echo "Error: failed to create temporary directory"
	exit 1
		#note for future programs: "exit 0" = "command success" and "exit n" = "command error", where n is nonzero.
fi

#config var.s
secret_file="/home/brontomage20/its_a_secret.txt"
#dw abt the password var now - 'password' is defined later.
cover_dir="/home/brontomage20/Documents/image_set_2"
#output_dir isn't needed for this program.

echo "Starting openstego embedding process..."

# Counter for tracking progress
count=0
success=0
failed=0







#The code works up until this point. i think the problem may be with the way the code 

#Begin "problem child" code








# Gather all JPG/JPEG cover images.
files=()
while IFS= read -r -d '' file; do
	files+=("$file")
done < <(find "$cover_dir" -maxdepth 1 \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0)

total=${#files[@]}

if [ "$total" -eq 0 ]; then
	echo "No .jpg or .jpeg files found in cover directory: $cover_dir"
	exit 1
fi

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

#track total and time count
script_start=$(date +%s%N)
image_count="$count"
total_image_time=0







#End "problem child" code. Rest of this should actually work.








# This loop processes every selected image file in randomized order.
for cover_file in "${files[@]}"; do
	# Check if the file exists (should always be true after find)
	if [ ! -f "$cover_file" ]; then
		echo "Skipping missing file: $cover_file"
		continue
	fi

	# Increment counter
	count=$((count + 1))
			# (Timestamp: August 3rd, 2026, ~3:02pm EST) # As a note, the following loop was commented out as i found an easier way to simplify this.
	# if [[ "$cover_file" == *.jpeg ]]; then
	# 	base_name=$(basename "$cover_file" .jpeg)
	# elif [[ "$cover_file" == *.jpg ]]; then
	# 	base_name=$(basename "$cover_file" .jpg)
	# fi
	base_name="${cover_file##*/}"; base_name="${base_name%.jp*g}"
	
	echo "[$count/$total] Processing: $base_name"

	# Convert JPG to BMP
	bmp_cover="/home/brontomage20/openstego_temp_round_2/${base_name}.BMP"
	echo "-> Converting JPG to BMP"
	convert "$cover_file" "$bmp_cover"
	
	if [ $? -ne 0 ]; then
		echo "Failed to convert $cover_file."
		continue #tells the program to skip the rest of the current for loop iteration (i.e. the current image), and move to the next.
	fi
	echo "Conversion successful!"

	# Define the output (stego) file name.
	stego_file="/home/brontomage20/openstego_stegos_round_2/${base_name}_stego.bmp"

	# Define the password being used - make sure to pull from the updated wordlist (see wordlist_updated_no_num.txt for said list; located within the Wordlists folder (within the home folder))
	#password="<password being used>" # will be filled out later	
	password="debug"

	echo "Embedding into $bmp_cover -> $stego_file"

	#start timing the individual embed
	START=$(date +%s%N)

	# Run the OpenStego command (note that "-mf"="--mesagefile", "-cf"="--coverfile", "-sf"="--stegofile", and "-E"="--noencrypt")
	openstego embed -mf "$secret_file" -cf "$bmp_cover" -sf "$stego_file" -p "$password" -e
	
	if [ $? -eq 0 ]; then
		echo "Successfully created $stego_file"
		success=$((success + 1))
	else
		echo "Failed to create $stego_file"
		failed=$((failed + 1))
	fi

	#calculate and display time
	END=$(date +%s%N)	
	elapsed=$(( (END - START) / 1000000 ))
	echo "time taken: ${elapsed} milliseconds"
	echo "==="
	echo ""

	#update counters
	image_count="$count"
	total_image_time=$((total_image_time + elapsed))
done

# Clean up temporary BMP files
#echo "Cleaning up temporary files..."
#rm -rf /home/brontomage20/openstego_temp_round_2

#calculate total time and average
script_end=$(date +%s%N)
total_time=$(((script_end - script_start) / 1000000))


if [ "$image_count" -gt 0 ]; then
	average_time=$((total_image_time / image_count))
else
	average_time=0
fi

echo "Embedding complete for all files."

echo "Output location: /home/brontomage20/openstego_stegos_round_2"
echo "Total files processed: $count"


echo "========"
echo "embedding complete!"
echo ""
echo "summary:"
echo " - total files processed: $count"
echo " - successful: $success"
echo " - failed: $failed"
echo ""
echo "time statistics:"
echo " - total processing time: ${total_time} milliseconds ($((total_time / 60)) mintues/1000000)"
echo " - average time per image: ${average_time} milliseconds"
echo "========"
