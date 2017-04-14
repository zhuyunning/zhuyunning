# -*- coding: utf-8 -*-
"""
Created on Sun Nov 20 15:47:29 2016

@author: zhuyunning
"""

import glob2
import json
import pymongo
import pulp as plp

def readandstore():
    client = pymongo.MongoClient('localhost:27017')
    db = client['myDB']
    collection = db['jsonfiles']
    if (collection.count() != 0):
        collection.drop()
    collection = db['jsonfiles']
    for i in glob2.glob('*.json'):
        fn=i.strip(".json")
        with open(i, 'r') as f:
            fn = json.load(f)
            db.jsonfiles.insert_one(fn)
    return db

#db = readandstore()
#a = db.jsonfiles.find()
#a.count()

def createandsolveLP():
    db=readandstore()
    All=db.jsonfiles.find()
    Data=[lp for lp in All]
    result={}
    for data in Data:
        if data['objective']=="MIN":
            my_model=plp.LpProblem('My Model',plp.LpMinimize)
        elif data['objective']=="MAX":
            my_model=plp.LpProblem('My Model',plp.LpMaximize)
        else:
            print("Neither max nor min")
            exit(0)
            
        decVars=data['variables']
        x=plp.LpVariable.dict('x_%s', decVars, lowBound=0)
        objCoeffList=data["objCoeffs"]
        objective=dict(zip(decVars, objCoeffList))
        
        my_model+=sum([objective[i] * x[i] for i in decVars])
        constraintKeys=data["LHS"].keys()
        for key in constraintKeys:
            LHScoeffs=dict(zip(decVars, data["LHS"][key]))
            if data["conditions"][key]=='<=':
                my_model += sum([LHScoeffs[j] * x[j] for j in decVars]) <= data['RHS'][key]
            elif data["conditions"][key]=='>=':
                my_model += sum([LHScoeffs[j] * x[j] for j in decVars]) >= data['RHS'][key]
            elif data["conditions"][key]=='==':
                my_model += sum([LHScoeffs[j] * x[j] for j in decVars]) == data['RHS'][key]
            else:
                print ("Problem with constraint {}".format(key))
                exit(0)
                
        my_model.solve()
        obj={}
        if plp.value(my_model.objective)!="NULL":
            obj['optimal_value']=plp.value(my_model.objective)
            result.update({data['name']:obj})
        else:
            result.update({data['name']:'NA'})
    return (result)
    
#b=createandsolveLP()
#print(b)

    
def writetxtfile(fn,data):
    opt=""
    Keys=data.keys()
    for key in Keys:
        opt=opt+"The problem name is "+ key +"\n"
    Values=list(data.values())
    for V in Values:
        v=list(V.values())
        for i in v:
            opt=opt+"\n"+"The optimal value is "+str(i)
        try:
            with open(fn,"w") as f:
                f.write(opt)
            print ("Output being sent to file {}".format(fn))
        except:
            print ("Error writing to file")
#print(writetxtfile("out.txt",b))
    
def writedatabase(tn,data):
    import pymysql as myDB
    conn = myDB.connect('localhost', 'root', 'root') 
    cursor = conn.cursor()

    sql = ' SHOW DATABASES; '
    cursor.execute(sql)
    
    sql = ' DROP DATABASE IF EXISTS LP; ' 
    cursor.execute(sql)
    
    sql = ' CREATE DATABASE LP; ' 
    cursor.execute(sql)
    
    sql = ' USE LP; ' 
    cursor.execute(sql)
    
    cursor.close()
    cursor = conn.cursor()
    
    sql =' DROP TABLE IF EXISTS %s; '%tn
    cursor.execute(sql)
    
    sql = '''
        CREATE TABLE %s ( 
        problemName CHAR(20),
        optimalValue CHAR(20));'''%tn
    cursor.execute(sql)
    
    values=[(value,data[value]['optimal_value']) for value in data.keys()]
    for n in values:
        sql="INSERT INTO"+tn+" (problemName, optimalValue) VALUES(%s,%s)"%(values[0][0], values[0][1])
        cursor.execute(sql,n)
        conn.commit()
    cursor.close()
 

