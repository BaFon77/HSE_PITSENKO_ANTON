-- =======================================
-- CLEAN TABLES
-- =======================================
TRUNCATE TABLE award CASCADE;
TRUNCATE TABLE player_game_stats CASCADE;
TRUNCATE TABLE match_game CASCADE;
TRUNCATE TABLE match CASCADE;
TRUNCATE TABLE tournament_registration CASCADE;
TRUNCATE TABLE prize CASCADE;
TRUNCATE TABLE team_member CASCADE;
TRUNCATE TABLE player_rating_history CASCADE;
TRUNCATE TABLE team_rating_history CASCADE;
TRUNCATE TABLE player CASCADE;
TRUNCATE TABLE team CASCADE;
TRUNCATE TABLE discipline CASCADE;
TRUNCATE TABLE tournament CASCADE;

-- =======================================
-- TEAMS
-- =======================================
INSERT INTO team (name, created_at, team_rating) VALUES
('Spirit', '2025-01-01', 1850),
('Vitality', '2025-01-01', 1900),
('FaZe', '2025-01-01', 1800),
('MOUZ', '2025-01-01', 1750);

-- =======================================
-- PLAYERS
-- =======================================
INSERT INTO player (full_name, nickname, email, game_account, level, rating) VALUES
('Leonid Vishnyakov', 'chopper', 'chopper@cs2mail.com', 'chopper_steam', 9, 1800),
('Danil Kryshkovets', 'donk', 'donk@cs2mail.com', 'donk_steam', 10, 1950),
('Dmitriy Sokolov', 'sh1ro', 'sh1ro@cs2mail.com', 'sh1ro_steam', 10, 1900),
('Ivan Gogin', 'zweih', 'zweih@cs2mail.com', 'zweih_steam', 8, 1820),
('Andrey Tatarinovich', 'tN1R', 'tn1r@cs2mail.com', 'tn1r_steam', 9, 1920),
('Dan Madesclaire', 'apEX', 'apex@cs2mail.com', 'apEX_steam', 9, 1920),
('Mathieu Herbaut', 'ZywOo', 'zywoo@cs2mail.com', 'ZywOo_steam', 10, 2000),
('Robin Kool', 'ropz', 'ropz@cs2mail.com', 'ropz_steam', 9, 1880),
('Shahar Shushan', 'flameZ', 'flameZ@cs2mail.com', 'flameZ_steam', 8, 1800),
('William Merriman', 'mezii', 'mezii@cs2mail.com', 'mezii_steam', 8, 1780),
('Finn Andersen', 'karrigan', 'karrigan@cs2mail.com', 'karrigan_steam', 9, 1870),
('Havard Nygaard', 'rain', 'rain@cs2mail.com', 'rain_steam', 8, 1800),
('David Cernansky', 'frozen', 'frozen@cs2mail.com', 'frozen_steam', 8, 1770),
('Helvijs Saukants', 'broky', 'broky@cs2mail.com', 'broky_steam', 9, 1900),
('Jonathan Jablonowski', 'EliGE', 'elige@cs2mail.com', 'EliGE_steam', 10, 1930),
('Ludvig Brolin', 'Brollan', 'brollan@cs2mail.com', 'Brollan_steam', 8, 1800),
('Adam Torzsas', 'torzsi', 'torzsi@cs2mail.com', 'torzsi_steam', 8, 1750),
('Dorian Berman', 'xertioN', 'xertioN@cs2mail.com', 'xertioN_steam', 8, 1780),
('Jimi Salo', 'Jimpphat', 'jimpphat@cs2mail.com', 'Jimpphat_steam', 7, 1700),
('Lotan Giladi', 'Spinx', 'spinx@cs2mail.com', 'Spinx_steam', 9, 1850);

-- =======================================
-- TEAM MEMBERS
-- =======================================
-- Spirit
INSERT INTO team_member (team_id, player_id, role, date_from) VALUES
(1, 1, 'капитан', '2025-01-01'),
(1, 2, 'основной', '2025-01-01'),
(1, 3, 'основной', '2025-01-01'),
(1, 4, 'основной', '2025-01-01'),
(1, 5, 'основной', '2025-09-01');

-- Vitality
INSERT INTO team_member (team_id, player_id, role, date_from) VALUES
(2, 6, 'капитан', '2025-01-01'),
(2, 7, 'основной', '2025-01-01'),
(2, 8, 'основной', '2025-01-01'),
(2, 9, 'основной', '2025-01-01'),
(2, 10, 'основной', '2025-01-01');

-- FaZe
INSERT INTO team_member (team_id, player_id, role, date_from) VALUES
(3, 11, 'капитан', '2025-01-01'),
(3, 12, 'основной', '2025-01-01'),
(3, 13, 'основной', '2025-01-01'),
(3, 14, 'основной', '2025-01-01'),
(3, 15, 'основной', '2025-01-01');

-- MOUZ
INSERT INTO team_member (team_id, player_id, role, date_from) VALUES
(4, 16, 'капитан', '2025-01-01'),
(4, 17, 'основной', '2025-01-01'),
(4, 18, 'основной', '2025-01-01'),
(4, 19, 'основной', '2025-01-01'),
(4, 20, 'основной', '2025-01-01');

-- =======================================
-- DISCIPLINES
-- =======================================
INSERT INTO discipline (name) VALUES
('CS2'),
('Dota2');

-- =======================================
-- TOURNAMENTS
-- =======================================
INSERT INTO tournament (name, discipline_id, start_date, end_date, format, max_participants, prize_pool) VALUES
('Winter Showdown', 1, '2025-12-01', '2025-12-21', 'BO13', 4, 50000);

-- =======================================
-- TOURNAMENT REGISTRATION
-- =======================================
INSERT INTO tournament_registration (tournament_id, team_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4);

-- =======================================
-- MATCHES
-- =======================================
INSERT INTO match (tournament_id, team1_id, team2_id, stage, start_time, end_time, winner_team_id) VALUES
(1, 1, 2, 'Group', '2025-12-01 18:00', '2025-12-01 20:30', 2),
(1, 3, 4, 'Group', '2025-12-01 21:00', '2025-12-01 23:30', 3),
(1, 1, 3, 'Group', '2025-12-02 18:00', '2025-12-02 20:30', 1),
(1, 2, 4, 'Group', '2025-12-02 21:00', '2025-12-02 23:30', 2);

-- =======================================
-- MATCH GAMES
-- =======================================
INSERT INTO match_game (match_id, game_number, map_name, team1_score, team2_score, winner_team_id) VALUES
(1, 1, 'Dust2', 8, 13, 2),
(2, 1, 'Inferno', 13, 11, 3),
(3, 1, 'Mirage', 13, 10, 1),
(4, 1, 'Ancient', 13, 7, 2);

-- =======================================
-- PLAYER GAME STATS
-- =======================================
INSERT INTO player_game_stats (game_id, player_id, kills, assists, damage, points) VALUES
(1, 1, 12, 4, 1800, 20),
(1, 2, 15, 3, 2100, 25),
(1, 3, 10, 5, 1600, 18),
(1, 4, 8, 2, 1200, 12),
(1, 5, 14, 3, 22),
(1, 6, 16, 4, 2300, 27),
(1, 7, 12, 5, 1900, 20),
(1, 8, 10, 2, 1600, 15),
(1, 9, 9, 1, 1300, 10),
(1, 10, 14, 3, 22);

-- =======================================
-- PRIZES
-- =======================================
INSERT INTO prize (tournament_id, prize_type, amount, place) VALUES
(1, 'money', 25000, 1),
(1, 'money', 15000, 2),
(1, 'money', 10000, 3);
