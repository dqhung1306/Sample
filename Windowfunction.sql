USE SomeKindofProduction
SELECT * FROM athlete_events
go 

CREATE FUNCTION get_medal_point(@medal NVARCHAR(50))
RETURNS INT
AS 
BEGIN 
    IF @medal = 'Gold'
        RETURN 3
    ELSE IF @medal = 'Silver'
        RETURN 2
	ELSE IF @medal = 'Bronze'
		RETURN 1
	RETURN 0
END
		
go 

SELECT  
	ID, 
	Name, 
	SUM(dbo.get_medal_point(Medal)) AS [Total Point]
FROM cleaned_athlete_events 
GROUP BY ID, Name
ORDER BY [Total Point] DESC

GO 
CREATE FUNCTION country_medals_each_year(@country Nvarchar(50), @game nvarchar(50))
RETURNS INT
AS
	BEGIN 
		RETURN (
			SELECT COUNT (*) 
			FROM cleaned_athlete_events
			WHERE NOC = @country AND Games = @game AND Medal IN ('Gold', 'Silver', 'Bronze')
		)
	END 
GO 
PRINT ( dbo.country_medals_each_year('USA', '1904 Summer') )


SELECT 
	DISTINCT *
	--DENSE_RANK() OVER(PARTITION BY Games ORDER BY [Total Medals]) AS [dense_rank]
FROM (
	SELECT 
		r.region,
		r.NOC,
		e.Games
		dbo.country_medals_each_year(r.NOC, e.Games) AS [Total Medals] 
		--Không hợp lí tí nào, sẽ tốn hiệu năng 
		--chỉ nên dùng với noc và games cụ thể như trên 

	FROM noc_regions r
	JOIN cleaned_athlete_events e ON e.NOC = r.NOC
	WHERE dbo.country_medals_each_year(r.NOC, e.Games) > 0
) AS Result 
--ORDER BY [Total Medals] DESC;


-- dùng count và group by trực tiếp sẽ tốt hơn
WITH Medal_count AS (
	SELECT 
		r.region,
		r.NOC,
		e.Games,
		COUNT(*) AS [Total Medals]
	FROM noc_regions r
	JOIN cleaned_athlete_events e ON e.NOC = r.NOC
	WHERE e.Medal IN ('Gold', 'Silver', 'Bronze')
	GROUP BY r.region, r.NOC, e.Games
)
SELECT 
	region,
	NOC,
	Games,
	[Total Medals],
	DENSE_RANK() OVER ( PARTITION BY Games ORDER BY [Total Medals] DESC ) AS [Dense_rank]
FROM Medal_count
--ORDER BY [Total Medals] DESC;

GO 
CREATE PROCEDURE get_information
	@noc nvarchar(50),
	@year nvarchar(50),
	@sport nvarchar(50)
AS 
BEGIN 
	SET NOCOUNT ON 
	SELECT
		DISTINCT ID, 
		Name,
		Event,
		Medal
	FROM cleaned_athlete_events 
	WHERE @noc = NOC AND @sport = Sport
END 
GO 

EXEC get_information @noc = 'USA', @year = '1988', @sport = 'Swimming'
SELECT * FROM cleaned_athlete_events

GO 
CREATE PROCEDURE set_null_medal 
AS
BEGIN 
	UPDATE athlete_events
	SET Medal = 'None'
	WHERE Medal = 'NA'
	PRINT ('Successfully updated athelete_events')
END 
GO 

EXEC set_null_medal
SELECT * FROM athlete_events

GO 
CREATE PROCEDURE set_inches
AS 
BEGIN 
	UPDATE athlete_events
	SET Height = CAST(CAST(Height AS FLOAT) * 2.54 AS DECIMAL(10, 2)),
		Weight = CAST(CAST(Weight AS FLOAT) / 2.2046 AS DECIMAL(10, 2))
	WHERE Height IS NOT NULL AND Weight IS NOT NULL
END 
GO 
DROP PROCEDURE set_inches
EXECUTE set_inches


SELECT 
	TOP 10 
	* 
FROM athlete_events

SELECT TOP 10
	* 
FROM cleaned_athlete_events
go 
--CREATE FUNCTION get_year (@game nvarchar(50)
--RETURNS int
--AS
--BEGIN 
go 
----
SELECT 
	DISTINCT Games,
	DENSE_RANK() OVER (ORDER BY Games) AS date_times 
FROM cleaned_athlete_events
----
SELECT 
	Games, 
	ID, 
	ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Games) AS rn
FROM cleaned_athlete_events

--ID, name, total medals of athlete has max medal count each game 
--
SELECT * FROM cleaned_athlete_events
go
WITH Medal_count AS(
	SELECT 
		DISTINCT ID,
		Games,
		COUNT (CASE WHEN Medal != 'None' THEN Medal END) AS Total
	FROM cleaned_athlete_events
	GROUP BY ID, Games
),
Max_medal_count AS (
	SELECT 
		Games, 
		MAX(Total) AS [Max_medal_count]
	FROM Medal_count
	GROUP BY Games 
)
SELECT 
	mc.ID,
	mmc.Games,
	mmc.[Max_medal_count] AS Medals,
	ROW_NUMBER() OVER (PARTITION BY mmc.Games ORDER BY mmc.[Max_medal_count]) as rn
FROM Medal_count mc
JOIN Max_medal_count mmc ON mmc.Games = mc.Games 
						AND mmc.[Max_medal_count] = mc.Total

with Medal_count as (
	select 
		id,
		name, 
		noc,
		count(case when medal != 'None' then 1 end) as total
	from cleaned_athlete_events
	group by id, name, noc
),
ranked_athletes as(
	select 
		*,
		ROW_NUMBER() over(partition by noc order by total desc, name) as rn
	from Medal_count
)
select 
	id, 
	name, 
	noc,
	total
from ranked_athletes 
where rn = 1
order by total desc


select distinct noc from cleaned_athlete_events