import os
from datetime import datetime
from pathlib import Path
from urllib.parse import quote_plus

from dotenv import load_dotenv
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from models import db, User, Club, ClubBoard, ClubPromotion

load_dotenv()

app = Flask(__name__)
CORS(app)

FRONTEND_DIST = (Path(__file__).resolve().parent.parent / "frontend" / "dist")

# MySQL-only configuration.
# It follows the same env variable style as the existing project.
db_user = quote_plus(os.getenv("DB_USER", "root"))
db_password = quote_plus(os.getenv("DB_PASSWORD", "password"))
db_host = os.getenv("DB_HOST", "127.0.0.1")
db_port = os.getenv("DB_PORT", "3306")
db_name = os.getenv("DB_NAME", "test")

database_url = os.getenv(
    "DATABASE_URL",
    f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}?charset=utf8mb4",
)
app.config["SQLALCHEMY_DATABASE_URI"] = database_url
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db.init_app(app)


def ensure_system_user() -> User:
    system_user = User.query.filter_by(user_id="landing_system").first()
    if system_user:
        return system_user

    now_token = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    system_user = User(
        user_id="landing_system",
        password="landing_system_pw",
        student_id=f"L{now_token}",
        name="Landing System",
        age=20,
        phone="N",
        grade=1,
        admission_year=2026,
        address="N",
        email="landing-system@example.com",
        belonging_club="N",
        off=0,
        role_level=0,
    )
    db.session.add(system_user)
    db.session.commit()
    return system_user


@app.route("/api/landing", methods=["GET"])
def get_landing_data():
    members = User.query.order_by(User.id.asc()).limit(6).all()
    clubs = Club.query.order_by(Club.name.asc()).all()
    latest_posts = (
        ClubBoard.query
        .filter(ClubBoard.is_public == 1)
        .order_by(ClubBoard.created_at.desc())
        .limit(5)
        .all()
    )
    promotion_posts = (
        ClubPromotion.query
        .order_by(ClubPromotion.created_at.desc())
        .limit(5)
        .all()
    )
    return jsonify(
        {
            "project": {
                "title": "ALL IN ONE Campus Club Platform",
                "description": "A unified platform for campus clubs: discovery, announcements, and collaboration.",
                "features": [
                    "Integrated club board and announcements",
                    "Simple account-based access",
                    "Club recruitment and communication support",
                ],
            },
            "team": [
                {
                    "id": member.id,
                    "name": member.name,
                    "role": f"Role Level {member.role_level}",
                    "major": member.belonging_club,
                }
                for member in members
            ],
            "clubs": [
                {
                    "id": club.id,
                    "name": club.name,
                }
                for club in clubs
            ],
            "latestPosts": [
                {
                    "id": post.id,
                    "title": post.title,
                    "club_name": post.club_name,
                    "author_name": post.author.name if post.author else "Unknown",
                    "is_public": post.is_public,
                    "is_notice": post.is_notice,
                    "post_type": post.post_type,
                    "created_at": post.created_at.strftime("%Y-%m-%d") if post.created_at else "",
                }
                for post in latest_posts
            ],
            "promotionPosts": [
                {
                    "id": post.id,
                    "title": post.title,
                    "club_name": post.club_name,
                    "author_name": post.author.name if post.author else "Unknown",
                    "created_at": post.created_at.strftime("%Y-%m-%d") if post.created_at else "",
                    "content": post.content,
                }
                for post in promotion_posts
            ],
        }
    )


@app.route("/api/contact", methods=["POST"])
def create_contact_message():
    payload = request.get_json(silent=True) or {}

    name = (payload.get("name") or "").strip()
    email = (payload.get("email") or "").strip()
    message = (payload.get("message") or "").strip()

    if not name or not email or not message:
        return jsonify({"error": "name, email, and message are required"}), 400

    system_user = ensure_system_user()

    post = ClubBoard(
        title=f"[랜딩 문의] {name}",
        content=f"email: {email}\n\n{message}",
        author_pk=system_user.id,
        club_name="공용게시판",
        is_public=0,
        is_notice=0,
        post_type="FREE",
    )
    db.session.add(post)
    db.session.commit()

    return jsonify({"message": "Contact message saved", "id": post.id}), 201


@app.route("/api/health", methods=["GET"])
def health_check():
    return jsonify({"status": "ok"})


@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def serve_frontend(path):
    # Keep API routes handled by dedicated endpoints.
    if path.startswith("api/"):
        return jsonify({"error": "API route not found"}), 404

    if not FRONTEND_DIST.exists():
        return jsonify({"error": "Frontend build not found. Run npm run build in frontend."}), 500

    if not path:
        return send_from_directory(FRONTEND_DIST, "index.html")

    target = FRONTEND_DIST / path
    if target.exists() and target.is_file():
        return send_from_directory(FRONTEND_DIST, path)

    return send_from_directory(FRONTEND_DIST, "index.html")


if __name__ == "__main__":
    is_reloader_main = os.environ.get("WERKZEUG_RUN_MAIN") == "true"
    if (not app.debug) or is_reloader_main:
        with app.app_context():
            db.create_all()

    port = int(os.getenv("PORT", "5002"))
    app.run(host="0.0.0.0", port=port, debug=True)
