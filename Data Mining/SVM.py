#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Apr 13 16:08:32 2017

@author: lijingning
"""

# load modules
import numpy as np 
import pandas as pd 
np.random.seed(1)
# get data
test  = pd.read_csv('test.csv')
train = pd.read_csv('train.csv')

print(train.shape)
print(test.shape)
train.head()

import matplotlib.pyplot as plt
plt.hist(train["label"])
plt.title("Frequency Histogram of Numbers in Training Data")
plt.xlabel("Number Value")
plt.ylabel("Frequency")

import math
# plot the first 25 digits in the training set. 
f, ax = plt.subplots(5, 5)
# plot some 4s as an example
for i in range(1,26):
    # Create a 1024x1024x3 array of 8 bit unsigned integers
    data = train.iloc[i,1:785].values #this is the first number
    nrows, ncols = 28, 28
    grid = data.reshape((nrows, ncols))
    n=math.ceil(i/5)-1
    m=[0,1,2,3,4]*5
    ax[m[i-1], n].imshow(grid)

## normalize data ##
label_train=train['label']
train=train.drop('label', axis=1)

#normalize data
train = train / 255
test = test / 255
train['label'] = label_train

from sklearn import decomposition

## PCA decomposition
pca = decomposition.PCA(n_components=200) #Finds first 200 PCs
pca.fit(train.drop('label', axis=1))
plt.plot(pca.explained_variance_ratio_)
plt.ylabel('% of variance explained')
#plot reaches asymptote at around 50, which is optimal number of PCs to use. 

## PCA decomposition with optimal number of PCs
#decompose train data
pca = decomposition.PCA(n_components=50) #use first 3 PCs (update to 100 later)
pca.fit(train.drop('label', axis=1))
PCtrain = pd.DataFrame(pca.transform(train.drop('label', axis=1)))
PCtrain['label'] = train['label']

#decompose test data
#pca.fit(test)
PCtest = pd.DataFrame(pca.transform(test))

mfrom mpl_toolkits.mplot3d import Axes3D

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
#ax = fig.add_subplot(111)

x =PCtrain[0]
y =PCtrain[1]
z =PCtrain[2]

colors = [int(i % 9) for i in PCtrain['label']]
ax.scatter(x, y, z, c=colors, marker='o', label=colors)

ax.set_xlabel('PC1')
ax.set_ylabel('PC2')
ax.set_zlabel('PC3')

plt.show()

from sklearn.neural_network import MLPClassifier
y = PCtrain['label'][0:20000]
X = PCtrain.drop('label', axis=1)[0:20000]
clf1 = MLPClassifier(solver='lbgfs', alpha=1e-5,
                    hidden_layer_sizes=(50,), random_state=1)
clf1.fit(X, y)

from sklearn import metrics
#accuracy and confusion matrix
predicted1 = clf1.predict(PCtrain.drop('label', axis=1)[20001:420000])
expected = PCtrain['label'][20001:42000]

print("Classification report for classifier %s:\n%s\n"
      % (clf1, metrics.classification_report(expected, predicted1)))
print("Confusion matrix:\n%s" % metrics.confusion_matrix(expected, predicted1))

output1 = pd.DataFrame(clf1.predict(PCtest), columns =['Label'])
output1.reset_index(inplace=True)
output1.rename(columns={'index': 'ImageId'}, inplace=True)
output1['ImageId']=output1['ImageId']+1
output1.to_csv('test_MLPClassfier.csv', index=False)

from sklearn import svm
y = PCtrain['label'][0:20000]
X = PCtrain.drop('label', axis=1)[0:20000]
clf2 = svm.SVC()
clf2.fit(X, y)

predicted2 = clf2.predict(PCtrain.drop('label', axis=1)[20001:42000])

print("Classification report for classifier %s:\n%s\n"
      % (clf2, metrics.classification_report(expected, predicted2)))
print("Confusion matrix:\n%s" % metrics.confusion_matrix(expected, predicted2))

output2 = pd.DataFrame(clf2.predict(PCtest), columns =['Label'])
output2.reset_index(inplace=True)
output2.rename(columns={'index': 'ImageId'}, inplace=True)
output2['ImageId']=output2['ImageId']+1
output2.to_csv('test_SVM_default.csv', index=False)

clf3 = svm.SVC(decision_function_shape='ovo')
clf3.fit(X, y)

predicted3 = clf3.predict(PCtrain.drop('label', axis=1)[20001:42000])

print("Classification report for classifier %s:\n%s\n"
      % (clf3, metrics.classification_report(expected, predicted3)))
print("Confusion matrix:\n%s" % metrics.confusion_matrix(expected, predicted3))

output3 = pd.DataFrame(clf3.predict(PCtest), columns =['Label'])
output3.reset_index(inplace=True)
output3.rename(columns={'index': 'ImageId'}, inplace=True)
output3['ImageId']=output3['ImageId']+1
output3.to_csv('test_SVM_ovo.csv', index=False)









 