import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import uuid # To generate unique IDs for new tasks

import firebase_admin
from firebase_admin import credentials, firestore

# --- App Initialization ---
app = FastAPI()
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


# --- Data Models ---
class User(BaseModel):
    uid: str
    email: str
    displayName: str | None = None

class ScheduledEvent(BaseModel):
    id: str
    subject: str
    startTime: str
    endTime: str
    color: str
    location: str
    isCompleted: bool

class CreateScheduledEvent(BaseModel):
    subject: str
    startTime: str
    endTime: str
    color: str
    location: str


# --- API Endpoints ---
@app.get("/")
def read_root():
    return {"message": "Welcome to the Chela API 🧠"}

@app.post("/users")
def create_user_profile(user: User):
    try:
        user_ref = db.collection('users').document(user.uid)
        user_ref.set(user.dict())
        return {"message": f"User profile for {user.email} created successfully."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- FULL CRUD FOR SCHEDULE ---

@app.get("/schedule/{user_id}", response_model=List[ScheduledEvent])
def get_user_schedule(user_id: str):
    """Fetches all schedule events for a given user from Firestore."""
    try:
        schedule_ref = db.collection('users').document(user_id).collection('schedule')
        docs = schedule_ref.stream()
        schedule_list = [doc.to_dict() for doc in docs]
        return schedule_list
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/schedule/{user_id}", response_model=ScheduledEvent)
def add_schedule_event(user_id: str, event: CreateScheduledEvent):
    """Adds a new event to a user's schedule in Firestore."""
    try:
        schedule_ref = db.collection('users').document(user_id).collection('schedule')
        new_event_id = str(uuid.uuid4())
        
        full_event_data = event.dict()
        full_event_data['id'] = new_event_id
        full_event_data['isCompleted'] = False
        
        schedule_ref.document(new_event_id).set(full_event_data)
        return full_event_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.put("/schedule/{user_id}/{event_id}/complete")
def complete_schedule_event(user_id: str, event_id: str):
    """Marks an event as completed in Firestore."""
    try:
        event_ref = db.collection('users').document(user_id).collection('schedule').document(event_id)
        event_ref.update({"isCompleted": True})
        return {"message": f"Event {event_id} marked as complete."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.put("/schedule/{user_id}/{event_id}/undo")
def undo_complete_schedule_event(user_id: str, event_id: str):
    """Marks an event as not completed (for the Undo action)."""
    try:
        event_ref = db.collection('users').document(user_id).collection('schedule').document(event_id)
        event_ref.update({"isCompleted": False})
        return {"message": f"Undo completion for event {event_id}."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))