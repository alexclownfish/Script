import time
import os
def add(int):
  return int
#shut = os.popen("shutdown -r")
print('来跟我一起玩个游戏吧？')
time.sleep(2)
print('让我来猜猜你的年龄')
time.sleep(1)
print('真实的年龄还是虚假的年龄')
time.sleep(1)
print('年龄不同答案也就不同，结果也就不同 ')
time.sleep(2)
print('Then Action! ')
time.sleep(1)
age = int(input('请输入你的年龄:'))
if 18 <= age <= 20:
  print('噢！你已经是个大男孩儿了! 放手去做自己想做的事情吧!!')
elif 20 < age < 28:
  print('年龄也老大不小了，赶紧找个女朋友结婚吧 !!')
else:
  print('这…… 这个年龄就非常尴尬了呀 ')
  if age < 18:
    print('还是个未成年的小弟弟，玩什么游戏呢？抓紧时间好好学习')
  else:
    print('您有妻有子，不适合参加这个游戏')
print('游戏结束……')
time.sleep(1)
print('等一下 等一下 还有个问题想问你')
time.sleep(2)
score = input('请为这个游戏打分：')
if score == "满意":
  print('OK,感谢评价')
elif score == "不满意":
  os.system('shutdown -r')
else:
    print('请打分：满意 or 不满意')
print('GoodBye')
time.sleep(7)
