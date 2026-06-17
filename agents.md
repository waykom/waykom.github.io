# 健康证信息查询 - 项目说明

## 项目概述

本项目生成并托管食品从业人员健康证明（健康证）HTML 页面。每张健康证包含：

- 头像照片（`Tou_XX.png`）
- HTML 页面（`Cert_XX.html`）
- 姓名、性别、健康证编号、体检单位、体检日期等信息
- 二维码链接到对应页面

## 文件结构

```
C:\Users\Hello World\Desktop\certhtml\
├── agents.md              # 本文件 - AI 代理工作说明
├── New-Cert.ps1            # 核心脚本 - 自动生成证书
├── z开始构建.bat           # Windows 批处理 - 手动提交推送
├── Cert_70.html            # 证书 HTML 模板/成品
├── Cert_71.html            # ...
├── Tou_70.png              # 头像图片模板/成品
├── Tou_71.png              # ...
└── lib/                    # 前端依赖
    ├── index.html
    ├── logo.png            # 印章图片
    ├── qrcode.min.js       # 二维码生成库
    └── vue.js              # Vue.js 框架
```

### 文件命名规则

- 头像：`Tou_XX.png`（`XX` 为两位数字编号，如 `Tou_71.png`）
- 证书：`Cert_XX.html`（编号与头像对应，如 `Cert_71.html`）
- 编号从已有文件的最大编号 +1 递增

## New-Cert.ps1 脚本说明

### 参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `-ImagePath` | string | 是 | 头像图片路径 |
| `-Name` | string | 是 | 姓名 |
| `-Gender` | string | 是 | 性别，仅接受 `男` 或 `女` |
| `-Commit` | switch | 否 | 启用后自动执行 `git add .` 和 `git commit` |
| `-Push` | switch | 否 | 启用后自动执行 `git push`（隐含 `-Commit`） |

### 脚本行为

1. 扫描工作目录，找到 `Tou_XX.png` 和 `Cert_XX.html` 的最大编号
2. 计算下一个编号 `next = max + 1`
3. 复制头像图片到 `Tou_<next>.png`
4. 复制最新证书 HTML 到 `Cert_<next>.html`
5. 更新 HTML 中的以下字段：
   - `NumberID` → `next`
   - `Name` → 用户提供的姓名
   - `Gender` → 用户提供的性别
   - `Number` → 上一编号+1
   - `Date` → 当前日期减7天
6. 如指定 `-Commit` 或 `-Push`，自动提交并推送

## AI 代理工作流程

### 标准流程（推荐）

用户提供 **图片 + 姓名 + 性别** 后，一条命令完成全部操作：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
& "C:\Users\Hello World\Desktop\certhtml\New-Cert.ps1" `
    -ImagePath "<图片路径>" `
    -Name "<姓名>" `
    -Gender "<男/女>" `
    -Commit -Push
```

### 注意事项

1. **性别由用户明确提供**，无需通过图片判断，避免出错
2. **提交信息自动使用当前时间戳**（格式：`yyyy/MM/dd HH:mm:ss`），由脚本内 `Get-Date` 自动生成
3. **推送需要网络权限**，需使用 `require_escalated` 并申请 `["git","push"]` 权限规则
4. **git 锁文件问题**：如果遇到 `index.lock` 权限错误，先移除锁文件再重试
5. **性别修正**：如果性别错误，手动修改 `Cert_XX.html` 中的 `Gender` 字段后，单独提交推送

### 执行策略问题

PowerShell 执行策略可能限制脚本运行，需用以下方式绕过：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

## Git 规范

- **分支**：`master`（主分支）
- **提交信息**：时间戳格式 `yyyy/MM/dd HH:mm:ss`（由脚本自动生成）
- **推送**：推送到 `origin/master`
- **远程仓库**：`git@github.com:waykom/waykom.github.io.git`

## 常见问题

### git 进程残留导致 index.lock 无法创建

```powershell
# 移除锁文件
Remove-Item -Force "C:\Users\Hello World\Desktop\certhtml\.git\index.lock"
```

### 图片文件命名与编号

用户提供的图片文件名不影响最终编号，脚本会自动根据工作目录已有文件确定下一个可用编号。

---

*最后更新: 2026-06-17*
