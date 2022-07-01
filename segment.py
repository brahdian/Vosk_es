import subprocess
def get_length(filename):
    print(filename)
    result = subprocess.run(["ffprobe", "-v", "error", "-show_entries",
                             "format=duration", "-of",
                             "default=noprint_wrappers=1:nokey=1", filename],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    return float(result.stdout)


def getQuakeData():
    readfile = open('data/train/text', "r")
    witefile = open('data/train/segments',"a")
    

    for i, line in enumerate(readfile):
        readline = line.split("\t")
        readline = readline[0]
        filename = readline[readline.index("common_"):len(readline)]
        filelength = get_length("db/cv/"+filename+".mp3")
        newline = readline+"\t"+filename+"\t"+"0.00"+"\t"+str(filelength)
        witefile.write(newline+'\n')
    witefile.close()



getQuakeData()

