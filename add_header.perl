
#增加邮件头：
#add_header { spam | ham | all } 信头名 字符串  
#可以对各种类型的信件（垃圾邮件、正常邮件和全部邮件）增加 SpamAssassin 的定制信头。所有的定制信头都会以 X-Spam- 开始（如信头 Foo 将显示为 X-Spam-Foo ）。信头只能使用下列字符：所有的大小写英文字符、所有的数字和下划线及中划线。([A-Za-z0-9_-])。   
#命令spamassassin -t <123.txt        #测试spamassassin  
#12月  7 12:00:18.020 [13636] warn: config: created user preferences file: /root/.spamassassin/user_prefs  
#X-Spam-Checker-Version: SpamAssassin 3.3.1 (2010-03-16) on mail  
#X-Spam-Flag: YES  
#X-Spam-Level: ******  
#X-Spam-Status: Yes, score=6.9 required=5.0 tests=EMPTY_MESSAGE,MISSING_DATE,MISSING_HEADERS,MISSING_MID,MISSING_SUBJECT,NO_HEADERS_MESSAGE,NO_RECEIVED,NO_RELAYS autolearn=no version=3.3.1  
#X-Spam-FFF: hahhaa  
#Subject: [SPAM]   
#X-Spam-Prev-Subject: (nonexistent)  
#...
#建立SpamAssassin的学习系统 
#sa-learn --rebuild -D -p user_prefs   
#sa-learn --dump all可以查看自学习的数据信息  

#增加邮件头：  
if ($do_tag && $is_local) {  
        $hdr_edits->add_header('X-Spam-Flag', $do_tag2 ? 'YES' : 'NO')  
          if $allowed_hdrs && $allowed_hdrs->{lc('X-Spam-Flag')};  
        if ($allowed_hdrs && $allowed_hdrs->{lc('X-Spam-Score')}) {  
          my($score) = 0+$spam_level+$boost;  
          $score = max(64,$score)  if $blacklisted;  # don't go below 64 if bl  
          $score = min( 0,$score)  if $whitelisted;  # don't go above  0 if wl  
          $hdr_edits->add_header('X-Spam-Score', 0+sprintf("%.3f",$score));  
        }  
        $hdr_edits->add_header('X-Spam-Level', $spam_level_bar)  
          if defined $spam_level_bar &&  
             $allowed_hdrs && $allowed_hdrs->{lc('X-Spam-Level')};  
        $hdr_edits->add_header('X-Spam-Status', $full_spam_status, 1)  
          if $allowed_hdrs && $allowed_hdrs->{lc('X-Spam-Status')};  
        $hdr_edits->add_header('X-Type-What', 'meeting');  
        $hdr_edits->add_header('Type-What', 'meeting');  
      }  
        $hdr_edits->add_header('What', 'meeting');  
#可以任意增加邮件头？
#X-Spam-Flag: YES  
#X-Spam-Score: 7.847  
#X-Spam-Level: *******  
#X-Spam-Status: Yes, score=7.847 tagged_above=0 required=6.2  
#tests=[ALL_TRUSTED=-1, FROM_EXCESS_BASE64=0.105, HTML_MESSAGE=0.001,  
#HTML_MIME_NO_HTML_TAG=0.635, LOAN=7, MIME_BASE64_BLANKS=0.001,  	
#MIME_HTML_ONLY=1.105] autolearn=no  
#X-Type-What: meeting  
#Type-What: meeting  
#What: meeting  

#X-Spam-Status的具体状态：
#Yes, score=7.847 tagged_above=0 required=6.2  
#tests=[ALL_TRUSTED=-1, FROM_EXCESS_BASE64=0.105, HTML_MESSAGE=0.001,  
#HTML_MIME_NO_HTML_TAG=0.635, LOAN=7, MIME_BASE64_BLANKS=0.001,  
#MIME_HTML_ONLY=1.105] autolearn=no  
#相关代码：
my($autolearn_status) = $msginfo->supplementary_info('AUTOLEARN');  
      my($slc) = c('sa_spam_level_char');  
      $spam_level_bar = $slc x min(64, $bypassed || $whitelisted ? 0  
                                     : $blacklisted ? 64  
                                     : 0+$spam_level+$boost)  if $slc ne '';  
      my(@s) = split(/,/, $msginfo->spam_status);  
      unshift(@s, 'AM:BOOST=' . (0+sprintf("%.3f",$boost)))  if $boost;  
      my($s) = join(",\n ", @s);  # allow header field wrapping at any comma  
      @s = ();  

$full_spam_status = sprintf(  
        "%s,\n score=%s\n %s%s%stests=[%s]\n autolearn=%s",  
        $do_tag2 ? 'Yes' : 'No',  
        !defined($spam_level) && !defined($boost) ? 'x' :  
                                         0+sprintf("%.3f",$spam_level+$boost),  
        !defined $tag_level || $tag_level eq '' ? ''  
                                   : sprintf("tagged_above=%s\n ",$tag_level),  
        !defined $tag2_level  ? '' : sprintf("required=%s\n ",  $tag2_level),  
        join('', $blacklisted ? "BLACKLISTED\n " : (),  
                 $whitelisted ? "WHITELISTED\n " : ()),  
        $s, $autolearn_status||'unavailable');  
    }  
