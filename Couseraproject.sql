USE SomeKindofProduction

SELECT * FROM noc_regions

SELECT * FROM athlete_events

INSERT INTO noc_regions VALUES ('SGP', 'Singapore', NULL)
-- filter the row that duplicate 
SELECT DISTINCT * FROM athlete_events


ALTER TABLE noc_regions ADD PRIMARY KEY (NOC)
ALTER TABLE athlete_events ADD FOREIGN KEY(NOC) REFERENCES noc_regions(NOC)
-- Find noc that not appears in no_regions table 
SELECT DISTINCT ae.NOC
FROM athlete_events ae
LEFT JOIN noc_regions nr ON ae.NOC = nr.NOC
WHERE nr.NOC IS NULL;
-- we find SGP
SELECT * FROM athlete_events WHERE NOC = 'SGP'

SELECT DISTINCT Games 
FROM athlete_events
ORDER BY Games


SELECT 
	DISTINCT NOC,
	COUNT (Games) AS [No Games]
FROM athlete_events
GROUP BY NOC
ORDER BY COUNT(Games)

/*
🟢 Câu hỏi cơ bản
Liệt kê tất cả các năm có Thế vận hội được tổ chức.

Có bao nhiêu vận động viên (khác nhau) tham gia Thế vận hội?

Có bao nhiêu quốc gia (NOC) khác nhau tham dự?

Liệt kê 10 vận động viên đầu tiên trong bảng athlete_events.

Tính số lượng huy chương mỗi loại (Gold, Silver, Bronze) đã được trao.

🟡 Câu hỏi trung bình
Với mỗi quốc gia (NOC), tính tổng số huy chương họ đã giành được.

Với mỗi năm, có bao nhiêu vận động viên nữ tham gia?

Vận động viên nào giành nhiều huy chương vàng nhất?
--- this is enough for today -- not efficiently



*/

SELECT 
	DISTINCT NOC, 
	COUNT(Medal) AS [No Medals]
FROM athlete_events
WHERE Medal NOT LIKE 'NA'
GROUP BY NOC
ORDER BY [No Medals] DESC

SELECT 
	DISTINCT Games,
	COUNT (DISTINCT 
				CASE 
					WHEN Sex = 'F' THEN ID  
				END ) AS [No of Female Participants],
	COUNT (DISTINCT 
				CASE 
					WHEN Sex = 'M' THEN ID 
				END ) AS [No of Male Paritcipants]
FROM athlete_events
GROUP BY Games

SELECT TOP 1 
	ID,
	Name,
	COUNT (Medal) [No of Gold Medal]
FROM athlete_events 
WHERE Medal = 'Gold'
GROUP BY ID, Name 
ORDER BY COUNT (Medal ) DESC

--Với mỗi môn thể thao (Sport), quốc gia nào giành nhiều huy chương nhất?
CREATE VIEW cleaned_athlete_events 
AS
SELECT DISTINCT * FROM athlete_events
SELECT 
	Sport,
	NOC,
	COUNT (CASE WHEN Medal != 'NA' THEN Medal END ) AS [No Medals]
FROM cleaned_athlete_events
GROUP BY Sport,NOC
ORDER BY [No Medals] DESC

SELECT DISTINCT Sport FROM	athlete_events


SELECT 
	Sport,
	MAX([No Medals]) AS [Max Medals]
FROM 
(
	SELECT 
		Sport,
		NOC,
		COUNT (CASE WHEN Medal != 'NA' THEN Medal END ) AS [No Medals]
	FROM cleaned_athlete_events
	GROUP BY Sport,NOC
) AS MAXMedalCount
GROUP BY Sport
ORDER BY [Max Medals] DESC



WITH MedalCount AS (
	SELECT 
		Sport,
		NOC,
		COUNT (CASE WHEN Medal != 'NA' THEN Medal END ) AS [No Medals]
	FROM cleaned_athlete_events
	GROUP BY Sport,NOC
),
MaxMedalCount AS(
	SELECT 
		Sport,
		MAX([No Medals]) AS [Max Medals]
	FROM MedalCount
	GROUP BY Sport
)
SELECT 
	DISTINCT m.Sport,
	m.NOC,
	m.[No Medals]
FROM MedalCount m
JOIN MaxMedalCount mmc
ON mmc.[Max Medals] = m.[No Medals] AND m.Sport = mmc.Sport
ORDER BY m.Sport


--Có bao nhiêu vận động viên dưới 18 tuổi từng giành huy chương?
SELECT 
	COUNT(DISTINCT ID)
FROM athlete_events
WHERE Age < 18 AND Medal != 'NA'


/*
🔴 Câu hỏi nâng cao (dùng JOIN)
Liệt kê số huy chương mỗi quốc gia giành được, kèm tên vùng (region) từ bảng noc_regions.

Với mỗi vùng (region), tổng số vận động viên tham gia là bao nhiêu?

Với mỗi năm, vùng nào có nhiều huy chương nhất?

Với mỗi quốc gia, xác định môn thể thao họ giành được huy chương nhiều nhất.

Quốc gia nào có tỷ lệ huy chương trên số vận động viên cao nhất?
*/
SELECT DISTINCT * FROM noc_regions
SELECT * FROM cleaned_athlete_events
SELECT 
	a.NOC,
	n.region,
	COUNT(CASE WHEN Medal != 'NA' THEN Medal END ) AS [No Medals],
	COUNT (DISTINCT ID) AS [No Participants]
FROM cleaned_athlete_events a
RIGHT JOIN noc_regions n
ON n.NOC = a.NOC
--WHERE a.NOC = 'SGP'
GROUP BY a.NOC, n.region


SELECT DISTINCT ID FROM cleaned_athlete_events WHERE NOC = 'USA'

-- với mỗi năm vùng nào có nhiều huy chương nhất 

WITH MedalCount AS (
	SELECT 
		--a.games,
		a.Year,
		n.region,
		COUNT( CASE WHEN  Medal != 'NA' THEN Medal END ) AS [No Medals]
	FROM cleaned_athlete_events a
	RIGHT JOIN noc_regions n
	ON n.NOC = a.NOC
	GROUP BY a.games, a.Year, n.region
),
MaxMedalCount AS (
	SELECT 
		Year,
		MAX ([No Medals]) AS Total
	FROM MedalCount
	GROUP BY Year
)
SELECT 
	mc.year,
	mc.region,
	mmc.Total AS Total
FROM MedalCount mc
JOIN MaxMedalCount mmc
ON mc.year = mmc.year AND mc.[No Medals] = mmc.Total
ORDER BY mc.Year