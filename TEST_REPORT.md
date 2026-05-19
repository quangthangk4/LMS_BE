# Backend Test Report

## Final Backend Suite

Command:

```bash
DOCKER_HOST=unix:///Users/hosythang/.docker/run/docker.sock mvn test -q
```

Result:

| Metric | Result |
|---|---:|
| Test classes | 23 |
| Test cases | 79 |
| Failures | 0 |
| Errors | 0 |
| Skipped | 0 |
| Surefire accumulated time | 15.372s |
| Maven result | Passed |

## Module Breakdown

| Module | Test classes | Test cases | Result |
|---|---:|---:|---|
| `library-auth-module` | 1 | 3 | Passed |
| `library-user-module` | 3 | 10 | Passed |
| `library-catalog-module` | 5 | 12 | Passed |
| `library-circulation-module` | 5 | 24 | Passed |
| `library-recommendation-module` | 7 | 24 | Passed |
| `library-bootstrap` | 2 | 6 | Passed |
| **Total** | **23** | **79** | **Passed** |

## Integration Environment

| Component | Value |
|---|---|
| Testcontainers | `1.21.4` |
| Docker host | `unix:///Users/hosythang/.docker/run/docker.sock` |
| Docker Desktop / Engine | `29.4.3` |
| Database container | `postgres:15-alpine` |
| Test profile | `application-test.yml` |

## Important Coverage

| Area | Coverage |
|---|---|
| Auth | Register controller accepts valid HCMUT payload and rejects invalid email/student id before use case execution. |
| User/Notification | Signup use case, mark one/all notifications read, unread count and notification page controller. |
| Catalog | Publication creation, item creation, document upload URL, save document URL, public search SQL contract and publication controller contract. |
| Circulation | Borrow request, return book, overdue fine, unpaid fine and borrow limit rules, reservation constraints, transaction controller contract, fine/cash/PayOS payment controller contract and native SQL reservation integration. |
| Recommendation | Wishlist, rating, AI gateway contract/fallback and signed AI callback controller. |
| Integration | PostgreSQL migrations, seeded data, borrow/return flow and reservation native SQL scenarios run against real PostgreSQL through Testcontainers. |

## Fixes Made For Correct Test Execution

| Issue | Resolution |
|---|---|
| Testcontainers could not connect to Docker Desktop with the older dependency set. | Pinned Testcontainers to `1.21.4`, which brings a newer Docker Java client compatible with the local Docker Engine. |
| Reservation integration tests failed before reaching reservation logic because seed data gave the test user unpaid fines. | Cleaned fines and generated transactions for the test user in `ReservationNativeSqlIntegrationTest.cleanState()`. |
| Kafka consumers attempted to connect to dummy `localhost:9999` during integration tests. | Disabled Kafka listener auto-startup in the test profile. |
| Document URL endpoint returned the saved URL as the response message instead of `data`. | Updated `PublicationController.saveDocumentUrl()` to return a message plus the URL in `data`. |
| AI schema had duplicate unused `ai_engine.tags`, `ai_engine.publication_tags`, and `ai_engine.recommendation_cache` tables. | Added Flyway `V20__schema_cleanup_and_ai_indexes.sql` and aligned AI bootstrap code to use `public.tags`, `public.publication_tags`, and `public.ai_recommendations` as the canonical tables. |
