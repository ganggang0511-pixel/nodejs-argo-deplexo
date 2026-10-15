# nodejs-argo-deplexo

`nodejs-argo` 的 Deplexo 适配版，基于 [ganggang0511-pixel/nodejs-argo](https://github.com/ganggang0511-pixel/nodejs-argo) 修改。

## 为什么要改

Deplexo 运行时根文件系统只读，`/tmp` 与 `/data` 两个可写目录都禁执行。
原版启动时下载 xray / cloudflared 二进制并就地执行，在 Deplexo 上跑不起来。
改法：构建时把二进制烘进镜像（`/app/bin`，只读可执行），
配置文件、订阅、日志等写文件改到持久卷 `/data/run`。

改动处在 `Dockerfile` 与 `index.js` 中以 `[deplexo]` 标记。
兼容性：不设 `BIN_DIR` / `WEB_NAME` / `BOT_NAME` 环境变量时，行为与原版完全一致。

## 在 Deplexo 上部署

1. 在 Deplexo 里从本仓库导入，构建方式选 Dockerfile。
2. 环境变量（在 Deplexo 的部署表单里填）：
   - `UUID`：必须换成你自己的（默认值是公开的）。
   - `ARGO_DOMAIN` / `ARGO_AUTH`：可选，填了用固定隧道，不填用临时隧道。
   - `NAME`：节点名称前缀，可选。
   - 其余变量见原项目 README。
3. 部署完成后，订阅地址：`https://你的域名/sub`。

## 注意

- 哪吒探针在 Deplexo 版下不可用（agent 需要运行时下载执行）。
- 若 Deplexo 免费套餐有闲置休眠策略，节点会随之休眠。
- 遵守原项目声明：仅限个人使用，遵守当地法律法规。

原项目：https://github.com/ganggang0511-pixel/nodejs-argo
