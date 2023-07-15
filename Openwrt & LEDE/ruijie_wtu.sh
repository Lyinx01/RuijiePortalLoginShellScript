#!/bin/sh

#If received logout parameter, send a logout request to eportal server
if [ "${1}" = "logout" ]; then
  userIndex=`curl -s -A "Mozilla/5.0 (Linux; Android 13; RMX3370) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36" -I http://172.30.1.111/eportal/redirectortosuccess.jsp | grep -o 'userIndex=.*'` #Fetch user index for logout request
  logoutResult=`curl -s -A "Mozilla/5.0 (Linux; Android 13; RMX3370) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36" -d "${userIndex}" http://172.30.1.111/eportal/InterFace.do?method=logout`
  echo $logoutResult
  exit 0
fi

#If received parameters is less than 3, print usage
if [ "${#}" -lt "3" ]; then
  echo "Usage: ./ruijie_wtu.sh service username password"
  echo "Service parameter can be \"chinamobile\", \"chinanet\" and \"chinaunicom\". If service parameter do not set as these value, it will use campus network as default internet service provider."
  echo "Example: ./ruijie_jmu.sh chinanet 201620000000 123456"
  echo "if you want to logout, use: ./ruijie_wtu.sh logout"
  exit 1
fi

#Exit the script when is already online, use www.google.cn/generate_204 to check the online status
captiveReturnCode=`curl -s -I -m 10 -o /dev/null -s -w %{http_code} http://www.google.cn/generate_204`
if [ "${captiveReturnCode}" = "204" ]; then
  echo "You are already online!"
  exit 0
fi

#If not online, begin Ruijie Auth

#Get Ruijie login page URL
loginPageURL=`curl -s "http://www.google.cn/generate_204" | awk -F \' '{print $2}'`

chinamobile="YD"
chinanet="DX"
chinaunicom="LT"
campus="XYW"

service=""

if [ "${1}" = "chinamobile" ]; then
  echo "Use ChinaMobile as internet service provider."
  service="${chinamobile}"
fi

if [ "${1}" = "chinanet" ]; then
  echo "Use ChinaNet as internet service provider."
  service="${chinanet}"
fi

if [ "${1}" = "chinaunicom" ]; then
  echo "Use ChinaUnicom as internet service provider."
  service="${chinaunicom}"
fi

if [ -z "${service}" ]; then
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
  authResult=`curl -s -A "Mozilla/5.0 (Linux; Android 13; RMX3370) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36" -e "${loginPageURL}" -b "EPORTAL_COOKIE_USERNAME=; EPORTAL_COOKIE_PASSWORD=; EPORTAL_COOKIE_SERVER=; EPORTAL_COOKIE_SERVER_NAME=; EPORTAL_AUTO_LAND=; EPORTAL_USER_GROUP=; EPORTAL_COOKIE_OPERATORPWD=;" -d "userId=${2}&password=${3}&service=${service}&queryString=${queryString}&operatorPwd=&operatorUserId=&validcode=&passwordEncrypt=false" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "${loginURL}"`
  echo $authResult
fi
