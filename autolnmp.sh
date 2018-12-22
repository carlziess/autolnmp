#!/bin/sh
# This script use to automatic deployment the NMP.
# I have never feeling coding this script by my self's hands it's a problem.
# Or feeling this actions will waste my time. 
# May you can find a same one in Github.
# May you can find a same one in Baidu.
# But you never know how to made this one when you need.
# This's free, If you like it, Please toke it. And don't forgot fixing the
# issues.
# Author lzl@rsung.com

SRC=/root/src/
DOWNLOADER=http://118.178.233.241:8080/

if [ $(whoami) != 'root' ];then
    echo "Sorry, The DeployScript must be running as root"
    exit 1
fi
if [ ! -d ${SRC} ];then
    mkdir -p ${SRC}
fi

update_server_centos() {
    yum update -y
    #install library
    yum -y install libjpeg libjpeg-devel libpng libpng-devel libvpx-devel libtiff libtiff-devel gettext gettext-devel libxml2 libxml2-devel zlib-devel file glib2 glib2-devel bzip2 diff* openldap-devel bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs freetype freetype-devel png jpeg zlib gd libiconv libevent mhash mcrypt pcre* openssl openssl-devel libxslt-devel libxml2-devel libXpm-devel fontconfig-devel jemalloc-devel unzip zip cmake gcc-c++ automake bison libedit-devel
}

update_server_ubuntu() {
    apt-get update
    #install library
    apt-get install -y build-essential libfontconfig-dev libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libvpx-dev libx11-dev libxpm-dev libxt-dev libz-dev libxml2 lib1g-dev file bzip2 file libncurses5-dev cmake  automake bison libedit-dev libxslt-dev unzip zip libmhash-dev libmcrypt-dev libjemalloc-dev libpcre++-dev libssl-dev zlib1g-dev
}

install_libiconv() {
    cd ${SRC}
    if [ ! -f ${SRC}libiconv-1.15.tar.gz ];then
        wget ${DOWNLOADER}libiconv-1.15.tar.gz
    fi
    sleep 1
    tar -zxvf libiconv-1.15.tar.gz
	cd libiconv-1.15
	./configure
	make && make install
}

install_libgd() {
    cd ${SRC}
    if [ ! -f ${SRC}libgd-2.1.1.tar.gz ];then
        wget ${DOWNLOADER}libgd-2.1.1.tar.gz
    fi
    sleep 1 
    tar -zxvf libgd-2.1.1.tar.gz
    cd libgd-2.1.1
    ./configure
    make && make install
}

install_nginx() {
    #If nginx has been installed.This steps will be skip.
    if [ ! -d /server/tengine-2.2.0 ]; then
        mkdir -p /server/tengine-2.2.0
    else
        return 0 
    fi
    if [ ! -d /data/web_log ];then
        mkdir -p /data/web_log
    fi
    if [ ! -d /data/webroot ];then
        mkdir -p /data/webroot
    fi
    cd ${SRC}
    #@fixme: I have no any ideas to got the groups and users currently state.If this group
    # or user has been created.This statement will be crash down.
    groupadd www
    useradd -g www www -d /data/webroot/ -s/bin/false
    chown -R www.www /data/webroot
    if [ ! -f ${SRC}echo-nginx-module.zip ];then
        wget ${DOWNLOADER}echo-nginx-module.zip
    fi
    sleep 1
    unzip -x echo-nginx-module.zip
    if [ ! -f ${SRC}tengine-2.2.0.tar.gz ];then
        wget ${DOWNLOADER}tengine-2.2.0.tar.gz
    fi
    sleep 1
    tar -zxvf tengine-2.2.0.tar.gz
    cd tengine-2.2.0

    ./configure --prefix=/server/tengine-2.2.0 --sbin-path=/server/tengine-2.2.0/sbin/nginx --conf-path=/server/tengine-2.2.0/conf/nginx.conf --error-log-path=/data/web_log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx --user=www --group=www --with-threads --with-file-aio --with-ipv6 --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_slice_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_concat_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_sysguard_module --with-http_charset_filter_module=shared --with-http_userid_filter_module=shared --with-http_footer_filter_module=shared --with-http_trim_filter_module=shared --with-http_access_module=shared --with-http_autoindex_module=shared --with-http_map_module=shared --with-http_split_clients_module=shared --with-http_referer_module=shared --with-http_rewrite_module=shared --with-http_fastcgi_module=shared --with-http_uwsgi_module=shared --with-http_scgi_module=shared --with-http_limit_conn_module=shared --with-http_limit_req_module=shared --with-http_empty_gif_module=shared --with-http_browser_module=shared --with-http_user_agent_module=shared --with-http_upstream_hash_module=shared --with-http_upstream_ip_hash_module=shared --with-http_upstream_least_conn_module=shared --with-http_upstream_session_sticky_module=shared --with-http_reqstat_module=shared --with-http_dyups_module --http-log-path=/data/web_log/nginx/access.log --http-client-body-temp-path=/tmp/client_body --http-proxy-temp-path=/tmp/proxy --http-fastcgi-temp-path=/tmp/fastcgi --http-uwsgi-temp-path=/tmp/uwsgi --http-scgi-temp-path=/tmp/scgi --with-jemalloc --add-module=/root/src/echo-nginx-module-master

    make && make install
    ln -s -T -f /usr/local/lib/libgd.so.3 /lib64/libgd.so.3
}

install_mysql56() {
    if [ ! -d /server/mysql-5.6.40  ];then
        mkdir -p /server/mysql-5.6.40
    else
        return 0
    fi
    if [ ! -d /data/mysql ];then
        mkdir -p /data/mysql
    fi
    cd ${SRC}
    groupadd mysql
    useradd -r -g mysql mysql -s/bin/false
    chown -R mysql.mysql /data/mysql
    if [ ! -f ${SRC}mysql-5.6.40.tar.gz ];then
        wget ${DOWNLOADER}mysql-5.6.40.tar.gz
    fi
    sleep 1
    if [ ! -f ${SRC}googletest-release-1.8.0.zip ];then
        wget ${DOWNLOADER}googletest-release-1.8.0.zip
    fi
    sleep 1
    tar -zxvf mysql-5.6.40.tar.gz
    unzip -x googletest-release-1.8.0.zip -d mysql-5.6.40/source_downloads/googletest-release-1.8.0
	cd mysql-5.6.40
    cmake -DCMAKE_INSTALL_PREFIX=/server/mysql-5.6.40 \
    -DMYSQL_UNIX_ADDR=/tmp/mysqld.sock \
    -DDEFAULT_CHARSET=utf8 \ 
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DWITH_EXTRA_CHARSET:STRING=utf8,gbk 
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_MEMORY_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DENABLED_LOCAL_INFILE=1 \
    -DMYSQL_DATADIR=/data/databases \
    -DENABLE_DOWNLOADS=1 \
    -DWITH_EMBEDDED_SERVER=0 \
    -DWITH_PARTITION_STORAGE_ENGINE=0 \
    -DWITH_FAST_MUTEXES=1
    make && make install

}

install_mysql80() {
    if [ ! -d /server/mysql-8.0.13  ];then
        mkdir -p /server/mysql-8.0.13
    else
        return 0
    fi
    if [ ! -d /data/mysql ];then
        mkdir -p /data/mysql
    fi
    cd ${SRC}
    groupadd mysql
    useradd -r -g mysql mysql -s/bin/false
    chown -R mysql.mysql /data/mysql
    if [ ! -f ${SRC}mysql-8.0.13.tar.gz ];then
        wget ${DOWNLOADER}mysql-8.0.13.tar.gz
    fi
    sleep 1
    if [ ! -f ${SRC}googletest-release-1.8.0.zip ];then
        wget ${DOWNLOADER}googletest-release-1.8.0.zip
    fi
    sleep 1
    tar -zxvf mysql-8.0.13.tar.gz
    unzip -x googletest-release-1.8.0.zip -d mysql-8.0.13/source_downloads/googletest-release-1.8.0
	cd mysql-8.0.13
    cmake -DCMAKE_INSTALL_PREFIX=/server/mysql-8.0.13 \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DENABLED_LOCAL_INFILE=1 \
    -DWITH_SSL=system \
    -DWITH_EXTRA_CHARSET:STRING=utf8,gbk \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
    -DDOWNLOAD_BOOST=1 \
    -DWITH_BOOST=/tmp \
    -DWITH_READLINE=1 \
    -DMYSQL_DATADIR=/data/databases \
    -DMYSQL_UNIX_ADDR=/tmp/mysqld.sock \
    -DSYSCONFDIR=/server/mysql-8.0.13/3306 

    make -j 12 && make install

}

install_php7() {
    if [ ! -d /server/php-7.2.4 ];then
        mkdir -p /server/php-7.2.4
    else
        return 0
    fi
    cd ${SRC}
    if [ ! -f ${SRC}php-7.2.4.tar.gz ];then
        wget ${DOWNLOADER}php-7.2.4.tar.gz
    fi
    sleep 1
    if [ ! -f ${SRC}yaf-3.0.7.tgz ];then
        wget ${DOWNLOADER}yaf-3.0.7.tgz
    fi
    if [ ! -f ${SRC}redis-4.0.2.tgz ];then
        wget ${DOWNLOADER}redis-4.0.2.tgz
    fi
    tar -zxvf php-7.2.4.tar.gz
    tar -xvf yaf-3.0.7.tgz
    tar -xvf redis-4.0.2.tgz
    cd php-7.2.4
    ./configure --prefix=/server/php-7.2.4 --enable-cli --enable-cgi --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/server/php-7.2.4/etc --with-config-file-scan-dir=/server/php-7.2.4/etc/conf.d --with-zlib --with-zlib-dir=/usr/local/lib --enable-bcmath --enable-calendar --enable-ctype --with-curl=/usr/local/lib --enable-dba=shared --enable-dom --with-libxml-dir=/usr/local/lib --enable-exif --enable-fileinfo --enable-filter --with-pcre-dir=/usr/local/lib --enable-ftp --with-openssl --with-gd --with-jpeg-dir=/usr/local/lib --with-png-dir=/usr/local/lib --with-xpm-dir=/usr/local/lib --with-freetype-dir=/usr/local/lib --with-iconv=/usr/local/lib --with-mhash=/usr/local/lib --enable-json --enable-mbstring --with-mysql-sock=/tmp/mysqld.sock --enable-shared  --with-mysqli=mysqlnd --enable-shared --with-libedit=/usr/local/lib  --enable-opcache --enable-pcntl --enable-pdo --with-pdo-mysql  --enable-phar --enable-posix --enable-session --enable-shmop --enable-simplexml --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem  --enable-sysvshm --enable-tokenizer --enable-wddx --enable-xml --enable-xmlreader --enable-zip --enable-mysqlnd --with-pear

    make && make install
    #Install Redis && Yaf extension.
    if [ -f /server/php-7.2.4/bin/phpize ];then
        cd ${SRC}yaf-3.0.7
        /server/php-7.2.4/bin/phpize
        ./configure --with-php-config=/server/php-7.2.4/bin/php-config
        make && make install
        cd ${SRC}redis-4.0.2
        /server/php-7.2.4/bin/phpize
        ./configure --with-php-config=/server/php-7.2.4/bin/php-config
        make && make install
    fi
}

install_php5() {
    if [ ! -d /server/php-5.6.35 ];then
        mkdir -p /server/php-5.6.35
    else
        return 0
    fi
    cd ${SRC}
    wget ${DOWNLOADER}php-5.6.35.tar.gz 
    wget ${DOWNLOADER}yaf-3.0.7.tgz
    wget ${DOWNLOADER}redis-4.0.2.tgz
    sleep 1
    tar -zxvf php-5.6.35.tar.gz
    tar -xvf yaf-3.0.7.tgz
    tar -xvf redis-4.0.2.tgz
    cd php-5.6.35
    ./configure --prefix=/server/php-5.6.35 --enable-cli --enable-cgi --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/server/php-5.6.35/etc --with-config-file-scan-dir=/server/php-5.6.35/etc/conf.d --with-zlib --with-zlib-dir=/usr/local/lib --enable-bcmath --enable-calendar --enable-ctype --with-curl=/usr/local/lib --enable-dba=shared --enable-dom --with-libxml-dir=/usr/local/lib --enable-exif --enable-fileinfo --enable-filter --with-pcre-dir=/usr/local/lib --enable-ftp --with-openssl --with-gd --with-jpeg-dir=/usr/local/lib --with-png-dir=/usr/local/lib --with-xpm-dir=/usr/local/lib --with-freetype-dir=/usr/local/lib --with-iconv=/usr/local/lib --with-mhash=/usr/local/lib --enable-json --enable-mbstring --with-mysql-sock=/tmp/mysqld.sock --enable-shared  --with-mysqli=mysqlnd --enable-shared --with-libedit=/usr/local/lib  --enable-opcache --enable-pcntl --enable-pdo --with-pdo-mysql  --enable-phar --enable-posix --enable-session --enable-shmop --enable-simplexml --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem  --enable-sysvshm --enable-tokenizer --enable-wddx --enable-xml --enable-xmlreader --enable-zip --enable-mysqlnd --with-pear

    make && make install
    #Install Redis && Yaf extension.
    if [ -f /server/php-5.6.35/bin/phpize ];then
        cd ${SRC}yaf-3.0.7
        /server/php-5.6.35/bin/phpize
        ./configure --with-php-config=/server/php-5.6.35/bin/php-config
        make && make install
        cd ${SRC}redis-4.0.2
        /server/php-5.6.35/bin/phpize
        ./configure --with-php-config=/server/php-5.6.35/bin/php-config
        make && make install
    fi
}

#Keep the functions order.
install_nmp() {
    update_server
    install_libiconv
    install_libgd
    install_nginx
    #install_mysql56
    install_mysql80
    install_php7
    #install_php5
}

case "$1" in 
    'update')
        update_server
    ;;

    'nmp')
        install_nmp
    ;;

    'nginx')
        install_libiconv
        install_libgd
        install_nginx
    ;;

    'php5')
        install_libiconv
        install_libgd
        install_php5
    ;;

    'php7')
        install_libiconv
        install_libgd
        install_php7
    ;;

    'mysql56')
        install_mysql56
    ;;

    'mysql80')
        install_mysql80 
    ;;

    *)
        basename=`basename "$0"`
        echo "Usage: $basename {update|nmp|nginx|php5|php7|mysql56|mysql80} to deployment server"
        exit 1
    ;;
esac
exit 0
