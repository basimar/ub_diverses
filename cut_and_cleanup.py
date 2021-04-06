# cut and cleanup big input file
# * cut according to defined criteria in row (basically list of sublibraries)
# * cleanup subfield codes preceding values
 
import csv
import re
 
infile = 'PST_all.seq'
outfile = 'all_out.csv'
 
with open(infile) as f1:
    with open(outfile, 'w') as f2:
        for row in f1:
            # create litte dict with subfield keys
            sfdict = {i[:1] : i[1:] for i in re.split('\$\$', row)}
 
            # pluck necessary values, use get() for NONE
            sys = row[0:9]
            itemkey = sfdict.get('1')
            sublibrary = sfdict.get('b', 'NO-SUBLIBRARY').ljust(6)
            location = sfdict.get('c', 'NO-LOCATION').ljust(6)
            mattype = sfdict.get('o')
            itemstatus = sfdict.get('d')
            processstatus = sfdict.get('e')
            holnumber = sfdict.get('r')
            callnumber = sfdict.get('h')
            dedupkey = sys + sublibrary + location
 
            # write csv file
            csvrow = [dedupkey, sys, sublibrary, location, itemkey, mattype, itemstatus, processstatus, holnumber, callnumber]
            outwriter = csv.writer(f2, dialect='unix', delimiter='|', quoting=0)
            outwriter.writerow(csvrow)
