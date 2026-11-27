#!/bin/bash
# So API 一键安装 / 升级。在服务器上执行：
#   curl -sSL https://raw.githubusercontent.com/ymandfq/cc4kuai5-install/main/install.sh | sudo bash
#
# 下载最新安装包 → 解压到 /root/soapi（可用 SOAPI_DIR 改）→ 运行其中的 install.sh。
# 重复执行 = 升级：自动找到正在跑的那套的安装目录原地升级；只覆盖安装文件，.env（密钥）和数据目录不会被动到，
# 升级前自动备份数据库，新版起不来自动退回旧版。装指定版本：在 sudo 后加
#   SOAPI_BASE_URL=https://github.com/<安装仓>/releases/download/<版本>
set -euo pipefail

BASE_URL="${SOAPI_BASE_URL:-https://github.com/ymandfq/cc4kuai5-install/releases/latest/download}"

main() {
  local dir="${SOAPI_DIR:-}"
  if [ -z "$dir" ]; then
    dir=/root/soapi
    # 已经装过（不管当初是一条命令还是安装包装的）：找到正在跑的那套的目录，原地升级。
    # 换目录升级会被 docker compose 当成另一套服务，撞容器名起不来（11-28）。
    local running=""
    command -v docker >/dev/null 2>&1 && \
      running="$(docker inspect sub2api --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' 2>/dev/null || true)"
    if [ -n "$running" ] && [ -f "$running/docker-compose.yml" ]; then
      dir="$running"
      echo "➜ 检测到已安装在 ${dir}，在原目录升级"
    elif [ ! -e "$dir" ] && [ -f /root/sub2api/install.sh ]; then
      # 旧版默认装在 /root/sub2api：原地升级，保持数据与 .env 位置不变
      dir=/root/sub2api
    fi
  fi
  [ "$(id -u)" = "0" ] || { echo "请用 root 运行（命令末尾用 | sudo bash）"; exit 1; }
  command -v tar >/dev/null 2>&1 || { echo "需要 tar"; exit 1; }

  # 全局变量：EXIT 钩子在 main 返回后才执行，局部变量那时已失效
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "${TMP_DIR:-}"' EXIT   # 只删下载的压缩包；安装目录永久保留

  echo "➜ 下载最新安装包（约 30MB）..."
  curl -fL --retry 3 "$BASE_URL/soapi.tar.gz" -o "$TMP_DIR/bundle.tar.gz" \
    || { echo "下载失败：网络不通或还没有发布安装包"; exit 1; }

  echo "➜ 解压到 ${dir}（已有的 .env 与数据目录不会被覆盖）..."
  mkdir -p "$dir"
  tar -C "$dir" --strip-components=1 -xzf "$TMP_DIR/bundle.tar.gz"

  echo "➜ 运行 install.sh ..."
  cd "$dir"
  bash install.sh
}

# 整个脚本先读完再执行，避免 curl | bash 时子进程读 stdin 把后半段脚本吃掉
main "$@"
