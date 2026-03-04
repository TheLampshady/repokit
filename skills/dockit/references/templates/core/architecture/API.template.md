# API Reference

Complete API documentation for [PROJECT_NAME].

## Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Error Handling](#error-handling)
- [Rate Limits](#rate-limits)
- [Versioning](#versioning)
- [Examples](#examples)

---

## Overview

[API_OVERVIEW]
<!-- Brief description of the API, its purpose, and primary use cases -->

### Base URLs

| Environment | URL |
|-------------|-----|
| Production | `[PRODUCTION_API_URL]` |
| Staging | `[STAGING_API_URL]` |
| Local | `http://localhost:[PORT]` |

### API Documentation

| Format | URL |
|--------|-----|
| OpenAPI/Swagger | `[API_URL]/docs` |
| ReDoc | `[API_URL]/redoc` |

---

## Authentication

[AUTH_OVERVIEW]
<!-- How authentication works -->

### Authentication Methods

| Method | Use Case | Header |
|--------|----------|--------|
[AUTH_METHODS_TABLE]

### Obtaining Tokens

[TOKEN_ACQUISITION]
<!-- How to get tokens -->

```bash
# Example: Get access token
[TOKEN_REQUEST_EXAMPLE]
```

### Token Refresh

```bash
[TOKEN_REFRESH_EXAMPLE]
```

### Token Lifetime

| Token Type | Lifetime | Refresh |
|------------|----------|---------|
| Access Token | [ACCESS_TOKEN_LIFETIME] | [ACCESS_REFRESH] |
| Refresh Token | [REFRESH_TOKEN_LIFETIME] | [REFRESH_REFRESH] |

---

## Endpoints

[REPEAT_FOR_ENDPOINT_GROUPS]
### [GROUP_NAME]

[GROUP_DESCRIPTION]

[REPEAT_FOR_ENDPOINTS]
#### [METHOD] [ENDPOINT_PATH]

[ENDPOINT_DESCRIPTION]

**Auth Required:** [AUTH_REQUIRED]

**Request:**
```bash
curl -X [METHOD] "[API_URL][ENDPOINT_PATH]" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  [REQUEST_BODY]
```

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
[PARAMETERS_TABLE]

**Response:** `[RESPONSE_CODE]`
```json
[RESPONSE_EXAMPLE]
```

[END_REPEAT]
[END_REPEAT]

---

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "[ERROR_CODE]",
    "message": "[ERROR_MESSAGE]",
    "details": {}
  }
}
```

### HTTP Status Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input, missing fields |
| 401 | Unauthorized | Missing or invalid auth |
| 403 | Forbidden | Valid auth, insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource state conflict |
| 422 | Unprocessable Entity | Validation failed |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Maintenance or overload |

### Application Error Codes

| Code | Meaning | Resolution |
|------|---------|------------|
[APP_ERROR_CODES_TABLE]

---

## Rate Limits

[RATE_LIMIT_OVERVIEW]
<!-- General rate limiting approach -->

### Limits by Tier

| Tier | Requests/Minute | Requests/Day |
|------|-----------------|--------------|
[RATE_LIMIT_TIERS_TABLE]

### Rate Limit Headers

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Max requests allowed |
| `X-RateLimit-Remaining` | Requests remaining |
| `X-RateLimit-Reset` | Time until limit resets (Unix timestamp) |

### Handling Rate Limits

```python
# Example: Exponential backoff
[RATE_LIMIT_HANDLING_EXAMPLE]
```

---

## Versioning

[VERSIONING_OVERVIEW]
<!-- How API versioning works -->

**Current Version:** [CURRENT_VERSION]

### Version History

| Version | Status | End of Life |
|---------|--------|-------------|
[VERSION_HISTORY_TABLE]

### Specifying Version

```bash
# Via URL path
curl "[API_URL]/v2/endpoint"

# Via header
curl -H "API-Version: 2" "[API_URL]/endpoint"
```

---

## Examples

### [EXAMPLE_1_NAME]

[EXAMPLE_1_DESCRIPTION]

```bash
[EXAMPLE_1_CODE]
```

### [EXAMPLE_2_NAME]

[EXAMPLE_2_DESCRIPTION]

```bash
[EXAMPLE_2_CODE]
```

---

## SDKs & Libraries

| Language | Package | Install |
|----------|---------|---------|
[SDK_TABLE]

---

## Related Documentation

- [ARCHITECTURE.md](../ARCHITECTURE.md) - System architecture
- [ENVIRONMENTS.md](../ENVIRONMENTS.md) - Environment setup
- [Authentication Flow](./AUTH.md) - Detailed auth documentation
