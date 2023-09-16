#!/bin/sh
while : ;do
#Exit the script when is already online, use wifi.vivo.com.cn/generate_204 to check the online status
captiveReturnCode=`curl -s -I -m 10 -o /dev/null -s -w %{http_code} http://wifi.vivo.com.cn/generate_204`
if [ "${captiveReturnCode}" = "204" ]; then
 echo "You are already online!"
  sleep 20
else

#If not online, begin Ruijie Auth

#Get Ruijie login page URL
 loginPageURL=`curl -s "http://www.google.cn/generate_204" | awk -F \' '{print $2}'`

 username=""
 password=""

 chinamobile="YD"
 chinanet="DX"
 chinaunicom="LT"
 campus="XYW"
 service=""


 if [ ${service} = "chinamobile" ]; then
  echo "Use ChinaMobile as internet service provider."
  service="${chinamobile}"
  fi

 if [ ${service} = "chinanet" ]; then
  echo "Use ChinaNet as internet service provider."
  service="${chinanet}"
  fi


 if [ ${service} = "chinaunicom" ]; then
  echo "Use ChinaUnicom as internet service provider."
  service="${chinaunicom}"
  fi


 if [ ${service} = "campus" ]; then
  echo "Use Campus Network internet service provider."
  service="${campus}"
  fi

#Structure loginURL
 loginURL=`echo ${loginPageURL} | awk -F \? '{print $1}'`
 loginURL="${loginURL/index.jsp/InterFace.do?method=login}"

#Structure quertString
 queryString=`echo ${loginPageURL} | awk -F \? '{print $2}'`
 queryString="${queryString//&/%2526}"
 queryString="${queryString//=/%253D}"

#Send Ruijie eportal auth request and output result
 if [ -n "${loginURL}" ]; then
  authResult=`curl -s -A "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36" -e "${loginPageURL}" -b "EPORTAL_COOKIE_USERNAME=; EPORTAL_COOKIE_PASSWORD=; EPORTAL_COOKIE_SERVER=; EPORTAL_COOKIE_SERVER_NAME=; EPORTAL_AUTO_LAND=; EPORTAL_USER_GROUP=; EPORTAL_COOKIE_OPERATORPWD=;" -d "userId=${username}&password=${password}&service=${service}&queryString=${queryString}&operatorPwd=&operatorUserId=&validcode=&passwordEncrypt=false" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "${loginURL}"`
  echo $authResult
 fi

sleep 20
fi
done