"""
LLM DevOps Orchestrator - Version Simple et Fonctionnelle
Objectif: 1 service qui marche vraiment
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime
import sqlite3
import json
import os
from typing import Optional, Dict, Any

# Configuration simple
DATABASE_PATH = os.getenv("DATABASE_URL", "llm_orchestrator.db")
API_KEY = os.getenv("API_KEY", "demo-key-12345")
PORT = int(os.getenv("PORT", 8000))

app = FastAPI(
    title="LLM DevOps Orchestrator",
    description="Automatisation DevOps simple et efficace",
    version="1.0.0"
)

# Modèles simples
class Task(BaseModel):
    name: str
    type: str  # "deploy", "test", "monitor"
    config: Optional[Dict[str, Any]] = {}

class TaskResponse(BaseModel):
    task_id: str
    status: str
    created_at: str
    message: str

# Database simple
def init_db():
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            status TEXT DEFAULT 'pending',
            config TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

# Endpoints essentiels
@app.on_event("startup")
async def startup():
    init_db()
    print(f"[OK] Database initialized at {DATABASE_PATH}")

@app.get("/")
def root():
    return {
        "name": "LLM DevOps Orchestrator",
        "status": "operational",
        "endpoints": [
            "/health",
            "/api/v1/tasks",
            "/api/v1/tasks/{task_id}",
            "/docs"
        ]
    }

@app.get("/health")
def health_check():
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM tasks")
        task_count = cursor.fetchone()[0]
        conn.close()
        
        return {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "database": "connected",
            "task_count": task_count
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))

@app.post("/api/v1/tasks", response_model=TaskResponse)
def create_task(task: Task, api_key: str = None):
    # Simple API key check
    if api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")
    
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO tasks (name, type, config, status)
            VALUES (?, ?, ?, 'pending')
        """, (task.name, task.type, json.dumps(task.config)))
        
        task_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return TaskResponse(
            task_id=str(task_id),
            status="created",
            created_at=datetime.now().isoformat(),
            message=f"Task '{task.name}' created successfully"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/tasks/{task_id}")
def get_task(task_id: int):
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT id, name, type, status, config, created_at
            FROM tasks WHERE id = ?
        """, (task_id,))
        
        row = cursor.fetchone()
        conn.close()
        
        if not row:
            raise HTTPException(status_code=404, detail="Task not found")
        
        return {
            "id": row[0],
            "name": row[1],
            "type": row[2],
            "status": row[3],
            "config": json.loads(row[4]) if row[4] else {},
            "created_at": row[5]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/tasks")
def list_tasks(limit: int = 10):
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT id, name, type, status, created_at
            FROM tasks
            ORDER BY created_at DESC
            LIMIT ?
        """, (limit,))
        
        tasks = []
        for row in cursor.fetchall():
            tasks.append({
                "id": row[0],
                "name": row[1],
                "type": row[2],
                "status": row[3],
                "created_at": row[4]
            })
        
        conn.close()
        return {"tasks": tasks, "count": len(tasks)}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Pour lancer: uvicorn app_simple:app --reload --port 8000