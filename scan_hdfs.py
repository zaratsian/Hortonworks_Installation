
###############################################################################################
#
#   Python analyze HDFS
#
###############################################################################################

import re
from pyhdfs import HdfsClient

client = HdfsClient(hosts='dzaratsian-nifi4.field.hortonworks.com:50070')

root_path = '/topics/minifitest/2017/01/'

days       = client.listdir(root_path)
days_path  = [root_path + str(path) for path in days]

hours_path = []
for day in days_path:
    hours = client.listdir(day)
    for hour in hours:
        path = day + '/' + str(hour)
        #print path
        hours_path.append(path)

minutes_path = []
for path in hours_path:
    minutes = client.listdir(path)
    if len(minutes) != 60:
        print '[ INFO ] Incomplete minutes (less than 60) in path: ' + str(path) + ' (Count = ' + str(len(minutes)) + ')'
    
    for minute in minutes:
        path_out = path + '/' + str(minute)
        #print path_out
        minutes_path.append(path_out)

counter = 0
len_contents_list = []
for path in minutes_path:
    len_contents = len(re.sub('\n$','',client.open(path).read()).split('\n'))
    len_contents_list.append(len_contents)
    counter += len_contents


print '\n\nTotal number of logs: ' + str(counter) + '\n\n'


#ZEND
