#data iteration
import os
import numpy as np

#pyosc
from pythonosc import osc_message_builder
from pythonosc import udp_client
import time

#import urllib.requests
import matplotlib.pyplot as plt
#load the .txt file
df = np.loadtxt(fname = os.getcwd()+"/GAVDOS1.txt", dtype='str')

#pyosc
client = udp_client.SimpleUDPClient("192.168.1.7", 57120)


#sum = 0;
#loop
for i in range(len(df)):
    client.send_message("/temp", df[i, 3])
    value = float(df[i, 3])
    print(df[i,3])
    time.sleep(value / 16666) # Seconds
    #sum = sum + 1

#sum = 0;
#loop
for i in range(len(df)):
    a = np.array([df[i, 3], df[i, 5]])
    client.send_message("/temp", a)
    #value = float(a)
    print(a)
    time.sleep(value / 16666) # Seconds
    #sum = sum + 1

#print(len(ES_D1)) #check length UNCOMMENT IN LOOP
#print(sum) #check length
print("klippa-hans-tung")

# The port for SuperCollider is '57120'

#

# now we can print them out too
#for i in range(len(genre)): (len means length)

#for i in range(10):
#      client.send_message("/print", 1)
#      time.sleep(0.015)
