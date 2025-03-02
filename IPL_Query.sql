create database IPL;
use IPL;
CREATE TABLE matches (
    id INT PRIMARY KEY,
    season varchar(30),
    city VARCHAR(50),
    date DATE,
    match_type VARCHAR(20),
    player_of_match VARCHAR(50),
    venue VARCHAR(100),
    team1 VARCHAR(50),
    team2 VARCHAR(50),
    toss_winner VARCHAR(50),
    toss_decision VARCHAR(10),
    winner VARCHAR(50),
    result VARCHAR(20),
    result_margin float,
    target_runs float,
    target_overs float,
    super_over varchar(10),
    method VARCHAR(50),
    umpire1 VARCHAR(50),
    umpire2 VARCHAR(50)
);
CREATE TABLE deliveries (
    match_id INT,
    inning INT,
    batting_team VARCHAR(50),
    bowling_team VARCHAR(50),
    overs INT,
    ball INT,
    batter VARCHAR(50),
    bowler VARCHAR(50),
    non_striker VARCHAR(50),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    extras_type VARCHAR(20),
    is_wicket int,
    player_dismissed VARCHAR(50),
    dismissal_kind VARCHAR(50),
    fielder VARCHAR(50),
    PRIMARY KEY (match_id, inning, overs, ball),
    FOREIGN KEY (match_id) REFERENCES matches(id)
);
use ipl;
select * from deliveries;
select * from matches;


-- Top 10 Run Scorer
SELECT batter,SUM(batsman_runs) total_run
FROM deliveries 
GROUP BY batter
ORDER BY total_run desc
LIMIT 10;
-- Most Successfull Team
SELECT winner,count(*) as Total_Wins
FROM matches
WHERE winner not in("No Winner") 
GROUP BY winner
ORDER BY Total_Wins desc;
-- Win percentage of each team
WITH match_counts AS (
    SELECT team, COUNT(*) AS matches_played
    FROM (
        SELECT team1 AS team FROM matches
        UNION ALL
        SELECT team2 AS team FROM matches
    ) AS all_teams
    GROUP BY team
),
win_counts AS (
    SELECT winner AS team, COUNT(*) AS wins
    FROM matches
    WHERE winner not in ("No winner")
    GROUP BY winner
)
SELECT
    mc.team,
    mc.matches_played,
    COALESCE(wc.wins, 0) AS wins,
    ROUND((CAST(COALESCE(wc.wins, 0) AS FLOAT) / mc.matches_played) * 100, 2) AS win_percentage
FROM match_counts mc
LEFT JOIN win_counts wc ON mc.team = wc.team
ORDER BY win_percentage DESC;
-- home-vs-away performance
WITH home_venues AS (
    SELECT 'Chennai Super Kings' AS team, 'Chennai' AS home_city UNION ALL
    SELECT 'Mumbai Indians', 'Mumbai' UNION ALL
    SELECT 'Royal Challengers Bangalore', 'Bangalore' UNION ALL
    SELECT 'Delhi Capitals', 'Delhi' UNION ALL
    SELECT 'Punjab Kings', 'Mohali' UNION ALL
    SELECT 'Kolkata Knight Riders', 'Kolkata' UNION ALL
    SELECT 'Sunrisers Hyderabad', 'Hyderabad' UNION ALL
    SELECT 'Rajasthan Royals', 'Jaipur' UNION ALL
    SELECT 'Lucknow Super Giants', 'Lucknow' UNION ALL
    SELECT 'Gujarat Titans', 'Ahmedabad'
)
SELECT
    t.team,
    SUM(CASE WHEN m.city = hv.home_city THEN 1 ELSE 0 END) AS home_matches,
    SUM(CASE WHEN m.city = hv.home_city AND m.winner = t.team THEN 1 ELSE 0 END) AS home_wins,
    SUM(CASE WHEN m.city != hv.home_city THEN 1 ELSE 0 END) AS away_matches,
    SUM(CASE WHEN m.city != hv.home_city AND m.winner = t.team THEN 1 ELSE 0 END) AS away_wins
FROM matches m
JOIN home_venues hv ON m.team1 = hv.team OR m.team2 = hv.team
JOIN (
    SELECT DISTINCT team1 AS team FROM matches
    UNION 
    SELECT DISTINCT team2 AS team FROM matches
) t ON t.team = hv.team
GROUP BY t.team
ORDER BY home_wins DESC;
-- Top Wicket Takers
SELECT bowler, COUNT(*) AS total_wickets
FROM deliveries
WHERE is_wicket = 1
AND dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
GROUP BY bowler
ORDER BY total_wickets DESC
LIMIT 10;




