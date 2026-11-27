# So API 安装

在一台全新的 Linux 服务器（推荐 Ubuntu 24.04，2 核 4G 起）上执行：

```bash
curl -sSL https://raw.githubusercontent.com/ymandfq/cc4kuai5-install/main/install.sh | sudo bash
```

脚本会自动安装 Docker、下载最新安装包、装到 `/root/soapi`，并询问管理员邮箱、域名（可留空）、是否开启自动维护。装完会打印后台地址和管理员密码。

**升级**：再执行一次同一条命令即可。它会自动找到原来的安装目录，先备份数据库再换新版本，密码和数据不会丢失；新版本起不来会自动退回旧版本。

**装指定版本**（例如退回上一版，版本号见 Releases，只保留最近 3 个）：

```bash
curl -sSL https://raw.githubusercontent.com/ymandfq/cc4kuai5-install/main/install.sh | sudo SOAPI_BASE_URL=https://github.com/ymandfq/cc4kuai5-install/releases/download/版本号 bash
```

> ⚠️ 安装目录里的 `.env` 保存数据库密码与加密密钥，丢失后备份无法解密，请另存一份。
