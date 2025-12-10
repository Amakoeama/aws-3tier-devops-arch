#!/bin/bash
set -e


#---UPDATE SYSTEM & INSTALL DEPENDENCIES ---

yum update -y
amazon-linux-extras enable python3.8
yum install -y python3.8 python3.8-devel git
pip3 install --upgrade pip

#--- Install database libraries ---
pip3 install fastapi uvicorn psycopg2-binary SQLAlchemy python-dotenv


#--- SETUP APPLICATION DIRECTORY ---

mkdir -p /opt/app
cd /opt/app


#--- WRITE ENVIRONMENT VARIABLES ---

cat > .env <<EOF
DB_HOST="${db_host}"
DB_PORT="5432"
DB_NAME="postgres"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"
EOF


#--- WRITE THE FASTAPI APPLICATION ---

cat > main.py << 'EOF'
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
EOF


#--- CREATE SYSTEMD SERVICE ---

cat > /etc/systemd/system/fastapi.service <<EOF
[Unit]
Description=FastAPI Application
After=network.target

[Service]
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF


#--- START & ENABLE SERVICE ---

systemctl daemon-reload
systemctl enable fastapi
systemctl start fastapi
