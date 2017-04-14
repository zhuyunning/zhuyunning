# -*- coding: utf-8 -*-
"""
Created on Sun Oct  9 13:51:08 2016

@author: nico

Programming Assignment 03: Web Scraping
Group 5
Yunning Zhu G39659638
Daniel Chen G25195689
Xinyi Wang G44230350
Tingting Ju
Abhinav Chandel G33895000
"""

#Question 1
#Mexican Restaurant
from bs4 import BeautifulSoup as bs
import urllib.request
import pandas as pd
import re
def step1():
    rooturl="https://www.yelp.com/search?find_desc=mexican+food&find_loc=Washington,+DC"
    links=[]
    lists=[]
    for i in range(0,750,10):
        i=str(i)
        nexturl=rooturl+"&start="+i
        links.append(nexturl)

    for link in links:
        url=link
        request = urllib.request.Request(url)
        response = urllib.request.urlopen(request)
        data=response.read()
        response.close()
        soup=bs(data,"html.parser")
        each=soup.find_all('li',class_="regular-search-result")
        for i in each:
            x=[]
            #name of restaurants
            name=i.find('a',class_="biz-name js-analytics-click")
            name=name.getText().strip()
            x.append(name)
            #all address
            addressall=i.find('address')
            addressall=str(addressall)
            street=re.search('\n            (.+?)<br>',addressall)
            if street is None:
                x.append('NaN') #street
                city = re.search('<br>(.+?),',addressall)
                if city is None:
                    x.append('NaN')#city
                    x.append('NaN') #state
                    x.append('NaN') #zip
                elif city is not None:
                    city = re.search('<br>(.+?),',addressall).group(1)
                    x.append(city)
                    state = re.search(', (.+?) ',addressall)
                    if state is not None:
                        state = state.group(1)
                        x.append(state)
                        zip = re.search(' (\d{5})\n',addressall)
                        if zip is not None:
                            zip = zip.group(1)
                            x.append(zip)
                        elif zip is None:
                            x.append('NaN')
                    elif state is None:
                        x.append('NaN')
                        x.append('NaN')
            elif street is not None:
                street = re.search('\n            (.+?)<br>',addressall).group(1)
                x.append(street)
                city = re.search('<br>(.+?),',addressall).group(1)
                city = re.search('<br>(.+?),',addressall)
                if city is None:
                    x.append('NaN') #city
                    x.append('NaN') #state
                    x.append('NaN') #zip
                elif city is not None:
                    city = re.search('<br>(.+?),',addressall).group(1)
                    x.append(city)
                    state = re.search(', (.+?) ',addressall)
                    if state is not None:
                        state = state.group(1)
                        x.append(state)
                        zip = re.search(' (\d{5})\n',addressall)
                        if zip is not None:
                            zip = zip.group(1)
                            x.append(zip)
                        elif zip is None:
                            x.append('NaN')
                    elif state is None:
                        x.append('NaN')
                        x.append('NaN')
            #phone
            phone=i.find('span',class_="biz-phone")
            if phone is None:
                x.append("NaN")
            else:
                phone=phone.getText()
                phone=phone[9:23]
                x.append(phone)
                #number of reviews
            views=i.find('span',class_='review-count rating-qualifier')
            if views is None:
                x.append("NaN")
            else:
                views=views.getText().strip().split()
                x.append(int(views[0]))
                #Rate
            rate=i.find('i')
            if rate is None:
                x.append("NaN")            
            else:
                rate=rate['title']
                rate=rate[0:3]
                rate=float(rate)
                x.append(rate)
                #price
            price=i.find("span",class_="business-attribute price-range")
            if price is None:
                x.append("NaN")
            if price is not None:
                price=price.getText()
                x.append(price)
                #price range
                if price =="$":
                    x.append(10)
                if price =="$$":
                    x.append(20)
                if price =="$$$":
                    x.append(30)
                if price =="$$$$":
                    x.append(40)
                lists.append(x)
                #print(lists)
    headings = ['Name', 'StreetAddress','City','State','Zip','Phone','Number of Reviews','Rating','Price','Price Range']
    df = pd.DataFrame(lists, columns=headings)
    df.to_csv('Mexican.csv')
    return df

#Chinese Restaurant
    rooturl="https://www.yelp.com/search?find_desc=chinese+food&find_loc=Washington,+DC"
    links=[]
    lists=[]
    for i in range(0,990,10):
        i=str(i)
        nexturl=rooturl+"&start="+i
        links.append(nexturl)
        
    for link in links:
        url=link
        request = urllib.request.Request(url)
        response = urllib.request.urlopen(request)
        data=response.read()
        response.close()
        soup=bs(data,"html.parser")
        each=soup.find_all('li',class_="regular-search-result")
        for i in each:
            x=[]
            #name of restaurants
            name=i.find('a',class_="biz-name js-analytics-click")
            name=name.getText().strip()
            x.append(name)
            #all address
            addressall=i.find('address')
            addressall=str(addressall)
            street=re.search('\n            (.+?)<br>',addressall)
            if street is None:
                x.append('NaN') #street
                city = re.search('<br>(.+?),',addressall)
                if city is None:
                    x.append('NaN')#city
                    x.append('NaN') #state
                    x.append('NaN') #zip
                elif city is not None:
                    city = re.search('<br>(.+?),',addressall).group(1)
                    x.append(city)
                    state = re.search(', (.+?) ',addressall)
                    if state is not None:
                        state = state.group(1)
                        x.append(state)
                        zip = re.search(' (\d{5})\n',addressall)
                        if zip is not None:
                            zip = zip.group(1)
                            x.append(zip)
                        elif zip is None:
                            x.append('NaN')
                    elif state is None:
                        x.append('NaN')
                        x.append('NaN')
            elif street is not None:
                street = re.search('\n            (.+?)<br>',addressall).group(1)
                x.append(street)
                city = re.search('<br>(.+?),',addressall).group(1)
                city = re.search('<br>(.+?),',addressall)
                if city is None:
                    x.append('NaN') #city
                    x.append('NaN') #state
                    x.append('NaN') #zip
                elif city is not None:
                    city = re.search('<br>(.+?),',addressall).group(1)
                    x.append(city)
                    state = re.search(', (.+?) ',addressall)
                    if state is not None:
                        state = state.group(1)
                        x.append(state)
                        zip = re.search(' (\d{5})\n',addressall)
                        if zip is not None:
                            zip = zip.group(1)
                            x.append(zip)
                        elif zip is None:
                            x.append('NaN')
                    elif state is None:
                        x.append('NaN')
                        x.append('NaN')
                        #phone
            phone=i.find('span',class_="biz-phone")
            if phone is None:
                x.append("NaN")
            else:
                phone=phone.getText()
                phone=phone[9:23]
                x.append(phone)
                #number of reviews
            views=i.find('span',class_='review-count rating-qualifier')
            if views is None:
                x.append("NaN")
            else:
                views=views.getText().strip().split()
                x.append(int(views[0]))
                #Rate
            rate=i.find('i')
            if rate is None:
                x.append("NaN")            
            else:
                rate=rate['title']
                rate=rate[0:3]
                rate=float(rate)
                x.append(rate)
                #price
            price=i.find("span",class_="business-attribute price-range")
            if price is None:
                x.append("NaN")
            if price is not None:
                price=price.getText()
                x.append(price)
                #price range
                if price =="$":
                    x.append(10)
                if price =="$$":
                    x.append(20)
                if price =="$$$":
                    x.append(30)
                if price =="$$$$":
                    x.append(40)
            lists.append(x)
            #print(lists)
    headings = ['Name', 'StreetAddress','City','State','Zip','Phone','Number of Reviews','Rating','Price','Price Range']
    df = pd.DataFrame(lists, columns=headings)
    df.to_csv('Chinese.csv')
    return df

#Question 2
#Histogram
import matplotlib.pyplot as plt
def step2():
    df=pd.read_csv('Mexican.csv')
    df['Rating'].hist(bins=8,color='pink')
    plt.xlabel('Rating')
    plt.title('Mexican Food Rating')
    plt.savefig('histRatingMexican.pdf')
    plt.show()
    
    df=pd.read_csv('Chinese.csv')
    df['Rating'].hist(bins=8,color='blue')
    plt.xlabel('Rating')
    plt.title('Chinese Food Rating')
    plt.savefig('histRatingChinese.pdf')
    plt.show()
    return

#Question 3
import numpy as np
def step3():
    #Plot the relationship between Mexican restaurants' Rating (Y) and Number of reviews (X).
    plt.figure(1)
    data = pd.read_csv("Mexican.csv")
    data = data.dropna()

    x = data['Number of Reviews']
    y = data['Rating']
    fit = np.polyfit(x,y,1) 
    P = np.poly1d(fit) 
    plt.plot(x,y,'bo',x,P(x),'--r') 
    plt.title('Relationship between Mexican Rating and Number of Reviews') 
    plt.xlabel('Number of Reviews')
    plt.ylabel('Rating')
    plt.savefig('MXY2.pdf')
    plt.show()
    
    #Plot the relationship between Mexican restaurants' Rating (Y) and Price Range (X).
    plt.figure(2)
    data = pd.read_csv("Mexican.csv")
    data = data.dropna()

    x = data['Price Range']
    y = data['Rating']
    fit = np.polyfit(x,y,1) 
    P = np.poly1d(fit) 
    plt.plot(x,y, 'yo', x, P(x), '--b') 
    plt.title( 'Relationship between Mexican Rating(Y) and Price Range (X)')
    plt.xlabel('Price range')
    plt.ylabel('Rating')
    plt.savefig('MXY1.pdf')
    plt.show()
    
    #Plot the relationship between Chinese restaurants' Rating (Y) and Number of reviews (X).
    plt.figure(3)
    data = pd.read_csv("Chinese.csv")
    data = data.dropna()

    x = data['Number of Reviews']
    y = data['Rating']
    fit = np.polyfit(x,y,1) 
    P = np.poly1d(fit) 
    plt.plot(x,y, 'yo', x, P(x), '--r') 
    plt.title('Relationship between Chinese Rating(Y) and Number of review (X)')
    plt.xlabel('Number of Reviews')
    plt.ylabel('Rating')
    plt.savefig('CXY2.pdf')
    plt.show()
    
    #Plot the relationship between Chinese restaurants' Rating (Y) and Price Range (X).
    plt.figure(4)
    data = pd.read_csv("Chinese.csv")
    data = data.dropna()

    x = data['Price Range']
    y = data['Rating']
    fit = np.polyfit(x,y,1) 
    P = np.poly1d(fit) 
    plt.plot(x,y, 'yo', x, P(x), '--b') 
    plt.title('Relationship between Chinese Rating(Y) and Price Range (X)')
    plt.xlabel('Price range')
    plt.ylabel('Rating')
    plt.savefig('CXY1.pdf')
    plt.show()
    return

#Question 4
from mpl_toolkits.mplot3d import *
from sklearn import linear_model
from sklearn.metrics import r2_score
def step4():
    #Combine 2 csv
    data1 = pd.read_csv("Mexican.csv")
    data2 = pd.read_csv("Chinese.csv")
    data3 = pd.concat([data1, data2], axis=0)
    data3 = data3.dropna()
    
    # Regression
    set1 = pd.concat([data3["Price Range"], data3["Number of Reviews"]], axis=1)
    X = set1.as_matrix()
    model = linear_model.LinearRegression(fit_intercept = True)        
    y = data3["Rating"]
    fit = model.fit(X,y)
    pred = model.predict(X)
    
    #Print out coefficients and R2   
    print("Intercept: ",fit.intercept_)
    print("Slope: ", fit.coef_)
    r2 = r2_score(y,pred) 
    print ('R-squared: %.2f' % (r2))

    #Plot a 3d scatter plot
    import matplotlib.pyplot as plt
    import numpy as np
    from matplotlib import cm      
    f = plt.figure()
    ax = f.gca(projection='3d')             
    plt.hold(True)
    x_max = max(data3["Price Range"])    
    y_max = max(data3["Number of Reviews"])   
    
    b0 = float(fit.intercept_)
    b1 = float(fit.coef_[0])
    b2 = float(fit.coef_[1])   
    
    x_surf=np.linspace(0, x_max, 100)                
    y_surf=np.linspace(0, y_max, 100)
    x_surf, y_surf = np.meshgrid(x_surf, y_surf)
    z_surf = b0 + b1*x_surf +b2*y_surf
    # plot a 3d surface
    ax.plot_surface(x_surf, y_surf, z_surf, cmap=cm.hot, alpha=0.2);    
    
    x=data3["Price Range"]
    y=data3["Number of Reviews"]
    z=data3["Rating"]
    # plot a 3d scatter plot
    ax.scatter(x, y, z);                        

    ax.set_xlabel('fit.coef_[0]')
    ax.set_ylabel('fit.coef_[1]')
    ax.set_zlabel('fit.intercept_')
    plt.title('regression')
    plt.xlabel('Price range')
    plt.ylabel('Number of reviews')
    plt.savefig('regression.pdf')
    plt.show()

    return


# In[ ]:



