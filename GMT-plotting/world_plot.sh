#--- Specify paramters
FOLDER=("F:\THESIS\3-MRA\gauss\world\temp")

UNITS="mgal"  
PROJ="N4.5i"
LON1="-179" LON2="179" LAT1="-89" LAT2="89"
SCALE=1 #scaling the hillshade (higher less/smaller more/1 is normal)
lim=(160 160 25 25 45 40 40 45 65 65)











#--- Function to plot

function world_plot() {

    for CALC_DIR in "${FOLDER[@]}"
    do

    #--- Building folders to place intermed. calculations
    CALC_DIR="$CALC_DIR" | sed 's|/|\\|g' #replacing slashes 
    AUX_FILES="/aux_calc/" 
    AUX_FILES="$CALC_DIR""$AUX_FILES"

    #--- Building coordinate array based on inputs
    COORD=$LON1"/"$LON2"/"$LAT1"/"$LAT2

    #--- Initialize counter array to axis limits
    cnt=0

    #--- Looping through each text file in directory 
    for DAT_FILE in "$CALC_DIR"/*'txt'
    do

    mkdir "$AUX_FILES"

    echo "Processing ... "$DAT_FILE

    #-- Setting variables
    DATA="$AUX_FILES""data.grd"   #gridded data
    SHADE="$AUX_FILES""shade.grd" #shadding from gridded data
    COLOR="$AUX_FILES""color.cpt" #colormap from gridded data

    #---Converting text file to a grd
    gmt xyz2grd "$DAT_FILE" -I0.1 -R"$COORD" -G"$DATA"

    #--- Computing shading to add illumination 
    gmt grdgradient "$DATA" -G"$SHADE" -A45 -N1

    #--- Normalizing the illumination along gaussian 
    gmt grdhisteq "$SHADE" -G"$SHADE" -N 

    #--- Finding the maximum value of the illumination grd
    SHADE_LIMS=$(gmt grdinfo "$SHADE" -T) SHADE_LIMS=$(echo "$SHADE_LIMS" | cut -d '/' -f 2-)
    SHADE_LIMS="${SHADE_LIMS%%.*}" SHADE_LIMS=$(expr $SHADE_LIMS + 1)

    #--- Scaling the maximum value by input parameter scale
    SHADE_LIMS=$(expr $SHADE_LIMS \* $SCALE)

    #--- Normalizing the value so shading is between [-1, 1] 
    gmt grdmath "$SHADE" $SHADE_LIMS DIV = "$SHADE" # 1 scale makes this true, higher value makes it less

    #--- Getting limits of grd to set color map
    ZLIMS=$(gmt grdinfo "$DATA" -T0.1)

    #--- If limits are populated with an array
    ZLIMS1="${lim[cnt]}" 

    #--- Making color map based on data
    gmt makecpt -Cpolar -T-$ZLIMS1/$ZLIMS1 > "$COLOR"

    #--- Making color map based on data
    gmt makecpt -Cpolar $ZLIMS -Z > "$COLOR"

    #--- Creating plot to png 
    FILE="${DAT_FILE##*/}" #Setting file name to same as text

    gmt begin "$CALC_DIR""/"${FILE:0:-4} png 

        #--- Producing color map from gridded data using colormap
        gmt grdimage "$DATA" -J$PROJ -R"$COORD" -I"$SHADE" -C"$COLOR"

        #--- Drawing coast lines 
        gmt coast -W1/thinner -R"$COORD" -J$PROJ -A100/0/4/4+p80 \
        \
        -Dl -B30f15 -BWrbt #-Bx10 -By5 -BWsNe #Specifies the spacing 

        #--- Adding color bar with units
        gmt colorbar -C"$COLOR" -Baf -By+l$UNITS
        
    gmt end

    #--- Removing directory with interemediary computations
    rm "$AUX_FILES" -r

    ((cnt++)) 

    done
    done
}

world_plot






