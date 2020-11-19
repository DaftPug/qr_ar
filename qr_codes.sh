#!/usr/bin/env bash

## declare an array variable
# declare -a products=("black" "grey" "red" "green" "blue" "yellow")

# ## now loop through the above array
# for i in "${products[@]}"
# do
#   png="$i.png"
#    qrcode -w 175 -o $png $i
#    # or do whatever with individual element of the array
# done

# montage -label '%f' *.png -geometry '175x175>' -quality 100 -page a4 qr_codes.pdf
# rm *.png
# You can access them using echo "${arr[0]}", "${arr[1]}" also

## new for loop
for i in {1..10}
do
  uuid=$(uuidgen)
  png="$uuid.png"
  qrcode -w 100 -o $png $uuid
done

montage *.png -geometry '100x100>' -quality 100 -page a4 qr_codes.pdf

rm *.png
