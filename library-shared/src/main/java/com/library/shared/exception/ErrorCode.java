package com.library.shared.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
  // General errors (1000-1099)
  UNCATEGORIZED_EXCEPTION(1000, "Uncategorized error", HttpStatus.INTERNAL_SERVER_ERROR),
  INVALID_REQUEST(1001, "Invalid request", HttpStatus.BAD_REQUEST),
  RESOURCE_NOT_FOUND(1002, "Resource not found", HttpStatus.NOT_FOUND),

  // User errors (1100-1199)
  USER_NOT_FOUND(1100, "User not found", HttpStatus.NOT_FOUND),
  USER_ALREADY_EXISTS(1101, "User already exists", HttpStatus.CONFLICT),
  USERNAME_ALREADY_EXISTS(1102, "Username already exists", HttpStatus.CONFLICT),
  EMAIL_ALREADY_EXISTS(1103, "Email already exists", HttpStatus.CONFLICT),
  INVALID_USERNAME(1104, "Invalid username format", HttpStatus.BAD_REQUEST),
  INVALID_EMAIL(1105, "Invalid email format, expect to: @hcmut.edu.vn", HttpStatus.BAD_REQUEST),
  INVALID_PASSWORD(1106, "Invalid password", HttpStatus.BAD_REQUEST),
  USER_NOT_ACTIVE(1107, "User account is not active", HttpStatus.FORBIDDEN),
  USER_SUSPENDED(1108, "User account is suspended", HttpStatus.FORBIDDEN),
  EMAIL_OR_PASSWORD_INCORRECT(1109, "Email or password is incorrect", HttpStatus.BAD_REQUEST),
  VERIFY_EMAIL_FAILED(1110, "Email verification failed", HttpStatus.BAD_REQUEST),
  INVALID_FILE_TYPE(1111, "Only image files are allowed (jpeg, png, gif, webp)", HttpStatus.BAD_REQUEST),
  FILE_TOO_LARGE(1112, "File size exceeds the 5MB limit", HttpStatus.BAD_REQUEST),
  FILE_UPLOAD_FAILED(1113, "Failed to upload file, please try again", HttpStatus.INTERNAL_SERVER_ERROR),

  // Role errors (1200-1299)
  ROLE_NOT_FOUND(1200, "Role not found", HttpStatus.NOT_FOUND),
  ROLE_ALREADY_EXISTS(1201, "Role already exists", HttpStatus.CONFLICT),
  ROLE_NAME_ALREADY_EXISTS(1202, "Role name already exists", HttpStatus.CONFLICT),
  CANNOT_DELETE_ROLE(1203, "Cannot delete role - users are assigned to it", HttpStatus.CONFLICT),
  USER_ALREADY_HAS_ROLE(1204, "User already has this role", HttpStatus.CONFLICT),

  // Permission errors (1300-1399)
  PERMISSION_NOT_FOUND(1300, "Permission not found", HttpStatus.NOT_FOUND),
  PERMISSION_ALREADY_EXISTS(1301, "Permission already exists", HttpStatus.CONFLICT),
  PERMISSION_NAME_ALREADY_EXISTS(1302, "Permission name already exists", HttpStatus.CONFLICT),
  INSUFFICIENT_PERMISSIONS(1303, "You do not have permission to access this resource",
      HttpStatus.FORBIDDEN),

  // Authentication errors (1400-1499)
  UNAUTHENTICATED(1400, "Authentication required", HttpStatus.UNAUTHORIZED),
  FORBIDDEN(1401, "Access denied", HttpStatus.FORBIDDEN),
  INVALID_TOKEN(1402, "Invalid token", HttpStatus.UNAUTHORIZED),
  TOKEN_EXPIRED(1403, "Token expired", HttpStatus.UNAUTHORIZED),
  TOKEN_GENERATION_FAILED(1404, "Token generation failed", HttpStatus.INTERNAL_SERVER_ERROR),
  NOT_OWNER(1405, "You are not the owner of this resource", HttpStatus.FORBIDDEN),
  TOKEN_REFRESH_FAILED(1406, "Token refresh failed", HttpStatus.BAD_REQUEST),

  // Validation errors (1500-1599)
  VALIDATION_ERROR(1500, "Validation error", HttpStatus.BAD_REQUEST),
  INVALID_INPUT(1501, "Invalid input", HttpStatus.BAD_REQUEST),

  // Catalog - Publication errors (2000-2099)
  PUBLICATION_NOT_FOUND(2001, "Publication not found", HttpStatus.NOT_FOUND),

  PUBLICATION_ALREADY_EXISTS(2001, "Publication already exists", HttpStatus.CONFLICT),
  ISBN_ALREADY_EXISTS(2002, "ISBN already exists", HttpStatus.CONFLICT),
  CANNOT_DELETE_PUBLICATION_HAS_ITEMS(2003, "Cannot delete publication: items still exist",
      HttpStatus.CONFLICT),
  CANNOT_DELETE_PUBLICATION_HAS_ACTIVE_RESERVATIONS(2004, "Cannot delete publication: active reservations exist",
      HttpStatus.CONFLICT),

  // Catalog - Item errors (2100-2199)
  ITEM_NOT_FOUND(2100, "Item not found", HttpStatus.NOT_FOUND),
  ITEM_ALREADY_EXISTS(2101, "Item already exists", HttpStatus.CONFLICT),
  BARCODE_ALREADY_EXISTS(2102, "Barcode already exists", HttpStatus.CONFLICT),
  ITEM_NOT_BORROWABLE(2103, "Item is not available for borrowing", HttpStatus.CONFLICT),

  // Catalog - Author errors (2200-2299)
  AUTHOR_NOT_FOUND(2200, "Author not found", HttpStatus.NOT_FOUND),
  AUTHOR_ALREADY_EXISTS(2201, "Author already exists", HttpStatus.CONFLICT),
  CANNOT_DELETE_AUTHOR_HAS_PUBLICATIONS(2202, "Cannot delete author has publications",
      HttpStatus.CONFLICT),
  AUTHOR_NAME_ALREADY_EXISTS(2003, "Author name already exists", HttpStatus.CONFLICT),

  // Catalog - Publisher errors (2300-2399)
  PUBLISHER_NOT_FOUND(2300, "Publisher not found", HttpStatus.NOT_FOUND),
  PUBLISHER_ALREADY_EXISTS(2301, "Publisher already exists", HttpStatus.CONFLICT),
  PUBLISHER_NAME_ALREADY_EXISTS(2302, "Publisher name already exists", HttpStatus.CONFLICT),
  CANNOT_DELETE_PUBLISHER_HAS_PUBLICATIONS(2303, "Cannot delete publisher has publications",
      HttpStatus.CONFLICT),

  // Catalog - Category errors (2400-2499)
  CATEGORY_NOT_FOUND(2400, "Category not found", HttpStatus.NOT_FOUND),
  CATEGORY_ALREADY_EXISTS(2401, "Category already exists", HttpStatus.CONFLICT),
  CATEGORY_NAME_ALREADY_EXISTS(2402, "Category name already exists", HttpStatus.CONFLICT),
  CANNOT_DELETE_CATEGORY_HAS_CHILDREN(2403, "Cannot delete category has children",
      HttpStatus.CONFLICT),
  CANNOT_DELETE_CATEGORY_HAS_PUBLICATIONS(2404, "Cannot delete category has publications",
      HttpStatus.CONFLICT),
  CIRCULAR_CATEGORY_REFERENCE(2405, "Circular category reference", HttpStatus.CONFLICT),
  INVALID_PARENT_CATEGORY(2406, "Invalid parent category", HttpStatus.BAD_REQUEST),

  // Catalog - Tag errors (2500-2599)
  TAG_NOT_FOUND(2500, "Tag not found", HttpStatus.NOT_FOUND),
  TAG_ALREADY_EXISTS(2501, "Tag already exists", HttpStatus.CONFLICT),
  TAG_NAME_ALREADY_EXISTS(2502, "Tag name already exists", HttpStatus.CONFLICT),

  // Circulation - Transaction errors (3000-3099)
  TRANSACTION_NOT_FOUND(3000, "Borrowing transaction not found", HttpStatus.NOT_FOUND),
  TRANSACTION_NOT_RETURNABLE(3001, "Transaction cannot be returned in its current status", HttpStatus.CONFLICT),
  USER_BORROW_LIMIT_EXCEEDED(3002, "User has exceeded the maximum borrow limit",
      HttpStatus.CONFLICT),
  CANNOT_RENEW_TRANSACTION(3003,
      "Cannot renew transaction - renewal limit reached or transaction is overdue",
      HttpStatus.CONFLICT),
  RESERVATION_NOT_FOUND(3004, "Reservation not found", HttpStatus.NOT_FOUND),
  RESERVATION_ALREADY_EXISTS(3005, "User already has a pending reservation for this publication",
      HttpStatus.CONFLICT),
  FINE_NOT_FOUND(3006, "Fine not found", HttpStatus.NOT_FOUND),
  USER_HAS_UNPAID_FINES(3007, "User has unpaid fines and cannot borrow", HttpStatus.FORBIDDEN),
  ACCOUNT_SUSPENDED(3008, "User account is suspended", HttpStatus.FORBIDDEN),
  FINE_ALREADY_PAID(3009, "Fine is already paid", HttpStatus.CONFLICT),
  RESERVATION_NOT_CANCELLABLE(3010, "Reservation cannot be cancelled in its current status", HttpStatus.CONFLICT),
  RESERVATION_BOOK_AVAILABLE(3011, "Book is currently available, please borrow it directly", HttpStatus.CONFLICT),
  RESERVATION_BRANCH_NO_ITEMS(3012, "No items of this publication found in the selected branch", HttpStatus.BAD_REQUEST),
  RESERVATION_LIMIT_EXCEEDED(3013, "User has exceeded the maximum reservation limit", HttpStatus.CONFLICT),
  RESERVATION_NOT_READY(3014, "Reservation is not in READY_FOR_PICKUP status", HttpStatus.BAD_REQUEST),


  // Security Error (2600 - 2699)
  USER_LOCKED(2600, "User account is locked", HttpStatus.LOCKED),
  USER_EMAIL_NOT_VERIFIED(2601, "Email address is not verified", HttpStatus.UNAUTHORIZED),
  USER_BANNED(2602, "User account has BANNED", HttpStatus.UNAUTHORIZED),
  PASSWORD_EXPIRED(2603, "User password has expired", HttpStatus.UNAUTHORIZED),
  TOKEN_INVALID(2604, "Token invalid", HttpStatus.UNAUTHORIZED),
  BUILD_OAUTH2_URL_FAILED(2605, "Failed to build OAuth2 URL", HttpStatus.BAD_REQUEST),


  // Rating (2700 - 2799)
  RATING_ALREADY_EXISTS(2700, "User already has a rating for this publication",
      HttpStatus.CONFLICT),
  USER_NOT_BORROWED_PUBLICATION(2701, "User has not borrowed this publication and cannot rate it",
      HttpStatus.FORBIDDEN),

  // Notification errors (3100-3199)
  NOTIFICATION_NOT_FOUND(3100, "Notification not found", HttpStatus.NOT_FOUND);

  private final int code;
  private final String message;
  private final HttpStatusCode status;

  ErrorCode(int code, String message, HttpStatusCode status) {
    this.code = code;
    this.message = message;
    this.status = status;
  }
}
