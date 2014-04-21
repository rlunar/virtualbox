#!/usr/bin/env bash -x

# Building and installing HHVM on Ubuntu 12.04
sudo apt-get update

# Packages installation
sudo apt-get install git-core cmake g++ libmysqlclient-dev libxml2-dev libmcrypt-dev libicu-dev openssl build-essential binutils-dev libcap-dev libgd2-xpm-dev zlib1g-dev libtbb-dev libonig-dev libpcre3-dev autoconf automake libtool libcurl4-openssl-dev wget memcached libreadline-dev libncurses-dev libmemcached-dev libbz2-dev libc-client2007e-dev php5-mcrypt php5-imagick libgoogle-perftools-dev libcloog-ppl0 libelf-dev libdwarf-dev subversion python-software-properties libmagickwand-dev libxslt1-dev ocaml-native-compilers libevent-dev

sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install gcc-4.7 g++-4.7

# Upgrading gcc to 4.7
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
sudo update-alternatives --set gcc /usr/bin/gcc-4.7

# Installing Boost 1.49
sudo add-apt-repository ppa:mapnik/boost
sudo apt-get update
sudo apt-get install libboost1.49-dev libboost-regex1.49-dev libboost-system1.49-dev libboost-program-options1.49-dev libboost-filesystem1.49-dev libboost-thread1.49-dev

# Getting HipHop source-code
mkdir dev
cd dev
git clone git://github.com/facebook/hhvm.git
cd hhvm
git submodule update --init --recursive
export CMAKE_PREFIX_PATH=`pwd`/..
cd ..

# libCurl
git clone git://github.com/bagder/curl.git
cd curl
./buildconf
./configure --prefix=$CMAKE_PREFIX_PATH
make
make install
cd ..

# cat ../hhvm/third-party/libcurl-7.22.1.fb-changes.diff | patch -p1

# Google glog
svn checkout http://google-glog.googlecode.com/svn/trunk/ google-glog
cd google-glog
./configure --prefix=$CMAKE_PREFIX_PATH
make
make install
cd ..

# JEMalloc 3.x
wget http://www.canonware.com/download/jemalloc/jemalloc-3.5.1.tar.bz2
tar xjvf jemalloc-3.5.1.tar.bz2
cd jemalloc-3.5.1
./configure --prefix=$CMAKE_PREFIX_PATH
make
make install
cd ..

# Building HipHop
cd hhvm
cmake .
make

