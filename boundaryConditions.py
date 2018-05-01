# file to change boundary conditions
# OpenFOAM uses 80 char lines, so this script should be appropriately changed. Now it is not elegant. Some indents are not correctly written. Maybe writing text into 80 char strings is a better idea. It will be tested for CH4, O2 and N2 BC.
# changing velocity

f_old = open("~U", 'r')
f_new = open("U", 'w')
# vector class:
class vector:
    def __init__(self, x, y, z):
      self.x = x
      self.y = y
      self.z = z
    
    def printVec(self):
        print("(%d %d %d)" % (self.x, self.y, self.z)) 
      
    def printVec(self, file):
        file.write("(%d %d %d)" % (self.x, self.y, self.z))
        
    def returnVec(self): 
        return ("(%d %d %d)" % (self.x, self.y, self.z))

# function checking whether string contains vector
def strContainsVector(string):
    k = 0  # value will tell whether there exist substring in the form "( something )"
    for char in string :
        if char == "(" :
            k += 1
        elif char == ")" and k == 1 :
            return 1
    return 0

# defining new velocities for "air" and "fuel" patches
Uair = vector(-0.8, 0., 0.)
Ufuel = vector(0.8, 0., 0.)

for line in f_old:
    if "fuel" in line :
        for line in f_old :
            if strContainsVector(line) :
                f_new.write(8*' '+"value"+12*' '+"uniform %s;\n" % Ufuel.returnVec())
                break
            else :
                f_new.write(line)
    elif "air" in line :
        for line in f_old :
            if strContainsVector(line) :
                f_new.write(8*' '+"value"+12*' '+"uniform %s;\n" % Uair.returnVec())
                break
            else :
                f_new.write(line)
    else:
        f_new.write(line)    
f_old.close()
f_new.close()
    

# changing temperature
f_old = open("~T", 'r')
f_new = open("T", 'w')
# new temperature
Tfuel = 305
Tair = 305
Toutlet = 305
TinternalField = 305

# function returning fixedValue type BC
def fixedValue(patchName, value):
    return (4*' ' + "%s\n" %patchName + 4*' ' + "{\n" + 8*' ' + "type" + 12*' ' + "fixedValue;\n" + 8*' ' + "value" + 12*' ' + "uniform " + "%s" %value + ";\n" + 4 * ' ' + "}\n")

# function returning inletOutlet type BC
def inletOutlet(patchName, inletValue, value):
    return (4*' ' + "%s\n" %patchName + 4*' ' + "{\n" + 8*' ' + "type" + 12*' ' +  "inletOutlet;\n" + 8*' ' + "inletValue" + 12*' ' + "uniform " + "%s" %inletValue + ";\n" + 8*' ' + "value" + 12*' ' + "uniform " + "%s" %value + ";\n" + 4 * ' ' + "}\n")
  
# function returning empty type BC
def empty(patchName):
    return (4*' ' + "%s\n" %patchName + 4*' ' + "{\n" + 8*' ' + "type" + 12*' ' + "empty;\n" + 4 * ' ' + "}\n")
  
for line in f_old:
    if "internalField" in line:
        f_new.write("internalField   uniform %d;\n\n" % TinternalField)
        break
    else:
        f_new.write(line)

f_new.write("boundaryField\n{\n")
f_new.write(fixedValue("fuel", Tfuel))
f_new.write(fixedValue("air", Tair))
f_new.write(inletOutlet("outlet", Toutlet, Toutlet))
f_new.write(empty("frontAndBack"))
f_new.write("}\n\n// ************************************************************************* //")

f_old.close()
f_new.close()

# changing CH4
inlet_CH4 = 0.055
outlet_CH4 = 0.0
f_old = open("~CH4", 'r')
f_new = open("CH4", 'w')
# writing header and dimension
for line in f_old:
    if "internalField" in line:
        break
    else:
        f_new.write(line)

# function returning internalField uniform string
def internalFieldUniform(value):
    line = "internalField"
    line += (16-len("internalField"))*' ' + "uniform" + ' '
    line += str(value) + ";\n\n"
    return line

# writing internalField line etc
f_new.write(internalFieldUniform(inlet_CH4))
f_new.write("boundaryField\n{\n")
f_new.write(fixedValue("fuel", inlet_CH4))
f_new.write(fixedValue("air", inlet_CH4))
f_new.write(inletOutlet("outlet", outlet_CH4, outlet_CH4))
f_new.write(empty("frontAndBack"))
f_new.write("}\n\n// ************************************************************************* //")
f_old.close()
f_new.close()

# changing O2
inlet_O2 = 0.220185
outlet_O2 = 0.233
f_old = open("~O2", 'r')
f_new = open("O2", 'w')
# writing header and dimension
for line in f_old:
    if "internalField" in line:
        break
    else:
        f_new.write(line)

# writing internalField line etc
f_new.write(internalFieldUniform(inlet_O2))
f_new.write("boundaryField\n{\n")
f_new.write(fixedValue("fuel", inlet_O2))
f_new.write(fixedValue("air", inlet_O2))
f_new.write(inletOutlet("outlet", outlet_O2, outlet_O2))
f_new.write(empty("frontAndBack"))
f_new.write("}\n\n// ************************************************************************* //")
f_old.close()
f_new.close()

# changing N2
inlet_N2 = 0.724815
outlet_N2 = 0.767
f_old = open("~N2", 'r')
f_new = open("N2", 'w')
# writing header and dimension
for line in f_old:
    if "internalField" in line:
        break
    else:
        f_new.write(line)

# writing internalField line etc
f_new.write(internalFieldUniform(inlet_N2))
f_new.write("boundaryField\n{\n")
f_new.write(fixedValue("fuel", inlet_N2))
f_new.write(fixedValue("air", inlet_N2))
f_new.write(inletOutlet("outlet", outlet_N2, outlet_N2))
f_new.write(empty("frontAndBack"))
f_new.write("}\n\n// ************************************************************************* //")
f_old.close()
f_new.close()