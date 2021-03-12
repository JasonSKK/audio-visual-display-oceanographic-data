from pythonosc import osc_message_builder
from pythonosc import udp_client
import time

# The port for SuperCollider is '57120'

client = udp_client.SimpleUDPClient("192.168.1.7", 57120)


#client.send_message("/print", muons_E)

# now we can print them out too

#for i in range(len(genre)): (len means length)
for i in range(10):
      client.send_message("/print", 1)
      time.sleep(0.015)
