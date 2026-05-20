# Đặc tả ERD - SmartLibrary LMS

Tài liệu này mô tả schema phục vụ vẽ ERD cho database của `LMS_BE`, có xét các migration Flyway đến `V24__admin_librarian_policy_audit.sql` và các bảng AI runtime từ `LMS-AI/init_schema.sql`.

Quy ước:

- `PK`: khóa chính.
- `FK`: khóa ngoại.
- `UK`: khóa duy nhất.
- `NN`: `NOT NULL`.
- `Nullable`: tùy chọn.
- `Total participation`: bản ghi ở phía con bắt buộc phải tham chiếu sang phía cha, thường thể hiện bằng FK `NOT NULL`.
- `Partial participation`: bản ghi ở phía con có thể không tham chiếu, hoặc phía cha có thể không có bản ghi con.
- Không vẽ `flyway_schema_history` vào ERD nghiệp vụ vì đây là bảng kỹ thuật của Flyway.

## 1. Nhóm người dùng và phân quyền

### `users`

Thực thể trung tâm đại diện tài khoản sinh viên/thủ thư/admin.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID người dùng |
| `created_at`, `updated_at` |  | Nullable | audit |
| `email` | UK | NN | email đăng nhập |
| `hashed_password` |  | Nullable | nullable cho OAuth |
| `full_name` |  | NN | họ tên |
| `date_of_birth` |  | Nullable | ngày sinh |
| `address` |  | Nullable | địa chỉ |
| `phone_number` |  | Nullable | số điện thoại |
| `profile_picture_url` |  | Nullable | avatar |
| `student_id` |  | Nullable | mã sinh viên |
| `faculty` | CHECK | Nullable | enum khoa |
| `status` | CHECK | NN | `ACTIVE`, `INACTIVE`, `LOCKED`, `BANNED` |
| `last_login_at` |  | Nullable | lần đăng nhập gần nhất |
| `provider`, `provider_id` |  | Nullable | OAuth provider |
| `credit_score` |  | NN | điểm uy tín |
| `contribution_score` |  | NN | điểm đóng góp |

### `roles`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID role |
| `created_at`, `updated_at` |  | Nullable | audit |
| `role_name` | UK | NN | `ADMIN`, `LIBRARIAN`, `STUDENT` |
| `description` |  | Nullable | mô tả |

### `user_roles`

Bảng nối N-N giữa `users` và `roles`.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `user_id` | PK, FK -> `users.id` | NN | người dùng |
| `role_id` | PK, FK -> `roles.id` | NN | vai trò |

Quan hệ:

- `users` N-N `roles` thông qua `user_roles`.
- `user_roles` total với cả `users` và `roles`.
- `users` partial với `roles` ở mức database, nhưng nghiệp vụ thường yêu cầu mỗi user có ít nhất một role.

## 2. Nhóm danh mục thư viện

### `publishers`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID nhà xuất bản |
| `created_at`, `updated_at` |  | Nullable | audit |
| `name` | indexed | NN | tên |
| `address` |  | Nullable | địa chỉ |

### `authors`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID tác giả |
| `created_at`, `updated_at` |  | Nullable | audit |
| `name` | indexed | NN | tên |
| `bio` |  | Nullable | tiểu sử |
| `date_of_birth`, `date_of_death` |  | Nullable | ngày sinh/mất |

### `categories`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID danh mục |
| `created_at`, `updated_at` |  | Nullable | audit |
| `name` | UK | NN | tên danh mục |
| `bio` |  | Nullable | mô tả |
| `parent_category_id` | FK -> `categories.id` | Nullable | danh mục cha |

Quan hệ tự tham chiếu:

- `categories(parent)` 1-N `categories(child)`.
- Child partial vì `parent_category_id` nullable.
- Parent partial vì danh mục có thể không có danh mục con.

### `tags`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID tag |
| `created_at`, `updated_at` |  | Nullable | audit |
| `name` | UK | NN | tên tag |

### `publications`

Ấn phẩm/sách trong thư viện.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID ấn phẩm |
| `created_at`, `updated_at` |  | Nullable | audit |
| `title` | indexed | NN | tiêu đề |
| `subtitle` |  | Nullable | phụ đề |
| `isbn` | UK | Nullable | ISBN |
| `language` |  | NN | ngôn ngữ tài liệu |
| `edition` |  | Nullable | lần xuất bản |
| `publication_year` |  | Nullable | năm xuất bản |
| `number_of_pages` |  | Nullable | số trang |
| `publisher_id` | FK -> `publishers.id` | Nullable | nhà xuất bản |
| `description` | indexed | Nullable | mô tả |
| `cover_image_url` |  | Nullable | ảnh bìa |
| `size`, `weight` |  | Nullable | kích thước/khối lượng |
| `call_number` |  | Nullable | mã phân loại thư viện |
| `file_url` |  | Nullable | URL PDF |
| `table_of_contents` |  | Nullable | mục lục |
| `ai_summary` | indexed | Nullable | tóm tắt AI |
| `ai_target_audience` | CHECK | Nullable | khoa/ngành phù hợp |

Quan hệ:

- `publishers` 1-N `publications`.
- `publications.publisher_id` nullable nên publication partial với publisher.
- Publisher partial vì có thể chưa có publication nào.

### `items`

Bản sao vật lý/digital copy của một publication.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID bản sao |
| `created_at`, `updated_at` |  | Nullable | audit |
| `barcode` | UK | NN | mã vạch |
| `publication_id` | FK -> `publications.id` | NN | ấn phẩm cha |
| `status` | CHECK | NN | `AVAILABLE`, `BORROWED`, `RESERVED`, `IN_MAINTENANCE`, `LOST` |
| `condition` | CHECK | Nullable | `NEW`, `OLD` |
| `branch` |  | Nullable | chi nhánh |
| `location` |  | Nullable | vị trí kệ/kho |

Quan hệ:

- `publications` 1-N `items`.
- `items` total với `publications`.
- `publications` partial với `items` vì có thể tạo metadata trước khi nhập bản sao.

## 3. Bảng nối metadata sách

### `publication_authors`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID kỹ thuật |
| `publication_id` | FK -> `publications.id`, UK pair | NN | ấn phẩm |
| `author_id` | FK -> `authors.id`, UK pair | NN | tác giả |

Quan hệ:

- `publications` N-N `authors`.
- Bảng nối total với cả hai phía.
- Sau `V20`, unique tự nhiên: `(publication_id, author_id)`.

### `publication_categories`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID kỹ thuật |
| `publication_id` | FK -> `publications.id`, UK pair | NN | ấn phẩm |
| `category_id` | FK -> `categories.id`, UK pair | NN | danh mục |

Quan hệ:

- `publications` N-N `categories`.
- Bảng nối total với cả hai phía.
- Sau `V20`, unique tự nhiên: `(publication_id, category_id)`.

### `publication_tags`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID kỹ thuật |
| `publication_id` | FK -> `publications.id`, UK pair | NN | ấn phẩm |
| `tag_id` | FK -> `tags.id`, UK pair | NN | tag |

Quan hệ:

- `publications` N-N `tags`.
- Bảng nối total với cả hai phía.
- Unique tự nhiên: `(publication_id, tag_id)`.

## 4. Nhóm i18n/translation

Các bảng này nên vẽ trong nhóm phụ trợ `metadata localization`. Đây là overlay tùy chọn cho English mode, không thay thế dữ liệu gốc.

### `publication_translations`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID bản dịch |
| `created_at`, `updated_at` |  | NN | audit |
| `publication_id` | FK -> `publications.id`, UK pair | NN | ấn phẩm |
| `language_code` | UK pair | NN | ví dụ `en` |
| `title`, `subtitle`, `description` |  | Nullable | bản dịch metadata |
| `ai_summary`, `table_of_contents` |  | Nullable | bản dịch nội dung AI/mục lục |

Quan hệ:

- `publications` 1-N `publication_translations`.
- Translation total với publication.
- Publication partial với translation.
- Unique: `(publication_id, language_code)`.
- `ON DELETE CASCADE` khi xóa publication.

### `category_translations`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID bản dịch |
| `created_at`, `updated_at` |  | NN | audit |
| `category_id` | FK -> `categories.id`, UK pair | NN | danh mục |
| `language_code` | UK pair | NN | ví dụ `en` |
| `name`, `bio` |  | Nullable | bản dịch |

Quan hệ:

- `categories` 1-N `category_translations`.
- Translation total với category.
- Category partial với translation.
- Unique: `(category_id, language_code)`.
- `ON DELETE CASCADE`.

### `tag_translations`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID bản dịch |
| `created_at`, `updated_at` |  | NN | audit |
| `tag_id` | FK -> `tags.id`, UK pair | NN | tag |
| `language_code` | UK pair | NN | ví dụ `en` |
| `name` |  | Nullable | bản dịch |

Quan hệ:

- `tags` 1-N `tag_translations`.
- Translation total với tag.
- Tag partial với translation.
- Unique: `(tag_id, language_code)`.
- `ON DELETE CASCADE`.

## 5. Wishlist, search và recommendation

### `search_history`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID lịch sử |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id` | NN | người tìm kiếm |
| `search_query` |  | NN | nội dung tìm kiếm |

Quan hệ:

- `users` 1-N `search_history`.
- Search history total với user.
- User partial với search history.

### `wish_lists`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID wishlist |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id`, UK partial | Nullable | chủ wishlist |

Quan hệ:

- `users` 0..1 - 0..1 `wish_lists` theo unique partial `uk_wish_lists_user`.
- `wish_lists.user_id` nullable nên wishlist partial với user ở DB.
- Nghiệp vụ thường coi mỗi user có tối đa một wishlist.

### `wish_lists_item`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID dòng wishlist |
| `created_at`, `updated_at` |  | Nullable | audit |
| `added_at` |  | Nullable | thời điểm thêm |
| `wish_list_id` | FK -> `wish_lists.id`, UK pair | Nullable | wishlist |
| `publication_id` | FK -> `publications.id`, UK pair | Nullable | ấn phẩm |

Quan hệ:

- `wish_lists` N-N `publications` thông qua `wish_lists_item`.
- Unique partial: `(wish_list_id, publication_id)` khi cả hai khác null.
- Do FK nullable, participation ở DB là partial; về nghiệp vụ nên hiểu dòng wishlist hợp lệ cần cả hai FK.

### `user_interactions`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID interaction |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id` | NN | người dùng |
| `publication_id` | FK -> `publications.id` | NN | ấn phẩm |
| `type` | CHECK | NN | `WATCH`, `WISHLIST`, `BORROWED` |

Quan hệ:

- `users` 1-N `user_interactions`.
- `publications` 1-N `user_interactions`.
- Interaction total với cả user và publication.

### `ai_recommendations`

Cache gợi ý cá nhân hóa.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `user_id` | PK, FK -> `users.id` | NN | mỗi user tối đa một cache |
| `pub_ids` |  | NN | JSONB danh sách publication id |
| `strategy` |  | NN | ví dụ `TRENDING_FALLBACK` |
| `computed_at` | indexed | NN | thời điểm tính |

Quan hệ:

- `users` 1 - 0..1 `ai_recommendations`.
- Recommendation total với user.
- User partial với recommendation.
- Lưu ý `pub_ids` là JSONB, không có FK trực tiếp tới `publications`.

## 6. Rating/review sách

### `ratings`

Review cho từng publication, có thể gắn với một transaction đã trả.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID rating |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id` | NN | người đánh giá |
| `publication_id` | FK -> `publications.id` | NN | sách được đánh giá |
| `transaction_id` | FK -> `borrowing_transactions.id`, UK partial | Nullable | giao dịch mượn liên quan |
| `item_barcode` |  | Nullable | snapshot barcode |
| `star` |  | NN | số sao |
| `comment` |  | Nullable | nhận xét |
| `helpful_count` |  | NN | số lượt hữu ích |
| `verified_borrow` |  | Nullable | đã mượn thật |

Quan hệ:

- `users` 1-N `ratings`.
- `publications` 1-N `ratings`.
- `borrowing_transactions` 0..1 - 0..1 `ratings` khi `transaction_id` khác null.
- Rating total với user và publication.
- Rating partial với transaction.
- Sau `V19`, unique cũ `(user_id, publication_id)` đã bị drop; unique mới là `transaction_id` khi không null. Điều này cho phép một user đánh giá nhiều lần nếu mượn nhiều transaction khác nhau.

### `rating_helpful_votes`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID vote |
| `created_at` |  | NN | thời điểm vote |
| `rating_id` | FK -> `ratings.id`, UK pair | NN | rating |
| `user_id` | FK -> `users.id`, UK pair | NN | người vote |

Quan hệ:

- `ratings` N-N `users` thông qua `rating_helpful_votes`.
- Vote total với rating và user.
- Unique: `(rating_id, user_id)`.
- `ON DELETE CASCADE` khi xóa rating/user.

### `rating_replies`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID reply |
| `created_at`, `updated_at` |  | Nullable/NN | `created_at` default NN |
| `rating_id` | FK -> `ratings.id` | NN | review được trả lời |
| `librarian_id` | FK -> `users.id` | NN | thủ thư trả lời |
| `content` |  | NN | nội dung |

Quan hệ:

- `ratings` 1-N `rating_replies`.
- `users(librarian)` 1-N `rating_replies`.
- Reply total với rating và librarian.
- Rating/librarian partial với reply.

## 7. Mượn, đặt trước, phạt và thanh toán

### `borrowing_transactions`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID giao dịch mượn |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id` | NN | người mượn |
| `item_id` | FK -> `items.id` | NN | bản sao được mượn |
| `librarian_id_issue` | FK -> `users.id` | Nullable | thủ thư xác nhận mượn |
| `librarian_id_return` | FK -> `users.id` | Nullable | thủ thư xác nhận trả |
| `borrowed_date` |  | Nullable | ngày mượn |
| `due_date` |  | NN | hạn trả |
| `picked_up_deadline` |  | NN | hạn nhận sách |
| `returned_date` |  | Nullable | ngày trả |
| `renewal_count` |  | NN | số lần gia hạn |
| `status` | CHECK | NN | `WAITING_FOR_PICKUP`, `BORROWING`, `RETURNED`, `OVERDUE`, `CANCELLED` |

Quan hệ:

- `users(student)` 1-N `borrowing_transactions`.
- `items` 1-N `borrowing_transactions` theo lịch sử.
- `users(librarian_issue)` 1-N `borrowing_transactions`, optional ở transaction.
- `users(librarian_return)` 1-N `borrowing_transactions`, optional ở transaction.
- Transaction total với student và item.
- Transaction partial với librarian issue/return.

### `reservations`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID đặt trước |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id` | NN | người đặt |
| `publication_id` | FK -> `publications.id` | NN | ấn phẩm được đặt |
| `assigned_item_id` | FK -> `items.id` | Nullable | bản sao được gán |
| `reservation_date` |  | NN | ngày đặt |
| `hold_expiration_time` |  | Nullable | hạn giữ |
| `preferred_branch` |  | NN | chi nhánh mong muốn, default `ANY` |
| `queue_position` |  | NN | vị trí hàng đợi |
| `status` | CHECK | NN | `PENDING`, `READY_FOR_PICKUP`, `CANCELLED`, `EXPIRED`, `COMPLETED` |

Quan hệ:

- `users` 1-N `reservations`.
- `publications` 1-N `reservations`.
- `items` 1-N `reservations` qua `assigned_item_id`, optional ở reservation.
- Reservation total với user và publication.
- Reservation partial với assigned item.

### `fines`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID phí phạt |
| `created_at`, `updated_at` |  | Nullable | audit |
| `transaction_id` | FK -> `borrowing_transactions.id` | NN | giao dịch gây phạt |
| `fine_amount` |  | NN | số tiền |
| `payment_status` | CHECK | NN | `UNPAID`, `PAID` |
| `paid_date` |  | Nullable | ngày thanh toán |
| `paid_by_librarian_id` | FK -> `users.id` | Nullable | thủ thư ghi nhận thanh toán thủ công hoặc sync |
| `type` | CHECK | Nullable | `DAMAGED_BOOK`, `OVERDUE_RETURN`, `LOST_BOOK` |

Quan hệ:

- `borrowing_transactions` 1-N `fines`.
- `users(librarian)` 1-N `fines` qua `paid_by_librarian_id`, optional vì PayOS webhook có thể tự xác nhận.
- Fine total với transaction.
- Transaction partial với fines.

### `fine_payment_orders`

Đơn thanh toán PayOS cho một hoặc nhiều fine.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID order |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id` | NN | người nộp phạt |
| `student_id` | indexed | NN | snapshot mã sinh viên |
| `order_code` | UK | NN | mã đơn PayOS |
| `amount` |  | NN | tổng tiền |
| `fine_count` |  | NN | số khoản phạt |
| `fine_ids` |  | NN | snapshot text các fine id |
| `description` |  | NN | mô tả |
| `provider` | CHECK | NN | hiện tại `PAYOS` |
| `status` | CHECK | NN | `PENDING`, `PAID`, `CANCELLED`, `EXPIRED`, `FAILED` |
| `payment_link_id` | indexed | Nullable | id link PayOS |
| `checkout_url`, `qr_code` |  | Nullable | thông tin thanh toán |
| `paid_at` |  | Nullable | thời điểm thanh toán |
| `created_by_librarian_id` | FK -> `users.id` | Nullable | thủ thư tạo QR/đơn thanh toán |
| `paid_by_librarian_id` | FK -> `users.id` | Nullable | thủ thư sync/ghi nhận thanh toán |
| `reference` |  | Nullable | mã tham chiếu |

Quan hệ:

- `users` 1-N `fine_payment_orders`.
- `users(librarian_created)` 1-N `fine_payment_orders`, optional.
- `users(librarian_paid)` 1-N `fine_payment_orders`, optional.
- Order total với user.
- User partial với orders.
- `fine_ids` là snapshot, không dùng để vẽ FK; quan hệ chuẩn nằm ở `fine_payment_order_fines`.

### `fine_payment_order_fines`

Bảng nối chuẩn hóa quan hệ giữa payment order và fine.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `order_id` | PK, FK -> `fine_payment_orders.id` | NN | order |
| `fine_id` | PK, FK -> `fines.id` | NN | fine |

Quan hệ:

- `fine_payment_orders` N-N `fines`.
- Bảng nối total với order và fine.
- `ON DELETE CASCADE` từ order.
- `ON DELETE RESTRICT` từ fine.

### `transaction_notes`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID note |
| `created_at`, `updated_at` |  | Nullable | audit |
| `transaction_id` | FK -> `borrowing_transactions.id` | NN | transaction |
| `librarian_id` | FK -> `users.id` | NN | thủ thư ghi chú |
| `important` |  | NN | mặc định `TRUE` |
| `note` |  | Nullable | nội dung |

Quan hệ:

- `borrowing_transactions` 1-N `transaction_notes` để nhiều thủ thư có thể ghi chú như một đoạn hội thoại nhỏ trong cùng giao dịch.
- `users(librarian)` 1-N `transaction_notes`.
- Note total với transaction và librarian.

## 8. Thông báo

### `notifications`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID thông báo mẫu/sự kiện |
| `created_at`, `updated_at` |  | Nullable | audit |
| `title` |  | NN | tiêu đề |
| `message` |  | NN | nội dung |
| `link` |  | Nullable | URL điều hướng |
| `reference_id` |  | Nullable | id nghiệp vụ liên quan |
| `type` | CHECK | NN | loại thông báo |

`type` hiện gồm: `BOOK_RESERVED`, `BOOK_AVAILABLE`, `BORROW_SUCCESS`, `BORROW_CANCELLED_EXPIRED`, `RESERVATION_EXPIRED`, `OVERDUE_WARNING`, `FINE_ISSUED`, `SYSTEM_MAINTENANCE`, `RETURN_REMINDER`, `PICKUP_CONFIRMED`, `RETURN_CONFIRMED`, `FINE_PAID`, `REVIEW_HELPFUL`, `REVIEW_REPLY`.

### `user_notifications`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID thông báo của user |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id` | NN | người nhận |
| `notification_id` | FK -> `notifications.id` | NN | thông báo gốc |
| `is_read` |  | NN | đã đọc |
| `read_at` |  | Nullable | thời điểm đọc |

Quan hệ:

- `users` N-N `notifications` thông qua `user_notifications`.
- `user_notifications` total với cả user và notification.

## 9. Auth token

### `refresh_tokens`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `uuid_token` | PK | NN | refresh token |
| `user_id` | FK -> `users.id`, UK pair | Nullable | chủ token |
| `device_id` | UK pair | Nullable | thiết bị |
| `expiry_date` |  | Nullable | hạn token |
| `revoked` |  | NN | đã thu hồi |

Quan hệ:

- `users` 1-N `refresh_tokens`.
- Token partial với user vì `user_id` nullable.
- Unique: `(user_id, device_id)`.

### `password_reset_tokens`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `token` | PK | NN | reset token |
| `user_id` | FK -> `users.id` | NN | user cần reset |
| `expires_at` |  | NN | hạn token |

Quan hệ:

- `users` 1-N `password_reset_tokens`.
- Reset token total với user.
- User partial với reset token.
- `ON DELETE CASCADE`.

## 10. Review hệ thống

### `system_reviews`

Đánh giá toàn hệ thống SmartLibrary, khác với `ratings` là review sách.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID review hệ thống |
| `created_at`, `updated_at` |  | Nullable | audit |
| `user_id` | FK -> `users.id`, UK partial | Nullable | user đánh giá thật |
| `reviewer_name` |  | NN | snapshot tên |
| `reviewer_role` |  | Nullable | snapshot vai trò |
| `profile_picture_url` |  | Nullable | snapshot avatar |
| `rating` | CHECK | NN | 1 đến 5 |
| `comment` |  | NN | nhận xét |
| `is_published` |  | NN | có hiển thị public không |

Quan hệ:

- `users` 1 - 0..1 `system_reviews` theo unique partial `uk_system_reviews_user_id`.
- Review partial với user ở DB vì các seed cũ có thể null, nhưng dữ liệu thật mới nên có `user_id`.
- Quy tắc nghiệp vụ hiện tại: mỗi người chỉ review hệ thống một lần và có thể sửa bất kỳ lúc nào.
- `rating >= 3` được tính là hài lòng trong thống kê.

## 11. Nhóm AI và semantic search

### `ai_engine.publication_etl_runs`

Theo dõi trạng thái ETL PDF.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `publication_id` | PK, FK -> `public.publications.id` | NN | publication được xử lý |
| `file_hash` |  | Nullable | hash PDF |
| `status` | indexed | NN | `QUEUED`, `RUNNING`, `SUCCESS`, `FAILED`, ... |
| `error_message` |  | Nullable | lỗi ETL |
| `chunks_count` |  | NN | số chunk |
| `vectors_count` |  | NN | số vector |
| `updated_at` | indexed | NN | lần cập nhật |

Quan hệ:

- `publications` 1 - 0..1 `ai_engine.publication_etl_runs`.
- ETL run total với publication.
- Publication partial với ETL run.
- `ON DELETE CASCADE`.

### `ai_engine.publication_vectors`

Bảng vector semantic search do `LMS-AI/init_schema.sql` tạo.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID vector |
| `publication_id` | FK -> `public.publications.id` | Nullable trong DDL | publication |
| `chunk_text` | indexed | NN | nội dung chunk |
| `embedding` | HNSW index | NN | vector(768) |
| `created_at` |  | NN | thời điểm tạo |

Quan hệ:

- `publications` 1-N `ai_engine.publication_vectors`.
- Về nghiệp vụ vector phải thuộc một publication, nhưng DDL không đặt `publication_id NOT NULL`; khi vẽ ERD có thể ghi optional ở DB, required ở nghiệp vụ.
- `ON DELETE CASCADE`.

### `ai_engine.search_logs`

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID log |
| `query_text` |  | NN | query người dùng |
| `publication_ids` |  | NN | JSONB kết quả |
| `created_at` |  | NN | thời điểm tìm |

Quan hệ:

- Không có FK trực tiếp.
- `publication_ids` là JSONB snapshot, không vẽ quan hệ FK tới `publications`.

## 12. Bảng nên loại khỏi ERD nghiệp vụ

## Bổ sung V24: Admin, quy định vận hành và audit

### `circulation_policies`

Bảng singleton lưu các quy định mượn trả đang được backend áp dụng thật.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK, CHECK `id = 1` | NN | chỉ có một dòng cấu hình |
| `created_at`, `updated_at` |  | NN | audit |
| `pickup_deadline_hours` | CHECK > 0 | NN | thời hạn nhận sách |
| `default_loan_days` | CHECK > 0 | NN | thời hạn mượn mặc định |
| `max_active_borrows` | CHECK > 0 | NN | số sách đang mượn/chờ lấy tối đa |
| `max_active_reservations` | CHECK >= 0 | NN | số reservation tối đa |
| `overdue_fine_per_day` | CHECK >= 0 | NN | phí trễ hạn mỗi ngày |
| `block_borrow_when_unpaid_fines` |  | NN | bật/tắt chặn khi còn fine unpaid |
| `updated_by_admin_id` | FK -> `users.id` | Nullable | admin cập nhật cuối |

Quan hệ:

- `users(admin)` 1-N `circulation_policies` về mặt lịch sử cập nhật, nhưng bảng chỉ có 1 dòng.
- Policy partial với admin vì seed mặc định chưa có người cập nhật.

### `audit_logs`

Nhật ký truy vết thao tác quan trọng của admin/thủ thư.

| Attribute | Key | Null | Ghi chú |
|---|---:|---:|---|
| `id` | PK | NN | ID log |
| `created_at` | indexed | NN | thời điểm thao tác |
| `actor_user_id` | FK -> `users.id` | Nullable | người thao tác; null cho webhook/system |
| `actor_role` | indexed | Nullable | `ADMIN`, `LIBRARIAN`, `PAYOS`, ... |
| `action` | indexed | NN | loại thao tác |
| `entity_type` | indexed | NN | bảng/loại đối tượng |
| `entity_id` | indexed | Nullable | id đối tượng ở dạng text |
| `summary` |  | Nullable | mô tả ngắn |
| `details` | JSONB | Nullable | dữ liệu phụ để truy vết |

Quan hệ:

- `users` 1-N `audit_logs`.
- Audit log partial với user vì một số thao tác có thể đến từ hệ thống/webhook.

---

Không nên vẽ các bảng sau trong ERD nghiệp vụ chính:

- `flyway_schema_history`: bảng quản lý migration.
- `user_notification_preferences`: đã tạo ở `V9` nhưng bị drop ở `V11`.
- `ai_engine.tags`, `ai_engine.publication_tags`, `ai_engine.recommendation_cache`: schema AI cũ, bị drop ở `V20`/AI init.

## 13. Tóm tắt quan hệ cardinality

### 1-1 hoặc 1-0..1

| Quan hệ | Cardinality | Participation |
|---|---|---|
| `users` - `wish_lists` | `users` 1 - 0..1 `wish_lists` | wishlist optional với user ở DB |
| `users` - `ai_recommendations` | `users` 1 - 0..1 `ai_recommendations` | recommendation total với user |
| `publications` - `ai_engine.publication_etl_runs` | `publications` 1 - 0..1 ETL run | ETL total với publication |
| `borrowing_transactions` - `transaction_notes` | transaction 1-N notes | nhiều ghi chú nội bộ theo từng thủ thư |
| `borrowing_transactions` - `ratings` | transaction 1 - 0..1 rating | rating optional với transaction |
| `users` - `system_reviews` | user 1 - 0..1 system review | review user optional ở DB, required cho dữ liệu thật |

### 1-N

| Quan hệ | Cardinality | Participation |
|---|---|---|
| `publishers` - `publications` | 1-N | `publications.publisher_id` optional |
| `publications` - `items` | 1-N | item total với publication |
| `users` - `search_history` | 1-N | search history total với user |
| `users` - `user_interactions` | 1-N | interaction total với user |
| `publications` - `user_interactions` | 1-N | interaction total với publication |
| `users` - `borrowing_transactions` | 1-N | transaction total với user |
| `items` - `borrowing_transactions` | 1-N | transaction total với item |
| `users(librarian_issue)` - `borrowing_transactions` | 1-N | optional ở transaction |
| `users(librarian_return)` - `borrowing_transactions` | 1-N | optional ở transaction |
| `users` - `reservations` | 1-N | reservation total với user |
| `publications` - `reservations` | 1-N | reservation total với publication |
| `items` - `reservations` | 1-N | assigned item optional |
| `borrowing_transactions` - `fines` | 1-N | fine total với transaction |
| `users` - `fine_payment_orders` | 1-N | order total với user |
| `users(librarian_paid)` - `fines` | 1-N | optional, dùng khi có thủ thư ghi nhận thanh toán |
| `users(librarian_created/paid)` - `fine_payment_orders` | 1-N | optional |
| `users(admin)` - `circulation_policies` | 1-N | optional, bảng policy là singleton |
| `users(actor)` - `audit_logs` | 1-N | optional vì webhook/system có thể không có user |
| `ratings` - `rating_replies` | 1-N | reply total với rating |
| `users(librarian)` - `rating_replies` | 1-N | reply total với librarian |
| `users` - `refresh_tokens` | 1-N | token optional với user ở DB |
| `users` - `password_reset_tokens` | 1-N | reset token total với user |
| `publications` - `publication_translations` | 1-N | translation total với publication |
| `categories` - `category_translations` | 1-N | translation total với category |
| `tags` - `tag_translations` | 1-N | translation total với tag |
| `publications` - `ai_engine.publication_vectors` | 1-N | vector belongs to publication in nghiệp vụ |

### N-N

| Quan hệ | Bảng nối | Ghi chú |
|---|---|---|
| `users` N-N `roles` | `user_roles` | PK kép `(user_id, role_id)` |
| `publications` N-N `authors` | `publication_authors` | unique `(publication_id, author_id)` |
| `publications` N-N `categories` | `publication_categories` | unique `(publication_id, category_id)` |
| `publications` N-N `tags` | `publication_tags` | unique `(publication_id, tag_id)` |
| `wish_lists` N-N `publications` | `wish_lists_item` | unique partial `(wish_list_id, publication_id)` |
| `users` N-N `notifications` | `user_notifications` | notification delivery per user |
| `users` N-N `ratings` | `rating_helpful_votes` | user đánh dấu review hữu ích |
| `fine_payment_orders` N-N `fines` | `fine_payment_order_fines` | order gồm nhiều khoản phạt |

## 14. Gợi ý bố cục khi vẽ ERD

Nên chia canvas thành các cụm:

1. **User/Auth/Admin**: `users`, `roles`, `user_roles`, `refresh_tokens`, `password_reset_tokens`, `audit_logs`.
2. **Catalog**: `publications`, `items`, `authors`, `publishers`, `categories`, `tags`, các bảng nối.
3. **Circulation**: `borrowing_transactions`, `reservations`, `fines`, `fine_payment_orders`, `fine_payment_order_fines`, `transaction_notes`, `circulation_policies`.
4. **Engagement**: `ratings`, `rating_helpful_votes`, `rating_replies`, `wish_lists`, `wish_lists_item`, `search_history`, `user_interactions`, `system_reviews`.
5. **Notification**: `notifications`, `user_notifications`.
6. **i18n**: `publication_translations`, `category_translations`, `tag_translations`.
7. **AI**: `ai_engine.publication_etl_runs`, `ai_engine.publication_vectors`, `ai_engine.search_logs`, `ai_recommendations`.

Nếu cần bản ERD gọn cho báo cáo, nên vẽ bảng đầy đủ cho các cụm 1-6 và để cụm AI ở một khung riêng vì một phần nằm trong schema `ai_engine`.
