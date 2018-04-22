# script for creating and running tutorial case
# you have to be inside OpenFOAM bash before running this script
# place all python scripts in the same folder as this shell script
# DRM19.dat and thermo30.dat files have to be downloaded
# you will be prompted to specify their directory

# if scripts directory will be needed for copying python scripts etc
scriptsDirectory="$PWD"

echo copying tutorial case
cp -r $FOAM_TUTORIALS/combustion/reactingFoam/laminar/counterFlowFlame2D $WM_PROJECT_USER_DIR/run/counterFlowFlame2D
echo creating chemkin directory in counterFlowFlame2D
mkdir $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin

while :
do
    echo enter the directory of drm19.dat and thermo30.dat files

    read griDirectory

    if [[ $griDirectory = *"WM_PROJECT_USER_DIR"* ]]
    then
        if [[ -e $WM_PROJECT_USER_DIR/drm19.dat && -e $WM_PROJECT_USER_DIR/thermo30.dat ]]
        then
            echo directory contains needed files. Proceeding.
            echo copying drm19.dat and thermo30.dat to case directory
            cp $WM_PROJECT_USER_DIR/drm19.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
            cp $WM_PROJECT_USER_DIR/thermo30.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
            break
        else
            echo directory does not contain needed files. Provide appropriate directory.
        fi
    else
        if [[ -e $griDirectory/drm19.dat && -e $griDirectory/thermo30.dat ]]
        then
            echo directory contains needed files. Proceeding.
            echo copying drm19.dat and thermo30.dat to case directory
            cp $griDirectory/drm19.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
            cp $griDirectory/thermo30.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
            break
        else
            echo directory does not contain needed files. Provide appropriate directory.
        fi
    fi

done

# variable to store case directory - code easier to read
caseDir="$WM_PROJECT_USER_DIR/run/counterFlowFlame2D"
echo caseDir = "$caseDir"
echo making backup of files to be changed
# cp $caseDir/constant/thermophysicalProperties $caseDir/constant/~thermophysicalProperties
# rm $caseDir/constant/thermophysicalProperties
mv $caseDir/constant/thermophysicalProperties $caseDir/constant/~thermophysicalProperties

# solution with shell editing would be probably faster,
# but for the sake of learning Python was chosen.
# copying of python scripts now unnecessary as scriptsDirectory variable is used
# echo copying python scripts
# cp ./thermophysicalProperties.py $caseDir/constant/thermophysicalProperties.py
echo editing constant/thermophysicalProperties

# to launch python script in appropriate location cd command is used
cd $caseDir/constant/
python $scriptsDirectory/thermophysicalProperties.py