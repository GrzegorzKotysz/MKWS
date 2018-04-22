# file to change thermophysicalProperties

f_old = open("~thermophysicalProperties", 'r')
f_new = open("thermophysicalProperties", 'w')

for line in f_old:
    if "chemistryReader" in line :
        f_new.write("chemistryReader chemkinReader;\n")
    elif "foamChemistryFile" in line :
        f_new.write("CHEMKINFile \"$FOAM_CASE/chemkin/drm19.dat\"\n")
    elif "foamChemistryThermoFile" in line :
        f_new.write("CHEMKINThermoFile \"$FOAM_CASE/chemkin/thermo30.dat")
    else:
        f_new.write(line)
    
f_old.close()
f_new.close()
    

 