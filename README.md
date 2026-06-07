# Landing Page Homework (Standalone)

This folder is a standalone submission package for the landing page homework.
It is independent from the existing project code.

## Requirement Mapping

1. Frontend in React: `frontend/` (Vite + React)
2. Clear project introduction: Hero, features, and team section in `frontend/src/App.jsx`
3. Connected to backend and database: React calls Flask API, Flask uses SQLAlchemy + MySQL
4. Retrieve or insert data through landing page:
   - Retrieve users + board data: `GET /api/landing`
   - Insert inquiry as board post: `POST /api/contact`
5. Backend language/framework: Python + Flask

## Folder Structure

- `frontend/`: React landing page
- `backend/`: Flask API server + database models + SQL script

## Quick Start

### 1) Backend

```bash
cd landing_page_match/backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
```

Backend runs on `http://localhost:5002`.

### 2) Frontend

```bash
cd landing_page_match/frontend
npm install
npm run dev
```

Frontend runs on `http://localhost:5173` and calls backend API on port `5002`.

## Database (MySQL Only)

This standalone version is configured for MySQL only.
It uses the core landing tables: `users`, `clubs`, `club_board`, `club_promotion`.

1. Run `backend/schema_mysql.sql`.

This file creates tables and inserts sample seed data with SQL `INSERT` statements.

```sql
source landing_page_match/backend/schema_mysql.sql;
```

Submission setting: database name is `test`.

2. Create `backend/.env` from `backend/.env.example`, then update values if needed.

```bash
cd landing_page_match/backend
copy .env.example .env
```

3. Configure DB connection in `backend/.env`:

```text
DB_USER=root
DB_PASSWORD=your_password
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=test
```

Optional override:

```text
DATABASE_URL=mysql+pymysql://username:password@127.0.0.1:3306/test?charset=utf8mb4
```
