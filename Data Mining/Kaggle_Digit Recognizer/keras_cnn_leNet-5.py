#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 22 00:15:12 2017

@author: lijingning
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import math
import keras
from keras import backend as K
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation, Flatten
from keras.layers.convolutional import Conv2D, MaxPooling2D
from keras.utils import np_utils
import matplotlib as plt
import numpy as np

# input image dimensions
img_rows, img_cols = 28, 28

batch_size = 128
nb_classes = 10
nb_epoch = 100

# Read data
train = pd.read_csv("train_mod.csv").values
test  = pd.read_csv("test_mod.csv").values



np.random.shuffle(train)

train, validate = train[6300:,:], train[:6300,:]

X_train, y_train = train[:,1:], train[:,0]
X_validate, y_validate = validate[:,1:], validate[:,0]


# reshape to be [samples][pixels][width][height]
X_train = X_train.reshape(X_train.shape[0], 1, img_rows, img_cols).astype('float32')
X_validate = X_validate.reshape(X_validate.shape[0], 1, img_rows, img_cols).astype('float32')

# Convert labels to binary classifiers
Y_train = np_utils.to_categorical(y_train, nb_classes)

model = Sequential()
model.add(Conv2D(20, (5, 5), activation = 'relu', input_shape=(1,img_rows,img_cols), kernel_initializer='he_normal'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Conv2D(50, (5, 5), activation = 'relu', kernel_initializer='he_normal'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Flatten())
model.add(Dense(180, activation = 'relu', kernel_initializer='he_normal'))
model.add(Dropout(0.5))
model.add(Dense(100, activation = 'relu', kernel_initializer='he_normal'))
model.add(Dropout(0.5))
model.add(Dense(nb_classes, activation = 'softmax', init='he_normal')) 

# The function to optimize is the cross entropy between the true label and the output (softmax) of the model
model.compile(loss='categorical_crossentropy', optimizer='adamax', metrics=["accuracy"])

filepath='checkpoint-{epoch:02d}-{val_loss:.2f}.hdf5'
earlyStopping=keras.callbacks.EarlyStopping(monitor='val_loss', patience=10, verbose=1, mode='auto')
saveBestModel = keras.callbacks.ModelCheckpoint(filepath, monitor='val_loss', verbose=1, save_best_only=True, mode='auto')


# Training
model.fit(X_train, Y_train, batch_size=batch_size, nb_epoch=nb_epoch, verbose=1,validation_data=(X_validate, y_validate),callbacks=[earlyStopping, saveBestModel])


# Predict the label for X_test
yPred = model.predict_classes(test,verbose=0)

# Save prediction in file for Kaggle submission
np.savetxt('test_cnn_lenet-5_v7.csv', np.c_[range(1,len(yPred)+1),yPred], delimiter=',', header = 'ImageId,Label', comments = '', fmt='%d')




def calc_misclass(classes, predict):
    diff_predict = predict - classes[:,0]
    indx = diff_predict.nonzero()
    wrongpred = predict[indx]
    wrongpred.resize(wrongpred.shape[0],1)
    misclasses = np.hstack((classes[indx,:][0],wrongpred))
    return misclasses

def plot_misclasses(misclassifications):
    f, ax = plt.subplots(3,3)

    for i in range(9):
        image = misclassifications[i+1,1:785].copy()
        image = image.reshape((28,28))
        col = math.floor(i/3)
        row = [0,1,2]*3
        ax[row[i],col].imshow(image)
        ax[row[i],col].set_title(str(misclassifications[i+1,-1]) + ' -> ' + str(misclassifications[i+1,0]), fontsize = 20)
        ax[row[i],col].get_xaxis().set_visible(False)
        ax[row[i],col].get_yaxis().set_visible(False)


val_predictions = model.predict_classes(X_validate, verbose=0)
val_misclasses = calc_misclass(validate, val_predictions)
plot_misclasses(val_misclasses)

