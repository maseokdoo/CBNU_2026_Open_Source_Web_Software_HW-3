from datetime import datetime

from flask_sqlalchemy import SQLAlchemy


db = SQLAlchemy()


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    student_id = db.Column(db.String(20), unique=True, nullable=False)
    name = db.Column(db.String(50), nullable=False)
    age = db.Column(db.Integer, default=0, nullable=False)
    phone = db.Column(db.String(20), default="N", nullable=False)
    grade = db.Column(db.Integer, nullable=False)
    admission_year = db.Column(db.Integer, default=0, nullable=False)
    address = db.Column(db.String(255), default="N", nullable=False)
    email = db.Column(db.String(255), default="N", nullable=False)
    belonging_club = db.Column(db.String(50), default="N", nullable=False)
    off = db.Column(db.Integer, default=0, nullable=False)
    role_level = db.Column(db.Integer, default=0, nullable=False)


class Club(db.Model):
    __tablename__ = "clubs"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    post_types_json = db.Column(db.Text, nullable=False)


class ClubBoard(db.Model):
    __tablename__ = "club_board"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    title = db.Column(db.String(150), nullable=False)
    content = db.Column(db.Text, nullable=False)
    author_pk = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    club_name = db.Column(db.String(50), nullable=False)
    is_public = db.Column(db.Integer, default=0, nullable=False)
    is_notice = db.Column(db.Integer, default=0, nullable=False)
    post_type = db.Column(db.String(20), default="", nullable=False)

    author = db.relationship("User", backref=db.backref("posts", lazy=True))


class ClubPromotion(db.Model):
    __tablename__ = "club_promotion"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    title = db.Column(db.String(150), nullable=False)
    content = db.Column(db.Text, nullable=False)
    author_pk = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    club_name = db.Column(db.String(50), nullable=False)

    author = db.relationship("User", backref=db.backref("promotions", lazy=True))
