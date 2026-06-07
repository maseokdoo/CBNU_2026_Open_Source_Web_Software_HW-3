CREATE DATABASE IF NOT EXISTS test
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE test;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  student_id VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(50) NOT NULL,
  age INT NOT NULL DEFAULT 0,
  phone VARCHAR(20) NOT NULL DEFAULT 'N',
  grade INT NOT NULL,
  admission_year INT NOT NULL DEFAULT 0,
  address VARCHAR(255) NOT NULL DEFAULT 'N',
  email VARCHAR(255) NOT NULL DEFAULT 'N',
  belonging_club VARCHAR(50) NOT NULL DEFAULT 'N',
  off INT NOT NULL DEFAULT 0,
  role_level INT NOT NULL DEFAULT 0,
  CONSTRAINT check_valid_club_member
    CHECK ((role_level < 10) OR (belonging_club <> 'N'))
);

CREATE TABLE IF NOT EXISTS clubs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  post_types_json TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS club_board (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  content TEXT NOT NULL,
  author_pk INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  club_name VARCHAR(50) NOT NULL,
  is_public INT NOT NULL DEFAULT 0,
  is_notice INT NOT NULL DEFAULT 0,
  post_type VARCHAR(20) NOT NULL DEFAULT '',
  CONSTRAINT fk_club_board_author FOREIGN KEY (author_pk) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS club_promotion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  content TEXT NOT NULL,
  author_pk INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  club_name VARCHAR(50) NOT NULL,
  CONSTRAINT fk_club_promotion_author FOREIGN KEY (author_pk) REFERENCES users(id)
);

INSERT INTO users (
  user_id, password, student_id, name, age, phone, grade, admission_year,
  address, email, belonging_club, off, role_level
) VALUES
('admin_e','1234','20210001','김이엠',24,'010-1111-0001',3,2021,'천안시','admin_e@test.com','EMSYS',0,30),
('member_e1','1234','20220001','이부원',23,'010-1111-0002',2,2022,'아산시','e1@test.com','EMSYS',0,10),
('member_e2','1234','20220002','박부원',23,'010-1111-0003',2,2022,'아산시','e2@test.com','EMSYS',0,10),
('member_e3','1234','20230001','최부원',22,'010-1111-0004',1,2023,'천안시','e3@test.com','EMSYS',0,10),
('member_e4','1234','20230002','정부원',22,'010-1111-0005',1,2023,'서울시','e4@test.com','EMSYS',0,10),
('admin_r','1234','20210002','김알씨',24,'010-2222-0001',3,2021,'아산시','admin_r@test.com','CUVIC',0,30),
('member_r1','1234','20220003','강부원',23,'010-2222-0002',2,2022,'수원시','r1@test.com','CUVIC',0,10),
('member_r2','1234','20220004','조부원',23,'010-2222-0003',2,2022,'아산시','r2@test.com','CUVIC',0,10),
('member_r3','1234','20230003','윤부원',22,'010-2222-0004',1,2023,'천안시','r3@test.com','CUVIC',0,10),
('member_r4','1234','20230004','장부원',22,'010-2222-0005',1,2023,'서울시','r4@test.com','CUVIC',0,10),
('admin_g','1234','20210003','김지디',24,'010-3333-0001',3,2021,'천안시','admin_g@test.com','NOVA',0,30),
('member_g1','1234','20220005','임부원',23,'010-3333-0002',2,2022,'아산시','g1@test.com','NOVA',0,10),
('member_g2','1234','20220006','한부원',23,'010-3333-0003',2,2022,'평택시','g2@test.com','NOVA',0,10),
('member_g3','1234','20230005','오부원',22,'010-3333-0004',1,2023,'천안시','g3@test.com','NOVA',0,10),
('member_g4','1234','20230006','서부원',22,'010-3333-0005',1,2023,'서울시','g4@test.com','NOVA',0,10),
('guest_1','1234','20240001','신입일',20,'010-9999-0001',1,2024,'아산시','guest1@test.com','N',0,0),
('guest_2','1234','20240002','신입이',20,'010-9999-0002',1,2024,'아산시','guest2@test.com','N',0,0),
('guest_3','1234','20240003','신입삼',20,'010-9999-0003',1,2024,'천안시','guest3@test.com','N',0,0),
('admin_40','1234','20200001','총관리자',26,'010-4444-0001',4,2020,'서울시','admin40@test.com','EMSYS',0,40)
ON DUPLICATE KEY UPDATE
  password = VALUES(password),
  name = VALUES(name),
  age = VALUES(age),
  phone = VALUES(phone),
  grade = VALUES(grade),
  admission_year = VALUES(admission_year),
  address = VALUES(address),
  email = VALUES(email),
  belonging_club = VALUES(belonging_club),
  off = VALUES(off),
  role_level = VALUES(role_level);

INSERT INTO clubs (name, post_types_json) VALUES
('EMSYS','["스터디"]'),
('CUVIC','["프로젝트"]'),
('NOVA','["질문"]')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  post_types_json = VALUES(post_types_json);

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'EMSYS 내부 공지',
  'EMSYS 동아리 내부 공지입니다.',
  u.id,
  '2026-06-01 09:00:00',
  'EMSYS',
  0,
  1,
  ''
FROM users u
WHERE u.user_id = 'admin_e'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'EMSYS 내부 공지'
      AND b.club_name = 'EMSYS'
  );

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'EMSYS 공개 안내',
  'EMSYS 외부 공개 가능한 안내입니다.',
  u.id,
  '2026-06-01 11:00:00',
  'EMSYS',
  1,
  0,
  ''
FROM users u
WHERE u.user_id = 'member_e1'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'EMSYS 공개 안내'
      AND b.club_name = 'EMSYS'
  );

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'EMSYS 스터디 모집',
  'EMSYS 스터디 모집 글입니다.',
  u.id,
  '2026-06-01 12:00:00',
  'EMSYS',
  1,
  0,
  '스터디'
FROM users u
WHERE u.user_id = 'member_e2'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'EMSYS 스터디 모집'
      AND b.club_name = 'EMSYS'
  );

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'CUVIC 내부 공지',
  'CUVIC 동아리 내부 공지입니다.',
  u.id,
  '2026-06-02 09:00:00',
  'CUVIC',
  0,
  1,
  ''
FROM users u
WHERE u.user_id = 'admin_r'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'CUVIC 내부 공지'
      AND b.club_name = 'CUVIC'
  );

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'CUVIC 공개 안내',
  'CUVIC 외부 공개 가능한 안내입니다.',
  u.id,
  '2026-06-02 11:00:00',
  'CUVIC',
  1,
  0,
  ''
FROM users u
WHERE u.user_id = 'member_r1'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'CUVIC 공개 안내'
      AND b.club_name = 'CUVIC'
  );

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'CUVIC 프로젝트 소개',
  'CUVIC 프로젝트 소개 글입니다.',
  u.id,
  '2026-06-02 12:00:00',
  'CUVIC',
  1,
  0,
  '프로젝트'
FROM users u
WHERE u.user_id = 'member_r2'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'CUVIC 프로젝트 소개'
      AND b.club_name = 'CUVIC'
  );

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'NOVA 내부 공지',
  'NOVA 동아리 내부 공지입니다.',
  u.id,
  '2026-06-03 09:00:00',
  'NOVA',
  0,
  1,
  ''
FROM users u
WHERE u.user_id = 'admin_g'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'NOVA 내부 공지'
      AND b.club_name = 'NOVA'
  );

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'NOVA 공개 안내',
  'NOVA 외부 공개 가능한 안내입니다.',
  u.id,
  '2026-06-03 11:00:00',
  'NOVA',
  1,
  0,
  ''
FROM users u
WHERE u.user_id = 'member_g1'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'NOVA 공개 안내'
      AND b.club_name = 'NOVA'
  );

INSERT INTO club_board (title, content, author_pk, created_at, club_name, is_public, is_notice, post_type)
SELECT
  'NOVA 질문 답변',
  'NOVA 질문 답변 글입니다.',
  u.id,
  '2026-06-03 12:00:00',
  'NOVA',
  1,
  0,
  '질문'
FROM users u
WHERE u.user_id = 'member_g2'
  AND NOT EXISTS (
    SELECT 1 FROM club_board b
    WHERE b.title = 'NOVA 질문 답변'
      AND b.club_name = 'NOVA'
  );

INSERT INTO club_promotion (title, content, author_pk, created_at, club_name)
SELECT
  'EMSYS 홍보: 임베디드 스터디 모집',
  'EMSYS에서 임베디드 기초 스터디 팀원을 모집합니다.',
  u.id,
  '2026-06-04 10:30:00',
  'EMSYS'
FROM users u
WHERE u.user_id = 'admin_e'
  AND NOT EXISTS (
    SELECT 1 FROM club_promotion p
    WHERE p.title = 'EMSYS 홍보: 임베디드 스터디 모집'
      AND p.club_name = 'EMSYS'
  );

INSERT INTO club_promotion (title, content, author_pk, created_at, club_name)
SELECT
  'CUVIC 홍보: 자율주행 프로젝트 설명회',
  'CUVIC에서 자율주행 프로젝트 설명회를 진행합니다.',
  u.id,
  '2026-06-04 11:00:00',
  'CUVIC'
FROM users u
WHERE u.user_id = 'admin_r'
  AND NOT EXISTS (
    SELECT 1 FROM club_promotion p
    WHERE p.title = 'CUVIC 홍보: 자율주행 프로젝트 설명회'
      AND p.club_name = 'CUVIC'
  );

INSERT INTO club_promotion (title, content, author_pk, created_at, club_name)
SELECT
  'NOVA 홍보: 앱 개발 세션 오픈',
  'NOVA 앱 개발 세션이 이번 주 금요일에 열립니다.',
  u.id,
  '2026-06-04 11:30:00',
  'NOVA'
FROM users u
WHERE u.user_id = 'admin_g'
  AND NOT EXISTS (
    SELECT 1 FROM club_promotion p
    WHERE p.title = 'NOVA 홍보: 앱 개발 세션 오픈'
      AND p.club_name = 'NOVA'
  );
