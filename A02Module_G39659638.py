# -*- coding: utf-8 -*-
"""
Created on Sun Sep 25 17:46:51 2016

@author: Yunning Zhu
GWid: G39659638
"""
import numpy as np

def fileinput():
    myData = np.loadtxt('dataforplotshow.txt', delimiter=',',dtype=int)
    print (myData)
    return(myData)

myData=fileinput()

def regress():
    x1=myData[:,1]
    x2=myData[:,2]
    y=myData[:,0]
    ones = [1]*len(x1)
    X = np.concatenate(([ones],[x1],[x2]),axis=0).transpose()
    X = np.matrix(X)
    y = np.reshape(y,(8,1))
    coe = (X.T*X).I*X.T*y
    print (coe)   
    return(coe)

coe=regress()
x1=myData[:,1]
x2=myData[:,2]
y=myData[:,0]  
 
from sklearn.metrics import r2_score  
def output():
    y_predict=coe[0,0]+coe[1,0]*x1+coe[2,0]*x2
    r2 = r2_score(y,y_predict) 
    print ("bo=",coe[0,0])
    print ("b1=",coe[1,0])
    print ("b2=",coe[2,0])
    print ('R-squared= %.4f' % (r2)) 
    return (coe[0,0],coe[1,0],coe[2,0],r2)
    
op=output()
b0=coe[0,0]
b1=coe[1,0]
b2=coe[2,0]
y_predict=b0+b1*x1+b2*x2
r2 = r2_score(y,y_predict)

def formatoutput():
    print ("The equation is: Y={:.2f}+{:.2f}X1+{:.2f}X2".format(coe[0,0],coe[1,0],coe[2,0]))
    print ("The R-sqaure value is: {:2f}".format(r2))
    print ("The formatted input is shown below:")
    s = " "*(6)
    for i in ['y','x1','x2']:
        title = '{0:6s}'.format(i)
        s = s + title
    print(s)
    print ((" ")*6 + "="*4*4)
    
    for n in range(myData.shape[0]):
        s=' '
        for m in range(myData.shape[1]):
            number='{0:6d}'.format(myData[n,m])
            s = s + number
        print(s)
        
verbose=formatoutput()

from mpl_toolkits.mplot3d import *  
def myPlot(myData, b):    
    import matplotlib.pyplot as plt
    import numpy as np
    from matplotlib import cm

    fig = plt.figure()
    ax = fig.gca(projection='3d')               # to work in 3d
    plt.hold(True)
    
    x_max = max(myData[:,1])    
    y_max = max(myData[:,2])   
    
    b0 = float(coe[0,0])
    b1 = float(coe[1,0])
    b2 = float(coe[2,0])   
    
    x_surf=np.linspace(0, x_max, 100)                # generate a mesh
    y_surf=np.linspace(0, y_max, 100)
    x_surf, y_surf = np.meshgrid(x_surf, y_surf)
    z_surf = b0 + b1*x_surf +b2*y_surf         # ex. function, which depends on x and y
    ax.plot_surface(x_surf, y_surf, z_surf, cmap=cm.hot, alpha=0.2);    # plot a 3d surface plot   
    
    x=myData[:,1]
    y=myData[:,2]
    z=myData[:,0]
    ax.scatter(x, y, z);                        # plot a 3d scatter plot
    
    ax.set_xlabel('x1')
    ax.set_ylabel('y2')
    ax.set_zlabel('y')

    plt.show()

if __name__ == "__main__":
    
    myData = np.genfromtxt('dataforplotshow.txt', delimiter=',')    

    b = np.array([[1.0],
         [2.0],
         [1.5]])
         
    print (b)
    
    myPlot(myData, b)
    
import argparse as ap
def Main():
    myP = ap.ArgumentParser()
    myP.add_argument('filename', help="input the file name you need to read", type=str)
    myP.add_argument('-v', '--verbose', help="verbose output", action='store_true')
    myP.add_argument("-b","--brief", help="brief output", action = "store_true") 
    myP.add_argument("-p","--plot", help="plot the regression", action="store_true")                                             
    myP.add_argument("-o", "--output", dest="outfile", action="store", help="output file")
    
    myArgs = myP.parse_args()
    mydata = fileinput(myArgs.filename)

    if myArgs.brief:
        print("b0= {:.2f}, b1= {:.2f}, b2= {:.2f}".format(coe[0,0],coe[1,0],coe[2,0]))
    elif myArgs.verbose:
        print(verbose)
    elif myArgs.plot:
        print(myPlot(myData, b))
    else:
        print("b0= {:.2f}, b1= {:.2f}, b2= {:.2f}, R-square= {:.2f}".format(coe[0,0],coe[1,0],coe[2,0],r2))
        
    if myArgs.output:
        with open(myArgs.output, 'a') as f:
            f.write(str(mydata)+'\n')

if __name__ == "__main__":
    Main()

