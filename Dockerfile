 # BUILD: sudo docker build -t eclipse-vnc .
 # TEST RUN: sudo docker run -it --rm -d -p5901:5901 --name eclipse eclipse-vnc
 
 FROM ubuntu:16.04
 
 LABEL maintainer "@Blissfish"
 LABEL description "Eclipse on Ubuntu over VNC"
 
 
 # install base packages required
 RUN   apt-get update \
   &&  apt-get install -y --no-install-recommends xfce4 \
         xfce4-goodies \
         xfce4-artwork \
         xfonts-base \
         xfonts-encodings \
         gnome-icon-theme-full \
         tango-icon-theme \
         sudo \
         openssh-server \
         rsync \
         openjdk-8-jdk-headless \
         openjdk-8-source \
         wget \
         unzip \
         curl \
         bash-completion \         
         software-properties-common \
         tightvncserver \
         git
 
 # install eclipse (use --no-install-recommends to avoid installing OpenJDK)
 COPY eclipse.desktop /usr/share/applications/eclipse.desktop
 
 RUN     cd /tmp \
     &&  wget http://download.eclipse.org/technology/epp/downloads/release/2019-12/R/eclipse-java-2019-12-R-linux-gtk-x86_64.tar.gz

 RUN     cd /tmp \
     &&  tar xvf eclipse-java-2019-12-R-linux-gtk-x86_64.tar.gz \
     &&  mv eclipse /opt \
     &&  rm -R eclipse* \
     &&  desktop-file-install /usr/share/applications/eclipse.desktop \
     &&  cd /usr/local/bin \
     &&  ln -s /opt/eclipse/eclipse
 
 # Maven installation
 COPY mavenenv.sh /etc/profile.d/mavenenv.sh
 
 RUN     cd /tmp \
     && wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
     
 RUN     cd /tmp \
     &&  tar -xvzf apache-maven-3.3.9-bin.tar.gz \
     &&  mv apache-maven-3.3.9 maven \
     &&  mv maven /opt \
     &&  rm -R apache* \
     && export M2_HOME=/opt/maven \
     && export PATH=${M2_HOME}/bin:${PATH} \
     &&  cd /usr/local/bin \
     &&  ln -s /opt/maven/bin/mvn

     #&&  chmod +x /etc/profile.d/mavenenv.sh \
     #&&  source /etc/profile.d/mavenenv.sh
     
 # set some labels so users can easily find the VNC access details
 ENV VNC_PASSWORD=eclipse
 ENV VNC_RESOLUTION=1024x768
 ENV USERNAME=eclipse
 ENV PASSWORD=eclipse
 
 # copy and prepare our startup script
 COPY startup.sh /startup.sh
 RUN     chmod +x /startup.sh
 
 # expose our VNC port
 EXPOSE 5901
 
 EXPOSE 8080
 
 # set our volume
 VOLUME /home
 
 # start our vncserver
ENTRYPOINT ["./startup.sh"]

  RUN     cd /home \
     &&  git clone https://github.com/blissfish/spring-boot-sample-service.git
