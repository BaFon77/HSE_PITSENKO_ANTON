DROP DATABASE IF EXISTS esports;
CREATE DATABASE esports;
\c esports;

-- Таблица игроков
CREATE TABLE player (
    player_id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    nickname VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    game_account TEXT,
    level INT CHECK (level >= 0),
    rating INT DEFAULT 1000
);

-- Таблица команд
CREATE TABLE team (
    team_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at DATE NOT NULL,
    team_rating INT DEFAULT 1000
);

-- Таблица состава команды (история)
CREATE TABLE team_member (
    team_id INT REFERENCES team(team_id),
    player_id INT REFERENCES player(player_id),
    role VARCHAR(20) CHECK (role IN ('капитан','основной','запасной','тренер')),
    date_from DATE NOT NULL,
    date_to DATE,
    PRIMARY KEY (team_id, player_id, date_from)
);

-- Таблица дисциплин
CREATE TABLE discipline (
    discipline_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Таблица турниров
CREATE TABLE tournament (
    tournament_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    discipline_id INT REFERENCES discipline(discipline_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    format VARCHAR(20),
    max_participants INT,
    prize_pool INT
);

-- Таблица регистрации команд в турнирах
CREATE TABLE tournament_registration (
    registration_id SERIAL PRIMARY KEY,
    tournament_id INT REFERENCES tournament(tournament_id),
    team_id INT REFERENCES team(team_id),
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица матчей турнира
CREATE TABLE match (
    match_id SERIAL PRIMARY KEY,
    tournament_id INT REFERENCES tournament(tournament_id),
    team1_id INT REFERENCES team(team_id),
    team2_id INT REFERENCES team(team_id),
    stage VARCHAR(50),
    winner_team_id INT REFERENCES team(team_id),
    start_time TIMESTAMP,
    end_time TIMESTAMP
);

-- Таблица отдельных игр матча (BO3, BO5) с картами
CREATE TABLE match_game (
    game_id SERIAL PRIMARY KEY,
    match_id INT REFERENCES match(match_id),
    game_number INT NOT NULL,
    map_name VARCHAR(50) NOT NULL,
    team1_score INT,
    team2_score INT,
    winner_team_id INT REFERENCES team(team_id),
    UNIQUE (match_id, game_number)
);

-- Таблица статистики игроков по каждой игре
CREATE TABLE player_game_stats (
    game_id INT REFERENCES match_game(game_id),
    player_id INT REFERENCES player(player_id),
    kills INT DEFAULT 0,
    assists INT DEFAULT 0,
    damage INT DEFAULT 0,
    points INT DEFAULT 0,
    PRIMARY KEY (game_id, player_id)
);

-- Таблица призов турнира
CREATE TABLE prize (
    prize_id SERIAL PRIMARY KEY,
    tournament_id INT REFERENCES tournament(tournament_id),
    prize_type VARCHAR(20),
    description TEXT,
    amount INT,
    place INT
);

-- История изменения рейтинга команд
CREATE TABLE team_rating_history (
    history_id SERIAL PRIMARY KEY,
    team_id INT REFERENCES team(team_id),
    previous_rating INT,
    new_rating INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- История изменения рейтинга игроков
CREATE TABLE player_rating_history (
    history_id SERIAL PRIMARY KEY,
    player_id INT REFERENCES player(player_id),
    previous_rating INT,
    new_rating INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Функция обновления рейтинга игрока
CREATE OR REPLACE FUNCTION update_player_rating()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO player_rating_history(player_id, previous_rating, new_rating)
    SELECT p.player_id, p.rating, p.rating + NEW.points
    FROM player p
    WHERE p.player_id = NEW.player_id;

    UPDATE player
    SET rating = rating + NEW.points
    WHERE player_id = NEW.player_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер обновления рейтинга игрока
CREATE TRIGGER trg_update_player_rating
AFTER INSERT ON player_game_stats
FOR EACH ROW
EXECUTE FUNCTION update_player_rating();

-- Функция обновления рейтинга команды
CREATE OR REPLACE FUNCTION update_team_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.winner_team_id IS NOT NULL THEN
        INSERT INTO team_rating_history(team_id, previous_rating, new_rating)
        SELECT t.team_id, t.team_rating, t.team_rating + 10
        FROM team t
        WHERE t.team_id = NEW.winner_team_id;

        UPDATE team
        SET team_rating = team_rating + 10
        WHERE team_id = NEW.winner_team_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер обновления рейтинга команды
CREATE TRIGGER trg_update_team_rating
AFTER INSERT ON match
FOR EACH ROW
EXECUTE FUNCTION update_team_rating();

-- Функция получения общей статистики игрока
CREATE OR REPLACE FUNCTION get_player_stats(p_player_id INT)
RETURNS TABLE(total_points BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(points), 0)
    FROM player_game_stats
    WHERE player_id = p_player_id;
END;
$$ LANGUAGE plpgsql;

-- Функция получения лучшего игрока турнира
CREATE OR REPLACE FUNCTION best_player_tournament(p_tournament_id INT)
RETURNS TABLE(player_name TEXT, nickname varchar(50), total_points bigint) AS $$
BEGIN
    RETURN QUERY
    SELECT p.full_name, p.nickname, SUM(ps.points) AS total_points
    FROM player_game_stats ps
    JOIN player p ON p.player_id = ps.player_id
    JOIN match_game mg ON mg.game_id = ps.game_id
    JOIN match m ON m.match_id = mg.match_id
    WHERE m.tournament_id = p_tournament_id
    GROUP BY p.player_id
    ORDER BY total_points DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;


