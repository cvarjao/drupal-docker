# Must use URL
FROM registry.access.redhat.com/rhel7
MAINTAINER cleciovarjao@gmail.com

ENV GOGS_CUSTOM /home/gogs

#Install core tools
RUN yum install -y curl tar sudo cronie && \
    sed -i '/Defaults    requiretty/s/^/#/' /etc/sudoers && \
    yum clean all -y

#Install gosu    
ADD https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 /usr/local/bin/gosu
ADD https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64.asc /usr/local/bin/gosu.asc
RUN chmod +x /usr/local/bin/gosu

#Install s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.17.2.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" --exclude="./sbin" && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin ./sbin && \
    rm -f  /tmp/s6-overlay-amd64.tar.gz

#Install PHP
RUN rpm -Uvh 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm' && \
    rpm -Uvh 'https://mirror.webtatic.com/yum/el7/webtatic-release.rpm' && \
    yum install -y httpd php55w php55w-opcache php55w-mbstring php55w-gd php55w-xml php55w-pear php55w-fpm php55w-mysql && \
    sudo systemctl enable httpd.service && \
    yum clean all -y
    
#Install Drupal
ADD https://ftp.drupal.org/files/projects/drupal-8.1.2.tar.gz /tmp/drupal.tar.gz
RUN mkdir -p /app/drupal/www && tar --strip-components=1 -xvzf drupal-x.x.tar.gz -C /app/drupal/www

COPY ./files/ /

RUN find /app -type f -name '*.sh' -exec chmod +x {} \; && \ 

EXPOSE 80
WORKDIR /app/www
VOLUME ["/data"]

ENTRYPOINT ["/app/httpd/run-httpd.sh"]