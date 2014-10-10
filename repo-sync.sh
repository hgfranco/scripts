#!/bin/zsh

RSYNC_SOURCES=(rsync://mirrors.kernel.org/centos//5/ \
               rsync://mirrors.kernel.org/centos/5.6/ \
              )
RSYNC_TARGETS=(/opt/data/repostore/mirror/5/ \
               /opt/data/repostore/mirror/5.6/ \
              )

BN0=`basename $0`;

outfile=/tmp/$BN0.$$.out
errfile=/tmp/$BN0.$$.err

cleanup () {
   exec 4>&-
   exec 5>&-

   if [ -s $errfile ]; then
      echo "errors present:\n\n"
      cat $errfile
      if [ -s $outfile ]; then
         echo "\n\noutput was:\n\n"
         cat $outfile
      fi
   fi

   rm -f $outfile
   rm -f $errfile
}

trap "cleanup" 0 1 2 3 5 15

i=1;

while [ $i -le ${#RSYNC_SOURCES} ]; do
#while [ $i -le 1 ]; do
   exec 4>$outfile
   exec 5>$errfile

   cmd="rsync --exclude=isos/ -rpltogv ${RSYNC_SOURCES[$i]} ${RSYNC_TARGETS[$i]}"
   eval $cmd >&4 2>&5
   rval=$?

   exec 4>&-
   exec 5>&-

   if [ $rval -gt 0 ] || [ -s $errfile ]; then
      echo "problem with command:\n$cmd\n\n"
      [ -s $errfile ] && cat $errfile
      echo "\n\noutput (if any):\n"
      [ -s $outfile ] && cat $outfile
   fi

   i=$(($i+1));
done
