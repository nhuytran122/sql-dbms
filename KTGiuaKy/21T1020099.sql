/*Câu 1: Viết các trigger sau đây:
a. Trigger trg_Question_Insert có chức năng bắt lệnh INSERT trên bảng Question sao cho
khi mỗi khi bổ sung một câu hỏi thì tự động tăng số lượng câu hỏi của tài khoản (cột
NumOfQuestions trong bảng UserAccount).*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Question_Insert')
DROP TRIGGER trg_Question_Insert;
GO

CREATE TRIGGER trg_Question_Insert
ON Question
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE ua
    SET NumOfQuestions += 1
    FROM UserAccount as ua INNER JOIN inserted i ON ua.UserName = i.UserName;
END
GO

INSERT INTO Question (QuestionTitle, QuestionContent, AskedTime, UserName, NumOfAnswers)
VALUES ('Moi Truong', 'Giu gin ve sinh chung 2', GETDATE(), 'Nhy03', 0);
GO

SELECT NumOfQuestions
FROM UserAccount
WHERE UserName = 'Nhy03';
GO

/*b. Trigger trg_Answer_Insert có chức năng bắt lệnh INSERT trên bảng Answer sao cho mỗi khi
bổ sung một trả lời thì tự động tăng số lượng câu trả lời của tài khoản (cột NumOfAnswers trong
bảng UserA*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Answer_Insert')
DROP TRIGGER trg_Answer_Insert;
GO

CREATE TRIGGER trg_Answer_Insert
ON Answer
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE ua
    SET NumOfAnswers += 1
    FROM UserAccount as ua INNER JOIN inserted i ON ua.UserName = i.UserName;
END
GO

INSERT INTO Answer (QuestionId, UserName, AnsweredTime, AnswerContent)
VALUES (1, 'Nhy03', GETDATE(), 'Đây là câu trả lời của tôi.');
GO

SELECT NumOfAnswers
FROM UserAccount
WHERE UserName = 'Nhy03';
GO
/*Câu 2: Viết các thủ tục sau đây:
a. proc_Question_Insert
@QuestionTitle nvarchar(255),
@QuestionContent nvarchar(2000),
@UserName nvarchar(50),
@QuestionId int output
Có chức năng tạo mới một câu hỏi. Tham số đầu ra @QuestionId trả về mã của câu hỏi được tạo
mới trong trường hợp thành công; Ngược lại, tham số này trả về giá trị nhỏ hơn hoặc bằng 0 nhằm
cho biết lý do không tạo được câu hỏi.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Question_Insert')
DROP PROCEDURE proc_Question_Insert
GO

CREATE PROCEDURE proc_Question_Insert
    @QuestionTitle NVARCHAR(255),
    @QuestionContent NVARCHAR(2000),
    @UserName NVARCHAR(50),
    @QuestionId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	IF NOT EXISTS(SELECT * FROM UserAccount WHERE UserName = @UserName)
    BEGIN
        SET @QuestionId = -1;
        RETURN;
    END

    INSERT INTO Question (QuestionTitle, QuestionContent, UserName)
    VALUES (@QuestionTitle, @QuestionContent, @UserName);

    SET @QuestionId = SCOPE_IDENTITY();
    RETURN @QuestionId;
END
GO

DECLARE @QuestionId INT;

-- Execute the stored procedure
EXEC proc_Question_Insert
    @QuestionTitle = 'QuestionTtl10',
    @QuestionContent = 'QuestionCtn10',
    @UserName = N'Thuuyn',
    @QuestionId = @QuestionId OUTPUT;
PRINT @QuestionId
GO

/*b. proc_UserAccount_Update
@UserName nvarchar(50),
@FullName nvarchar(100),
@Email nvarchar(50),
@Result nvarchar(255) output
Có chức năng cập nhật thông tin của tài khoản. Nếu việc cập nhật là thành công, tham số đầu ra
@Result trả về chuỗi rỗng; Ngược lại, tham số này trả về chuỗi cho biết lý do tại sao không cập
nhật được dữ liệu.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_UserAccount_Update')
DROP PROCEDURE proc_UserAccount_Update
GO
CREATE PROCEDURE proc_UserAccount_Update
    @UserName NVARCHAR(50),
    @FullName NVARCHAR(100),
    @Email NVARCHAR(50),
    @Result NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT * FROM UserAccount WHERE UserName = @UserName)
    BEGIN
        SET @Result = 'Người dùng không tồn tại';
        RETURN;
    END

	IF  EXISTS (SELECT * FROM UserAccount WHERE Email = @Email)
    BEGIN
        SET @Result = 'Email đã tồn tại';
        RETURN;
    END

    UPDATE UserAccount
    SET FullName = @FullName, Email = @Email
    WHERE UserName = @UserName;
    
	SET @Result = ''; 
END
GO

DECLARE @Result NVARCHAR(255);
EXEC proc_UserAccount_Update
    @UserName = N'Thuuyn',
    @FullName = 'Thu Uyen',
    @Email = '21t1020099@husc.edu.vn',
    @Result = @Result OUTPUT;
PRINT @Result;
go

/*c. proc_Question_Select
@SearchValue nvarchar(255) = N’’,
@Page int = 1,
@PageSize int = 20,
@RowCount int output,
@PageCount int output
Có chức năng tìm kiếm và hiển thị danh sách các câu hỏi dưới dạng phân trang. Trong đó, tham số
@SearchValue là tiêu đề hoặc nội dung của câu hỏi cần tìm (tìm kiếm tương đối). @Page là trang
cần hiển thị, @PageSize là số dòng dữ liệu được hiển thị trên mỗi trang, tham số đầu ra
@RowCount cho biết tổng số dòng dữ liệu và tham số đầu ra @PageCount cho biết tổng số trang*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Question_Select')
DROP PROCEDURE proc_Question_Select
GO

CREATE PROCEDURE proc_Question_Select
(
	@SearchValue nvarchar(255) = N'',
	@Page int = 1,
	@PageSize int = 20,
	@RowCount int output,
	@PageCount int output
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *, ROW_NUMBER() over(order by QuestionId) as RowNumber
	INTO #TempQues
	FROM Question

	SELECT @RowCount = COUNT(*)
	FROM Question
	where (@SearchValue = N'') or (QuestionTitle like @SearchValue);

	IF(@PageSize = 0)
		SET @PageCount = 1
	ELSE
		BEGIN
			SET @PageCount = @RowCount / @PageSize;
			IF (@RowCount % @PageSize > 0)
				SET @PageCount += 1;
		END;


	;WITH cte as
	(
		SELECT * from #TempQues
		where (@SearchValue = N'') or (QuestionTitle like @SearchValue)
	)
	SELECT * FROM cte
	where (@PageSize = 0) or
			RowNumber between (@Page - 1) * @PageSize + 1 AND @Page * @PageSize
	ORDER BY RowNumber
END
GO

--TEST
DECLARE @RowCount int,
		@PageCount int 
EXECUTE proc_Question_Select
	@Page = 1,
	@PageSize = 10,
	@SearchValue = N'',
	@RowCount = @RowCount OUTPUT,
	@PageCount = @PageCount OUTPUT
GO

/*d. proc_CountQuestionByYear
@FromYear int,
@ToYear int
Có chức năng thống kê số lượng câu hỏi và số lượng câu trả lời của từng năm trong khoảng thời
gian từ năm @FromYear đến năm @ToYear. Yêu cầu kết quả thống kê phải hiển thị đủ tất cả các
năm (kể cả những năm không có câu hỏi hay câu trả lời).*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_CountQuestionByYear')
DROP PROCEDURE proc_CountQuestionByYear
GO

CREATE PROCEDURE proc_CountQuestionByYear
    @FromYear INT,
    @ToYear INT
AS
BEGIN
    SET NOCOUNT ON;
	CREATE TABLE #YearStats (
        Nam INT,
        QuestionCount INT,
        AnswerCount INT
    );

    DECLARE @tmpyear INT = @FromYear;
    WHILE @tmpyear <= @ToYear
    BEGIN
        INSERT INTO #YearStats (Nam, QuestionCount, AnswerCount)
        SELECT @tmpyear, ISNULL(COUNT(q.QuestionId), 0), ISNULL(COUNT(a.AnswerId), 0)
        FROM Question as q JOIN Answer as a ON q.QuestionId = a.QuestionId
        WHERE  YEAR(AskedTime) = @tmpyear
        SET @tmpyear = @tmpyear + 1;
    END;
    SELECT * FROM #YearStats;
END
GO

EXEC proc_CountQuestionByYear
    @FromYear = 2020,
    @ToYear = 2023;
GO

/*Câu 3: Viết các hàm sau đây
a. func_CountAnswers(@From date, @To date) có chức năng tính tổng số lượng câu trả lời
được đăng trong khoảng thời gian từ ngày @From đến ngày @To.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_CountAnswers')
	DROP FUNCTION func_CountAnswers;
GO

CREATE FUNCTION func_CountAnswers
(
    @From DATE,
    @To DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @AnswerCount INT;

    SELECT @AnswerCount = COUNT(AnswerId)
    FROM Answer
    WHERE AnsweredTime >= @From AND AnsweredTime <= @To;
    RETURN @AnswerCount;
END;
GO

SELECT dbo.func_CountAnswers('2023-01-01 00:00:00', '2023-12-01 12:00:00');

/* func_CountQuestionByYear(@FromYear int, @ToYear int) trả về bảng thống kê số
lượng câu hỏi và số lượng câu trả lời của từng năm trong khoảng thời gian từ năm @FromYear đến
năm @ToYear. Yêu cầu kết quả thống kê phải hiển thị đủ tất cả các năm (kể cả những năm không có
câu hỏi hay câu trả lời)*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_CountQuestionByYear')
	DROP FUNCTION func_CountQuestionByYear;
GO

CREATE FUNCTION func_CountQuestionByYear
(
    @FromYear INT,
    @ToYear INT
)
RETURNS @tbl TABLE
(
	Nam INT,
	QuestionCount INT,
	AnswerCount INT
)
AS 
BEGIN
INSERT INTO @tbl(Nam, QuestionCount, AnswerCount)
			SELECT YEAR(Q.AskedTime), ISNULL(COUNT(q.QuestionId), 0), ISNULL(COUNT(a.AnswerId), 0)
			FROM Question as q JOIN Answer as a ON q.QuestionId = a.QuestionId
			WHERE YEAR(q.AskedTime) between @FromYear and @ToYear
			GROUP BY YEAR(q.AskedTime)
	
	DECLARE @y INT = @FromYear;
	WHILE @y <= @ToYear
		BEGIN
			IF NOT EXISTS (SELECT * FROM @tbl WHERE Nam = @y)
				INSERT INTO @tbl(Nam, QuestionCount, AnswerCount) VALUES(@y, 0, 0)
			SET @y += 1;
		END
	RETURN;
END
GO
