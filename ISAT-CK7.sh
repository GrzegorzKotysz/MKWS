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
while :
do
printf "Do you want to use Anaconda? [Y/n]\n"
read useAnaconda
if [[ $useAnaconda == "Y" || $useAnaconda == "n" ]]; then
    break
fi
done
if [[ $choice == "Y" ]]
then
    if [[ $useAnaconda == "Y" ]]; then
        printf "Provide name of Anaconda environment\n"
        read condaEnv
        source activate $condaEnv
        sudo apt install g++ libboost-all-dev python-numpy-dev python-dev libsundials-serial-dev python-numpy python-setuptools
        conda install python scons cython #some errors, to be solved later
    else
        sudo apt install g++ python scons libboost-all-dev libsundials-serial-dev cython python-dev python-numpy python-numpy-dev
    fi
elif [[ $useAnaconda == "Y" ]]; then
    printf "Provide name of Anaconda environment\n"
    read condaEnv
    source activate $condaEnv
fi
# ADD COMPILATION of and eigen!!!
# ADD changing global.h


printf "Provide cantera directory\n"
read canteraDir

# # Compilation of fmt
# while :
# do
#     printf "Do you want to compile fmt 5.0.0 library? [Y/n]\n"
#     read compileFmt
#     if [[ $compileFmt == "n" ]]
#     then
#         break
#     elif [[ $compileFmt == "Y" ]]
#     then
#         printf "Provide fmt directory\n"
#         read fmtDir
#         cd $fmtDir
#         mkdir build
#         cd build
#         cmake ..
#         make
#         sudo make install
#     fi
# done
# # Compilation of gtest
# while :
# do
#     printf "Do you want to compile gtest library? [Y/n]\n"
#     read compileGtest
#     if [[ $compileGtest == "n" ]]
#     then
#         break
#     elif [[ $compileGtest == "Y" ]]
#     then
#         printf "Provide gtest directory\n"
#         read gtestDir
#         cd $gtestDir
#         mkdir build
#         cd build
#         cmake ..
#         make
#         sudo make install
#     fi
# done
# 
# cd $canteraDir/
# # Compilation of eigen
# while :
# do
#     printf "Do you want to compile eigen library on the go? [Y/n]\n"
#     read compileEigen
#     if [[ $compileEigen == "n" ]]
#     then
#         break
#     elif [[ $compileEigen == "Y" ]]
#     then
#         printf "Provide eigen directory\n"
#         read eigenDir
#         cp -r $eigenDir/* ext/eigen/
#         break
#     fi
# done
# 
# 
# printf "Editing SConstruct file\n"
# mv SConstruct ~SConstruct
# python $scriptsDirectory/ISAT-CK7.py edit SConstruct
# # No backups of following files as the Cantera compiler tries to compile them
# printf "Editing include/cantera/base/global.h\n"
# cd $canteraDir/include/cantera/base/
# python $scriptsDirectory/ISAT-CK7.py edit global.h
# printf "Editing include/cantera/base/fmt.h\n"
# cd $canteraDir/include/cantera/base/
# python $scriptsDirectory/ISAT-CK7.py edit fmt.h
# printf "Editing src/thermo/MolalityVPSSTP.cpp\n"
# cd $canteraDir/src/thermo/
# python $scriptsDirectory/ISAT-CK7.py adjust_fmt MolalityVPSSTP.cpp b
# printf "Editing src/thermo/MolarityIonicVPSSTP.cpp\n"
# python $scriptsDirectory/ISAT-CK7.py adjust_fmt MolarityIonicVPSSTP.cpp b
# printf "Editing src/thermo/PureFluidPhase.cpp\n"
# python $scriptsDirectory/ISAT-CK7.py adjust_fmt PureFluidPhase.cpp b
# printf "Editing src/thermo/ThermoPhase.cpp\n"
# python $scriptsDirectory/ISAT-CK7.py adjust_fmt ThermoPhase.cpp b
# cd $canteraDir/src/numerics/
# printf "Editing src/numerics/CVodesIntegrator.cpp\n"
# python $scriptsDirectory/ISAT-CK7.py adjust_fmt CVodesIntegrator.cpp s
# 
# cd $canteraDir/
# printf "Compiling Cantera...\n"
# 
# #ADD DECISION WHETHER STABLE OR DEVELOPMENT
# 
# sudo scons build
# sudo scons install

printf "Checking whether fortran interface file for Cantera exists\n"
if [ -e /usr/local/lib/libcantera_fortran.a ] ; then
    printf "Inteface exists\n"
else
    printf "ERROR: interface was not created. Review installation\n"
fi

#Building ISAT CK7 Cantera package
printf "Provide ISAT-CK7-Cantera-Master path\n"
read ISATDir
cd $ISATDir/ISAT/build-files/
printf "Editing /ISAT/build-files/vars.mk\n"
# https://stackoverflow.com/questions/11145270/how-to-replace-an-entire-line-in-a-text-file-by-line-number#11145362
sed -i "20s#.*#CANTERA_SRC=$canteraDir/src#" vars.mk
sed -i "22s#.*#CPPFLAGS= -O3 -fPIC -std=c++11#" vars.mk

ISATsymlink=$ISATDir/ISAT_dependencies/lib/libcantera_fortran.a
# https://stackoverflow.com/questions/5767062/how-to-check-if-a-symlink-exists
# if [ -L $ISATsymlink ] && [ -e $ISATsymlink ] ; then
#     printf "Symbolic link to libcantera_fortran ok\n"
# else
# # https://askubuntu.com/questions/843740/how-to-create-a-symbolic-link-in-a-linux-directory
#     printf "Symbolic link to libcantera_fortran will be created\n"
#     ln -s /usr/local/lib/libcantera_fortran.a $ISATsymlink
#     if [ -L $ISATsymlink ] && [ -e $ISATsymlink ] ; then
#         printf "Symbolic link to libcantera_fortran ok\n"
#     else
#         printf "ERROR: symbolic link not created\n"
#     fi
# fi

printf "Editing isatab.f90\n"
cd $ISATDir/ISAT/isatab_ser/
sed -i "1946s#jfe+12#jfe+11#" isatab.f90
#sed -i "3s#.*#\nset(MAKE_CXX_FLAGS \"\${MAKE_CXX_FLAGS}-std=c++11\")\n#" Makefile
printf "Building ISAT CK7 Cantera\n"
cd $ISATDir/ISAT/
make

printf "Provide ISAT Chemistry Solver directory\n"
read ISATChemSolverDir
# cp -r $ISATChemSolverDir $WM_PROJECT_DIR/src/ISATChemistrySolver/
# printf "Compiling OpenFOAM interface\n"
# cd $WM_PROJECT_DIR/src/ISATChemistrySolver/lib/
# wmake

printf "Copying cti2xml.py\n"
cp $ISATChemSolverDir/run/cti2xml.py $FOAM_USER_APPBIN/
printf "Creating symlinks in $FOAM_USER_LIBBIN\n"
# create appropriate directory if does not exist
if ![ -e $FOAM_USER_LIBBIN ] ; then
    mkdir $FOAM_USER_LIBBIN
fi
# cd $FOAM_USER_LIBBIN
# ln -s 



fi