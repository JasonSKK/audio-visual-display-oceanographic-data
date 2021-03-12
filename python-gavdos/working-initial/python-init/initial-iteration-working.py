import os
import numpy as np
import time
#import urllib.requests
import matplotlib.pyplot as plt

#load the .txt file
ES_D1 = np.loadtxt(fname = os.getcwd()+"/GAVDOS1.txt", dtype='str')


for i in range(ES_D1.shape[0]):
    if ES_D1[i,3] > ES_D1[i,6]:

        fl = float(ES_D1[i,3])
        time.sleep(fl/666) # Seconds


        #osc data? how?
        #2 ways
        #1) create fl for every column with time controled by fl/666
        #(every col controled by fl/666 => so time sleep same on every one)
        #then send individual OSC message for every col (date, time, temp ...)

        #2) Create an array and send the array
        #like =
        #[date, time, temp, Ht, Tz, Hmax]

        #HAVE TO SEND DATE AND TIME AS WELL?? OR PRINT ON PYTHON?

        print(ES_D1[i,3])



#test-comment-out-loop
#fl = float(ES_D1[1,3])
#print(fl)
print("klippa-hans-tung")


#DONE
#what is goind to control the time? => Temp col (time = same period so no point)
#temperature = 4th means [3]
