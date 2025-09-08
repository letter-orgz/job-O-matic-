from datetime import datetime, timedelta
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).resolve().parents[1]))

from sqlmodel import Session, select

from src.gamification import (
    get_engine,
    init_db,
    record_application,
    activate_boost,
    available_boost_cards,
    get_state,
    EarnedBadge,
)


def setup_engine(tmp_path: Path):
    engine = get_engine(tmp_path / "game.db")
    init_db(engine)
    return engine


def test_xp_and_streak(tmp_path: Path) -> None:
    engine = setup_engine(tmp_path)
    day1 = datetime(2024, 1, 1, 12)
    record_application(engine, "low", now=day1)
    record_application(engine, "low", now=day1 + timedelta(days=1))
    with Session(engine) as session:
        state = get_state(session)
    assert state.xp == 20
    assert state.streak == 2


def test_badge_unlock_and_image(tmp_path: Path) -> None:
    engine = setup_engine(tmp_path)
    day = datetime(2024, 1, 1, 12)
    for i in range(10):
        record_application(engine, "high", now=day + timedelta(days=i))
    with Session(engine) as session:
        state = get_state(session)
        assert state.xp >= 300
        badges = session.exec(select(EarnedBadge)).all()
    badge_path = Path("data/badges/rookie.png")
    assert len(badges) == 1
    assert badge_path.exists()


def test_boost_card_doubles_xp(tmp_path: Path) -> None:
    engine = setup_engine(tmp_path)
    with Session(engine) as session:
        card = available_boost_cards(session)[0]
    start = datetime(2024, 1, 1, 12)
    activate_boost(engine, card.id, now=start)
    record_application(engine, "low", now=start + timedelta(hours=1))
    with Session(engine) as session:
        state = get_state(session)
    assert state.xp == 20

