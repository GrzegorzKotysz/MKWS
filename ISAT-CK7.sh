# script for creating and running tutorial case
# you have to be inside OpenFOAM bash before running this script
# place all python scripts in the same folder as this shell script
# DRM19.dat and thermo30.dat files have to be downloaded
# you will be prompted to specify their directory

# if scripts directory will be needed for copying python scripts etc
scriptsDirectory="$PWD"

# check whether user wants to prepare ISAT library or run the tutorial case
while :
do
    printf "Choose appropriate option\n"
    printf "To install ISAT library: ISAT\n"
    printf "To create tutorial case: tutorial\n"
    read whichOption
    if [[ $whichOption == "ISAT" || $whichOption == "tutorial" ]] ; then
        break
    fi
done

if [[ $whichOption == "tutorial" ]]; then
#check whether folder already exists and delete it, if so
if [ -d "$WM_PROJECT_USER_DIR/run/counterFlowFlame2D" ]; then
  rm -r "$WM_PROJECT_USER_DIR/run/counterFlowFlame2D"
fi

echo copying tutorial case
cp -r $FOAM_TUTORIALS/combustion/reactingFoam/laminar/counterFlowFlame2D $WM_PROJECT_USER_DIR/run/counterFlowFlame2D
# variable to store case directory - code easier to read
caseDir="$WM_PROJECT_USER_DIR/run/counterFlowFlame2D"
echo caseDir = "$caseDir"

while :
do
echo 0 - use CHEMKIN 3 files\; 1 - use tutorial files
read whichChemistry
if [[ $whichChemistry == 0 ]]
then
    while :
    do
        echo creating chemkin directory in counterFlowFlame2D
        mkdir $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin
        echo enter the directory of drm19.dat, thermo30.dat and transport.dat files

        read griDirectory

        if [[ $griDirectory = *"WM_PROJECT_USER_DIR"* ]]
        then
            if [[ -e $WM_PROJECT_USER_DIR/drm19.dat && -e $WM_PROJECT_USER_DIR/thermo30.dat && -e $WM_PROJECT_USER_DIR/transport.dat ]]
            then
                echo directory contains needed files. Proceeding.
                echo copying drm19.dat, thermo30.dat and transport.dat to case directory
                cp $WM_PROJECT_USER_DIR/drm19.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
                cp $WM_PROJECT_USER_DIR/thermo30.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
                cp $WM_PROJECT_USER_DIR/transport.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
                break
            else
                echo directory does not contain needed files. Provide appropriate directory.
            fi
        else
            if [[ -e $griDirectory/drm19.dat && -e $griDirectory/thermo30.dat && -e $griDirectory/transport.dat ]]
            then
                echo directory contains needed files. Proceeding.
                echo copying drm19.dat, thermo30.dat and transport.dat to case directory
                cp $griDirectory/drm19.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
                cp $griDirectory/thermo30.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
                cp $griDirectory/transport.dat $WM_PROJECT_USER_DIR/run/counterFlowFlame2D/chemkin/
                break
            else
                echo directory does not contain needed files. Provide appropriate directory.
            fi
        fi
    break
    done
fi
if [[ $whichChemistry == 1 ]]
then
    cp $WM_PROJECT_DIR/tutorials/combustion/reactingFoam/laminar/counterFlowFlame2D_GRI/constant/reactionsGRI $caseDir/constant/
    cp $WM_PROJECT_DIR/tutorials/combustion/reactingFoam/laminar/counterFlowFlame2D_GRI/constant/thermo.compressibleGasGRI $caseDir/constant/
    break
fi
done

echo making backup of files to be changed
# cp $caseDir/constant/thermophysicalProperties $caseDir/constant/~thermophysicalProperties
# rm $caseDir/constant/thermophysicalProperties
mv $caseDir/constant/thermophysicalProperties $caseDir/constant/~thermophysicalProperties
mv $caseDir/0/U $caseDir/0/~U
mv $caseDir/0/T $caseDir/0/~T
mv $caseDir/0/CH4 $caseDir/0/~CH4
mv $caseDir/0/O2 $caseDir/0/~O2
mv $caseDir/0/N2 $caseDir/0/~N2

# converting chemkin to foam
# cd $caseDir/chemkin/
# chemkinToFoam drm19.dat thermo30.dat transport.dat foamChemistry foamThermo

# solution with shell editing would be probably faster,
# but for the sake of learning Python was chosen.
# copying of python scripts now unnecessary as scriptsDirectory variable is used
# echo copying python scripts
# cp ./thermophysicalProperties.py $caseDir/constant/thermophysicalProperties.py
echo editing constant/thermophysicalProperties

# to launch python script in appropriate location cd command is used
cd $caseDir/constant/
python $scriptsDirectory/thermophysicalProperties.py $whichChemistry

# script for adjusting boundary condition
echo editing boundary conditions
cd $caseDir/0/
python $scriptsDirectory/boundaryConditions.py 

# script for creating setFieldsDict file
# cd $caseDir/system/
# python $scriptsDirectory/setFieldsDict.py
# copying setFieldsDict
cp $scriptsDirectory/setFieldsDict $caseDir/system/setFieldsDict

# running tutorial case
cd $caseDir/
blockMesh
setFields
reactingFoam

fi

if [[ $whichOption == "ISAT" ]]; then
while :
do
    printf "Do you want to automatically install prerequisites? [Y/n]\n"
    read choice
    if [[ $choice == "Y" || $choice == "n" ]]
    then
        break
fi
done 
if [[ $choice == "Y" ]]
then
    sudo apt install g++ python scons libboost-all-dev libsundials-serial-dev cython python-dev python-numpy python-numpy-dev
fi

printf "Provide cantera directory\n"
read canteraDir
cd $canteraDir/
printf "Editing SConstruct file\n"
mv SConstruct ~SConstruct
python $scriptsDirectory/ISAT-CK7.py

printf "Compiling Cantera...\n"
scons build
scons install
fi