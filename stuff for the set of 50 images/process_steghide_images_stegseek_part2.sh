#!/bin/bash

### Navigate to the directory (don't use this cuz it wont work)
# cd ~/Desktop/chal/stegano/archive || exit

# Create results directory in the current location
mkdir -p /home/brontomage20/stegseek_steghide_results_part2

# Make sure rockyou.txt is decompressed
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
	echo "Decompressing rockyou.txt ..."
	sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
fi

# Track total time and count.
SCRIPT_START=$(date +%s%N)
IMAGE_COUNT=0
TOTAL_IMAGE_TIME=0

# Process all JPG files.
echo "Processing: JPG files."
find /home/brontomage20/steghide_stegos_part2 -type f -name '*.jpg' | while read -r img; do
	echo "============="
	echo "Processing: $img"
	echo "============="
	
	# Start timing
	START=$(date +%s%N)

	# Get just the file name for the output
	filename=$(basename "$img")
	
	outfile="./stegseek_steghide_results_part2/${filename}.out"
	logfile="./stegseek_steghide_results_part2/${filename}_result.txt"

	# Run stegseek and save results
	stegseek "$img" /home/brontomage20/Wordlists/wordlist_updated_no_num.txt "$outfile" 2>&1 | tee "$logfile"
	
	# Calculate and display time
	END=$(date +%s%N)
	ELAPSED=$(((END - START) / 1000000))
	echo "Time taken: ${ELAPSED} milliseconds."
	echo "==="
	echo ""

	# Update counters
	IMAGE_COUNT=$((IMAGE_COUNT + 1))
	TOTAL_IMAGE_TIME=$(((TOTAL_IMAGE_TIME + ELAPSED) / 1000000))

done


#The following has ben commented out, as I am not sure if the extension jpeg is necessarily distinct from jpg.


#Process all JPEG files.
echo "Processing: JPEG files."
find . -type f -name '*.jpeg' | while read -r img; do
	echo "============="
	echo "Processing: $img"
	echo "============="

	# Start timing
	START=$(date +%s)
	
	# Get just the file name for the output
	filename=$(basename "$img")

	outfile="./stegseek_results_part2/${filename}.out"
	logfile="./stegseek_results_part2/${filename}_result.txt"

	# Run stegseek and save results
	stegseek "$img" /usr/share/wordlists/rockyou.txt "$outfile" 2>&1 | tee "$logfile"

	# Calculate and display time
	END=$(date +%s)
	ELAPSED=$((END - START))
	echo "Time taken: ${ELAPSED} seconds."
	echo "==="
	echo ""

	# Update counters
	IMAGE_COUNT=$((IMAGE_COUNT + 1))
	TOTAL_IMAGE_TIME=$((TOTAL_IMAGE_TIME + ELAPSED))
done


##Process all BMP files.
#echo "Processing: BMP files."
#find . -type f -name '*.bmp' | while read -r img; do
#	echo "============="
#	echo "Processing: $img"
#	echo "============="
#
#	# Start timing
#	START=$(date +%s)
#
#	# Get just the file name for the output
#	filename=$(basename "$img")
#
#	outfile="./stegseek_results_part2/${filename}.out"
#	logfile="./stegseek_results_part2/${filename}_result.txt"
#
#	# Run stegseek and save results
#	stegseek "$img" /usr/share/wordlists/rockyou.txt "$outfile" 2>&1 | tee "$logfile"
#
#	# Calculate and display time
#	END=$(date +%s)
#	ELAPSED=$((END - START))
#	echo "Time taken: ${ELAPSED} seconds."
#	echo "==="
#	echo ""
#
#	# Update counters
#	IMAGE_COUNT=$((IMAGE_COUNT + 1))
#	TOTAL_IMAGE_TIME=$((TOTAL_IMAGE_TIME + ELAPSED))
#done

# Calculate total time and average
SCRIPT_END=$(date +%s%N)
TOTAL_TIME=$(((SCRIPT_END - SCRIPT_START) / 1000000))

if [ $IMAGE_COUNT -gt 0 ]; then
	AVERAGE_TIME=$((TOTAL_IMAGE_TIME / IMAGE_COUNT))
else
	AVERAGE_TIME=0
fi


echo "============================"
echo "Processing complete! Check results in:"
echo "~/Desktop/chal/stegano/archive/stegseek_steghide_results_part2"
echo ""
echo "Statistics:"
echo " - Total images processed: ${IMAGE_COUNT}"
echo " - Total processing time: ${TOTAL_TIME} milliseconds ($((TOTAL_TIME / 60)) minutes/1000000)"
echo " - Average time per image: ${AVERAGE_TIME} milliseconds"
echo "============================"
echo ""

# Show summary of successful cracks
echo ""
echo "Summary of successful extractions:"
SUCCESSFUL=0
for file in ./stegseek_steghide_results/*.out; do
	if [ -f "$file" ] && [ -s "$file" ]; then
		echo "[*checkmark*] $file"
		SUCCESSFUL=$((SUCCESSFUL + 1))
	fi
done

if [ $SUCCESSFUL -eq 0 ]; then
	echo "No hidden data found in any image."
else
	echo ""
	echo "Total successful extractions: $SUCCESSFUL"
	echo "Number of failed extractions: $((IMAGE_COUNT - SUCCESSFUL))"
fi


#The following was initially used on 11/28/25; please keep the below in the case that the above does NOT work. -Liam

#ls -1 stegseek_results_part2/*.out 2>/dev/null | while read file; do
#	echo "$file"
#done
#echo "============================"
