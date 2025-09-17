import uvicorn
from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
from typing import List, Optional
import uuid

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
    displayName: Optional[str] = None

class UpdateUserProfile(BaseModel):
    name: Optional[str] = None
    college: Optional[str] = None
    course: Optional[str] = None
    codechef_username: Optional[str] = None
    leetcode_username: Optional[str] = None

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

# --- USER PROFILE ENDPOINTS ---
@app.post("/users")
def create_user_profile(user: User):
    try:
        user_ref = db.collection('users').document(user.uid)
        user_data = user.dict()
        user_ref.set(user_data)
        return {"message": f"User profile for {user.email} created successfully."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/users/{user_id}", response_model=UpdateUserProfile)
def get_user_profile(user_id: str):
    try:
        user_ref = db.collection('users').document(user_id)
        user_doc = user_ref.get()
        if user_doc.exists:
            return user_doc.to_dict()
        return {} # Return empty object if no profile data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/users/{user_id}")
def update_user_profile(user_id: str, profile_data: UpdateUserProfile):
    try:
        user_ref = db.collection('users').document(user_id)
        update_data = profile_data.dict(exclude_unset=True)
        
        if not update_data:
            raise HTTPException(status_code=400, detail="No update data provided.")
            
        # --- THE FIX IS HERE ---
        # Using .set() with merge=True is safer than .update()
        # It creates the document if it doesn't exist, and updates it if it does.
        user_ref.set(update_data, merge=True)
        
        return {"message": f"Profile for user {user_id} updated successfully."}
    except Exception as e:
        print(f"ERROR updating profile: {e}")
        raise HTTPException(status_code=500, detail="An internal error occurred.")


# --- SCHEDULE ENDPOINTS ---
@app.get("/schedule/{user_id}", response_model=List[ScheduledEvent])
def get_user_schedule(user_id: str):
    try:
        schedule_ref = db.collection('users').document(user_id).collection('schedule')
        docs = schedule_ref.stream()
        return [doc.to_dict() for doc in docs]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ... (Include all other POST, PUT endpoints for the schedule)
@app.post("/schedule/{user_id}", response_model=ScheduledEvent)
def add_schedule_event(user_id: str, event: CreateScheduledEvent):
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
    try:
        event_ref = db.collection('users').document(user_id).collection('schedule').document(event_id)
        event_ref.update({"isCompleted": True})
        return {"message": f"Event {event_id} marked as complete."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.put("/schedule/{user_id}/{event_id}/undo")
def undo_complete_schedule_event(user_id: str, event_id: str):
    try:
        event_ref = db.collection('users').document(user_id).collection('schedule').document(event_id)
        event_ref.update({"isCompleted": False})
        return {"message": f"Undo completion for event {event_id}."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))