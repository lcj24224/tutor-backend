-- ============================================================
-- 学伴小屋 · 业务字典种子数据
-- 配套:《数据库设计文档 v0.3》
-- 说明(v0.3):字典复用 yudao system_dict_data(后台字典管理页面可直接维护),
--          不再使用自建 t_dict 表。
-- 执行前提:先执行 01-schema.sql(本脚本只依赖框架表 system_dict_data)
-- 执行方式:psql -U <user> -d <db> -f 02-dict-data.sql
-- ID 分配:1000001 起,与 yudao 雪花 ID 无冲突
-- ============================================================

-- 科目 subject
INSERT INTO system_dict_data (id, sort, label, value, dict_type, status, remark, deleted) VALUES
(1000001, 1,  '语文', 'chinese',   'subject', 0, '授课科目', 0),
(1000002, 2,  '数学', 'math',      'subject', 0, '授课科目', 0),
(1000003, 3,  '英语', 'english',   'subject', 0, '授课科目', 0),
(1000004, 4,  '物理', 'physics',   'subject', 0, '授课科目', 0),
(1000005, 5,  '化学', 'chemistry', 'subject', 0, '授课科目', 0),
(1000006, 6,  '生物', 'biology',   'subject', 0, '授课科目', 0),
(1000007, 7,  '历史', 'history',   'subject', 0, '授课科目', 0),
(1000008, 8,  '地理', 'geography', 'subject', 0, '授课科目', 0),
(1000009, 9,  '政治', 'politics',  'subject', 0, '授课科目', 0),
(1000010, 10, '奥数', 'olympiad',  'subject', 0, '授课科目', 0),
(1000011, 11, '编程', 'coding',    'subject', 0, '授课科目', 0),
(1000012, 12, '其他', 'other',     'subject', 0, '授课科目', 0);

-- 学段 grade
INSERT INTO system_dict_data (id, sort, label, value, dict_type, status, remark, deleted) VALUES
(1000013, 1, '小学低年级(1-3)', 'primary_low',  'grade', 0, '学段', 0),
(1000014, 2, '小学高年级(4-6)', 'primary_high', 'grade', 0, '学段', 0),
(1000015, 3, '初一',            'junior1',      'grade', 0, '学段', 0),
(1000016, 4, '初二',            'junior2',      'grade', 0, '学段', 0),
(1000017, 5, '初三',            'junior3',      'grade', 0, '学段', 0),
(1000018, 6, '高一',            'senior1',      'grade', 0, '学段', 0),
(1000019, 7, '高二',            'senior2',      'grade', 0, '学段', 0),
(1000020, 8, '高三',            'senior3',      'grade', 0, '学段', 0);

-- 学历 education
INSERT INTO system_dict_data (id, sort, label, value, dict_type, status, remark, deleted) VALUES
(1000021, 1, '专科', 'college',  'education', 0, '学历', 0),
(1000022, 2, '本科', 'bachelor', 'education', 0, '学历', 0),
(1000023, 3, '211',  'p211',     'education', 0, '学历', 0),
(1000024, 4, '985',  'p985',     'education', 0, '学历', 0),
(1000025, 5, '硕士', 'master',   'education', 0, '学历', 0),
(1000026, 6, '博士', 'doctor',   'education', 0, '学历', 0);

-- 评价标签 eval_tag
INSERT INTO system_dict_data (id, sort, label, value, dict_type, status, remark, deleted) VALUES
(1000027, 1, '教学能力', 'teaching',  'eval_tag', 0, '家长评老师', 0),
(1000028, 2, '沟通',     'comm',      'eval_tag', 0, '家长评老师', 0),
(1000029, 3, '守时',     'punctual',  'eval_tag', 0, '家长评老师', 0),
(1000030, 4, '负责',     'duty',      'eval_tag', 0, '家长评老师', 0),
(1000031, 5, '描述真实', 'accurate',  'eval_tag', 0, '老师评家长', 0),
(1000032, 6, '守约',     'promise',   'eval_tag', 0, '老师评家长', 0),
(1000033, 7, '配合',     'cooperate', 'eval_tag', 0, '老师评家长', 0);

-- 验证
SELECT dict_type, count(*) FROM system_dict_data
WHERE dict_type IN ('subject', 'grade', 'education', 'eval_tag')
GROUP BY dict_type ORDER BY dict_type;
