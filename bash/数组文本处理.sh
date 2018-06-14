## 例1
```
#!/bin/bash
while read -a array
    do
        echo ${#array}

    done
```

## 例2
```
#!/bin/bash

a=(2017.09.26_17.15_activity 2017.09.26_17.35_activity 2017.09.26_17.38_activity 2017.09.26_17.51_activity 2017.09.26_18.00_activity 2017.09.26_18.08_activity 2017.09.26_19.31_activity)

result=`echo ${a[0]}|sed 's/_//'|sed 's/\.//g'|cut -f 1 -d "_"`
num=`expr ${#a[*]} - 1`

for i in $(seq 1 $num)
        do
                tmp=`echo ${a[i]}|sed 's/_//'|sed 's/\.//g'|cut -f 1 -d "_"`
                if [ $result -le $tmp ]
                then
                        result=$tmp
                        tagRes=${a[i]}
                fi
        done
echo $result
echo $tagRes

```
