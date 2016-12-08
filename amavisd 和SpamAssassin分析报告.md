#amavisd分析：
amavisd-new 是一个介于 MTA 和邮件过滤软件之间的桥梁，其角色就像是两者之间的沟通者。 amavisd-new 在这里的作用主要是： 负责调用 SpamAssassin 对邮件内容进行过滤 。
##在/etc/amavisd/amavisd.conf中  
amavisd 只有在以下两个条件同时满足的时候才会在邮件头中插入 'X-Spam-Status', 'X-Spam-Level' 等标记：  
1接收邮件的域名被列在 '@local_domains_maps' 参数中；  
2邮件扫描的结果，分值（score）大于或等于 '$sa_tag_level_deflt' 中定义的分值时才会插入 'X-Spam-Status' 等标记；    
$sa_tag_level_deflt = -999;          #高于这个分数，就会在邮件头加上标识（设置为-999 后，则可以在所有邮件中加标识）  
$sa_tag2_level_deflt = 6.2;          #高于这个分数，允许改写邮件标题，加上\*\*\*SPAM\*\*\*标识  

##在/usr/sbin/amavisd中  
邮件头：X-Virus-Scanned: amavisd-new at extmail.org，相对应的在amavisd中的设置：  
$X_HEADER_LINE= "$myproduct_name at $mydomain"  if !defined $X_HEADER_LINE;  
$X_HEADER_TAG = 'X-Virus-Scanned'               if !defined $X_HEADER_TAG;  

#SpamAssassin分析：
SpamAssassin (SA)是利用Perl来进行文字分析以达到过滤垃圾邮件之目的。它的判断方式是藉由评分方式－若这封邮件符合某种特征，则加以评分。若总得分高于某项标准，则判定为垃圾邮件。 
为了应用于高负载之服务器上，它也提供了spamc/spamd这组以Client/Server为架构之程式，如此可以有效降低SpamAssassin对系统资源的需求。还可以替而使用Amavisd-new来呼叫SpamAssassin，也就是让Amavisd-new肩负扫毒及过滤垃圾邮件的重责。这个方法比起使用spamc/spamd的做法快很多，所以采用这种作法。  
1.关于规则：  
Spamassassin支持自定义规则，官方提供的规则配置网址：http://spamassassin.apache.org/full/3.3.x/doc/Mail_SpamAssassin_Conf.html  
在/usr/share/spamassasssin中是所有基本的规则，官方的建议是不要改动。/etc/mail/spamassassin/local.cf是站点级配置，用户的.Spamassassin/user_prefs是用户级配置。  
我们可以在/etc/mail/spamassassin/local.cf自定义规则，这部分规则会覆盖基本规则，还可以在user_prefs中为个人自定义规则，用户级规则会覆盖站点级规则。  
如在/etc/mail/spamassassin/local.cf中设置：required_score 8 #邮件被判定为垃圾邮件的分数线，不过amavisd.conf中的$sa_tag2_level_deflt = 6.2会覆盖8这个分数。这是由于spamassassin是由amavisd调用的，amavisd.conf定义的优先级高，所以amavisd自己提供了参数覆盖一小部分spamassassin的参数。还如：local.cf中的rewrite_header subject [ SPAM ]不会生效，而在amavisd.conf中有$sa_spam_subject_tag=***SPAM***会生效。  
还可以增加针对邮件内容的规则，如：  
body    LOAN       /loan/                                              
score   LOAN       1000  
describe   LOAN    This is LOAN  
对应的Status报告：  
X-Spam-Status: Yes, score=1003.285 tagged_above=-999 required=6.2  
tests=[ALL_TRUSTED=-1, DNS_FROM_AHBL_RHSBL=2.438,  
FROM_EXCESS_BASE64=0.105, HTML_MESSAGE=0.001,  
HTML_MIME_NO_HTML_TAG=0.635, LOAN=1000, MIME_BASE64_BLANKS=0.001,MIME_HTML_ONLY=1.105] autolearn=spam  
2.SpamAssassin的学习系统：  
sa-learn --rebuild -D -p user_prefs                            #建立学习系统
sa-learn --dump all                                            #可以查看自学习的数据信息
