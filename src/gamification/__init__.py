"""Gamification package for Job-O-Matic."""

from .models import (
    GamificationState,
    Badge,
    EarnedBadge,
    BoostCard,
    get_engine,
)
from .service import (
    init_db,
    record_application,
    activate_boost,
    available_boost_cards,
    active_boost,
    get_state,
    get_earned_badges,
)

__all__ = [
    "GamificationState",
    "Badge",
    "EarnedBadge",
    "BoostCard",
    "get_engine",
    "init_db",
    "record_application",
    "activate_boost",
    "available_boost_cards",
    "active_boost",
    "get_state",
    "get_earned_badges",
]
