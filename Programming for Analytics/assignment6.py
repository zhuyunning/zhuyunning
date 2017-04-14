# -*- coding: utf-8 -*-
"""
Created on Wed Nov  9 15:03:03 2016

@author: zhuyunning
"""
import pulp as plp

def readData(fn):
  """Input = name of JSON file, Returns = JSON object"""
  import json
  try:
    with open(fn, 'r') as f:
      data=json.load(f)
    return data
  except:
    return None
 

def createandsolveLP(data):
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
    obj[str(my_model.objective)]=plp.value(my_model.objective)
    dec=[(v.name, v.varValue) for v in my_model.variables()]
    dec_val=dict(dec)
    from nested_dict import nested_dict
    result=nested_dict()
    result['decision_value']=dec_val
    result['objective_function']=obj
    return (result)


def writefile(fn,data):
    """
    Input = name of output file
    Output = text file with the detailed output or error message if the write
    operation was unsuccessful
    """
    opt=""
    opt=opt+"The optimal value is "+str(list(data['objective_function'].values())[0])
    opt=opt+"\n"+"The decision variables and their values are:"
    Keys=data['decision_value'].keys()
    for key in Keys:
        opt=opt+"\n"+str(key)+"="+str(data['decision_value'][key])

    try:
        with open(fn,"w") as f:
            f.write(opt)
        print ("Output written to {}".format(fn))
    except:
        print ("Error writing to file")
        



    