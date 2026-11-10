-- ============================================
-- 湖南现代物流职业技术学院 - 数据库初始化脚本
-- 数据来源: https://www.hmlc.edu.cn
-- 采集时间: 2026-06-25
-- 版本: 2.0 (新增智慧物院APP、完整专业列表、校园文化、新闻动态、智慧校园、分数线)
-- 兼容: MySQL 5.7+ / MariaDB 10.2+
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS hmlc_college DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hmlc_college;

-- ============================================
-- 1. 学校基本信息表
-- ============================================
DROP TABLE IF EXISTS school_info;
CREATE TABLE school_info (
    id INT PRIMARY KEY AUTO_INCREMENT,
    info_key VARCHAR(100) NOT NULL COMMENT '信息键',
    info_value TEXT NOT NULL COMMENT '信息值',
    category VARCHAR(50) COMMENT '分类',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学校基本信息';

INSERT INTO school_info (info_key, info_value, category, sort_order) VALUES
('学校全称', '湖南现代物流职业技术学院', '基本信息', 1),
('英文名称', 'Hunan Modern Logistics College', '基本信息', 2),
('英文缩写', 'HMLC', '基本信息', 3),
('办学性质', '公办全日制普通高等院校', '基本信息', 4),
('主管单位', '湖南省教育厅（2023年1月起）', '基本信息', 5),
('共建单位', '湖南省人民政府、中国物流与采购联合会', '基本信息', 6),
('建校时间', '1965年', '基本信息', 7),
('前身', '湖南省物资学校', '基本信息', 8),
('升格时间', '2005年3月', '基本信息', 9),
('学校地址', '湖南省长沙市远大二路泉塘', '基本信息', 10),
('邮政编码', '410131', '基本信息', 11),
('区位优势', '毗邻星沙国家级经济技术开发区，周边产业资源丰富', '基本信息', 12),
('在校学生', '约8800余人', '基本信息', 13),
('教职工数', '约400余人', '基本信息', 14),
('专业总数', '28个', '基本信息', 15),
('学校特色', '全国唯一以现代物流为主导专业的高等院校', '基本信息', 16),
('学校定位', '湖南省楚怡高水平高职学校建设单位A档', '基本信息', 17),
('官网', 'https://www.hmlc.edu.cn', '基本信息', 18),
('备案号', '湘ICP备05008287号-2', '基本信息', 19),
('教育备案号', '湘教QS3-200505-000119', '基本信息', 20),
('办学理念', '全方位对接物流产业，打造现代物流大专业群', '办学理念', 1),
('服务社会', '参与湖南省及长株潭地区物流产业规划制定，中非经贸深度合作先行区、湘粤非铁海联运通道等重大项目', '办学理念', 2);

-- ============================================
-- 2. 历史沿革表
-- ============================================
DROP TABLE IF EXISTS school_history;
CREATE TABLE school_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    year VARCHAR(20) NOT NULL COMMENT '年份/时间段',
    title VARCHAR(200) NOT NULL COMMENT '事件标题',
    description TEXT COMMENT '详细描述',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学校历史沿革';

INSERT INTO school_history (year, title, description, sort_order) VALUES
('1965年', '建校起点', '创建湖南省物资学校，专注于物资管理人才培养。', 1),
('2005年3月', '升格为高职', '湖南省物资学校与湖南省石油化工职工大学合并，正式升格为湖南现代物流职业技术学院。', 2),
('2013年-2022年', '归口商务厅', '归口湖南省商务厅管理，在此期间获得多项国家级荣誉和项目。', 3),
('2023年1月', '隶属调整', '改由湖南省教育厅直属管理。', 4),
('2025年', '60周年校庆', '学校迎来60周年校庆，出版校庆宣传片《筋络 脊梁》。', 5);

-- ============================================
-- 3. 学校领导表
-- ============================================
DROP TABLE IF EXISTS school_leadership;
CREATE TABLE school_leadership (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    title VARCHAR(100) NOT NULL COMMENT '职务',
    responsibilities TEXT COMMENT '职责分工',
    contact_dept VARCHAR(100) COMMENT '联系单位/学院',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学校领导';

INSERT INTO school_leadership (name, title, responsibilities, contact_dept, sort_order) VALUES
('龙吟', '党委书记', '主持学校党委全面工作', '马克思主义学院', 1),
('朱元双', '校长', '主持学校行政全面工作，分管审计处', '物流管理学院', 2),
('邓剑波', '党委副书记', '分管党政办、组织人事部、宣传统战部、离退休办公室、工会、基建处、后勤与资产管理处', NULL, 3),
('罗勇', '党委委员、副校长', '分管教务处（教师发展中心）、科研处、质量诊改与督导办、计财处、图文信息中心、实训中心、继续教育学院', '物流工程学院', 4),
('刘贵书', '党委委员、纪委书记', '分管纪检监察处', '物流商学院', 5),
('肖勇', '党委委员、副校长', '分管学生工作部（武装部）、校企合作与招生就业处（创新创业学院）、保卫部、团委', '物流信息学院', 6),
('邢伟', '党委委员、副校长', '岳阳现代服务职业学院党委书记（督导专员）', NULL, 7),
('柳琼', '党委委员、宣传统战部部长', '协管宣传、统战工作', '通识学院', 8),
('梁飞', '党委委员、组织人事部部长', '协管组织、人事工作', '国际物流学院', 9);

-- ============================================
-- 4. 二级学院表
-- ============================================
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL COMMENT '学院名称',
    dept_type ENUM('专业学院','公共学院','教辅机构','党政机构') NOT NULL DEFAULT '专业学院' COMMENT '机构类型',
    description TEXT COMMENT '学院简介',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二级学院/部门';

INSERT INTO departments (dept_name, dept_type, description, sort_order) VALUES
('物流管理学院', '专业学院', '核心学院，聚焦物流管理全流程，涵盖现代物流管理、供应链运营、采购与供应管理、工程物流管理、航空物流管理、冷链物流技术与管理等方向', 1),
('物流信息学院', '专业学院', '信息技术与现代物流融合，涵盖智能物流技术、物联网应用技术、物流信息技术、人工智能技术应用、大数据技术、电子商务等', 2),
('物流商学院', '专业学院', '物流金融与商业管理，涵盖物流金融管理、市场营销、会计信息管理等', 3),
('物流工程学院', '专业学院', '物流工程技术与装备，涵盖物流工程技术、工业机器人技术、汽车检测与维修技术等', 4),
('国际物流学院', '专业学院', '国际物流与跨境贸易，涵盖国际物流、跨境电商、商务英语、关务与外贸服务、港口与航运管理等', 5),
('通识学院', '公共学院', '负责全校通识教育课程，开展美育浸润等特色活动', 6),
('马克思主义学院', '公共学院', '负责全校思想政治理论课教学', 7),
('继续教育学院', '公共学院', '负责成人教育、职业培训等继续教育工作', 8);

-- ============================================
-- 5. 专业信息表
-- ============================================
DROP TABLE IF EXISTS majors;
CREATE TABLE majors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    major_name VARCHAR(100) NOT NULL COMMENT '专业名称',
    dept_id INT COMMENT '所属学院ID',
    major_level VARCHAR(20) DEFAULT '专科' COMMENT '层次',
    is_featured TINYINT(1) DEFAULT 0 COMMENT '是否特色专业',
    description TEXT COMMENT '专业简介',
    FOREIGN KEY (dept_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='专业信息';

INSERT INTO majors (major_name, dept_id, major_level, is_featured, description) VALUES
-- 物流管理学院 (dept_id=1)
('现代物流管理', 1, '专科', 1, '国家级骨干专业，学校王牌专业'),
('供应链运营', 1, '专科', 0, '面向供应链管理岗位群'),
('采购与供应管理', 1, '专科', 0, '采购管理方向'),
('工程物流管理', 1, '专科', 0, '工程项目物流方向'),
('航空物流管理', 1, '专科', 0, '航空物流方向'),
('冷链物流技术与管理', 1, '专科', 0, '冷链物流方向'),
-- 物流信息学院 (dept_id=2)
('智能物流技术', 2, '专科', 1, '国家级教学资源库立项专业'),
('物联网应用技术', 2, '专科', 1, '国赛一等奖获奖专业'),
('物流信息技术', 2, '专科', 1, '国家级精品资源共享课支撑专业'),
('人工智能技术应用', 2, '专科', 0, 'AI技术应用方向'),
('大数据技术', 2, '专科', 0, '大数据分析与应用'),
('电子商务', 2, '专科', 0, '电商运营与管理'),
-- 物流商学院 (dept_id=3)
('物流金融管理', 3, '专科', 1, '国家级专业教学标准牵头制定'),
('市场营销', 3, '专科', 0, '物流营销方向'),
('会计信息管理', 3, '专科', 0, '物流企业财务管理'),
-- 物流工程学院 (dept_id=4)
('物流工程技术', 4, '专科', 1, '国家级专业教学标准牵头制定'),
('工业机器人技术', 4, '专科', 0, '智慧物流装备方向'),
('汽车检测与维修技术', 4, '专科', 0, '物流车辆方向'),
-- 国际物流学院 (dept_id=5)
('国际物流', 5, '专科', 1, '面向国际物流与跨境贸易'),
('跨境电商', 5, '专科', 0, '跨境电商运营方向'),
('商务英语', 5, '专科', 0, '国际商务方向'),
('关务与外贸服务', 5, '专科', 0, '报关与外贸服务方向'),
('港口与航运管理', 5, '专科', 0, '港口航运管理方向');

-- ============================================
-- 6. 荣誉成就表
-- ============================================
DROP TABLE IF EXISTS honors;
CREATE TABLE honors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    honor_name VARCHAR(300) NOT NULL COMMENT '荣誉名称',
    honor_level ENUM('国家级','省级','市级','校级') NOT NULL COMMENT '荣誉级别',
    category VARCHAR(50) COMMENT '类别',
    award_year VARCHAR(20) COMMENT '获奖年份',
    description TEXT COMMENT '详细说明',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='荣誉成就';

INSERT INTO honors (honor_name, honor_level, category, award_year, description, sort_order) VALUES
-- 国家级荣誉
('教育部人才培养工作水平评估优秀院校', '国家级', '综合办学', NULL, NULL, 1),
('全国职业教育改革创新试验校', '国家级', '综合办学', NULL, NULL, 2),
('国家物流职业教育人才培养基地', '国家级', '综合办学', NULL, NULL, 3),
('首批国家级职业教育教师教学创新团队立项建设单位', '国家级', '教师团队', NULL, NULL, 4),
('第三批国家级职业教育教师教学创新团队立项建设单位', '国家级', '教师团队', NULL, NULL, 5),
('首批国家级课程思政示范课程及教学名师和团队', '国家级', '教师团队', NULL, NULL, 6),
('全国第一届物流行业职业教育教学名师奖（米志强）', '国家级', '教师团队', NULL, NULL, 7),
('国家教学名师1人', '国家级', '教师团队', NULL, NULL, 8),
('国家级劳模、专家、裁判10余人', '国家级', '教师团队', NULL, NULL, 9),
('第一批国家级示范性职业教育集团（联盟）培育单位', '国家级', '集团化办学', NULL, NULL, 10),
('首批全国五个1+X证书制度试点专业牵头单位', '国家级', '1+X证书', NULL, NULL, 11),
('第二批国家现代学徒制试点院校专业', '国家级', '现代学徒制', NULL, NULL, 12),
('全国物流管理1+X证书制度师资培训基地', '国家级', '1+X证书', NULL, NULL, 13),
('物流信息专业国家级教学资源库立项建设单位', '国家级', '教学资源', NULL, NULL, 14),
('国家级精品在线开放课程4门（含RFID技术与应用等）', '国家级', '课程建设', NULL, NULL, 15),
('第一批国家精品资源共享课：物流信息技术与应用', '国家级', '课程建设', NULL, NULL, 16),
('国家级"十三五"规划教材4本', '国家级', '教材建设', NULL, NULL, 17),
('国家级"十四五"规划教材6本', '国家级', '教材建设', NULL, NULL, 18),
('首届全国教材建设奖二等奖2项', '国家级', '教材建设', NULL, NULL, 19),
('物流金融管理、物流信息技术、物流工程技术3个国家级专业教学标准牵头制定', '国家级', '标准制定', NULL, NULL, 20),
('《供应链管理师（2020年版）》国家职业技能标准主要参与制定', '国家级', '标准制定', NULL, NULL, 21),
('国家社科基金高校思想政治专项课题1项', '国家级', '课题研究', NULL, NULL, 22),
('国家级课题6项', '国家级', '课题研究', NULL, NULL, 23),
('教育部网络学习空间应用普及活动优秀学校', '国家级', '信息化', NULL, NULL, 24),
('物联网技术应用赛项国赛一等奖1项、二等奖5项、三等奖1项', '国家级', '技能竞赛', NULL, NULL, 25),
('智慧物流作业方案设计与实施赛项国赛一等奖1项、二等奖3项、三等奖1项', '国家级', '技能竞赛', NULL, NULL, 26),
('2014年"挑战杯"全国职业学校创新创效创业大赛特等奖', '国家级', '技能竞赛', '2014', NULL, 27),
('2021年中国国际"互联网+"大学生创新创业大赛铜奖1项', '国家级', '技能竞赛', '2021', NULL, 28),
('首届全国高校思想政治理论课教学展示活动一等奖1项', '国家级', '教学比赛', NULL, NULL, 29),
('第三批"全国党建工作样板支部"培育创建单位', '国家级', '党建工作', NULL, NULL, 30),
('入选国家级提质培优典型案例3个', '国家级', '典型案例', '2021', NULL, 31),
('学校办学成果案例被《2019年中国高等职业教育质量年度报告》收录', '国家级', '典型案例', '2019', NULL, 32),
('首届上海合作组织国家职业技能大赛银奖2项', '国家级', '国际荣誉', NULL, NULL, 33),
-- 省级荣誉
('湖南省示范性高等职业学院', '省级', '综合办学', NULL, NULL, 101),
('湖南省楚怡双高校A类建设单位', '省级', '综合办学', NULL, NULL, 102),
('湖南省文明校园', '省级', '综合办学', NULL, NULL, 103),
('湖南省平安高校', '省级', '综合办学', NULL, NULL, 104),
('湖南省语言文字示范校', '省级', '综合办学', NULL, NULL, 105),
('湖南省"三全育人"试点单位', '省级', '综合办学', NULL, NULL, 106),
('湖南省实习管理八强校', '省级', '综合办学', NULL, NULL, 107),
('湖南省3个一流特色专业群建设单位', '省级', '专业建设', NULL, NULL, 108),
('省级专业教学团队3个', '省级', '教师团队', NULL, NULL, 109),
('省级思政教学团队1个', '省级', '教师团队', NULL, NULL, 110),
('省级"楚怡"高水平教师队伍建设项目12个', '省级', '教师团队', NULL, NULL, 111),
('省级专业教学资源库1个', '省级', '教学资源', NULL, NULL, 112),
('省级教学成果奖一等奖4项、二等奖2项、三等奖1项', '省级', '教学成果', NULL, NULL, 113),
('省级精品在线开放课程9门', '省级', '课程建设', NULL, NULL, 114),
('入选省级职业教育优秀教材5本', '省级', '教材建设', NULL, NULL, 115),
('1人获得"湖湘青年英才计划"', '省级', '师资荣誉', NULL, NULL, 116),
('1人入选首批省级芙蓉教学名师', '省级', '师资荣誉', NULL, NULL, 117),
('省级"双师型"名师工作室1个', '省级', '师资荣誉', NULL, NULL, 118),
('省级教师技艺技能传承创新平台1个', '省级', '师资荣誉', NULL, NULL, 119),
('湖南省高校大学生创新创业孵化示范基地', '省级', '创新创业', NULL, NULL, 120),
('湖南省有留学生招生资格的高职院校', '省级', '国际办学', NULL, NULL, 121),
('首批湖南1+X证书制度研究中心', '省级', '1+X证书', NULL, NULL, 122),
('湖南省高校先进党校', '省级', '党建工作', NULL, NULL, 123),
('湖南省第二批"节水型高校"', '省级', '其他', NULL, NULL, 124);

-- ============================================
-- 7. 联系方式表
-- ============================================
DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL COMMENT '部门名称',
    contact_type VARCHAR(50) COMMENT '联系方式类型',
    contact_value VARCHAR(100) NOT NULL COMMENT '联系号码/地址',
    description VARCHAR(200) COMMENT '备注',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='联系方式';

INSERT INTO contacts (dept_name, contact_type, contact_value, description, sort_order) VALUES
('学校地址', '地址', '湖南省长沙市远大二路泉塘', '邮编：410131', 1),
('党政办', '电话', '0731-84073065', NULL, 2),
('党政办', '传真', '0731-84073059', NULL, 3),
('招生办', '电话', '0731-84083169', '招生咨询', 4),
('招生办', '电话', '0731-84083978', '招生咨询', 5),
('校企合作与就业处', '电话', '0731-84876071', '就业服务', 6),
('校企合作与就业处', '电话', '0731-86281505', '校企合作', 7),
('学生工作处', '电话', '0731-84073057', '学生事务', 8),
('官方网站', '网址', 'https://www.hmlc.edu.cn', NULL, 9),
('智慧物院APP', '移动应用', 'iOS/Android', '学校官方移动应用', 10),
('微信公众号', '社交媒体', '湖南现代物流职业技术学院', '学校官方公众号', 11);

-- ============================================
-- 8. 招生方式表
-- ============================================
DROP TABLE IF EXISTS admission_types;
CREATE TABLE admission_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(100) NOT NULL COMMENT '招生类型',
    description TEXT COMMENT '说明',
    typical_time VARCHAR(50) COMMENT '通常时间',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='招生方式';

INSERT INTO admission_types (type_name, description, typical_time, sort_order) VALUES
('单独招生（单招）', '面向湖南省内考生的提前招生方式，每年春季进行', '每年3-4月', 1),
('普通高考招生', '通过全国普通高等学校招生统一考试录取', '每年6-8月', 2),
('对口升学', '面向中职毕业生的对口升学招生', '与高考同期', 3),
('"3+2"中高职衔接', '与中职学校合作的分段培养模式，前3年中职+后2年高职', '按合作协议', 4);

-- ============================================
-- 9. 应用系统表
-- ============================================
DROP TABLE IF EXISTS campus_systems;
CREATE TABLE campus_systems (
    id INT PRIMARY KEY AUTO_INCREMENT,
    system_name VARCHAR(100) NOT NULL COMMENT '系统名称',
    category VARCHAR(50) COMMENT '分类',
    description TEXT COMMENT '功能描述',
    access_url VARCHAR(300) COMMENT '访问地址',
    is_public TINYINT(1) DEFAULT 1 COMMENT '是否对外公开'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园应用系统';

INSERT INTO campus_systems (system_name, category, description, access_url, is_public) VALUES
('统一门户', '综合门户', '学校统一身份认证平台，一站式登录各业务系统', NULL, 0),
('学籍查询系统', '教务系统', '学生学籍信息查询与管理', NULL, 0),
('成绩查询系统', '教务系统', '学生成绩查询', NULL, 0),
('课程展示平台', '教务系统', '课程信息展示与选课', NULL, 0),
('考试管理中心', '教务系统', '考试安排与成绩管理', NULL, 0),
('精品课程平台', '教学资源', '国家级、省级精品课程在线学习', NULL, 1),
('电子图书馆', '学习资源', '电子图书、期刊、论文等数字资源', NULL, 1),
('网络学习空间', '学习资源', '在线学习与互动平台', NULL, 1),
('培训云平台', '学习资源', '职业技能培训与继续教育', NULL, 1),
('电子离校系统', '管理服务', '毕业生离校手续办理', NULL, 0),
('阳光服务平台', '管理服务', '师生一站式服务与投诉建议', NULL, 1),
('书记校长信箱', '管理服务', '师生意见反馈渠道', NULL, 1),
('质量诊改系统', '管理服务', '教学质量诊断与改进', NULL, 0),
('校园一卡通系统', '生活服务', '食堂消费、门禁、图书借阅、水电缴费', NULL, 0),
('数字迎新系统', '管理服务', '新生在线报到、缴费、选宿舍', NULL, 0),
('学校校历', '信息服务', '学校学期日程安排', NULL, 1),
('一周工作安排', '信息服务', '学校每周工作安排公示', NULL, 1),
('智慧物院APP', '移动应用', '学校官方移动端应用，支持iOS和Android。功能包括：通知公告查看、课表查询、成绩查询、考试安排、一卡通服务、图书馆借阅、宿舍报修、线上缴费、活动报名、请假审批、校长信箱等。登录使用学校统一身份认证账号。', NULL, 1);

-- ============================================
-- 10. 新生FAQ表
-- ============================================
DROP TABLE IF EXISTS faq;
CREATE TABLE faq (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question VARCHAR(500) NOT NULL COMMENT '问题',
    answer TEXT NOT NULL COMMENT '答案',
    category VARCHAR(50) COMMENT '分类',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='新生常见问题';

INSERT INTO faq (question, answer, category, sort_order) VALUES
('学校是公办还是民办？', '学校是公办全日制普通高等院校，由湖南省教育厅直属管理，湖南省人民政府和中国物流与采购联合会共建。', '学校性质', 1),
('学校有什么特色？', '学校是全国唯一以现代物流为主导专业的高等院校，所有专业都围绕物流产业链设置，特色鲜明。被评为湖南省楚怡高水平高职学校建设单位A档。', '学校性质', 2),
('学校在哪个城市？交通方便吗？', '学校位于湖南省长沙市远大二路泉塘，地处长沙经济技术开发区，交通便利，周边产业资源丰富。', '校园生活', 3),
('有哪些招生方式？', '主要有四种：单独招生（单招，每年春季）、普通高考招生、对口升学（面向中职生）、"3+2"中高职衔接。具体请关注学校招生网站或拨打招生办电话0731-84083169。', '招生录取', 4),
('学校有哪些二级学院？', '5个专业二级学院：物流管理学院、物流信息学院、物流商学院、物流工程学院、国际物流学院。另有通识学院、马克思主义学院、继续教育学院。', '院系专业', 5),
('学费大概多少？', '作为公办院校，学费按照湖南省物价部门核定标准收取。一般公办高职学费在3500-7800元/年不等，具体以当年招生简章为准。', '招生录取', 6),
('学校就业怎么样？', '学校与顺丰等知名企业深度合作，开设订单班，精准助力就业。学校是国家级示范性职教集团，物流行业认可度高，毕业生就业前景好。', '就业创业', 7),
('可以专升本吗？', '可以。湖南省高职院校毕业生可参加"专升本"考试，升入本科院校继续深造。', '升学深造', 8),
('学校有留学生吗？', '学校是湖南省有留学生招生资格的高职院校，开展国际交流合作项目，包括中国-东盟职教合作等。', '国际交流', 9),
('宿舍条件怎么样？', '学校提供标准学生公寓，具体配置请参考入学须知或咨询学生工作处：0731-84073057。', '校园生活', 10),
('学校有什么学生活动？', '学校有丰富的校园文化活动：校园好声音、五四主题活动、毕业季活动（含辅导员快闪献唱）、各类社团活动、技能竞赛、美育浸润行动等。', '校园文化', 11),
('怎么联系学校？', '招生办：0731-84083169 / 84083978；党政办：0731-84073065；学生工作处：0731-84073057。官网：https://www.hmlc.edu.cn', '联系方式', 12),
('学校有多少学生和老师？', '目前在校学生约8800余人，教职工约400余人，其中包括国家教学名师1人、省级芙蓉教学名师等优秀师资。', '学校概况', 13),
('学校有哪些应用系统？', '学校提供统一门户、学籍查询、成绩查询、课程展示、考试管理、电子图书馆、网络学习空间、智慧物院APP等丰富的数字化校园服务。', '应用系统', 14),
-- 智慧物院APP相关FAQ
('智慧物院APP怎么下载？', '在学校官网（www.hmlc.edu.cn）底部有智慧物院APP的下载二维码，分为苹果版（iOS）和安卓版（Android），扫码即可下载。也可以在App Store或各大安卓应用商店（华为、小米、应用宝等）搜索"智慧物院"下载。', '智慧物院APP', 15),
('智慧物院APP有什么用？', '智慧物院是学校官方移动应用，功能包括：校园通知公告查看、课表查询、成绩查询、考试安排查看、校园一卡通服务、图书馆借阅查询、宿舍报修与后勤服务、校园地图导航、线上缴费（学费、水电费等）、校园活动报名与签到、请假审批流程、师生通讯录、校园论坛/社区、校长信箱等。', '智慧物院APP', 16),
('智慧物院APP登录账号是什么？', '使用学校统一身份认证账号登录，学生用学号，教职工用工号。新生入校报到后会分配账号。智慧物院与统一门户、电子图书馆等系统账号互通。', '智慧物院APP', 17),
('智慧物院APP忘记密码怎么办？', '可通过统一身份认证平台找回密码，或联系学校图文信息中心重置密码。党政办电话：0731-84073065。', '智慧物院APP', 18),
-- 专业相关FAQ
('学校有哪些专业？一共有多少个？', '学校开设28个专业，全方位对接物流产业链。包括：现代物流管理、供应链运营、采购与供应管理、工程物流管理、航空物流管理、冷链物流技术与管理、智能物流技术、物联网应用技术、物流信息技术、人工智能技术应用、大数据技术、电子商务、物流金融管理、市场营销、会计信息管理、物流工程技术、工业机器人技术、汽车检测与维修技术、国际物流、跨境电商、商务英语、关务与外贸服务、港口与航运管理等。', '院系专业', 19),
-- 分数线FAQ
('学校分数线是多少？', '湖南省高考专科批次分数线一般在260-320分左右（历史/物理类），单招分数线由学校自主确定。单招考试分为文化素质测试和职业技能测试两部分。每年分数线会有所浮动，具体请关注学校招生平台或咨询招生办。', '招生录取', 20),
-- 校园文化FAQ
('学校有什么校园文化特色？', '学校校园文化包括"文明校园"、"师德师风"、"光影物院"三大板块。学校是湖南省文明校园、湖南省"三全育人"试点单位。校园文化活动丰富，包括《夺金2025》系列节目、美育浸润行动等特色项目。', '校园文化', 21),
-- 智慧校园FAQ
('学校数字化、信息化建设怎么样？', '学校是教育部网络学习空间应用普及活动优秀学校。智慧校园建设包括：统一身份认证平台、校园一卡通系统、电子图书馆、网络学习空间、智慧物院APP（iOS/Android）、精品课程平台、培训云平台、质量诊改系统等，数字化校园体系完善。', '智慧校园', 22),
-- 学校荣誉FAQ
('学校是教育部优秀院校吗？', '是的。学校是教育部人才培养工作水平评估优秀院校，也是全国职业教育改革创新试验校、国家物流职业教育人才培养基地。拥有国家级精品在线开放课程4门、国家级教学资源库1个、国家级教师教学创新团队等。', '学校荣誉', 23),
-- 新闻动态FAQ
('学校近期的新闻有哪些？', '最新动态（2026年6月）：学校召开教师代表专题调研座谈会，校长朱元双出席（6月25日）；通识学院赴永顺县高坪乡初级中学开展美育浸润行动（6月25日）；物流信息技术国家级教学资源库项目党支部获"国字号"荣誉（6月19日）；学校召开校园安全稳定工作形势研判专题会议（6月19日）；2026届毕业生活动——辅导员快闪献唱、校长亲送祝福（6月12日）。', '新闻动态', 24);

-- ============================================
-- 11. 校园文化/活动表
-- ============================================
DROP TABLE IF EXISTS campus_activities;
CREATE TABLE campus_activities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    activity_name VARCHAR(200) NOT NULL COMMENT '活动名称',
    category VARCHAR(50) COMMENT '类别',
    description TEXT COMMENT '活动描述',
    typical_time VARCHAR(50) COMMENT '通常举办时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园文化活动';

INSERT INTO campus_activities (activity_name, category, description, typical_time) VALUES
('校园好声音', '文艺活动', '校园歌唱比赛，展示学生才艺', '每年定期'),
('五四主题活动', '主题教育', '五四青年节主题MV及系列活动', '每年5月'),
('毕业季主题活动', '主题教育', '毕业典礼、辅导员快闪献唱、校长亲送祝福等', '每年6月'),
('美育浸润行动', '社会实践', '送美育课程进乡村学校（如赴永顺县高坪乡初级中学）', '不定期'),
('技能竞赛', '学术竞赛', '物联网、智慧物流等各级技能大赛', '全年'),
('学生社团活动', '社团活动', '各类学生社团定期开展的活动', '全年'),
('校庆活动', '重大活动', '学校周年庆典系列活动', '校庆日'),
('《夺金2025》系列节目', '校园文化', '校园文明建设主题活动', '2025年3月'),
('图书馆五楼阅览室翻新开放', '校园建设', '图书馆五楼阅览室"阅"然一新，重绽光芒', '2024年10月'),
('订单班宣讲会', '就业创业', '企业订单班招生宣讲与面试', '按需举办'),
('安全教育专题', '主题教育', '消防安全、网络安全等专题会议和演练', '定期开展');

-- ============================================
-- 12. 校企合作企业表
-- ============================================
DROP TABLE IF EXISTS partner_companies;
CREATE TABLE partner_companies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL COMMENT '企业名称',
    cooperation_type VARCHAR(100) COMMENT '合作类型',
    description TEXT COMMENT '合作描述'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校企合作企业';

INSERT INTO partner_companies (company_name, cooperation_type, description) VALUES
('顺丰速运', '订单班、实习就业', '华西客户服务中心订单班，深度产教融合'),
('精飞集团', '合作洽谈', '无人机物流方向合作'),
('智航飞购', '合作洽谈', '智慧物流方向合作'),
('长沙财经学校', '校校合作', '"3+2"中高职衔接合作办学'),
('湖南水利水电职院', '校校合作', '校际合作备忘录签约'),
('中国物流与采购联合会', '行业共建', '学校共建单位');

-- ============================================
-- 13. 智慧物院APP详情表
-- ============================================
DROP TABLE IF EXISTS smart_campus_app;
CREATE TABLE smart_campus_app (
    id INT PRIMARY KEY AUTO_INCREMENT,
    info_key VARCHAR(100) NOT NULL COMMENT '信息键',
    info_value TEXT NOT NULL COMMENT '信息值',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='智慧物院APP详情';

INSERT INTO smart_campus_app (info_key, info_value, sort_order) VALUES
('应用名称', '智慧物院', 1),
('全称', '智慧物院APP', 2),
('类型', '移动应用（学校官方APP）', 3),
('支持平台', 'iOS（苹果版）、Android（安卓版）', 4),
('下载方式', '扫描学校官网底部二维码下载，或在App Store/各大安卓应用商店搜索"智慧物院"', 5),
('登录方式', '使用学校统一身份认证账号（学号/工号）登录，与统一门户、电子图书馆等账号互通', 6),
('主要功能_通知公告', '校园通知公告查看与推送', 7),
('主要功能_课表查询', '课表查询与选课', 8),
('主要功能_成绩查询', '成绩查询与绩点查看', 9),
('主要功能_考试安排', '考试安排查看', 10),
('主要功能_一卡通', '校园一卡通服务（余额查询、消费记录）', 11),
('主要功能_图书馆', '图书馆借阅查询、续借', 12),
('主要功能_宿舍报修', '宿舍报修与后勤服务', 13),
('主要功能_校园地图', '校园地图导航', 14),
('主要功能_线上缴费', '线上缴费（学费、住宿费、水电费等）', 15),
('主要功能_活动报名', '校园活动报名与签到', 16),
('主要功能_请假审批', '请假审批流程', 17),
('主要功能_通讯录', '师生通讯录', 18),
('主要功能_校园社区', '校园论坛/社区互动', 19),
('主要功能_校长信箱', '校长信箱反馈', 20),
('适用人群', '在校学生、教职工、新生（部分功能）', 21),
('关联系统', '统一门户、电子图书馆、网络学习空间、质量诊改系统、阳光服务平台', 22);

-- ============================================
-- 14. 新闻动态表
-- ============================================
DROP TABLE IF EXISTS news;
CREATE TABLE news (
    id INT PRIMARY KEY AUTO_INCREMENT,
    news_date DATE NOT NULL COMMENT '发布日期',
    title VARCHAR(300) NOT NULL COMMENT '新闻标题',
    summary TEXT COMMENT '新闻摘要',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学校新闻动态';

INSERT INTO news (news_date, title, summary, sort_order) VALUES
('2026-06-25', '学校召开教师代表专题调研座谈会', '校长朱元双出席会议，旨在贯彻人才强校战略。', 1),
('2026-06-25', '通识学院赴永顺县高坪乡初级中学开展美育浸润行动', '学校团队将美育课送教到湘西山区。', 2),
('2026-06-19', '喜报|"国字号"+1！学校物流信息技术国家级教学资源库项目党支部获荣誉', '在教育部思政工作司遴选中获得荣誉。', 3),
('2026-06-19', '学校召开校园安全稳定工作形势研判专题会议', '校长朱元双、党委副书记等参会。', 4),
('2026-06-12', '辅导员快闪献唱 校长真诚送祝福——我校2026届毕业生活动', '2026届毕业生活动，校长朱元双亲送祝福。', 5);

-- ============================================
-- 15. 录取分数线参考表
-- ============================================
DROP TABLE IF EXISTS admission_scores;
CREATE TABLE admission_scores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    exam_year VARCHAR(10) NOT NULL COMMENT '年份',
    exam_type VARCHAR(50) NOT NULL COMMENT '考试类型（高考/单招）',
    subject_category VARCHAR(50) COMMENT '科类（历史/物理等）',
    score_range VARCHAR(50) COMMENT '分数范围',
    description TEXT COMMENT '说明'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='录取分数线参考';

INSERT INTO admission_scores (exam_year, exam_type, subject_category, score_range, description) VALUES
('2024', '湖南省高考', '历史类', '约260-320分', '湖南省专科批次分数线，每年浮动'),
('2024', '湖南省高考', '物理类', '约260-320分', '湖南省专科批次分数线，每年浮动'),
('2023', '湖南省高考', '历史类', '约250-310分', '湖南省专科批次分数线，每年浮动'),
('2023', '湖南省高考', '物理类', '约250-310分', '湖南省专科批次分数线，每年浮动'),
('2022', '湖南省高考', '历史类', '约230-300分', '湖南省专科批次分数线，每年浮动'),
('2022', '湖南省高考', '物理类', '约230-300分', '湖南省专科批次分数线，每年浮动'),
('每年', '单招', '不分科类', '学校自主划定', '单招考试分文化素质测试和职业技能测试两部分，由学校自主命题和划线。录取率一般在50%-70%左右。');

-- ============================================
-- 16. 智慧校园建设表
-- ============================================
DROP TABLE IF EXISTS smart_campus;
CREATE TABLE smart_campus (
    id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(200) NOT NULL COMMENT '建设项名称',
    category VARCHAR(50) COMMENT '分类',
    description TEXT COMMENT '详细描述',
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='智慧校园建设';

INSERT INTO smart_campus (item_name, category, description, sort_order) VALUES
('统一身份认证平台', '基础平台', '学校统一身份认证，一站式登录各业务系统，与智慧物院APP账号互通', 1),
('校园一卡通系统', '生活服务', '食堂消费、门禁通行、图书借阅、水电缴费等一体化管理', 2),
('电子图书馆', '学习资源', '电子图书、期刊、论文数据库，支持远程访问', 3),
('网络学习空间', '在线教学', '在线学习、课程互动、作业提交与批改', 4),
('精品课程平台', '教学资源', '国家级4门、省级9门精品在线开放课程', 5),
('培训云平台', '继续教育', '职业培训与继续教育在线平台', 6),
('质量诊改系统', '教学管理', '教学质量监控、诊断与改进', 7),
('阳光服务平台', '综合服务', '师生一站式服务大厅', 8),
('数字迎新系统', '管理服务', '新生在线报到、缴费、选宿舍', 9),
('智慧物院APP', '移动应用', '学校官方移动端综合服务平台（iOS/Android），功能涵盖教学、生活、管理', 10),
('学校校历系统', '信息服务', '学校学期日程安排在线查看', 11),
('书记校长信箱', '沟通渠道', '师生意见反馈线上渠道', 12),
('教育部网络学习空间应用普及活动优秀学校', '信息化荣誉', '学校在信息化教学方面获教育部认可', 13);

-- ============================================
-- 验证数据完整性
-- ============================================
SELECT 'school_info' AS table_name, COUNT(*) AS record_count FROM school_info
UNION ALL
SELECT 'school_history', COUNT(*) FROM school_history
UNION ALL
SELECT 'school_leadership', COUNT(*) FROM school_leadership
UNION ALL
SELECT 'departments', COUNT(*) FROM departments
UNION ALL
SELECT 'majors', COUNT(*) FROM majors
UNION ALL
SELECT 'honors', COUNT(*) FROM honors
UNION ALL
SELECT 'contacts', COUNT(*) FROM contacts
UNION ALL
SELECT 'admission_types', COUNT(*) FROM admission_types
UNION ALL
SELECT 'campus_systems', COUNT(*) FROM campus_systems
UNION ALL
SELECT 'faq', COUNT(*) FROM faq
UNION ALL
SELECT 'campus_activities', COUNT(*) FROM campus_activities
UNION ALL
SELECT 'partner_companies', COUNT(*) FROM partner_companies
UNION ALL
SELECT 'smart_campus_app', COUNT(*) FROM smart_campus_app
UNION ALL
SELECT 'news', COUNT(*) FROM news
UNION ALL
SELECT 'admission_scores', COUNT(*) FROM admission_scores
UNION ALL
SELECT 'smart_campus', COUNT(*) FROM smart_campus;

-- ============================================
-- 使用完毕
-- ============================================
-- 导入方法（MySQL命令行）:
--   mysql -u root -p < 湖南现代物流职业技术学院_数据库.sql
--
-- 或者使用 Navicat/DBeaver/phpMyAdmin 等工具导入此SQL文件
-- ============================================
