import matplotlib.pyplot as plt

plot1=[611.29 ,1605.6]
plot2=[53.22 ,139.16]
speedup=[11.486, 11.538]
img_sizes=[0, 1]

plt.plot(img_sizes, plot1, color='red', label='CPU time')
plt.plot(img_sizes, plot2, color='blue', label='GPU time')
plt.plot(img_sizes, speedup, color='yellow', label='Speedup')
plt.xlabel('Graph')
plt.ylabel('Execution time')
plt.legend(loc='best')
plt.show()
