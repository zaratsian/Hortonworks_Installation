
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
for hour in hours_path:
    minutes = client.listdir(hour)
    for minute in minutes:
        path = hour + '/' + str(minute)
        #print path
        minutes_path.append(path)

counter = 0
for path in minutes_path:
    contents = re.sub('\n$','',client.open(path).read())
    counter += len(contents.split('\n'))

print '\n\nTotal number of logs: ' + str(counter) + '\n\n'


#ZEND
