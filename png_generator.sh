#!/bin/bash

# Define colors for the three versions
ACTIVE="#00FF00"    # already in the file, but we include for completeness
IN_PERMIT="#F1C40F"
INACTIVE="#7F8C8D"

# Define the SVG files (adjust the list as needed)
svgs=("assets/aerodrome.svg" "assets/heliport.svg" "assets/seaplane_base.svg" "assets/takeoff_zone.svg")

# Loop over each file and each status version
for svg in "${svgs[@]}"; do
    # extract basename without extension
    base=$(basename "$svg" .svg)
    
    # Active version (if needed, simply copy or convert without substituting)
    rsvg-convert -w 80 -h 80 -a -o "assets/${base}_active.png" "$svg"
    
    # In Permit version: replace the fill color with the in-permit color
    sed "s/#00FF00/${IN_PERMIT}/Ig" "$svg" | rsvg-convert -w 80 -h 80 -a -o "assets/${base}_in_permit.png"
    
    # Inactive version: replace the fill color with the inactive color
    sed "s/#00FF00/${INACTIVE}/Ig" "$svg" | rsvg-convert -w 80 -h 80 -a -o "assets/${base}_inactive.png"
done
