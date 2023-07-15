#!/bin/sh

service="chinanet"
username="your_username"
password="your_password"
interval=60

authenticate() {
  # Get Ruijie login page URL
  loginPageURL=$(curl -s "http://www.google.cn/generate_204" | awk -F \' '{print $2}')

  chinamobile="YD"
  chinanet="DX"
  chinaunicom="LT"
  campus="XYW"

  if [ "${service}" = "chinamobile" ]; then
    echo "Using ChinaMobile as internet service provider."
    service="${chinamobile}"
  fi

  if [ "${service}" = "chinanet" ]; then
    echo "Using ChinaNet as internet service provider."
    service="${chinanet}"
  fi

  if [ "${service}" = "chinaunicom" ]; then
    echo "Using ChinaUnicom as internet service provider."
    service="${chinaunicom}"
  fi

  if [ -z "${service}" ]; then
    echo "Using Campus Network as internet service provider."
    service="${campus}"
  fi

  # Structure loginURL
  loginURL="${loginPageURL/index.jsp/InterFace.do?method=login}"

  # Structure queryString
  queryString=$(echo "${loginPageURL}" | awk -F \? '{print $2}')
  queryString="${queryString//&/%2526}"
  queryString="${queryString//=/%253D}"

  # Send Ruijie eportal auth request and output result
  if [ -n "${loginURL}" ]; then
    authResult=$(curl -s -A "Mozilla/5.0 (Linux; Android 13; RMX3370) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36" -e "${loginPageURL}" -b "EPORTAL_COOKIE_USERNAME=; EPORTAL_COOKIE_PASSWORD=; EPORTAL_COOKIE_SERVER=; EPORTAL_COOKIE_SERVER_NAME=; EPORTAL_AUTO_LAND=; EPORTAL_USER_GROUP=; EPORTAL_COOKIE_OPERATORPWD=;" -d "userId=${username}&password=${password}&service=${service}&queryString=${queryString}&operatorPwd=&operatorUserId=&validcode=&passwordEncrypt=false" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "${loginURL}")
    echo "${authResult}"
  fi
}

logout() {
  userIndex=$(curl -s -A "Mozilla/5.0 (Linux; Android 13; RMX3370) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36" -I http://172.30.1.111/eportal/redirectortosuccess.jsp | grep -o 'userIndex=.*')
  logoutResult=$(curl -s -A "Mozilla/5.0 (Linux; Android 13; RMX3370) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36" -d "${userIndex}" http://172.30.1.111/eportal/InterFace.do?method=logout)
  echo "${logoutResult}"
}

while true; do
  # Check if already online
  captiveReturnCode=$(curl -s -I -m 10 -o /dev/null -s -w %{http_code} http://www.google.cn/generate_204)
  if [ "${captiveReturnCode}" = "204" ]; then
    echo "You are already online!"
  else
    echo "You are not online. Starting authentication..."
    authenticate
  fi

  sleep "${interval}"
done

