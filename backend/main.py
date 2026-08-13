import os
import uuid
from typing import List
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
import boto3
from botocore.exceptions import BotoCoreError, ClientError

app = FastAPI(
    title="FilaFlow API",
    description="API para gerenciamento e controle do inventário de filamentos 3D",
    version="1.0.0"
)

# Configuração do DynamoDB
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE", "filaflow-inventory")

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)


class FilamentCreate(BaseModel):
    cor: str = Field(..., example="Azul Cobalto")
    material: str = Field(..., example="PLA")  # Exemplos: PLA, PETG, ABS
    marca: str = Field(..., example="Tecnocubo 3D")  # Exemplos: Tecnocubo 3D, 3D Lab
    peso_atual_gramas: int = Field(..., example=1000, ge=0)


class Filament(FilamentCreate):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()), example="550e8400-e29b-41d4-a716-446655440000")


@app.get("/")
def read_root():
    return {"message": "FilaFlow API is running"}


@app.post("/filamentos", response_model=Filament, status_code=status.HTTP_201_CREATED)
def create_filament(filament_input: FilamentCreate):
    try:
        filament_data = filament_input.dict()
        filament_id = str(uuid.uuid4())
        
        item = {
            "id": filament_id,
            "cor": filament_data["cor"],
            "material": filament_data["material"],
            "marca": filament_data["marca"],
            "peso_atual_gramas": int(filament_data["peso_atual_gramas"])
        }
        
        table.put_item(Item=item)
        return item
    except (BotoCoreError, ClientError) as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao salvar item no DynamoDB: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro interno no servidor: {str(e)}"
        )


@app.get("/filamentos", response_model=List[Filament])
def get_filaments():
    try:
        response = table.scan()
        items = response.get("Items", [])
        
        # Converte tipos numéricos do DynamoDB (Decimal) para int caso necessário
        for item in items:
            if "peso_atual_gramas" in item:
                item["peso_atual_gramas"] = int(item["peso_atual_gramas"])
                
        return items
    except (BotoCoreError, ClientError) as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao consultar itens no DynamoDB: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro interno no servidor: {str(e)}"
        )
