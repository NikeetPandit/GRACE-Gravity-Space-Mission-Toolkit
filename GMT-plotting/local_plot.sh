#--- Specify paramters
FOLDER=("F:\THESIS\3-MRA\db3\him")

UNITS="mgal"  
PROJ="M4.5i"
LON1="60" LON2="110" LAT1="15" LAT2="35"
SCALE=100 #scaling the hillshade (higher less/smaller more/1 is normal)
lim=(120 120 10 10 15 15 20 45 65 65)











#--- Function to plot

function local_plot() {

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
    
    mkdir "$AUX_FILES" #
    echo "Processing ... "$DAT_FILE #

    #-- Setting variables
    DATA="$AUX_FILES""data.grd"   #gridded data
    COLOR="$AUX_FILES""color.cpt" #colormap from gridded data

    #---Converting text file to a grd
    gmt xyz2grd "$DAT_FILE" -I0.1 -R"$COORD" -G"$DATA"

    #--- Getting limits of grd to set color map
    ZLIMS=$(gmt grdinfo "$DATA" -T0.1)

    #--- If limits are populated with an array
    ZLIMS1="${lim[cnt]}" 

    #--- Making color map based on data
    gmt makecpt -Cpolar -T-$ZLIMS1/$ZLIMS1 > "$COLOR"

    #--- Creating plot to png 
    FILE="${DAT_FILE##*/}" #Setting file name to same as text

    gmt begin "$CALC_DIR""/"${FILE:0:-4} png 

        #--- Producing color map from gridded data using colormap
        gmt grdimage "$DATA" -J$PROJ -R"$COORD" -C"$COLOR"

        #--- Drawing coast lines 
        gmt coast -W1/thinner -R"$COORD" -J$PROJ -A100/0/4/4+p80 \
        \
        -Df -B10f5 -BWrNb #-Bx10 -By5 -BWsNe #Specifies the spacing 

        #--- Adding color bar with units
        gmt colorbar -C"$COLOR" -Baf -By+l$UNITS
        
    gmt end

    #--- Removing directory with interemediary computations
    rm "$AUX_FILES" -r

    ((cnt++)) 

    done
    done
}

local_plot






