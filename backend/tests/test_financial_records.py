from fastapi.testclient import TestClient

def get_auth_token(client: TestClient, email: str = "user@example.com"):
    client.post("/auth/register", json={"email": email, "password": "password123"})
    res = client.post("/auth/login", data={"username": email, "password": "password123"})
    return res.json()["access_token"]

def test_create_financial_record(client: TestClient):
    token = get_auth_token(client)
    payload = {
        "direction": "I_OWE",
        "title": "Rent",
        "amount": 500.0,
        "currency": "USD"
    }
    response = client.post("/financial-records/", json=payload, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Rent"

def test_read_own_records(client: TestClient):
    token = get_auth_token(client)
    payload = {"direction": "OWED_TO_ME", "title": "Loan", "amount": 100.0, "currency": "USD"}
    client.post("/financial-records/", json=payload, headers={"Authorization": f"Bearer {token}"})
    
    response = client.get("/financial-records/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert len(response.json()) == 1

def test_cross_user_record_access(client: TestClient):
    token1 = get_auth_token(client, "user1@example.com")
    token2 = get_auth_token(client, "user2@example.com")
    
    # User 1 creates record
    res = client.post("/financial-records/", json={
        "direction": "I_OWE", "title": "Debt", "amount": 50.0, "currency": "USD"
    }, headers={"Authorization": f"Bearer {token1}"})
    record_id = res.json()["id"]
    
    # User 2 tries to access User 1's record
    response = client.get(f"/financial-records/{record_id}", headers={"Authorization": f"Bearer {token2}"})
    assert response.status_code == 404
