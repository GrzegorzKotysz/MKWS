# file to change boundary conditions

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
                f_new.write(8*' '+"value"+12*' '+"uniform %s\n;" % Ufuel.returnVec())
                break
            else :
                f_new.write(line)
    elif "air" in line :
        for line in f_old :
            if strContainsVector(line) :
                f_new.write(8*' '+"value"+12*' '+"uniform %s\n;" % Uair.returnVec())
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
    return (4*' ' + "%s\n" %patchName + 4*' ' + "{\n" + 8*' ' + "type" + 12*' ' + "fixedValue;\n" + 8*' ' + "value" + 12*' ' + "uniform " + "%d" %value + ";\n" + 4 * ' ' + "}\n")

# function returning inletOutlet type BC
def inletOutlet(patchName, inletValue, value):
    return (4*' ' + "%s\n" %patchName + 4*' ' + "{\n" + 8*' ' + "type" + 12*' ' +  "inletOutlet;\n" + 8*' ' + "inletValue" + 12*' ' + "uniform " + "%d" %inletValue + ";\n" + 8*' ' + "value" + 12*' ' + "uniform " + "%d" %value + ";\n" + 4 * ' ' + "}\n")
  
# function returning frontAndBack type BC
def frontAndBack(patchName):
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
f_new.write("}\n\n// ************************************************************************* //")

f_old.close()
f_new.close()