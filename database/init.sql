-- 钧鉴设计交易平台数据库初始化脚本

-- 创建数据库
CREATE DATABASE IF NOT EXISTS junjian_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE junjian_platform;

-- 用户表
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    password VARCHAR(255) NOT NULL COMMENT '加密密码',
    role ENUM('DESIGNER', 'OWNER') NOT NULL COMMENT '用户角色',
    nickname VARCHAR(50) COMMENT '昵称',
    avatar VARCHAR(255) COMMENT '头像URL',
    phone VARCHAR(20) COMMENT '手机号',
    status ENUM('ACTIVE', 'INACTIVE', 'BANNED') DEFAULT 'ACTIVE' COMMENT '用户状态',
    email_verified BOOLEAN DEFAULT FALSE COMMENT '邮箱是否验证',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_status (status)
) COMMENT '用户表';

-- 邀请码表
CREATE TABLE invite_codes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '邀请码',
    role ENUM('DESIGNER', 'OWNER') NOT NULL COMMENT '角色类型',
    used_by BIGINT COMMENT '使用者ID',
    used_at TIMESTAMP NULL COMMENT '使用时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (used_by) REFERENCES users(id),
    INDEX idx_code (code),
    INDEX idx_role (role)
) COMMENT '邀请码表';

-- 邮箱验证码表
CREATE TABLE email_verifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL COMMENT '邮箱',
    code VARCHAR(6) NOT NULL COMMENT '验证码',
    type ENUM('REGISTER', 'RESET_PASSWORD') NOT NULL COMMENT '验证类型',
    expires_at TIMESTAMP NOT NULL COMMENT '过期时间',
    used BOOLEAN DEFAULT FALSE COMMENT '是否已使用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email_code (email, code),
    INDEX idx_expires_at (expires_at)
) COMMENT '邮箱验证码表';

-- 设计师信息表
CREATE TABLE designer_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    specialties JSON COMMENT '专业领域',
    experience_years INT COMMENT '从业年限',
    education VARCHAR(100) COMMENT '教育背景',
    certifications JSON COMMENT '认证证书',
    portfolio_url VARCHAR(255) COMMENT '作品集链接',
    hourly_rate DECIMAL(10,2) COMMENT '时薪',
    rating DECIMAL(3,2) DEFAULT 0.00 COMMENT '评分',
    total_orders INT DEFAULT 0 COMMENT '总订单数',
    completed_orders INT DEFAULT 0 COMMENT '完成订单数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_rating (rating),
    INDEX idx_specialties ((CAST(specialties AS CHAR(255) ARRAY)))
) COMMENT '设计师信息表';

-- 业主信息表
CREATE TABLE owner_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    company_name VARCHAR(100) COMMENT '公司名称',
    industry VARCHAR(50) COMMENT '行业',
    company_size ENUM('STARTUP', 'SMALL', 'MEDIUM', 'LARGE') COMMENT '公司规模',
    total_projects INT DEFAULT 0 COMMENT '总项目数',
    completed_projects INT DEFAULT 0 COMMENT '完成项目数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) COMMENT '业主信息表';

-- 项目表
CREATE TABLE projects (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    owner_id BIGINT NOT NULL COMMENT '业主ID',
    title VARCHAR(200) NOT NULL COMMENT '项目标题',
    description TEXT COMMENT '项目描述',
    requirements JSON COMMENT '需求详情',
    budget_min DECIMAL(10,2) COMMENT '预算下限',
    budget_max DECIMAL(10,2) COMMENT '预算上限',
    deadline DATE COMMENT '截止日期',
    status ENUM('DRAFT', 'PUBLISHED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'DRAFT' COMMENT '项目状态',
    category VARCHAR(50) COMMENT '项目分类',
    tags JSON COMMENT '标签',
    attachments JSON COMMENT '附件',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id),
    INDEX idx_owner_id (owner_id),
    INDEX idx_status (status),
    INDEX idx_category (category),
    INDEX idx_deadline (deadline)
) COMMENT '项目表';

-- 订单表
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL COMMENT '项目ID',
    designer_id BIGINT NOT NULL COMMENT '设计师ID',
    owner_id BIGINT NOT NULL COMMENT '业主ID',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '总金额',
    status ENUM('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DISPUTED') DEFAULT 'PENDING' COMMENT '订单状态',
    contract_url VARCHAR(255) COMMENT '合同文件URL',
    milestones JSON COMMENT '里程碑',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (designer_id) REFERENCES users(id),
    FOREIGN KEY (owner_id) REFERENCES users(id),
    INDEX idx_project_id (project_id),
    INDEX idx_designer_id (designer_id),
    INDEX idx_owner_id (owner_id),
    INDEX idx_status (status)
) COMMENT '订单表';

-- 支付记录表
CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    type ENUM('DEPOSIT', 'MILESTONE', 'FINAL') NOT NULL COMMENT '支付类型',
    status ENUM('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED') DEFAULT 'PENDING' COMMENT '支付状态',
    payment_method VARCHAR(50) COMMENT '支付方式',
    transaction_id VARCHAR(100) COMMENT '交易ID',
    paid_at TIMESTAMP NULL COMMENT '支付时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_order_id (order_id),
    INDEX idx_status (status),
    INDEX idx_transaction_id (transaction_id)
) COMMENT '支付记录表';

-- 作品表
CREATE TABLE portfolios (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    designer_id BIGINT NOT NULL COMMENT '设计师ID',
    title VARCHAR(200) NOT NULL COMMENT '作品标题',
    description TEXT COMMENT '作品描述',
    images JSON COMMENT '图片URLs',
    videos JSON COMMENT '视频URLs',
    category VARCHAR(50) COMMENT '作品分类',
    tags JSON COMMENT '标签',
    likes_count INT DEFAULT 0 COMMENT '点赞数',
    views_count INT DEFAULT 0 COMMENT '浏览数',
    is_featured BOOLEAN DEFAULT FALSE COMMENT '是否精选',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (designer_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_designer_id (designer_id),
    INDEX idx_category (category),
    INDEX idx_is_featured (is_featured),
    INDEX idx_likes_count (likes_count)
) COMMENT '作品表';

-- 评价表
CREATE TABLE reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    reviewer_id BIGINT NOT NULL COMMENT '评价者ID',
    reviewee_id BIGINT NOT NULL COMMENT '被评价者ID',
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5) COMMENT '评分',
    comment TEXT COMMENT '评价内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (reviewer_id) REFERENCES users(id),
    FOREIGN KEY (reviewee_id) REFERENCES users(id),
    INDEX idx_order_id (order_id),
    INDEX idx_reviewee_id (reviewee_id),
    INDEX idx_rating (rating)
) COMMENT '评价表';

-- 消息表
CREATE TABLE messages (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sender_id BIGINT NOT NULL COMMENT '发送者ID',
    receiver_id BIGINT NOT NULL COMMENT '接收者ID',
    order_id BIGINT COMMENT '关联订单ID',
    content TEXT NOT NULL COMMENT '消息内容',
    type ENUM('TEXT', 'IMAGE', 'FILE', 'SYSTEM') DEFAULT 'TEXT' COMMENT '消息类型',
    is_read BOOLEAN DEFAULT FALSE COMMENT '是否已读',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_sender_id (sender_id),
    INDEX idx_receiver_id (receiver_id),
    INDEX idx_order_id (order_id),
    INDEX idx_is_read (is_read)
) COMMENT '消息表';

-- 插入初始邀请码
INSERT INTO invite_codes (code, role) VALUES 
('DESIGNER2024', 'DESIGNER'),
('OWNER2024', 'OWNER'),
('DESIGNER_VIP', 'DESIGNER'),
('OWNER_VIP', 'OWNER');