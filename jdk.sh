#!/bin/bash
#安装jdk
cd ~
sudo wget http://download.oracle.com/otn-pub/java/jdk/8u11-b12/jdk-8u11-linux-x64.tar.gz
tar -xvzf jdk-8u11-linux-x64.tar.gz
sudo mv jdk1.8.0_11 jdk /opt/jdk
sudo chown -R luo:luo /opt/jdk
cd /opt/jdk
echo "export JAVA_HOME=/opt/jdk" >>~/.bashrc
echo "export JRE_HOME=\${JAVA_HOME}/jre" >>~/.bashrc
echo "export CLASSPATH=.:\${JAVA_HOME}/lib:\${JRE_HOME}/lib" >>~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java" >>~/.bashrc

sudo update-alternatives --install /usr/bin/java java /opt/jdk/bin/java 300
sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/bin/javac 300
sudo update-alternatives --install /usr/bin/jar jar /opt/jdk/bin/jar 300
sudo update-alternatives --install /usr/bin/javah javah /opt/jdk/bin/javah 300
sudo update-alternatives --install /usr/bin/javap javap /opt/jdk/bin/javap 300
sudo update-alternatives --config java
