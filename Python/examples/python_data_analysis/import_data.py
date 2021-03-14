# Numpy (data import, manipulation, export)
import numpy as np
# Matplotlib (create trends)
import matplotlib.pyplot as plt

# load the data file
data_file = np.genfromtxt('data_file.txt', delimiter=',')

# create time vector from imported data (starts from index 0)
time = data_file[:,0]
# parse good sensor data from imported data
sensors = data_file[:,1:5]

# display the first 6 sensor rows
print(sensors[0:6])

# adjust time to start at zero by subtracting the
#  first element in the time vector (index = 0)
time = time - time[0]

# calculate the average of the sensor readings
avg = np.mean(sensors,1) # over the 2nd dimension

# export data
# stack time and avg as column vectors
my_data = np.vstack((time,sensors.T,avg))
# transpose data
my_data = my_data.T
# save text file with comma delimiter
np.savetxt('export_from_python.txt',my_data,delimiter=',')

# generate a figure
plt.figure(1)
plt.plot(time/60.0,sensors[:,1],'ro')
plt.plot(time/60.0,avg,'b.')
# add text labels to the plot
plt.legend(['Sensor 2','Average Sensors 1-4'])
plt.xlabel('Time (min)')
plt.ylabel('Sensor Values')
# save the figure as a PNG file
plt.savefig('my_Python_plot.png')
# show the figure on the screen (pauses execution until closed)
plt.show()
