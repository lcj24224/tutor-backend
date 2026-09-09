# CLAUDE.md — 学伴小屋 · 后端项目(ruoyi-vue-pro)

## 项目概述

**学伴小屋**:大学生上门家教信息撮合平台(微信小程序)。后端基于 **yudao(芋道)单体裁剪版**:只保留 system/infra 基础设施模块,业务模块自建 `yudao-module-tutor`。平台收一次性信息费(99 元),联系方式仅客服线下发放,**防跳单是商业模式生命线**。设计已定稿,业务代码未动工。

## 技术栈

- JDK 8(可用 JDK17 编译运行)/ Spring Boot 2.7.18 / MyBatis-Plus / dynamic-datasource + Druid
- PostgreSQL 16.14 + pgvector 0.8.6 / Redis(Redisson)/ Quartz
- 业务表 11 张(`t_` 前缀),框架表复用 yudao(system_/infra_)
- **版本决策(已定,勿再折腾)**:写作标准 JDK 8 + 引擎 JDK 17(本机 17.0.12,已验证);SB 2.7.18 被 yudao jdk8 分支生态锁定,**禁止自行改 spring.boot.version 升 3.x**;JDK 21 的虚拟线程/新语法在 SB 2.7 + 编译目标 1.8 下全部无法兑现,换 21 无意义。升级路径 = 将来整体切 yudao master-jdk17 分支(重新拉代码库),业务 SQL 与设计文档可复用

## AI 会话工作流(每次会话启动)

1. 读本文件(自动加载)
2. 读 `docs/当前状态.md` —— 阶段/活跃任务/待裁定事项
3. 涉及历史决策时查 `docs/决策日志.md` —— 已有结论直接采用,不重复讨论
4. 按任务类型取用对应文档(索引见下)

## 文档索引

| 文档 | 位置 | 说明 |
|---|---|---|
| 文档索引(文档宪法) | `docs/文档索引.md` | 阅读顺序 + 效力与维护规则 |
| 当前状态(会话入口) | `docs/当前状态.md` | 阶段/活跃任务/待裁定事项 |
| 决策日志 | `docs/决策日志.md` | 历史决策,同类问题先查再讨论 |
| 产品设计文档 v0.3 | `docs/产品设计文档.md` | 业务规则唯一权威来源(先读) |
| 数据库设计文档 v0.3 | `docs/数据库设计文档.md` | 表设计与状态机 |
| 数据库字段字典 v0.3 | `docs/数据库字段字典.md` | 11 张表字段/索引/状态机速查 |
| 接口设计 v0.3(按模块拆分) | `docs/接口/README.md` + 00-07 | API 合同;全局约定与安全矩阵在 00 |
| 开发规范 v0.3 | `docs/开发规范.md` | 强制开发规范(评审依据) |
| yudao 底座使用指南 | `docs/架构/yudao-底座使用指南.md` | 复用能力接入方式 + 二开注意事项 |
| 业务 SQL | `sql/tutor/01-schema.sql`、`02-dict-data.sql` | 已执行,变更先改这里 |

## 目录结构

```
ruoyi-vue-pro/
├── CLAUDE.md                 # 本文件
├── docs/                     # 后端文档(字段字典/接口/规范)
├── sql/postgresql/           # yudao 官方 PG 初始化脚本(已执行;其余数据库脚本已删)
├── yudao-server/             # 启动模块(pom 已裁剪:仅 system/infra + postgresql 驱动)
├── yudao-framework/          # 框架(starter-mybatis 含 PG 驱动 optional)
├── yudao-module-system/      # 系统模块(后台用户/权限/字典/通知/文件)
├── yudao-module-infra/       # 基础设施(定时任务/文件/日志)
└── yudao-module-tutor/       # ★ 待建:业务模块(包 cn.iocoder.yudao.module.tutor)
```

> 模块裁剪说明:member/mp/pay/bpm/crm/erp/mes/wms/hrm/fms/iot/im/ai/mall/report/pms 共 16 个模块**仅注释依赖禁用,目录保留**。模块启用/禁用的唯一开关是 `yudao-server/pom.xml` 的依赖 + 根 pom 的 modules 列表(均为注释状态)。恢复启用 = 取消注释 + 重新编译。⚠️ 未经用户明确要求,不得物理删除任何模块目录。**wx-java-miniapp-spring-boot-starter 依赖在 yudao-module-system 的 pom 里(非 mp 模块),已在 classpath 直接可用**,小程序登录/订阅消息无需自行引入。

## 启用模块地图(日常开发只用这 5 个)

| 模块 | 职责 | 业务直接复用的能力 |
|---|---|---|
| yudao-dependencies | 依赖版本管理(BOM) | — |
| yudao-framework | 15 个 starter 技术底座 | common(CommonResult/异常)、web(校验/接口文档)、security(登录用户/token 过滤)、mybatis(MP/多数据源/Druid)、redis(Redisson)、job(Quartz)、protection(幂等/分布式锁)、excel、websocket |
| yudao-module-system | 系统模块 | **user+auth+oauth2**(客服账号与 token 体系,二开核心)、**permission**(RBAC)、**dict**(业务字典已迁入)、**notify**(单向站内信)、**social**(justauth 微信小程序登录二开基础)、logger |
| yudao-module-infra | 基础设施 | **file**(图片上传)、**job**(定时任务管理页)、**codegen**(代码生成器,生成 tutor 模块 CRUD 骨架)、config、logger |
| yudao-server | 启动入口 + 配置文件 | application.yaml / application-local.yaml |

## 关键配置状态(勿动)

- **多租户已关闭**:`application.yaml` 中 `yudao.tenant.enable: false`。原因:业务表 `t_*` 无 `tenant_id` 列,开启租户会导致业务表查询注入租户条件报错。**不可改回 true**(除非给业务表加 tenant_id 列)。
- 数据源:`application-local.yaml` / `application-dev.yaml` 已切 PostgreSQL(勿改回 MySQL);`validation-query: SELECT 1`(PG 无 DUAL)。
- `script/` 目录为 yudao 官方部署模板(docker/jenkins/deploy.sh/livekit),本地开发无视;将来部署参考 `script/shell/deploy.sh` 思路。

## 本地环境

| 项 | 值 |
|---|---|
| 数据库 | PostgreSQL 16.14 @ 127.0.0.1:5432,库 `ruoyi-vue-pro`,postgres/123456 |
| PG 启动 | `E:\pgsql\pgsql\bin\pg_ctl.exe -D E:\pgsql\data start`(未注册服务,重启后手动) |
| Redis | 127.0.0.1:6379 |
| 后端 | local profile,端口 48080;`yudao-server/src/main/resources/application-local.yaml` 已配 PG |
| Maven | `C:/Users/user/.m2/wrapper/dists/apache-maven-3.9.12-bin/5nmfsn99br87k5d4ajlekdq10k/apache-maven-3.9.12/bin/mvn.cmd`(PATH 无 mvn) |
| 网络 | GitHub 走 Clash 代理 `http://127.0.0.1:7890` |

常用命令:
```bash
# 编译打包
mvn.cmd -pl yudao-server -am package -DskipTests -Dmaven.test.skip=true
# 启动
java -jar yudao-server/target/yudao-server.jar --spring.profiles.active=local
# psql(Windows 下需 export PGCLIENTENCODING=UTF8 防中文乱码)
psql.exe -U postgres -h 127.0.0.1 -d ruoyi-vue-pro
# 重建业务表(无数据阶段)
psql.exe -U postgres -h 127.0.0.1 -d ruoyi-vue-pro -f sql/tutor/01-schema.sql
```

## 核心业务规则(实现必须遵守,详见 docs)

1. **防跳单生命线**:小程序端任何接口不返回完整手机号/详细地址/坐标;完整手机号解密仅管理端接口(`/admin-api/user/{id}`、`/admin-api/order/{id}`);C 端 VO 强制掩码 `138****1234`
2. **订单状态机**:0 待确认 →(老师确认)→ 1 待收费 →(客服收费+发联系方式)→ 2 试课中 →(客服标记)→ 3 完成 / 4 试课失败(**先退费,fee_status=2,必填 fail_blame 责任方**)/ 5 已取消(老师反悔→需求回退;家长放弃→需求关闭)
3. **信息费 99 元**:收费前置;订单表不存金额
4. **三身份并存**:游客/老师(cert_status=2)/家长(publish_enabled=true)由 profile 表推断;身份级处罚不连坐,用户封禁全封
5. **撤回终态**:申请撤回后不可重投(部分唯一索引 + 业务校验)
6. **禁止自我成交**:投递校验 parent_user_id ≠ 自己
7. **可见性 = 纯开关**:实际可见 = visible AND review_status=1 AND 未黑名单;敏感字段编辑 → 重审且强制隐藏
8. **站内信单向**:系统→用户,复用 yudao notify,用户间禁互发
9. **评价挂人**:聚合按 to_user_id;家长评老师公开,老师评家长仅后台可见;≤2 星先审核
10. **复用原则**:字典(system_dict_data,id 1000001 起)/文件(infra_file)/定时任务(infra_job)/站内信(system_notify_*)一律复用 yudao,不自建

## 开发约定

- **文档落地规则(强制)**:开发讨论或写代码过程中,出现以下内容时,**先提示用户判断是否落档,经用户确认后再写入对应文档**(不擅自落档):
  | 内容类型 | 落档目标 |
  |---|---|
  | 业务规则/流程/定价的设计拍板 | `docs/产品设计文档.md`(版本号 +1) |
  | 表结构/字段/索引/状态机变更 | `sql/tutor/01-schema.sql` + `docs/数据库字段字典.md` + 本地重建验证 |
  | 接口新增/变更/权限规则 | `docs/接口设计文档.md` |
  | 编码约定/安全红线/流程规范的新增或修改 | `docs/开发规范.md` |
  | 环境与配置关键状态(PG/代理/开关/版本决策) | 本文件 CLAUDE.md |
  | 用户工作偏好与红线(如"禁用≠删除") | 长期记忆(memory) |
  | 纯实现细节、临时讨论、无决策性质的内容 | 不落档 |
- **设计变更流程:先改设计文档(版本号 +1)→ 改 `sql/tutor/01-schema.sql` → 本地重建验证 → 最后写代码**
- 分层:controller(校验/装配,无业务)→ service(业务/状态机/事务)→ dal;状态流转收口 service 专用方法,禁止散落 update
- **鉴权二开不自研**:admin-api 复用 yudao OAuth2+RBAC 零改动;app-api 自建微信登录接口(`/app-api/auth/wechat-login`),复用 yudao token 体系(TokenAuthenticationFilter、system_oauth2_access_token、Redis 会话);**业务权限(cert_status/blacklist/publish_enabled/自我成交校验)一律写在 service 层,不进 RBAC**
- 手机号工具:`MobileCrypto`(AES 加密,密钥环境变量)+ `MobileMasker`(掩码)+ `MobileHash`(统一盐 SHA-256,客服查找)
- 枚举用 SMALLINT + 枚举类,禁止魔法数字
- 提交信息中文,动词开头(feat:/fix:/docs:/refactor:);设计变更需文档与代码同提交
- 不深度耦合 yudao 内部机制(业务逻辑写在独立 service 层,保证可剥离)

## 待办

- [x] PG 切换、11 张业务表建库、字典迁移
- [x] 后端文档齐备(字段字典/接口/规范)
- [ ] 新建 yudao-module-tutor 模块骨架(阶段 0)
- [ ] 业务 API 开发(阶段 1:登录/认证/简历/需求/申请/订单/评价/举报/站内信/动态墙/定时任务)
- [ ] 管理后台业务页面(审核/订单工作台/评价/举报/反悔/统计)
- [ ] 合规:正式小程序账号、OSS、腾讯地图 key、隐私政策、订阅消息模板
- [ ] 信息费定价 99 元为模拟 v0.1,正式定价待确认
