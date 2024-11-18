SELECT name, wins, losses, draws, performance_metric FROM mytable ORDER BY performance_metric DESC LIMIT 3;

SELECT name, significant_strikes_landed_per_minute, significant_striking_accuracy FROM mytable
ORDER BY (significant_strikes_landed_per_minute * significant_striking_accuracy) DESC LIMIT 5;

SELECT stance, COUNT(*) AS fighter_count, AVG(wins * 1.0 / (wins + losses + draws)) AS avg_win_ratio
FROM mytable
WHERE wins + losses + draws > 0
GROUP BY stance
ORDER BY avg_win_ratio DESC;

WITH RankedFighters AS (
    SELECT 
        name,
        CASE 
            WHEN weight_in_kg <= 56.7 THEN 'Flyweight'
            WHEN weight_in_kg <= 61.2 THEN 'Bantamweight'
            WHEN weight_in_kg <= 65.8 THEN 'Featherweight'
            WHEN weight_in_kg <= 70.3 THEN 'Lightweight'
            WHEN weight_in_kg <= 77.1 THEN 'Welterweight'
            WHEN weight_in_kg <= 83.9 THEN 'Middleweight'
            WHEN weight_in_kg <= 93.0 THEN 'Light Heavyweight'
            ELSE 'Heavyweight'
        END AS weight_class,
        height_cm,
        reach_in_cm,
        wins,
        losses,
        draws,
        performance_metric,
        ROW_NUMBER() OVER (PARTITION BY 
            CASE 
                WHEN weight_in_kg <= 56.7 THEN 'Flyweight'
                WHEN weight_in_kg <= 61.2 THEN 'Bantamweight'
                WHEN weight_in_kg <= 65.8 THEN 'Featherweight'
                WHEN weight_in_kg <= 70.3 THEN 'Lightweight'
                WHEN weight_in_kg <= 77.1 THEN 'Welterweight'
                WHEN weight_in_kg <= 83.9 THEN 'Middleweight'
                WHEN weight_in_kg <= 93.0 THEN 'Light Heavyweight'
                ELSE 'Heavyweight'
            END 
            ORDER BY performance_metric DESC
        ) AS rank_in_class
    FROM mytable
    WHERE height_cm IS NOT NULL 
      AND reach_in_cm IS NOT NULL 
      AND (wins + losses + draws) > 0
)
SELECT 
    weight_class,
    AVG(height_cm) AS avg_height,
    AVG(reach_in_cm) AS avg_reach,
    AVG(CASE WHEN rank_in_class <= 3 THEN height_cm ELSE NULL END) AS top3_avg_height,
    AVG(CASE WHEN rank_in_class <= 3 THEN reach_in_cm ELSE NULL END) AS top3_avg_reach,
	AVG(performance_metric) AS avg_per_met
FROM RankedFighters
GROUP BY weight_class
ORDER BY avg_height DESC;

SELECT name, average_takedowns_landed_per_15_minutes, takedown_accuracy, average_submissions_attempted_per_15_minutes
FROM mytable
ORDER BY (average_takedowns_landed_per_15_minutes*(takedown_accuracy/20) + average_submissions_attempted_per_15_minutes*3)*performance_metric DESC
LIMIT 5;