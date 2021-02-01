 BIM指数计算
import time
import datetime
print('BMI指数计算器'.center(100,'#'))
print('height：单位米  |  weight：单位kg'.center(100,'#'))
print(('当前时间：'+datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')).center(100,'#'))
time.sleep(1)
height = float(input('请输入你的身高：'))
weight = float(input('请输入你的体重：'))
bmi = weight/(height * height)
if bmi < 18.5:
    print('BMI指数为'+ str(bmi))
    print('体重过轻 ~@_@~')
elif 24.9 > bmi >= 18.5:
    print('BMI指数为'+ str(bmi))
    print('体重在正常范围哦 ~@_@~')
elif 29.9 > bmi >= 24.9:
    print('BMI指数为')+ str(bmi)
    print('体重过重 ~@_@~')
else:
    print('BMI指数为：'+str(bmi))
    print('肥胖')
time.sleep(3)
print('计算结束，see you again')
print('程序6s后自动退出')
time.sleep(6)
