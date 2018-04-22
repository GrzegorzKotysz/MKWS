# script for creating and running tutorial case
# you have to be inside OpenFOAM bash before running this script
# DRM19.dat and thermo30.dat files have to be downloaded
# you will be prompted to specify their directory

echo copying tutorial case
cp -r $FOAM_TUTORIALS/combustion/reactingFoam/laminar/counterFlowFlame2D $WM_PROJECT_USER_DIR/run/counterFlowFlame2D
echo creating chemkin directory in counterFlowFlame2D
cd $WM_PROJECT_USER_DIR/run/counterFlowFlame2D
mkdir chemkin

while :
do
    echo enter the directory of drm19.dat and thermo30.dat files

    read griDirectory

    if [[ $griDirectory = *"WM_PROJECT_USER_DIR"* ]]
    then
        if [[ -e $WM_PROJECT_USER_DIR/drm19.dat && -e $WM_PROJECT_USER_DIR/thermo30.dat ]]
        then
            echo directory contains needed files. Proceeding.
            break
        else
            echo directory does not contain needed files. Provide appropriate directory.
        fi
    else
        if [[ -e $griDirectory/drm19.dat && -e $griDirectory/thermo30.dat ]]
        then
            echo directory contains needed files. Proceeding.
            break
        else
            echo directory does not contain needed files. Provide appropriate directory.
        fi
    fi

done
