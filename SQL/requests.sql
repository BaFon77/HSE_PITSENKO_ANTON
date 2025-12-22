-- Получаем всех игроков с командами
SELECT 
    p.nickname AS player,
    t.name AS team,
    tm.role,
    tm.date_from
FROM player p
JOIN team_member tm ON tm.player_id = p.player_id
JOIN team t ON t.team_id = tm.team_id
ORDER BY t.name, tm.role;

-- Выбираем игроков, которые набрали больше среднего числа очков в матчах
SELECT 
    p.nickname,
    SUM(ps.points) AS total_points
FROM player p
JOIN player_game_stats ps ON ps.player_id = p.player_id
GROUP BY p.player_id, p.nickname
HAVING SUM(ps.points) > (
    SELECT AVG(total) 
    FROM (
        SELECT SUM(points) AS total
        FROM player_game_stats
        GROUP BY player_id
    ) AS sub
);

-- Выбираем команды с наибольшем количество баллов за турнир
WITH team_scores AS (
    SELECT 
        t.team_id,
        t.name AS team_name,
        SUM(ps.points) AS total_points
    FROM team t
    JOIN team_member tm ON tm.team_id = t.team_id
    JOIN player_game_stats ps ON ps.player_id = tm.player_id
    JOIN match_game mg ON mg.game_id = ps.game_id
    GROUP BY t.team_id, t.name
)
SELECT 
    team_name,
    total_points,
    RANK() OVER (ORDER BY total_points DESC) AS rank
FROM team_scores;

-- Статистика для каждой команды по картамs
SELECT 
    t.name AS team,
    mg.map_name,
    SUM(CASE WHEN mg.winner_team_id = t.team_id THEN 1 ELSE 0 END) AS wins_on_map,
    COUNT(*) AS total_games,
    SUM(CASE WHEN mg.winner_team_id = t.team_id THEN 1 ELSE 0 END) * 100.0 / COUNT(*) 
        OVER (PARTITION BY t.team_id) AS win_percentage
FROM team t
JOIN match_game mg ON mg.team1_score IS NOT NULL -- участвует в игре
    AND (mg.winner_team_id = t.team_id OR mg.team1_score IS NOT NULL)
GROUP BY t.team_id, t.name, mg.map_name
ORDER BY t.name, win_percentage DESC;

-- Получаем новый и предыдущий рейтинг игрока
SELECT 
    p.nickname,
    prh.changed_at,
    prh.previous_rating,
    prh.new_rating,
    prh.new_rating - prh.previous_rating AS rating_change,
    LAG(prh.new_rating) OVER (PARTITION BY p.player_id ORDER BY prh.changed_at) AS prev_rating_window
FROM player p
JOIN player_rating_history prh ON prh.player_id = p.player_id
ORDER BY p.nickname, prh.changed_at;

-- Получить список призов турнира с указанием типа, суммы и места, за которое они выдаются
SELECT 
    t.name        AS tournament_name,
    p.prize_type  AS prize_type,
    p.amount      AS prize_amount,
    p.place       AS place
FROM prize p
JOIN tournament t 
    ON t.tournament_id = p.tournament_id
WHERE t.name = 'Winter Showdown'
ORDER BY p.place;

-- Перечислить всех команд, участвующих в указанном турнире
SELECT
    t.team_id,
    t.name
FROM team t
JOIN tournament_registration tr
    ON tr.team_id = t.team_id
JOIN tournament tour
    ON tour.tournament_id = tr.tournament_id
WHERE tour.name = 'Winter Showdown';

-- Найти игроков по никнейму
SELECT
    player_id,
    full_name,
    nickname,
    rating
FROM player
WHERE nickname ILIKE '%donk%';

-- Получения общей статистики игрока (тут суммируются все поинты игрока из таблицы player_game_stats)
SELECT * FROM get_player_stats(2);

-- Функция получения лучшего игрока турнира
SELECT * FROM best_player_tournament(1);