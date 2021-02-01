import time
import datetime
comehometime = datetime.datetime.strptime('2021-2-5 20:25:00','%Y-%m-%d %H:%M:%S')
nowtime = datetime.datetime.today()
djstime = comehometime - nowtime
day = djstime.days
hour = int(djstime.seconds / 60 / 60)
mintue = int((djstime.seconds - hour * 60 * 60 ) / 60)
second = djstime.seconds- hour * 60 * 60 - mintue * 60
print('距离回家倒计时还有：'+str(day) + '天' + str(hour) + '小时' + str(mintue) + '分' + str(second) + '秒')
time.sleep(1)
print('五秒后退出程序')
time.sleep(5)
