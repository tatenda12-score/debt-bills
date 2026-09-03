from fastapi.testclient import TestClient

def test_register_user(client: TestClient):
    response = client.post(
        "/auth/register",
        json={"email": "test@example.com", "password": "password123", "full_name": "Test User"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data

def test_register_duplicate_email(client: TestClient):
    client.post("/auth/register", json={"email": "test2@example.com", "password": "password123"})
    response = client.post("/auth/register", json={"email": "test2@example.com", "password": "password123"})
    assert response.status_code == 400

def test_login_user(client: TestClient):
    client.post("/auth/register", json={"email": "test3@example.com", "password": "password123"})
    response = client.post("/auth/login", data={"username": "test3@example.com", "password": "password123"})
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data

def test_read_user_me(client: TestClient):
    client.post("/auth/register", json={"email": "test4@example.com", "password": "password123"})
    login_res = client.post("/auth/login", data={"username": "test4@example.com", "password": "password123"})
    token = login_res.json()["access_token"]
    
    response = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["email"] == "test4@example.com"
