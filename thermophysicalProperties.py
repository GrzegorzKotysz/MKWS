# file to change thermophysicalProperties
# import libraries to read variable from bash
import sys, os
whichChemistry = sys.argv[1]
for i in range(100):
    print("test %s\n" %whichChemistry)
f_old = open("~thermophysicalProperties", 'r')
f_new = open("thermophysicalProperties", 'w')

# if chemkin is used:
if whichChemistry == "0":
    for line in f_old:
        if "chemistryReader" in line :
            f_new.write("chemistryReader chemkinReader;\n")
        elif "foamChemistryFile" in line :
            f_new.write("CHEMKINFile \"$FOAM_CASE/chemkin/drm19.dat\";\n")
        elif "foamChemistryThermoFile" in line :
            f_new.write("CHEMKINThermoFile \"$FOAM_CASE/chemkin/thermo30.dat\";\n")
            f_new.write("CHEMKINTransportFile \"$FOAM_CASE/chemkin/transport.dat\";")
        else:
            f_new.write(line)
# if tutorial reactions are used
elif whichChemistry == "1":
    for line in f_old:
        if "foamChemistryFile" in line :
            f_new.write("foamChemistryFile \"$FOAM_CASE/constant/reactionsGRI\";\n")
        elif "foamChemistryThermoFile" in line :
            f_new.write("foamChemistryThermoFile \"$FOAM_CASE/constant/thermo.compressibleGasGRI\";\n")
        else:
            f_new.write(line)
else:  
    print("\n\n\n ERROR : thermophysicalProperties file EMPTY\n\n\n")
f_old.close()
f_new.close()
    

 