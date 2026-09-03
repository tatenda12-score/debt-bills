from fastapi.testclient import TestClient

def get_auth_token(client: TestClient, email: str = "user@example.com"):
    client.post("/auth/register", json={"email": email, "password": "password123"})
    res = client.post("/auth/login", data={"username": email, "password": "password123"})
    return res.json()["access_token"]

def create_record(client: TestClient, token: str):
    res = client.post("/financial-records/", json={
        "direction": "I_OWE", "title": "Test", "amount": 10.0, "currency": "USD"
    }, headers={"Authorization": f"Bearer {token}"})
    return res.json()["id"]

def test_create_reminder(client: TestClient):
    token = get_auth_token(client)
    record_id = create_record(client, token)
    
    response = client.post(f"/financial-records/{record_id}/reminders", json={
        "days_before": 2, "notification_enabled": True
    }, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 201
    assert response.json()["days_before"] == 2

def test_cross_user_reminder_access(client: TestClient):
    token1 = get_auth_token(client, "user1@example.com")
    token2 = get_auth_token(client, "user2@example.com")
    
    record_id = create_record(client, token1)
    
    # User 2 attempts to create a reminder for User 1's record
    res = client.post(f"/financial-records/{record_id}/reminders", json={
        "days_before": 1
    }, headers={"Authorization": f"Bearer {token2}"})
    assert res.status_code == 404
