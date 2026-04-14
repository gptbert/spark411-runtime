# GitHub Actions 发布说明

在仓库的 **Settings → Secrets and variables → Actions** 中配置：

## Variables
- `DOCKERHUB_USERNAME`：Docker Hub 用户名
- `DOCKERHUB_REPOSITORY`：目标仓库名，例如 `spark411-runtime`

## Secrets
- `DOCKERHUB_TOKEN`：Docker Hub Access Token（Read/Write）

## 工作流行为
- PR：构建并运行 smoke test，不推送镜像
- push 到 `main/master`：构建、测试、推送
- 打 tag `v*`：构建、测试、推送带 tag 的镜像

## 前提
以下离线构建文件必须已提交到仓库根目录，或在后续改成从内部制品库下载：
- `patchelf`
- `jdk-21-linux-x64.tar.gz`
- `glibc-2.28.tar.gz`
- `Miniconda3-latest-Linux-x86_64.sh`
- `spark-4.1.1-bin-hadoop3.tgz`
