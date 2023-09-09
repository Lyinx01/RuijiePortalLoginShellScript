# 简介

本脚本实现了锐捷 ePortal Web 认证的登录，需要 curl 指令的支持，通过 curl 发送认证所需的 POST 数据包来实现 Web 认证。

如果你所在的学校也是使用锐捷进行校园网认证，并且开启了 Web 的认证方式（如下图），那么应该是可以使用本脚本进行认证的。

项目中的脚本文件以 **_jmu** 结尾命名的仅适用于集美大学，以**_wtu**结尾命名的适用于武汉纺织大学，SCU版本的以 _scu 结尾。

关于该脚本更加详细的使用说明请参考 [Wiki](https://github.com/LGiki/RuijiePortalLoginTool/wiki) 中的内容：

- [利用 Cron 实现每天定时进行锐捷认证](https://github.com/LGiki/RuijiePortalLoginTool/wiki/%E5%88%A9%E7%94%A8-Cron-%E5%AE%9E%E7%8E%B0%E6%AF%8F%E5%A4%A9%E5%AE%9A%E6%97%B6%E8%BF%9B%E8%A1%8C%E9%94%90%E6%8D%B7%E8%AE%A4%E8%AF%81)

- [修改代码以适配异常情况](https://github.com/LGiki/RuijiePortalLoginTool/wiki/%E4%BF%AE%E6%94%B9%E4%BB%A3%E7%A0%81%E4%BB%A5%E9%80%82%E9%85%8D%E5%BC%82%E5%B8%B8%E6%83%85%E5%86%B5)

**脚本依赖于 curl，所以使用之前请确保系统中已经安装了 curl。**

# 脚本工作原理

这个 Shell script 主要工作原理如下：

1. 向 [Captive Portal Server](https://en.wikipedia.org/wiki/Captive_portal) 发送 GET 请求，检查返回的 HTTP 状态码是否为 204：
   1. 如果为 204 则说明当前已经能正常联网，退出脚本，停止后续认证流程；
   2. 如果不是 204 则说明当前未进行锐捷认证（一般来说，在未认证的情况下请求任意页面，认证服务器都会返回一个 HTTP 302 或者 301 状态码，用于将你重定向到 ePortal 认证页面），则将 HTTP 重定向所转向的页面的 URL 作为认证页面 URL。
2. 构造进行锐捷 ePortal 认证所需的 HTTP 请求，并通过 curl 发送该请求。
3. 认证成功。

# 基本用法

```shell
./ruijie_general.sh username password
```

- username 参数为认证用户名。
- password 参数为认证密码。


# 局限性

如果多次认证失败（例如用户名或密码错误）或者多次重复刷新认证页面，则认证过程需要输入页面上显示的验证码。此脚本并没有识别验证码的功能。

如果你所在的学校需要在认证过程中输入验证码，则不适合使用这个 shell script 进行认证，需要使用 Python 等脚本语言实现验证码识别功能再进行认证。

# 后记

锐捷的 ePortal Web 认证上了之后，向 `InterFace.do?method=getOnlineUserInfo` 这个接口中 Post 提交 `userIndex` 参数会明文显示用户的密码，感觉一点安全性都没有。（集美大学在认证系统升级之后已修复该问题）

未认证的情况下，53端口对DNS流量是可以正常通信的。如果你所在的学校也有类似的情况，也许可以尝试搭建个53端口的代理实现免认证上网。

wtu这边基本没放什么正常端口，所以弄代理不是很有效，wtu版本的脚本把username,password,service都设成了静态变量，并且添加了周期性的联网检测，便于在路由器端使用
