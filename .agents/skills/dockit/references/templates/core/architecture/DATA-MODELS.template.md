# Data Models

Database schemas, relationships, and data flow documentation.

## Table of Contents

- [Overview](#overview)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Tables/Collections](#tablescollections)
- [Relationships](#relationships)
- [Indexes](#indexes)
- [Migrations](#migrations)

---

## Overview

[DATA_MODELS_OVERVIEW]
<!-- Brief description of the data layer: what databases, why chosen, how organized -->

| Attribute | Value |
|-----------|-------|
| Primary Database | [DATABASE_TYPE] |
| ORM/Client | [ORM_CLIENT] |
| Additional Stores | [ADDITIONAL_STORES] |

---

## Entity Relationship Diagram

```mermaid
erDiagram
[ERD_DIAGRAM]
```

---

## Tables/Collections

[REPEAT_FOR_EACH_TABLE]
### [TABLE_NAME]

[TABLE_DESCRIPTION]

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
[COLUMNS_TABLE]

**Indexes:**
- [INDEX_1]
- [INDEX_2]

[END_REPEAT]

---

## Relationships

| From | To | Type | Description |
|------|-----|------|-------------|
[RELATIONSHIPS_TABLE]

---

## Indexes

[INDEXES_CONTEXT]
<!-- Explain indexing strategy -->

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
[INDEXES_TABLE]

---

## Migrations

[MIGRATIONS_CONTEXT]
<!-- How to run migrations, create new ones -->

```bash
# Check migration status
[MIGRATION_STATUS_CMD]

# Run migrations
[MIGRATION_RUN_CMD]

# Create new migration
[MIGRATION_CREATE_CMD]
```

---

## Related Documentation

- [Architecture Overview](../ARCHITECTURE.md)
- [Services](./SERVICES.md)
