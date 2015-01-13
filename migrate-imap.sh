#!/bin/bash
   
  host1=mail01.francotechnologies.com
  #host1 is Source
  
  host2=san-mail01.francotechnologies.com
  #host2 is Dest
  
  cat users.txt | while read
      do
      username1=`echo $REPLY` # $REPLY is a bash builtin
      username2=`echo $REPLY | cut -d\* -f 1` # Strip the star etc
      
      echo "Syncing User $username1 to $username2"
      imapsync --nosyncacls --syncinternaldates \
              --host1 $host1 --authmech1 PLAIN --user1 "$username1" --passfile1 host1pass.txt \
              --host2 $host2 --authmech2 PLAIN --ssl2 --user2 "$username2" --passfile2 host2pass.txt
      done

