#!/bin/sh

dd=`date +%s`
tmpdir=/tmp/nicedocker-$dd
mkdir $tmpdir
git clone --branch testing https://github.com/nicescale/nicedocker.git $tmpdir/
cd $tmpdir
sed -i "s/^REPOHOST=nicedocker.com/REPOHOST=127.0.0.1/" nicedocker
#sed -i "/cfagent/d" nicedocker
/bin/cp nicedocker /usr/local/bin/nicedocker
ln -s nicedocker /usr/local/bin/dockernice

cd /tmp
rm -fr $tmpdir
