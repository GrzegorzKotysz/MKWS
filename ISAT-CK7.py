 # file which adjusts SConstruct
 # import libraries to read variable from bash
import sys, os
#command tells the script what to do
command = sys.argv[1]
if len(sys.argv) > 2 :
    name = sys.argv[2]
if len(sys.argv) > 3 :
    var = sys.argv[3]

if (command == "edit") and (name == "SConstruct") : 
    with open('~SConstruct', 'r') as file:
        # read a list of lines into data
        data = file.readlines()
    with open('SConstruct','w') as f :
        for i,line in enumerate(data,1) :         ## STARTS THE NUMBERING FROM 1 (by default it begins with 0)    
            if i == 241 :                              ## OVERWRITES line:2
                f.writelines("defaults.ccFlags = '-fPIC'\n")
            elif i == 411 :
                f.writelines("     '-fPIC -O3'),\n")
            else:
                f.writelines(line)
                
if command == "adjust_fmt" :
    with open(name, 'r') as file :
        data = file.readlines()
    with open(name, 'w') as f :
        for line in data :
            line = line.replace("fmt::MemoryWriter %s" %var, "fmt::memory_buffer %s" %var)
            line = line.replace("%s.write(" %var, "format_to(%s," %var)
            line = line.replace("%s.str()" %var, "to_string(%s)" %var)
            f.writelines(line)
            
if (command == "edit") and (name == "global.h") :
    with open(name, 'r') as file :
        data = file.readlines()
    with open(name, 'w') as f :
        for i, line in enumerate(data, 1) :
            if i == 24 :
                f.writelines("#include \"/usr/local/include/fmt/printf.h\"\n")
            f.writelines(line)
                
if (command == "edit") and (name == "fmt.h") :
    with open(name, 'r') as file:
        data = file.readlines()
    with open(name, 'w') as f :
        for i, line in enumerate(data, 1):
            if i == 4 :
                f.writelines("#define FMT_NO_FMT_STRING_ALIAS\n")
                f.writelines("#define FMT_HEADER_ONLY\n")
            f.writelines(line)