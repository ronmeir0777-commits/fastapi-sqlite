FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# מתקינים את כלי sqlite3 כדי להריץ SQL טהור בזמן ריצה
RUN apt-get update && apt-get install -y --no-install-recommends \
    sqlite3 ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# תלותים (FastAPI + Uvicorn)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# נעתיק את כל קבצי הפרויקט (כולל main.py, services/, create.sql)
COPY . .

# בדיפלוי נגדיר DB_PATH=/data/app.db וה-PVC ימופה ל-/data
ENV DB_PATH=/data/app.db

EXPOSE 8080

# בזמן ריצה:
# 1) יצירת תיקיית ה-DB אם אינה קיימת
# 2) החלת הסכימה על קובץ ה-DB ב-PVC
# 3) הפעלת שרת ה-API (FastAPI) עם Uvicorn
CMD ["sh","-c","DBP=${DB_PATH:-/data/app.db}; DB_DIR=$(dirname $DBP); mkdir -p $DB_DIR; sqlite3 $DBP < /app/create.sql; exec uvicorn main:app --host 0.0.0.0 --port 8080"]
