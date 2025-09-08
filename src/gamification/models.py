"""Database models for the gamification system."""

from __future__ import annotations

from datetime import date, datetime
from pathlib import Path
from typing import Optional

from sqlmodel import SQLModel, Field, create_engine


class GamificationState(SQLModel, table=True):
    """Stores aggregate gamification statistics."""

    id: Optional[int] = Field(default=None, primary_key=True)
    xp: int = 0
    streak: int = 0
    last_application_date: Optional[date] = None


class Badge(SQLModel, table=True):
    """Badge definition unlocked at specific XP milestones."""

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    xp_threshold: int
    description: str = ""


class EarnedBadge(SQLModel, table=True):
    """Badge instances earned by the user."""

    id: Optional[int] = Field(default=None, primary_key=True)
    badge_id: int = Field(foreign_key="badge.id")
    earned_at: datetime = Field(default_factory=datetime.utcnow)
    image_path: str


class BoostCard(SQLModel, table=True):
    """Consumable boost card that temporarily alters XP gains."""

    id: Optional[int] = Field(default=None, primary_key=True)
    type: str = "double_xp"
    multiplier: float = 2.0
    duration_hours: int = 24
    active: bool = False
    expires_at: Optional[datetime] = None


def get_engine(path: Path) -> create_engine:
    """Create a SQLite engine pointing to *path*.

    Parameters
    ----------
    path:
        Location of the SQLite database file.
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    return create_engine(f"sqlite:///{path}", echo=False, connect_args={"check_same_thread": False})


__all__ = [
    "GamificationState",
    "Badge",
    "EarnedBadge",
    "BoostCard",
    "get_engine",
]
