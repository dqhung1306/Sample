USE DBDESIGN_ONETABLE
--TRIGGER là một hàm void, không nhận tham số, không trả về giá trị 
--làm việc như một cảnh báo của một table nào đó 
-- để kiểm tra, hay đảm bảo tính toàn vẹn của data
-- dùng để ràng buộc những thứ mà SQL thông thường không cung cấp 
-- gắn với một table nhưng có thể gắn sang table khác
-- gắn liền với các câu lệnh select update delete

SELECT * FROM [event]
GO 

CREATE TRIGGER TR_CheckInsertOnEvent ON [event]
FOR INSERT 
AS 
	BEGIN
		PRINT 'You have just inserted an event on table'
	END

GO 

EXEC Insertevent 'Tung tung tung tung sahur'

GO 
CREATE TRIGGER ForbidInsertionOnEvent ON [event]
FOR INSERT 
AS 
	BEGIN 
		PRINT 'You have just inserted an event on table. Sorry'
		ROLLBACK
	END 
GO 
DROP TRIGGER CheckLimitationOnEvent
EXEC Insertevent 'Lirili Larilia'
SELECT * FROM [event]
GO 
CREATE TRIGGER CheckLimitationOnEvent ON [event]
-- if sk > 5 thì rollback
-- phải đếm số sk đang có 

FOR INSERT 
AS 
	BEGIN 
		DECLARE @num int
		SELECT @num = COUNT(*) FROM [event]
		--SELECT * FROM INSERTED 
		IF @num > 6
		BEGIN 
			PRINT 'Sorry you have 0 attempt left'
			ROLLBACK
		END 
	END 
GO 
INSERT INTO [event] VALUES ('bombadiro crocodilo')
INSERT INTO [event] VALUES ('bombadiro crocodilo')
EXEC Insertevent 'Cappucinno Assasino'
SELECT * FROM [event]
--TRIGGER Tạo ra hai table ảo lúc run 
-- insert ==> DBE tạo ra một table ảo Inserted chứa table chứa thông tin vừa được insert 
-- delete ==< table deleted chứa value sau khi bị xóa 
--update chứa hai table 
-- một là inserted - table mới 
-- hai là deleted - table vừa bị ghi đè 
DELETE FROM [event] WHERE Name = 'bombadiro crocodilo'


