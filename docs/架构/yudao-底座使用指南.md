# yudao 底座使用指南(学伴小屋二开版)

> AI 摘要:yudao 框架复用能力(字典/通知/社交登录/文件/定时任务/代码生成)的接入方式 + 包结构约定 + 二开红线,写业务代码前必读 | 何时读:接入框架能力、创建业务模块时 | 更新:2026-09-09

> 版本:v0.3(2026-09-09)
> 目的:记录 yudao 框架各复用能力的**接入方式与二开注意事项**,作为业务开发(AI 辅助)的操作手册。
> 前提:后端为 yudao 单体裁剪版(JDK8 标准 + SB 2.7.18 + PG 16),仅启用 system/infra;业务模块 `yudao-module-tutor`(待建,包 `cn.iocoder.yudao.module.tutor`)。

## 1. 复用能力清单与接入方式

| 能力 | 所在 | 接入方式 | 业务用途 |
|---|---|---|---|
| 字典 | system 模块 `system_dict_data` | 调 `DictDataApi`/`DictFrameworkUtils.getDictDataLabel(...)`;业务字典 subject/grade/education/eval_tag 已迁入(id 1000001 起) | 科目/学段/学历/标签下拉与翻译 |
| 站内信 | system 模块 notify | 复用 `NotifyMessageService` 发送系统通知;模板在后台"通知中心"配置;C 端接口 `/app-api/notify/message/**` | 审核结果/失效/排除通知 |
| 社交登录(justauth) | yudao-common 依赖 | justauth starter 1.4.0 已在 classpath;`wx.miniapp` 配置已在 application-local.yaml;登录接口自建(见接口文档 01) | 微信小程序登录 |
| 订阅消息 SDK | system 模块 pom 已引入 | `wx-java-miniapp-spring-boot-starter` 已在 classpath 直接可用;access_token 用 Redis 缓存自行刷新 | subscribeMessage.send |
| 文件上传 | infra 模块 file | 复用 `/app-api/file/upload` 与 FileApi;存储方式在后台"文件配置"选择(本地/OSS) | 学生证/学信网/头像 |
| 定时任务 | infra 模块 job | 后台"定时任务"可视化配置执行器 Bean;业务 JobHandler 实现 `JobHandler` 接口 | 8:00 催办 / 1:00 超时检查 |
| 代码生成 | infra 模块 codegen | 管理后台"代码生成"→ 导入业务表 → 配置 → 生成代码 → 拷入 yudao-module-tutor | tutor 模块 CRUD 骨架 |
| 客服账号/RBAC | system 模块 user/permission | 后台创建客服账号、分配角色菜单 | 管理端权限 |
| token 体系 | system 模块 oauth2 + security starter | C 端登录签发 token 调 `OAuth2TokenService.createAccessToken`;userType=MEMBER | C 端鉴权 |
| 幂等/分布式锁 | protection starter | `@Idempotent` 注解 / `Lock4j` | 状态机接口防重复提交 |
| Excel | excel starter | `ExcelUtils` 导出 | 后台订单导出(可选) |

## 2. 包结构约定(tutor 模块)

```
yudao-module-tutor/src/main/java/cn/iocoder/yudao/module/tutor/
├── controller/
│   ├── admin/        # /admin-api/tutor/** 客服工作台接口
│   └── app/          # /app-api/tutor/** C 端接口
├── service/          # 业务逻辑 + 状态机 + 事务(业务权限校验收口于此)
├── dal/
│   ├── dataobject/   # XxxDO 对应 t_* 表
│   └── mysql/        # XxxMapper(包名沿 yudao 惯例仍叫 mysql)
├── convert/          # DO ↔ VO(MapStruct)
├── enums/            # SMALLINT 状态枚举(XxxStatusEnum)
└── framework/        # 模块私有配置(敏感词过滤器等)
```

## 3. 二开注意事项

1. **业务权限不进 RBAC**:cert_status/blacklist/publish_enabled/自我成交等校验写在 service 方法入口(见接口文档 00 §2)。
2. **状态机收口**:订单/申请/需求的状态流转只允许走对应 Service 专用方法(`OrderService.confirm/reject/collectFee/refund/markFinished/markFailed/cancel`),禁止散落 updateById。
3. **手机号三件套**:`MobileCrypto`(AES 加密/解密)、`MobileMasker`(掩码,仅 C 端 VO)、`MobileHash`(统一盐 SHA-256,仅客服查找);密钥/盐在环境变量。
4. **脱敏在 VO 层强制**:C 端 RespVO 只含 `mobileMasked`;不含详细地址/坐标字段(不是返回 null,是字段不存在)。
5. **实体 ID**:业务表用 IDENTITY;实体类 `id` 配 `@TableId(type = IdType.AUTO)`;created_at/updated_at 走 yudao autoFill。
6. **字典枚举**:SMALLINT 字段一律建 `XxxStatusEnum`(value + 中文),禁止魔法数字。
7. **分页/查询**:MyBatis-Plus 分页 `PageResult`;JSONB 数组查询用 `@>`;禁止无索引模糊查询。
8. **事务边界**:跨表一致性操作(选中生成订单、反悔回退、收费登记)必须 `@Transactional`。
9. **通知规范**:订阅消息发送失败(43101)静默;审核类长文本走站内信;用户间禁互发。
10. **测试**:订单状态机全分支、投递资格校验、收费/退费一致性必须有单元测试(yudao starter-test 基座)。
