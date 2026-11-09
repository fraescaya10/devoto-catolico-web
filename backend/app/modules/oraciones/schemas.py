from pydantic import BaseModel, ConfigDict


class OracionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    slug: str
    titulo: str
    texto: str
