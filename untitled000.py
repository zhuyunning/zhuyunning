# -*- coding: utf-8 -*-
"""
Created on Sat Sep 10 12:34:07 2016
@author: Yunning Zhu
GWID: G39659638
Using pandas to create dataframe and sort datas, also making plots and graphs 
to visualize the results.
"""

import pandas as pd
import time

def getData():
    '''reads mutiple files and returns contents in a pandas dataframe
    Args:
        None:
    Requests fot the name of the path for the files in the program
    Returns:
        a list with the file contents
    '''
    
# create empty dataframe
start_time = time.time()
dfAll=pd.DataFrame({'Name' : [],'Sex' : [],'Count' : [],'Year' : []})

print ('Started ...')
for year in range(1880,2016):
    filename = 'yob'+str(year)+'.txt'
    filepath = '/home/nico/Downloads/names/'+filename
    # Read a new file into a dataframe
    df = pd.read_csv(filepath, header=None)
    df.columns = ['Name', 'Sex', 'Count']
    df['Year'] = str(year)
    dfAll = pd.concat([dfAll,df])  
    
print('Done...')
print ('It took', round(time.time()-start_time,4), 'seconds to read all the data into a dataframe.')

# Part 1

def q1(myDF):
    '''Compute the total number of birth for each year and provide a formatted printout of that
    Args:
       filename: the pandas dataframe with all data
    Returns:
       nothing
    '''
    
dfCount = dfAll['Count'].groupby(dfAll['Year']).sum()
s = '{:>5}'.format('Year')
s = s + '{:>10}'.format('Births')
print(s)
for myIndex, myValue in dfCount.iteritems():
    s = '{:>5}'.format(myIndex)
    s = s + '{:>10}'.format(str(int(myValue)))
    print (s)
    
# Part 2
    
def q2(myDF):
    '''Compute the total number of birth for each year for males and females and make a plot for that
    Args:
       dataframe
    Returns:
       dataframe contents
    '''
    
import matplotlib       # import the libraries to plot          
matplotlib.style.use('ggplot')   # set the plot style to ggplot type
%matplotlib inline             
# Exceute the condition provided in the assignment
dfSubset = dfAll[ (dfAll['Year'] >= '1990') & (dfAll['Year'] <= '2014') ]
# Subset by sex and sum the variable of interest
dfCountBySex = dfSubset['Count'].groupby(dfSubset['Sex']).sum()
dfCountBySex.plot.bar()            

# Part 3

def q3(myDF):
    '''Print the top 5 names for each year from each year starting in 1950
    Args:
       dataframe
    Returns:
       dataframe contents
    '''
    
# Prepare header
s = ''
s = '{:>5}'.format('Year')
s = s + '{:>10}'.format('Name 1')
s = s + '{:>10}'.format('Name 2')
s = s + '{:>10}'.format('Name 3')
s = s + '{:>10}'.format('Name 4')
s = s + '{:>10}'.format('Name 5')
print (s)
# Now go through all the years for the report
for i in range(1950,1954):
    fn = dfAll[(dfAll['Year'] == str(i))]                   
    fn = fn.sort_values('Count', ascending=False).head(5)  
    s = ''
    s = s = s + '{:>5}'.format(str(i))
    # Now iterate through the data frame with five records
    for idx, row in fn.iterrows():
        s = s + '{:>10}'.format(row["Name"])
    print(s)

# Part 4

def q4(myDF):
    '''Find the top 3 female and male names for years 2010and up and plot the frequency by gender
    Args:
       dataframe
    Returns:
       dataframe
    '''
    
import matplotlib.pyplot as plt               
plt.style.use('ggplot')   
%matplotlib inline
# create dataframe with data from 2010-2016 with male names
# grouped by names
# find the top 3 male names
df4a = dfAll[ (dfAll['Year'] >= '2010') & (dfAll['Sex']=='M')]
dfCountByName = df4a.groupby(df4a['Name']).sum()
dfMale = dfCountByName.sort_values('Count', ascending=False).head(3)
print (dfMale)
# same as before but with female names
df4b = dfAll[(dfAll['Year'] >= '2010') & (dfAll['Sex']=='F')]
dfCountByName2 = df4b.groupby(df4b['Name']).sum()
dfFemale = dfCountByName2.sort_values('Count', ascending=False).head(3)
print (dfFemale)
# combine the dataframe to show data in one plot
result = pd.concat([dfMale,dfFemale])
result.plot.bar()  
  
# Part 5
  
def q5(myDF):
    '''Plot the trend of 4 names all over the year
    Args:
       dataframe
    Returns:
       dataframe
    '''
    
# a
# create new dataframes of each name
dfJohn = dfAll[(dfAll['Name']=='John')].groupby(['Year']).sum()
dfHarry = dfAll[(dfAll['Name']=='Harry')].groupby(['Year']).sum()
dfMary = dfAll[(dfAll['Name']=='Mary')].groupby(['Year']).sum()
dfMarilyn = dfAll[(dfAll['Name']=='Marilyn')].groupby(['Year']).sum()
# make a combined dataframe with 4 names and set names columns
names = [dfJohn,dfHarry,dfMary,dfMarilyn]
df5a = pd.concat(names,axis=1)
df5a.columns = ['John','harry','Mary','Marilyn']
print (df5a)
# create the stacked plot
df5a.plot.bar(stacked=True)

# b
# let 4 trends in 1 plot 
df5a.plot()

# Part 6

'''Plot the trend of 4 names all over the year
    Args:
       dataframe
    Returns:
       dataframe contents
    '''
    
# create dataframe grouped by name and count the standard deviation
import numpy as np
df6 = dfAll.groupby(['Name']).agg({'Count':[np.std]})
print (df6)
# sort and rank the top 10 std
df6Name = df6.sort_values([('Count','std')],ascending=False).head(10)
print (df6Name)
# create the trend plot
df6Name['Count','std'].plot()
 











