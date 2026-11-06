# 云吞插件：思源笔记

把[思源笔记](https://github.com/siyuan-note/siyuan)装进云吞：本地优先的个人知识库，块级引用、双链和
Markdown 所见即所得，浏览器即开即用，手机浏览器是移动版布局。

开发流程见[插件开发指南](https://github.com/geraldpeng6/wonton-docs/blob/main/develop.md)，
规则见[插件规范](https://github.com/geraldpeng6/wonton-docs/blob/main/plugin-spec.md)。

## 用法

- 装好后从云吞打开，直接进工作区：思源是单用户应用，锁屏密码按上游官方开关
  `SIYUAN_ACCESS_AUTH_CODE_BYPASS` 关闭，只有云吞登录后的你打得开。
- 笔记、附件和索引存在这台服务器上（插件数据目录的 `workspace/`）。备份就是备份这个目录。
- 不申请出网权限：集市主题和插件下载、云同步、AI 写作这些要连外网的功能用不了；笔记数据不出家门。

## 为什么不是 OIDC 登录

思源上游支持 OIDC（`SIYUAN_OIDC_*`），但它的网页登录要求回调地址是 https
（内核 `model/oidc.go` 对非本机请求强制 https），云吞给插件的网页地址是 http，接不上；
连不上回调就进不了工作区。所以这里用 `sso: none`：网关把关，应用侧无登录。
上游的 OIDC 支持本身没有问题，接 https 部署的思源可以用。

## 镜像

- 上游官方镜像 `b3log/siyuan`（amd64/arm64 多架构，Docker Hub），按清单列表摘要固定。

## 图标

`icon.svg` 来自思源笔记官方仓库的 `app/stage/icon.svg`，原样使用；它是云南彼立练迪科技有限公司
（b3log.org）的商标。来源、许可全文和商标说明见 [NOTICE](NOTICE)。
