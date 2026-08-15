# Library Management System

Hệ thống Quản lý Thư viện Trực tuyến Tích hợp AI - được xây dựng theo kiến trúc **Modular Monolith** với **Clean Architecture** và **Domain-Driven Design (DDD)**.

📄 **Tài liệu dự án:** [DRAFT.pdf](./DRAFT.pdf)

## 🔑 Tài khoản trải nghiệm (Demo Accounts)

Dành cho nhà tuyển dụng và người trải nghiệm hệ thống:

| Vai trò | Email / Tài khoản | Mật khẩu | Ghi chú |
| :--- | :--- | :--- | :--- |
| **Quản trị viên (Admin)** | `admin@hcmut.edu.vn` | `admin` | Toàn quyền quản trị hệ thống |
| **Thủ thư (Librarian)** | `hothang2004@hcmut.edu.vn` | `05102004rR@` | Quản lý mượn/trả, sách & bạn đọc |
| **Người dùng (Member)** | `thangvip030201@gmail.com` | `12345678` | Hoặc đăng nhập trực tiếp qua **Google** |


## Kiến trúc Tổng quan

### Modular Monolith Architecture

Dự án được tổ chức theo mô hình **Vertical Slicing** - chia theo nghiệp vụ (Bounded Contexts) thay vì chia theo layer ngang. Mỗi module là một đơn vị nghiệp vụ độc lập, chứa đầy đủ các layer theo Clean Architecture.

### Cấu trúc Module

```
library-management-system/
├── library-shared/                    # Common utilities & shared components
├── library-user-module/               # User Management (Identity & Access)
├── library-catalog-module/            # Catalog Management (Publications & Items)
├── library-circulation-module/        # Circulation Management (Borrowing & Reservations)
├── library-recommendation-module/     # AI/Recommendation Engine
└── library-bootstrap/                 # Main Application Entry Point
```

## Các Module Chi tiết

### 1. library-shared
**Mục đích:** Chứa các thành phần dùng chung cho tất cả các module

**Cấu trúc:**
- `exception/` - Base exception classes
- `util/` - Utility classes
- `constant/` - System constants
- `validator/` - Custom validators

### 2. library-user-module
**Bounded Context:** User Management & Authorization

**Domain Models:**
- User (Người dùng)
- Role (Vai trò)
- Permission (Quyền hạn)

**Responsibilities:**
- Quản lý người dùng (CRUD)
- Xác thực và phân quyền (Authentication & Authorization)
- Quản lý vai trò và quyền hạn (RBAC)

**Cấu trúc Clean Architecture:**
```
library-user-module/
├── domain/
│   ├── model/           # Domain entities (User, Role, Permission)
│   ├── repository/      # Repository interfaces
│   ├── service/         # Domain services
│   ├── exception/       # Domain-specific exceptions
│   └── event/           # Domain events
├── application/
│   ├── usecase/         # Use cases (business logic orchestration)
│   ├── dto/             # DTOs for use cases
│   ├── port/            # Port interfaces (input/output)
│   └── mapper/          # Domain <-> DTO mappers
├── infrastructure/
│   ├── persistence/
│   │   ├── jpa/
│   │   │   ├── entity/     # JPA entities
│   │   │   └── repository/ # JPA repository implementations
│   │   └── mapper/         # Domain <-> JPA entity mappers
│   ├── security/        # Spring Security configuration
│   └── config/          # Module-specific configuration
└── api/
    ├── controller/      # REST controllers
    ├── dto/             # Request/Response DTOs
    ├── mapper/          # API DTO <-> Application DTO mappers
    └── exception/       # API exception handlers
```

### 3. library-catalog-module
**Bounded Context:** Catalog Management

**Domain Models:**
- Publication (Ấn phẩm)
- Item (Bản sao)
- Author (Tác giả)
- Publisher (Nhà xuất bản)
- Category (Thể loại)
- Tag (Thẻ/Từ khóa)

**Responsibilities:**
- Quản lý danh mục ấn phẩm
- Quản lý các bản sao (vật lý & số)
- Quản lý tác giả, nhà xuất bản
- Phân loại và gắn thẻ

**Cấu trúc:** Tương tự library-user-module (domain, application, infrastructure, api)

### 4. library-circulation-module
**Bounded Context:** Circulation Management

**Domain Models:**
- BorrowingTransaction (Giao dịch mượn)
- Reservation (Đặt trước)
- Fine (Phạt)

**Responsibilities:**
- Quản lý giao dịch mượn/trả sách
- Quản lý đặt trước ấn phẩm
- Tính toán và quản lý phạt

**Dependencies:**
- library-user-module (cần thông tin User)
- library-catalog-module (cần thông tin Item)

**Cấu trúc:** Tương tự library-user-module

### 5. library-recommendation-module
**Bounded Context:** AI & Recommendation Engine

**Domain Models:**
- SearchHistory (Lịch sử tìm kiếm)
- UserInteraction (Tương tác người dùng)
- Rating (Xếp hạng)
- Review (Đánh giá)

**Responsibilities:**
- Thu thập dữ liệu hành vi người dùng
- Gợi ý sách cá nhân hóa (Collaborative Filtering, Content-Based)
- Tìm kiếm thông minh (Intelligent Search)
- Phân tích dữ liệu

**Infrastructure đặc biệt:**
- `infrastructure/ai/engine/` - AI/ML models
- `infrastructure/ai/model/` - Trained models
- `infrastructure/analytics/` - Data analytics

**Dependencies:**
- library-user-module
- library-catalog-module

**Cấu trúc:** Tương tự library-user-module + thêm AI infrastructure

### 6. library-bootstrap
**Mục đích:** Main Application - Spring Boot entry point

**Responsibilities:**
- Khởi động ứng dụng Spring Boot
- Component scanning cho tất cả modules
- Global configuration
- Database migration (Flyway)

**Dependencies:** Tất cả các module khác

## Nguyên tắc Clean Architecture

Mỗi module tuân theo các nguyên tắc Clean Architecture:

1. **Domain Layer (Innermost):**
   - Chứa business logic thuần túy
   - Không phụ thuộc vào framework hay infrastructure
   - Entities, Value Objects, Domain Services, Repository Interfaces

2. **Application Layer:**
   - Orchestrate business logic
   - Use Cases / Application Services
   - Port interfaces (Hexagonal Architecture)

3. **Infrastructure Layer:**
   - Implementation details
   - JPA, Security, External services
   - Adapters for repositories

4. **API Layer (Outermost):**
   - REST controllers
   - Request/Response handling
   - Exception handling

**Dependency Rule:** Dependencies chỉ đi từ ngoài vào trong. Các layer bên ngoài phụ thuộc vào layer bên trong, không ngược lại.

## Domain-Driven Design (DDD)

### Bounded Contexts
Mỗi module đại diện cho một Bounded Context độc lập:
- User Management Context
- Catalog Context
- Circulation Context
- Recommendation Context

### Ubiquitous Language
Mỗi context có ngôn ngữ riêng, phản ánh trong naming của domain models, services, và use cases.

### Aggregate Roots
- User module: User là aggregate root
- Catalog module: Publication và Item là aggregate roots
- Circulation module: BorrowingTransaction là aggregate root

## Tech Stack

- **Language:** Java 21
- **Framework:** Spring Boot 3.3.5
- **Build Tool:** Maven (Multi-module)
- **Database:** MySQL 8
- **ORM:** JPA/Hibernate
- **Migration:** Flyway
- **Mapping:** MapStruct
- **Testing:** JUnit 5, Mockito, AssertJ

## Cách Build và Chạy

### Prerequisites
- JDK 21
- Maven 3.8+
- MySQL 8.0+

### Build tất cả modules
```bash
mvn clean install
```

### Chạy ứng dụng
```bash
cd library-bootstrap
mvn spring-boot:run
```

hoặc

```bash
java -jar library-bootstrap/target/library-bootstrap-1.0.0-SNAPSHOT.jar
```

## Database Schema

Database được thiết kế theo đặc tả trong tài liệu "Báo cáo đặc tả hệ thống cơ sở dữ liệu", bao gồm:

**User Management:**
- users, roles, permissions
- user_roles, role_permissions (junction tables)

**Catalog:**
- publications, items
- authors, publishers, categories, tags
- publication_authors, publication_categories, publication_tags

**Circulation:**
- borrowing_transactions
- reservations
- fines

**Recommendation/AI:**
- search_history
- user_interactions
- ratings
- reviews

## Tính năng chính

1. **User Management & RBAC**
   - Đăng ký/đăng nhập
   - Quản lý vai trò và quyền hạn linh hoạt

2. **Catalog Management**
   - Quản lý ấn phẩm và bản sao
   - Phân loại đa cấp
   - Tagging system

3. **Circulation**
   - Mượn/trả sách
   - Đặt trước
   - Quản lý phạt

4. **AI-Powered Recommendations**
   - Gợi ý sách cá nhân hóa
   - Tìm kiếm thông minh
   - Phân tích hành vi người dùng

## License

Private project - All rights reserved
