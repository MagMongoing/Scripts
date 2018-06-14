#!/bin/bash
DIR=/home/dba/ke
#temp=`find $DIR  -type f -name  package.json |awk -F '[/]' '{print $(NF-1)}'`
c=0
find $DIR  -type f -name  package.json >/tmp/hreplace.log
sed -i "s/\/package.json//g" /tmp/hreplace.log
for a in `cat /tmp/hreplace.log`
    do  
         c=`expr $c + 1`
         temp=`find $DIR  -type f -name  package.json |awk -F '[/]' '{print $(NF-1)}'|xargs |awk '{print $'"$c"'}'`
         ls  $a|grep dist >/dev/null 
         if [ $? -eq 0 ];
         then
         echo "Operation dir: $a"
         echo "Operation target: $temp"
         NEW_DIR="new_$temp"
         target_dir="$a"
         target_dir+="/dist/$temp"
         echo $target_dir
            if [ -d "$target_dir" ]
                 then 
                 echo "$target_dir will be moved to up dir:"
                 cd $a
                 cd ..
                 cp -r $target_dir ./$NEW_DIR
                 if [ $? -eq 0 ] 
                     then echo "$target_dir is coped sucessed!, and it will delete the dir $a:"
                         rm -rf $a
                         if [ $? -eq 0 ];then echo "$a is deleted."
                             mv $NEW_DIR $temp
                             else "$a delete failed"
                         fi  
                     else echo "$target_dir is coped failed!"
                 fi  
    
            fi  

         fi  

          done
