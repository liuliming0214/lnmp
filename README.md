tltw lnmp shell/一起学习编写LNMP安装脚本
===
最近接触太多关于操作系统配置的事情了，自己俨然成了一名运维。    
面对这样的情景，每天都在做重复的工作，肯定非常不爽。  
于是乎，我就决定自己去写一个LNMP的安装脚本好了！  
shell我也不懂太多，都是想到什么，就去谷歌找。或者看一下别人写的。  
如果你也想学shell，可以一起来看这份GIT仓库的操作记录。注释我都写好的了.  

# 注意事项
目前仅支持ubuntu 12.04 + 以上运行！   
Centos用户需要的话，请自行将apt-get 换成对应的yum包！   

# Mysql安装事项
脚本默认的安装时，会配置用户密码为 123456 请自行修改!   
脚本安装完毕后，若直接运行 mysql 提示没有命令，请执行 source /etc/profile

