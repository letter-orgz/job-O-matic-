"""Service layer for gamification operations."""

from __future__ import annotations

from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Optional

from PIL import Image, ImageDraw
from sqlmodel import Session, select

from .models import (
    GamificationState,
    Badge,
    EarnedBadge,
    BoostCard,
)

EFFORT_XP = {"low": 10, "medium": 20, "high": 30}
DEFAULT_BADGES = [
    ("Rookie", 100),
    ("Intermediate", 500),
    ("Expert", 1000),
]
BADGE_DIR = Path("data/badges")


def init_db(engine) -> None:
    """Initialise database and default records."""
    from sqlmodel import SQLModel

    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        state = session.get(GamificationState, 1)
        if not state:
            session.add(GamificationState(id=1, xp=0, streak=0))
        if not session.exec(select(Badge)).first():
            for name, xp in DEFAULT_BADGES:
                session.add(Badge(name=name, xp_threshold=xp, description=f"Unlock at {xp} XP"))
        if not session.exec(select(BoostCard)).first():
            session.add(BoostCard())  # default double XP card
        session.commit()


def get_state(session: Session) -> GamificationState:
    """Return the single gamification state record."""
    state = session.get(GamificationState, 1)
    if not state:
        state = GamificationState(id=1, xp=0, streak=0)
        session.add(state)
        session.commit()
    return state


def available_boost_cards(session: Session) -> List[BoostCard]:
    """Return non-active boost cards."""
    return list(session.exec(select(BoostCard).where(BoostCard.active == False)))


def active_boost(session: Session, now: Optional[datetime] = None) -> Optional[BoostCard]:
    """Return active boost card if one is valid."""
    now = now or datetime.utcnow()
    boost = session.exec(select(BoostCard).where(BoostCard.active == True)).first()
    if boost and boost.expires_at and boost.expires_at < now:
        boost.active = False
        boost.expires_at = None
        session.add(boost)
        session.commit()
        return None
    return boost


def activate_boost(engine, card_id: int, now: Optional[datetime] = None) -> None:
    """Activate the boost card with *card_id*."""
    now = now or datetime.utcnow()
    with Session(engine) as session:
        card = session.get(BoostCard, card_id)
        if card and not card.active:
            card.active = True
            card.expires_at = now + timedelta(hours=card.duration_hours)
            session.add(card)
            session.commit()


def _current_multiplier(session: Session, now: Optional[datetime] = None) -> float:
    now = now or datetime.utcnow()
    boost = active_boost(session, now)
    return boost.multiplier if boost else 1.0


def record_application(engine, effort: str, now: Optional[datetime] = None) -> List[EarnedBadge]:
    """Record an application and update gamification state.

    Parameters
    ----------
    engine:
        SQLModel engine.
    effort:
        Effort level: ``"low"``, ``"medium"`` or ``"high"``.
    now:
        Override timestamp mainly for testing.
    """
    now = now or datetime.utcnow()
    effort = effort.lower()
    if effort not in EFFORT_XP:
        raise ValueError("Unknown effort level")

    with Session(engine) as session:
        state = get_state(session)
        multiplier = _current_multiplier(session, now)
        gained = int(EFFORT_XP[effort] * multiplier)
        state.xp += gained

        today = now.date()
        if state.last_application_date == today:
            pass
        elif state.last_application_date == today - timedelta(days=1):
            state.streak += 1
        else:
            state.streak = 1
        state.last_application_date = today
        session.add(state)

        earned: List[EarnedBadge] = []
        unlocked = session.exec(select(Badge).where(Badge.xp_threshold <= state.xp)).all()
        for badge in unlocked:
            exists = session.exec(
                select(EarnedBadge).where(EarnedBadge.badge_id == badge.id)
            ).first()
            if not exists:
                image_path = _create_badge_image(badge)
                earned_badge = EarnedBadge(badge_id=badge.id, image_path=str(image_path))
                session.add(earned_badge)
                earned.append(earned_badge)
        session.commit()
        return earned


def _create_badge_image(badge: Badge) -> Path:
    """Generate a PNG for *badge* and return the file path."""
    BADGE_DIR.mkdir(parents=True, exist_ok=True)
    path = BADGE_DIR / f"{badge.name.replace(' ', '_').lower()}.png"
    img = Image.new("RGB", (400, 200), "white")
    draw = ImageDraw.Draw(img)
    text = f"{badge.name}\n{badge.xp_threshold} XP"
    draw.text((200, 100), text, fill="black", anchor="mm")
    img.save(path)
    return path


def get_earned_badges(session: Session) -> List[EarnedBadge]:
    """Return list of earned badges."""
    return list(session.exec(select(EarnedBadge)))
