from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.oraciones import repository
from app.modules.oraciones.models import Oracion


class OracionNoEncontrada(Exception):
    """El slug pedido no existe."""


async def listar(session: AsyncSession) -> list[Oracion]:
    return await repository.list_all(session)


async def obtener(session: AsyncSession, slug: str) -> Oracion:
    oracion = await repository.get_by_slug(session, slug)
    if oracion is None:
        raise OracionNoEncontrada(slug)
    return oracion
