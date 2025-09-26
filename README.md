# 钧鉴设计交易平台

一个专业的设计师与业主对接的交易平台，提供完整的设计服务交易解决方案。

## 功能特性

### 用户认证
- 用户注册/登录系统
- 邀请码注册机制
- JWT Token 认证
- 角色权限管理（设计师/业主/管理员）

### 用户界面
- 现代化响应式设计
- 基于 Ant Design 的 UI 组件
- 粉白色主题风格
- 移动端适配

### 设计师功能
- 个人作品集展示
- 项目接单管理
- 收入统计分析
- 客户沟通系统

### 业主功能
- 项目需求发布
- 设计师筛选
- 项目进度跟踪
- 支付管理

### 核心交易系统
- 项目匹配算法
- 在线支付集成
- 合同管理
- 评价反馈系统

## 技术栈

### 前端
- **React 18** - 现代化前端框架
- **Ant Design** - 企业级 UI 设计语言
- **TypeScript** - 类型安全的 JavaScript
- **Vite** - 快速构建工具
- **React Router** - 前端路由管理
- **Zustand** - 轻量级状态管理
- **Axios** - HTTP 客户端
- **React Query** - 数据获取和缓存

### 后端
- **Spring Boot 3.2.1** - Java 企业级框架
- **JDK 17+** - Java 开发环境
- **Spring Security** - 安全认证框架
- **Spring Data JPA** - 数据持久化
- **MySQL 8.0+** - 关系型数据库
- **Redis** - 缓存和会话存储
- **JWT** - 无状态认证
- **MyBatis Plus** - ORM 框架

### 基础设施
- **Docker** - 容器化部署
- **Nginx** - 反向代理和静态文件服务
- **Prometheus** - 监控指标收集
- **Grafana** - 数据可视化

## 项目结构

```
rj-project/
├── frontend/          # React 前端应用
│   ├── src/
│   │   ├── components/    # 可复用组件
│   │   ├── pages/        # 页面组件
│   │   ├── services/     # API 服务
│   │   └── stores/       # 状态管理
│   └── package.json
├── backend/           # Spring Boot 后端
│   ├── src/main/java/
│   │   └── com/junjian/platform/
│   │       ├── controller/   # 控制器
│   │       ├── service/      # 业务逻辑
│   │       ├── entity/       # 实体类
│   │       └── repository/   # 数据访问
│   └── pom.xml
├── database/          # 数据库脚本
├── nginx/            # Nginx 配置
├── monitoring/       # 监控配置
└── scripts/          # 部署脚本
```

## 快速开始

### 环境要求
- Node.js 18+
- Java 17+
- MySQL 8.0+
- Redis 6.0+

### 前端启动
```bash
cd frontend
npm install
npm run dev
```

### 后端启动
```bash
cd backend
./mvnw spring-boot:run
```

### 数据库初始化
```bash
# 执行数据库脚本
mysql -u root -p < database/init.sql
```

## 部署

项目支持 Docker 容器化部署，详细部署说明请参考 `scripts/deploy.sh`。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进项目。

## 许可证

MIT License