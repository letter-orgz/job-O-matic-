---
applyTo: "src/models.py"
---

# Database Models Instructions for Job-O-Matic

This file contains SQLAlchemy database models. Follow these guidelines when modifying:

## SQLAlchemy Best Practices

1. **Model Definition** - Inherit from the existing `Base` declarative base
2. **Table Names** - Use plural, lowercase table names with underscores
3. **Primary Keys** - Always include an auto-incrementing integer primary key
4. **Indexing** - Add indexes for frequently queried columns

## Column Definitions

1. **Data Types** - Choose appropriate SQLAlchemy data types
   - `String(length)` for text with known max length
   - `Text` for unlimited text content
   - `DateTime` for timestamps
   - `Integer` for numeric IDs and counts
   - `Boolean` for true/false fields

2. **Constraints** - Add appropriate constraints
   - `nullable=False` for required fields
   - `unique=True` for unique fields
   - `default=value` for default values
   - `index=True` for frequently searched fields

3. **Relationships** - Define relationships when needed
   - Use `relationship()` for foreign key relationships
   - Add `back_populates` for bidirectional relationships
   - Consider lazy loading strategies

## Existing Model Pattern

Follow the pattern established by the `Job` model:

```python
class Job(Base):
    __tablename__ = "jobs"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(256), nullable=False)
    company = Column(String(256), nullable=False)
    location = Column(String(128), nullable=True)
    apply_url = Column(String(1024), nullable=True)
    description = Column(Text, nullable=True)
    posted_date = Column(String(64), nullable=True)
    status = Column(String(64), default="NOT_APPLIED")
    created_at = Column(DateTime, default=datetime.utcnow)
```

## Status Field Conventions

For status fields, use standardized values:
- `NOT_APPLIED` - Initial state when job is found
- `PREVIEW_READY` - Application materials prepared, awaiting review
- `APPROVED` - Human approved, ready for submission
- `SENT` - Application submitted successfully
- `REJECTED` - Application was rejected
- `WITHDRAWN` - Application withdrawn by user

## Adding New Models

When adding new models, consider:

1. **Audit Fields** - Include created_at and updated_at timestamps
2. **Soft Deletes** - Consider adding deleted_at for soft deletion
3. **User Association** - Add user_id if the system becomes multi-user
4. **Validation** - Add model-level validation where appropriate

Example new model:
```python
class Application(Base):
    __tablename__ = "applications"
    
    id = Column(Integer, primary_key=True, index=True)
    job_id = Column(Integer, ForeignKey("jobs.id"), nullable=False)
    cv_variant = Column(String(128), nullable=False)
    cover_letter_path = Column(String(512), nullable=True)
    submitted_at = Column(DateTime, nullable=True)
    status = Column(String(64), default="DRAFT")
    response_received = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    job = relationship("Job", back_populates="applications")
```

## Migration Considerations

1. **Backward Compatibility** - Ensure new columns have defaults or are nullable
2. **Data Migration** - Consider how existing data will be handled
3. **Index Creation** - Add indexes for new searchable columns
4. **Foreign Key Constraints** - Add proper foreign key relationships

## Performance Considerations

1. **Query Optimization** - Add indexes for columns used in WHERE clauses
2. **Relationship Loading** - Use appropriate lazy loading strategies
3. **Large Text Fields** - Consider separate tables for large content
4. **Archival Strategy** - Plan for data archival and cleanup

## Data Integrity

1. **Constraints** - Add database-level constraints where possible
2. **Validation** - Implement model-level validation methods
3. **Cascading** - Define proper cascade behavior for relationships
4. **Transaction Safety** - Ensure model operations are transaction-safe