import os
import sqlite3

class DataLoader:
    def __init__(self, db_path: str | None = None):
        # נקבל את מיקום ה-DB מהסביבה (בדיפלוי נגדיר DB_PATH=/data/app.db)
        self.db_path = db_path or os.getenv("DB_PATH", "/data/app.db")

    def get_all_data(self):
        # קורא את כל הרשומות מהטבלה items
        with sqlite3.connect(self.db_path, timeout=30) as conn:
            conn.row_factory = sqlite3.Row
            rows = conn.execute(
                "SELECT id, name, created_at FROM items ORDER BY id DESC"
            ).fetchall()
            return [dict(r) for r in rows]
