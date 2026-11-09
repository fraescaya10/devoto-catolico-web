from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class Oracion(Base):
    __tablename__ = "oraciones"

    id: Mapped[int] = mapped_column(primary_key=True)
    slug: Mapped[str] = mapped_column(unique=True, index=True)
    titulo: Mapped[str]
    texto: Mapped[str]
