# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 20:46:03 2016

@author: zhuyunning
"""

import assignment6_2 as a

def main():
    import argparse as ap
    myP=ap.ArgumentParser()
    myP.add_argument("-d", "--database", help="write output to table", action="store_true")
    myP.add_argument("-t", "--txt", help="send output to txt file", action="store_true")
    myArgs=myP.parse_args()
    
    result=a.createandsolveLP()
    
    if (myArgs.database and myArgs.txt):
        a.writedatabase(myArgs.database,result)
        print ("Output being sent to table: {} in the LP databas".format(myArgs.database)+"\n"+"Output written to table")
        a.writetxtfile(myArgs.txt,result)
        print ("Output written to file: {}".format(myArgs.txt))
    elif myArgs.database:
        a.writedatabase(myArgs.database,result)
        print ("Output being sent to table: {} in the LP databas".format(myArgs.database)+"\n"+"Output written to table")
    elif myArgs.txt:
        a.writetxtfile(myArgs.txt,result)
    else:
        opt=""
        Keys=result.keys()
        for key in Keys:
            opt=opt+"The problem name is "+ key +"\n"
        Values=list(result.values())
        for V in Values:
            v=list(V.values())
            for i in v:
                opt=opt+"\n"+"The optimal value is "+str(i)
        print (opt)
    
if __name__=="__main__":
    main()