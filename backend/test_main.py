from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient

# Mock das variáveis de ambiente antes de importar a aplicação FastAPI
with patch.dict("os.environ", {"AWS_REGION": "us-east-1", "DYNAMODB_TABLE": "filaflow-inventory"}):
    with patch("boto3.resource") as mock_boto:
        mock_table = MagicMock()
        mock_boto.return_value.Table.return_value = mock_table
        from main import app

client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "FilaFlow API is running"}


@patch("main.table")
def test_get_filamentos(mock_table):
    # Mock do retorno do DynamoDB scan
    mock_table.scan.return_value = {
        "Items": [
            {
                "id": "test-id-123",
                "cor": "Azul Cobalto",
                "material": "PLA",
                "marca": "Tecnocubo 3D",
                "peso_atual_gramas": 1000
            }
        ]
    }

    response = client.get("/filamentos")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 1
    assert data[0]["cor"] == "Azul Cobalto"
    assert data[0]["material"] == "PLA"


@patch("main.table")
def test_create_filament(mock_table):
    payload = {
        "cor": "Vermelho",
        "material": "PETG",
        "marca": "3D Lab",
        "peso_atual_gramas": 850
    }
    
    mock_table.put_item.return_value = {}

    response = client.post("/filamentos", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["cor"] == "Vermelho"
    assert data["material"] == "PETG"
    assert "id" in data
