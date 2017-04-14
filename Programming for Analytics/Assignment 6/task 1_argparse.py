# -*- coding: utf-8 -*-
"""
Created on Sat Nov 19 15:13:20 2016

@author: zhuyunning
"""
import assignment6 as a

def main():
    import argparse as ap
    
    myP=ap.ArgumentParser()
    myP.add_argument("filename", help="Name of input JSON file")
    myP.add_argument("-b", "--brief", help="brief output", action="store_true")
    myP.add_argument("-d", "--detailed", help="detailed output", action="store_true")
    myP.add_argument("-o", dest="output", help="send the output to a file")
    myArgs=myP.parse_args()
    data=a.readData(myArgs.filename)
    result=a.createandsolveLP(data)
    
    if (myArgs.output and myArgs.detailed):
        opt="The optimal value is "+str(list(result['objective_function'].values())[0])
        opt=opt+"\n"+"The decision variables and their values are:"
        Keys=result['decision_value'].keys()
        for key in Keys:
            opt=opt+"\n"+str(key)+"="+str(result['decision_value'][key])
        print (opt)
        a.writefile(myArgs.output,result)
    elif myArgs.brief:
        print (list(result['objective_function'].values())[0])
    elif myArgs.detailed:
        opt="The optimal value is "+str(list(result['objective_function'].values())[0])
        opt=opt+"\n"+"The decision variables and their values are:"
        Keys=result['decision_value'].keys()
        for key in Keys:
            opt=opt+"\n"+str(key)+"="+str(result['decision_value'][key])
        print (opt)
    elif myArgs.output:
        a.writefile(myArgs.output,result)    
    else:
        print ("The optimal value is "+str(list(result['objective_function'].values())[0]))
    
if __name__=="__main__":
    main()
