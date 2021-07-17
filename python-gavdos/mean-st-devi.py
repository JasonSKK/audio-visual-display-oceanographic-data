#data iteration
import os
import numpy as np

#pyosc
from pythonosc import osc_message_builder
from pythonosc import udp_client
import time

#Load the .txt file
df = np.loadtxt(fname = os.getcwd()+"/GAVDOS1.txt", dtype='str')

#for i in range(len(df)):
    #p = np.mean(df[i,7])
 #np.std(COLUMN_MEAN_PERIOD)
 #np.mean(COLUMN_MAX_HEIGHT)
 #np.std(COLUMN_MAX_HEIGHT)
 #np.max(COLUMN_TEMPERATURE)
 #np.std(COLUMN_TEMPERATURE)

#pyosc
#client = udp_client.SimpleUDPClient("192.168.1.9", 57120)
#IP Address might change sometimes - CAREFULL IF ERROR

for i in range(len(df)):
#for i in range(70):
#    client.send_message("/send", df[i])
#    a = [df[i,0], df[i,1], df[i,3], df[i,6], df[i,7], df[i,8]]
#    #date
#    #time
#    #temp
#    #Significant height (Ht)
#    #Zero up-crossing wave period (Tz)
#    #Max height (Hmax)
#    print(str(a))
#    p = np.mean(df[i,7])
#    time.sleep(float(df[i,3]) / 16) # Seconds


print(str(np.mean(df[1,7])))
