from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.oraciones import service
from app.modules.oraciones.schemas import OracionOut

router = APIRouter(prefix="/public/oraciones", tags=["oraciones"])
SessionDep = Annotated[AsyncSession, Depends(get_session)]


@router.get("", response_model=list[OracionOut])
async def listar(session: SessionDep) -> list[OracionOut]:
    return [OracionOut.model_validate(o) for o in await service.listar(session)]


@router.get("/{slug}", response_model=OracionOut)
async def obtener(slug: str, session: SessionDep) -> OracionOut:
    try:
        return OracionOut.model_validate(await service.obtener(session, slug))
    except service.OracionNoEncontrada:
        raise HTTPException(status_code=404, detail="Oración no encontrada") from None
