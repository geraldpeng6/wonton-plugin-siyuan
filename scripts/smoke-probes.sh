# shellcheck shell=bash
# scripts/smoke.sh / e2e/smoke.sh source 本文件，不单独执行。
#
# 思源笔记：sso=none。思源是单用户工作区，没有用户体系：锁屏密码用上游官方开关
# SIYUAN_ACCESS_AUTH_CODE_BYPASS 关掉，网关会话打开网页直达工作区（等价管理员），
# 没有当前用户接口可断言。清单没有 mcp。
export IDENTITY_NA=1
export SMOKE_NOTE="思源是单用户工作区，没有用户体系：锁屏密码按上游官方开关关闭，网关登录后直接打开工作区（等价管理员），无当前用户接口可断言。"
export E2E_NOTE="思源是单用户工作区：网关登录后直接打开工作区，应用内无用户身份可断言。"

web_assert() { grep -q '<title>SiYuan</title>'; }

# 数据：笔记本是思源的工作区持久数据（在插件数据目录里，升级、重装都保留）。
# data_write 建一个带随机标记的笔记本；data_check 在笔记本列表里找回它。
# 标记放在 .wonton/ 下（开发环境这里是目录；e2e 的 SMOKE_STATE 是文件，不能当目录用）。
mark_file() { printf '%s' "${E2E_DIR:-${SMOKE_DIR:-?}}/.wonton/siyuan-data-mark"; }

data_write() (
  set -eu
  local mark out file
  file="$(mark_file)"
  mkdir -p "$(dirname "$file")"
  mark="$(date +%Y%m%d%H%M%S)-$RANDOM"
  out="$(web_post /api/notebook/createNotebook "{\"name\":\"wonton-smoke-$mark\"}")" ||
    { echo "创建笔记本失败：$out"; return 1; }
  jq -e '.code == 0' <<<"$out" >/dev/null || { echo "createNotebook 返回非 0：$out"; return 1; }
  printf '%s' "$mark" >"$file"
  echo "已建笔记本 wonton-smoke-$mark"
)

data_check() (
  set -eu
  local mark out file
  file="$(mark_file)"
  mark="$(cat "$file" 2>/dev/null)" || true
  [[ -n "$mark" ]] || { echo "没有 data_write 写下的标记"; return 1; }
  out="$(web_post /api/notebook/lsNotebooks '{}')" || { echo "读笔记本列表失败：$out"; return 1; }
  jq -e --arg n "wonton-smoke-$mark" \
    '.code == 0 and any(.data.notebooks[]; .name == $n)' <<<"$out" >/dev/null ||
    { echo "找不到笔记本 wonton-smoke-$mark，看到的是：$(head -c 200 <<<"$out")"; return 1; }
  echo "笔记本 wonton-smoke-$mark 还在：升级/重装保住了数据"
)

# POST 助手：带用户会话（核心网关会话）向应用自己的接口发 JSON，返回响应体。
web_post() (
  set -eu
  local path="$1" body="$2" url="${E2E_WEB_URL:-${SMOKE_WEB_URL:-}}"
  [[ -n "$url" ]] || { echo "没有插件网页地址"; return 1; }
  curl -fsS --noproxy '*' -b "${E2E_JAR:-${SMOKE_JAR:-}}" --max-time 30 \
    -H 'Content-Type: application/json' -d "$body" "$url$path"
)
