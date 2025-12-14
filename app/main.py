import os
import uvicorn
from sqlalchemy import text
from typing import Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Text
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv


#--- Load environment variables ---

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD")

DATABASE_URL = (
    f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


#--- SQLAlchemy setup ---

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


#--- ORM Model ---

class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    author = Column(String(100), nullable=True)
    content = Column(Text, nullable=False)

#--- Auto-create table ---
Base.metadata.create_all(bind=engine)


#--- FastAPI setup ---

app = FastAPI()

class MessageCreate(BaseModel):
    author: Optional[str] = None
    content: str


#--- Health Check ---

@app.get("/")
def root():
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        return {"status": "ok", "message": "Hello Amakoe, the EC2 instance reached PostgreSQL successfully"}
    except Exception as e:
        return {"status": "error", "details": str(e)}


#--- Add Message ---

@app.post("/messages/add")
def add_message(message: MessageCreate):
    db = SessionLocal()
    try:
        msg = Message(content=message.content, author=message.author)
        db.add(msg)
        db.commit()
        db.refresh(msg)
        return {"status": "success", "id": msg.id}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()


#--- Get All Messages ---

@app.get("/messages/all")
def get_messages():
    db = SessionLocal()
    try:
        msgs = db.query(Message).all()
        return [
            {"id": m.id, "author": m.author, "content": m.content}
            for m in msgs
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()


#--- Run App ---

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)