#!/bin/bash

SWAPFILE="/swapfile"
SIZE="1G"
TOMCAT_VERSION=10.1.48

fallocate -l $SIZE $SWAPFILE
chmod 600 $SWAPFILE
mkswap $SWAPFILE
swapon $SWAPFILE
echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab

apt update -y
apt install -y openjdk-17-jdk wget

sleep 10  # 네트워크 안정화 대기
wget -q http://mirror.apache-kr.org/apache/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
tar -xf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat
mv /opt/tomcat/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat/tomcat-10
chown -RH tomcat: /opt/tomcat/tomcat-10
chmod +x /opt/tomcat/tomcat-10/bin/*.sh

cat >/etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat 10
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat/tomcat-10"
Environment="CATALINA_BASE=/opt/tomcat/tomcat-10"
Environment="CATALINA_PID=/opt/tomcat/tomcat-10/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/tomcat-10/bin/startup.sh
ExecStop=/opt/tomcat/tomcat-10/bin/shutdown.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tomcat
sleep 10  # 데몬 재시작 대기
systemctl start tomcat

# boot.war를 웹서버에 전송한다.(S3 or SCP 2개 중 1개의 방법을 선택해서 전송)
# boot.war를 /opt/tomcat/tomcat-10/webapps/boot.war 위치로 move한다.
# sed -i 's/^spring.datasource.username.*/spring.datasource.username=web/' /opt/tomcat/tomcat-10/webapps/boot/WEB-INF/classes/application.properties
# sed -i 's/^spring.datasource.password.*/spring.datasource.password=1234/' /opt/tomcat/tomcat-10/webapps/boot/WEB-INF/classes/application.properties
# sed -i 's/^spring.datasource.url.*/spring.datasource.url=jdbc:mariadb://DB_EC2_PRIVATE_IP:3306/care /' /opt/tomcat/tomcat-10/webapps/boot/WEB-INF/classes/application.properties
