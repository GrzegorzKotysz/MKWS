 # file which adjusts SConstruct
 
with open('~SConstruct', 'r') as file:
    # read a list of lines into data
    data = file.readlines()
    
with open("SConstruct",'w') as f:
    for i,line in enumerate(data,1):         ## STARTS THE NUMBERING FROM 1 (by default it begins with 0)    
        if i == 241:                              ## OVERWRITES line:2
            f.writelines("defaults.ccFlags = '-fPIC'\n")
        elif i == 411:
            f.writelines("     '-fPIC -O3'),\n")
        else:
            f.writelines(line)