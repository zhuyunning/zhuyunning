# -*- coding: utf-8 -*-
"""
Created on Wed Apr 12 13:53:34 2017

@author: patri
"""

import pandas as pd
import math
import matplotlib.pyplot as plt

train = pd.read_csv('train.csv')
test = pd.read_csv('test.csv')

#Visualize digits
f, ax = plt.subplots(4, 4)

for i in range(0,16):
    data = train.iloc[i,1:785].values
    image = data.reshape((28, 28))
    col=math.floor(i/4)
    row=[0,1,2,3]*4
    ax[row[i], col].imshow(image)
    ax[row[i],col].get_xaxis().set_visible(False)
    ax[row[i],col].get_yaxis().set_visible(False)

#Frequency of digits
plt.hist(train.iloc[:,0])
plt.title('Distribution of digits')

#Normaliztion
train.iloc[:,1:] = train.iloc[:,1:]/255
test = test/255

train.to_csv('train_mod.csv', index=False)
test.to_csv('test_mod.csv')