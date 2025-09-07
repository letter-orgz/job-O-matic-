from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, Integer, String, Text, DateTime
from datetime import datetime

Base = declarative_base()


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
