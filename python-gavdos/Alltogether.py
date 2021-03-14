#data iteration
import os
import numpy as np

#pyosc
from pythonosc import osc_message_builder
from pythonosc import udp_client
import time

#import urllib.requests
import matplotlib.pyplot as plt
#Load the .txt file
df = np.loadtxt(fname = os.getcwd()+"/GAVDOS1.txt", dtype='str')

#pyosc
client = udp_client.SimpleUDPClient("192.168.1.3", 57120)
#IP Address might change sometimes - CAREFULL IF ERROR

#Official!!!!CAREFULL
for i in range(len(df)):
#for i in range(70):
    client.send_message("/send", df[i])
    a = [df[i,0], df[i,1], df[i,3], df[i,6], df[i,7], df[i,8]]
    #date
    #time
    #temp
    #Significant height (Ht)
    #Zero up-crossing wave period (Tz)
    #Max height (Hmax)
    print(str(a))
    time.sleep(float(df[i,3]) / 16) # Seconds



print("klippa-hans-tung")
