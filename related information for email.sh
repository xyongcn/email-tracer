#!/bin/bash
access_log=/var/log/httpd/access_log*
allaccessip=($(cut -d ' ' -f1 $access_log|sort -u)) 
listallip()
{
echo "所有访问者IP:"
for ((i=0;i<${#allaccessip[@]};++i))
do
	echo "${allaccessip[i]}"
done
}
accesstimes()
{
echo "访问者IP		访问次数"
allaccesstimes=($(cut -d ' ' -f1 $access_log|sort|uniq -c))
for ((i=1;i<${#allaccesstimes[@]};++i,++i))
do
	echo "${allaccesstimes[i]}		${allaccesstimes[i-1]}" 
done
}
readmsgid()
{
touch read1.txt
for ((i=0;i<${#allaccessip[@]};++i))
do
	echo  "${allaccessip[i]} has read these msgids:"
	cat $access_log|grep "${allaccessip[i]}"|grep "msgid"|sed 's/^.*msgid=//g'|sed 's/,.*$//g'|sort -u 
done
}
maillog=/var/log/maillog
userlogin=($(cat $maillog|grep "user"|grep "status=loginok"|sed 's/^.*user=<//g'|sed 's/>.*$//g'|sort -u))
listallusers()
{
echo "所有登录成功的ExtMail账号："
for ((i=0;i<${#userlogin[@]};++i))
do
        echo "${userlogin[i]}"
done

}
timeandaddofuser()
{
echo "用户的登录时间和IP地址"
for ((i=0;i<${#userlogin[@]};++i))
do
        echo "${userlogin[i]}"
	str=$(cat $maillog|grep "${userlogin[i]}"|grep "status=loginok"|sed 's/,//g'|sed 's/client=//g'|awk '{print $1 " " $2 " " $3 " " $7 }')
	echo "$str" 	
done

}
showmail()
{
echo "	编号	       时间	     客户端 		From		To	message-id  "        
numbers=($(cat $maillog|grep "postfix"|awk '{print $6}'|sed 's/://g'|grep '[0-9]'|sort -u))
for ((i=0;i<${#numbers[@]};++i))
do
	tm=$(cat $maillog|grep "postfix"|grep "${numbers[i]}"|grep "client"|awk '{print $1 " " $2 " " $3 " "}') #时间　
	client=$(cat $maillog|grep "postfix"|grep "${numbers[i]}"|grep "client"|awk '{print $7}'|sed 's/client=//g') #客户端
	from=$(cat $maillog|grep "postfix"|grep "${numbers[i]}"|grep "$t"|grep "from="|awk '{print $7}'|sed 's/from=<//g'|sed 's/>,//g'|uniq)
	to=$(cat $maillog|grep "postfix"|grep "${numbers[i]}"|grep "$t"|grep "to="|awk '{print $7}'|sed 's/to=<//g'|sed 's/>,//g'|uniq)
	messageid=$(cat $maillog|grep "postfix"|grep "${numbers[i]}"|grep "message-id="|awk '{print $7}'|sed 's/message-id=<//g'|sed 's/>//g')
echo -e "n=${numbers[i]} t=$tm c=$client f=$from t=$to \n messageid=$messageid"
done

echo "向外发送:"
for ((i=0;i<${#numbers[@]};++i))
do
send=($(cat $maillog|grep "postfix"|grep "${numbers[i]}"|grep "MTA"|awk '{print $6}'|sed 's/://g'|sort|uniq -i))
        for ((j=0;j<${#send[@]};++j))
        do
                if [ "${numbers[i]}" == "${send[j]}" ];then
                        echo "${numbers[i]}"
                fi
        done
done
echo "发送延迟:"
cat $maillog|grep "postfix"|grep "${numbers[i]}"|grep "status=deferred"|awk '{print $6}'|sed 's/://g'|sort -u
echo "发送反弹:"
cat $maillog|grep "postfix"|grep "${numbers[i]}"|grep "status=bounced"|awk '{print $6}'|sed 's/://g'|sort -u
}
listallip
#accesstimes
#readmsgid
#listallusers
#timeandaddofuser
#showmail
