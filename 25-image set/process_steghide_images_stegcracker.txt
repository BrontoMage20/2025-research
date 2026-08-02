# Create results directory
mkdir -p stegcracker_steghide_results

#track total time and count
script_start=$(date +%s%N)
image_count=0
total_image_time=0


#process all JPG files found
find /home/brontomage20/steghide_stegos -type f -name '*.jpg' | while read -r img; do
    	echo "==="
    	echo "Processing: $img"
    	echo "==="
    
    	#start timing
    	start=$(date +%s%N)
 
    	#get just the file name for the output
    	filename=$(basename "$img" | sed 's/\.[^.]*$//')
    
    	outfile="./stegcracker_steghide_results/${filename}.out"
    	logfile="./stegcracker_steghide_results/${filename}_result.txt"
    
    	#run stegcracker and save results
    	stegcracker "$img" /home/brontomage20/Wordlists/wordlist_updated_no_num.txt 2>&1 | tee "$logfile"
    
	# Stegcracker creates the file in the same directory as the input with .out appended
	stegcracker_output="${img}.out"

    	#check if a .out file was created (successful crack)
    	if [ -f "$stegcracker_output" ]; then
        	echo "Success! Hidden data extracted to: ${filename}.out"
        	cp "$stegcracker_output" "$outfile"
		rm "$stegcracker_output"
    	fi
	#calculate and display time
	END=$(date +%s%N)
	elapsed=$(((END - start) / 1000000))
	echo "time taken: ${elapsed} milliseconds"
	echo "==="
    	echo ""

	#update counters
	image_count=$((image_count + 1))
	total_image_time=$((total_image_time + elapsed))
done


##The below is commented out for now, as I do not know if the system treats "jpeg" and "jpg" as distinct file extensions.

##process all JPEG files found
#find <folder location> -type f -name '*.jpeg' | while read -r img; do
#    	echo "==="
#    	echo "Processing: $img"
#    	echo "==="
#
#    	#start timing
#    	start=$(date +%s)
#
#    	#get just the file name for the output
#    	filename=$(basename "$img")
#
#    	outfile="./stegcracker_results/${filename}.out"
#    	logfile="./stegcracker_results/${filename}_result.txt"
#
#    	#run stegcracker and save results
#    	stegcracker "$img" 2>&1 | tee "$logfile"
#
#    	#check if a .out file was created (successful crack)
#    	if [ -f "${img}.out"]; then
#        	echo "Success! Hidden data extracted to: ${img}.out"
#        	cp "${img}.out" "$outfile"
#    	fi
#
#    	#calculate and display time
#	END=$(date +%s)
#	elapsed=$((END - start))
#	echo "time taken: ${elapsed} seconds"
#	echo "==="
#    	echo ""
#
#	#update counters
#	image_count=$((image_count + 1))
#	total_image_time=$((total_image_time + elapsed))
#done



##process all BMP files found
#find <folder location> -type f -name '*.bmp' | while read -r img; do
#   	echo "==="
#   	echo "Processing: $img"
#   	echo "==="
#
#   	#start timing
#    	start=$(date +%s)
#
#    	#get just the file name for the output
#   	filename=$(basename "$img")
#
#   	outfile="./stegcracker_results/${filename}.out"
#   	logfile="./stegcracker_results/${filename}_result.txt"
#
#   	#run stegcracker and save results
#   	stegcracker "$img" 2>&1 | tee "$logfile"
#
#   	#check if a .out file was created (successful crack)
#   	if [ -f "${img}.out"]; then
#    	   	echo "Success! Hidden data extracted to: ${img}.out"
#    	   	cp "${img}.out" "$outfile"
#    	fi
#
#	#calculate and display time
#	END=$(date +%s)
#	elapsed=$((END - start))
#	echo "time taken: ${elapsed} seconds"
#	echo "==="
#	echo ""
#
#	#update counters
#	image_count=$((image_count + 1))
#	total_image_time=$((total_image_time + elapsed))
#done


#calculate total time and average
script_end=$(date +%s%N)
total_time=$(((script_end - script_start) / 1000000))

if [ $image_count -gt 0 ]; then
	average_time=$((total_image_time / image_count))
else
	average_time=0
fi



echo "============================"
echo "Processing complete! Check results in:"
echo "home directory"
echo "Summary of successful extractions:"
ls -1 stegcracker_steghide_results/*.out 2>/dev/null | while read file; do
	echo "$file"
done
echo "time statistics:"
echo " - total images processed: ${image_count}"
echo " - total processing time: ${total_time} milliseconds ($((total_time / 60)) minutes/1000000)"
echo "============================"
echo ""

#show summary of successful cracks
echo ""
echo "summary of successful extractions:"
successful=0
for file in ./stegcracker_steghide_results/*.out; do
	if [ -f "$file" ] && [ -s "$file" ]; then
		echo "[*checkmark*] $file"
		successful=$((successful + 1))
	fi
done

if [ $successful -eq 0 ]; then
	echo "no hidden data found in any image."
else
	echo ""
	echo "total successful extractions: $successful"
	echo "total failed extractions: $((image_count - successful))"
fi
