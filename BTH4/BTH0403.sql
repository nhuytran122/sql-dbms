/*Câu 1: Viết các trigger sau đây:
a. Các trigger cho bảng Posts
Tên Trigger         Lệnh xử lý
trg_Posts_Insert      INSERT
trg_Post_Delete       DELETE
Sao cho khi bổ sung hoặc xóa dữ liệu trong bảng Posts thì cập nhật lại số lượng bài viết
của tài khoản (cột NumOfPosts) trong bảng Accounts*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Posts_Insert')
DROP TRIGGER trg_Posts_Insert;
GO

CREATE TRIGGER trg_Posts_Insert
ON Posts
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
    UPDATE Accounts
	SET NumOfPost = NumOfPost + 1
	FROM Accounts INNER JOIN inserted ON Accounts.AccountId = inserted.AccountId
END
GO

-- TEST
INSERT INTO Posts(PostTitle, PostContent, CreatedTime, AccountId, NumOfComments)
VALUES  ('Title 1', 'Content 1', GETDATE(), 2, 6)
GO

INSERT INTO Posts(PostTitle, PostContent, CreatedTime, AccountId, NumOfComments)
VALUES  ('Title 2', 'Content 2', GETDATE(), 3, 8)
GO

INSERT INTO Posts(PostTitle, PostContent, CreatedTime, AccountId, NumOfComments)
VALUES  ('Title 3', 'Content 3', GETDATE(), 5, 10)
GO

-- trg_Post_Delete       DELETE
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Post_Delete')
DROP TRIGGER trg_Post_Delete;
GO
CREATE TRIGGER trg_Post_Delete
ON Posts
FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Accounts
		SET NumOfPost = NumOfPost - 1
		FROM Accounts INNER JOIN deleted ON Accounts.AccountId = deleted.AccountId
END
GO
-- TEST
DELETE FROM Posts
WHERE PostId = 1

/*b. Các trigger cho bảng Comments
Tên Trigger              Lệnh xử lý
trg_Comments_Insert        INSERT
trg_Comments_Delete        DELETE
Sao cho khi bổ sung hoặc xóa dữ liệu trong bảng Comments thì cập nhật lại số lượng bài
bình luận của tài khoản (cột NumOfComments của bảng Accounts) và số lượng bài
bình luận của bài viết (cột NumOfComments của bảng Posts)*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Comments_Insert')
DROP TRIGGER trg_Comments_Insert;
GO

CREATE TRIGGER trg_Comments_Insert
ON Comments
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
    UPDATE Accounts
	SET NumOfComments = NumOfComments + 1
	FROM Accounts INNER JOIN inserted ON Accounts.AccountId = inserted.AccountId

	UPDATE Posts
	SET NumOfComments = NumOfComments + 1
	FROM Posts INNER JOIN inserted ON Posts.PostId = inserted.PostId
END
GO

-- TEST
INSERT INTO Comments(PostId, AccountId, CreatedTime, CommentText)
VALUES  (2, 4, GETDATE(), 'ABCD')
GO

INSERT INTO Comments(PostId, AccountId, CreatedTime, CommentText)
VALUES  (2, 3, GETDATE(), 'ABCDE')
GO

-- trg_Comments_Delete       DELETE
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Comments_Delete')
DROP TRIGGER trg_Comments_Delete;
GO
CREATE TRIGGER trg_Comments_Delete
ON Comments
FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Accounts
		SET NumOfComments = NumOfComments - 1
		FROM Accounts INNER JOIN deleted ON Accounts.AccountId = deleted.AccountId
	UPDATE Posts
		SET NumOfComments = NumOfComments - 1
		FROM Posts INNER JOIN deleted ON Posts.PostId = deleted.PostId
END
GO
-- TEST
DELETE FROM Comments
WHERE CommentId = 1
GO

/*Câu 2: Viết các thủ tục sau đây:
a. proc_Posts_Insert
@PostTitle nvarchar(255),
@PostContent nvarchar(2000),
@AccountId int,
@PostId int output
Có chức năng tạo mới một bài viết. Tham số đầu ra @PostId trả về mã của bài viết được
tạo mới trong trường hợp thành công; Ngược lại, tham số này trả về giá trị nhỏ hơn hoặc
bằng 0 nhằm cho biết lý do không tạo được bài viết.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Posts_Insert')
DROP PROCEDURE proc_Posts_Insert
GO
CREATE PROCEDURE proc_Posts_Insert
	@PostTitle nvarchar(255),
	@PostContent nvarchar(2000),
	@AccountId int,
	@PostId int output
AS
BEGIN
	SET NOCOUNT ON;
	IF (LEN(@PostTitle) < 0 OR LEN(@PostContent) < 0)
	BEGIN
		SET @PostId = -1;
		RETURN;
	END
	IF NOT EXISTS (SELECT * FROM Accounts WHERE AccountId = @AccountId)
	BEGIN
		SET @PostId = -2;
		RETURN;
	END

	INSERT INTO Posts(PostTitle, PostContent, CreatedTime, AccountId, NumOfComments)
	VALUES  (@PostTitle, @PostContent, GETDATE(), @AccountId, 0)
	SET @PostId = @@IDENTITY;

	/*UPDATE Accounts
	SET NumOfPost = NumOfPost + 1
	WHERE AccountId = @AccountId*/
END
GO

-- TEST
DECLARE @PostId int;
EXECUTE proc_Posts_Insert @PostTitle = 'Title 6',
							@PostContent = 'Content 6',
							@AccountId = 2,
							@PostId = @PostId OUTPUT;
PRINT @PostId;
GO

/*b. proc_Accounts_Update
@AccountId int,
@AccountName nvarchar(100),
@Gender nvarchar(50),
@Email nvarchar(50),
@Result nvarchar(255) output
Có chức năng cập nhật thông tin của tài khoản có mã @AccountId. Nếu việc cập nhật là
thành công, tham số đầu ra @Result trả về chuỗi rỗng; Ngược lại, tham số này trả về
chuỗi cho biết lý do tại sao không cập nhật được dữ liệu*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Accounts_Update')
DROP PROCEDURE proc_Accounts_Update
GO
CREATE PROCEDURE proc_Accounts_Update
	@AccountId int,
	@AccountName nvarchar(100),
	@Gender nvarchar(50),
	@Email nvarchar(50),
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;

	IF @Email IS NULL or @Email = N''
		BEGIN
			SET @Result = 'Email rong';
			RETURN;
		END
	IF EXISTS (SELECT * FROM Accounts WHERE Email = @Email AND AccountId <> @AccountId)
		BEGIN
			SET @Result = 'Email trung voi Email cua tai khoan khac';
			RETURN;
		END
	IF @AccountName IS NULL or @AccountName = N''
		BEGIN
			SET @Result = 'Ten tai khoan rong';
			RETURN;
		END
	IF @Gender IS NULL or @Gender = N''
		BEGIN
			SET @Result = 'Gioi tinh rong';
			RETURN;
		END

	UPDATE Accounts
	SET AccountName = @AccountName,
		Gender = @Gender,
		Email = @Email
	WHERE AccountId = @AccountId

	IF (@@ROWCOUNT < 1)
	BEGIN	
		SET @Result = 'AccountId khong ton tai';
		RETURN;
	END
END
GO

DECLARE @Result nvarchar(255);
EXECUTE proc_Accounts_Update @AccountId = 3,
							@AccountName = 'LeMinh',
							@Gender = 'Nam',
							@Email = 'leminh@gmail.com',
							@Result = @Result output
PRINT @Result;
go

/*c. proc_Posts_Select
@SearchValue nvarchar(255) = N'',
@Page int = 1,
@PageSize int = 20,
@RowCount int output,
@PageCount int output
Có chức năng tìm kiếm và hiển thị danh sách các bài viết dưới dạng phân trang. Trong
đó, tham số @SearchValue là tiêu đề hoặc nội dung của bài viết cần tìm (tìm kiếm tương
đối). @Page là trang cần hiển thị, @PageSize là số dòng dữ liệu được hiển thị trên mỗi
trang, tham số đầu ra @RowCount cho biết tổng số dòng dữ liệu và tham số đầu ra
@PageCount cho biết tổng số trang.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Posts_Select')
DROP PROCEDURE proc_Posts_Select
GO
CREATE PROCEDURE proc_Posts_Select
	@SearchValue nvarchar(255) = N'',
	@Page int = 1,
	@PageSize int = 20,
	@RowCount int output,
	@PageCount int output
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *, ROW_NUMBER() over(order by PostId) as RowNumber
	INTO #TempPost
	FROM Posts

	-- @RowCount : Tham số đầu ra cho biết tổng số dòng dữ liệu tìm được
	SELECT @RowCount = COUNT(*)
	FROM Posts
	where (@SearchValue = N'') or (PostTitle like @SearchValue OR PostContent like @SearchValue);

	IF(@PageSize = 0)
		SET @PageCount = 1
	ELSE
		BEGIN
		-- @PageCount : Tham số đầu ra cho biết tổng số trang.
			SET @PageCount = @RowCount / @PageSize;
			IF (@RowCount % @PageSize > 0)
				SET @PageCount += 1;
		END;
	;WITH cte as
	(
		SELECT * from #TempPost
		where (@SearchValue = N'') or (PostTitle like @SearchValue OR PostContent like @SearchValue)
	)
	SELECT * FROM cte
	-- @PageSize : Số dòng trên mỗi trang (nếu @PageSize = 0 thì hiển thị toàn bộ dữ liệu tìm được)
	where (@PageSize = 0) or
			RowNumber between (@Page - 1) * @PageSize + 1 AND @Page * @PageSize
	ORDER BY RowNumber
END
GO

--TEST
DECLARE @RowCount int,
		@PageCount int 
EXECUTE proc_Posts_Select
	@Page = 1,
	@PageSize = 10,
	@SearchValue = N'',
	@RowCount = @RowCount OUTPUT,
	@PageCount = @PageCount OUTPUT
GO

/*d. proc_CountPostByYear
@FromYear int,
@ToYear int
Có chức năng thống kê số lượng bài viết và số lượng bài thảo luận của từng năm trong
khoảng thời gian từ năm @FromYear đến năm @ToYear. Yêu cầu kết quả thống kê
phải hiển thị đủ tất cả các năm trong khoảng thời gian trên (kể cả những năm không có
bài viết hay bài thảo luận)*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_CountPostByYear')
DROP PROCEDURE proc_CountPostByYear
GO
CREATE PROCEDURE proc_CountPostByYear
	@FromYear int,
	@ToYear int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE table #tblNam
	(
	Nam int
	)

	DECLARE @tmpYear int = @FromYear;
	WHILE (@tmpYear <= @ToYear)
		BEGIN
			INSERT INTO #tblNam VALUES (@tmpYear);
			SET @tmpYear += 1;
		END

	SELECT t1.Nam, ISNULL(t2.SoLuongBaiViet, 0) as SoLuongBaiViet
	FROM #tblNam as t1
		LEFT JOIN 
		(
			select YEAR(p.CreatedTime) as Nam,
					COUNT(p.PostId) AS SoLuongBaiViet
			FROM Posts as p
			GROUP BY YEAR(p.CreatedTime)
		) as t2
		ON t1.Nam = t2.Nam
	DROP TABLE #tblNam
END
GO

-- TEST
EXECUTE proc_CountPostByYear @FromYear = 2020,
						@ToYear = 2023
GO

/*Câu 3: Viết các hàm sau đây
a. func_CountPost(@From date, @To date) có chức năng tính tổng số lượng bài
được viết trong khoảng thời gian từ ngày @From đến ngày @To.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_CountPost')
DROP FUNCTION func_CountPost;
GO
CREATE FUNCTION func_CountPost 
(
	@From date, 
	@To date
)
RETURNS int
AS
BEGIN
	DECLARE @sl int;
	SELECT @sl = COUNT(PostId)
	FROM Posts
	WHERE CreatedTime BETWEEN @From and @To
	RETURN @sl;
END
GO

SELECT dbo.func_CountPost('2023-11-15', '2023-11-20')

/*b. func_CountPostByYear(@FromYear int, @ToYear int) trả về bảng thống kê
số lượng bài viết và số lượng bài thảo luận của từng năm trong khoảng thời gian từ năm
@FromYear đến năm @ToYear. Yêu cầu kết quả thống kê phải hiển thị đủ tất cả các
năm trong khoảng thời gian trên (kể cả những năm không có bài viết hay bài thảo luận).*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_CountPostByYear')
DROP FUNCTION func_CountPostByYear;
GO
CREATE FUNCTION func_CountPostByYear 
(
	@FromYear int, 
	@ToYear int
)
RETURNS @tbl TABLE
(
	Nam int,
	SoLuong int
)
AS
BEGIN
	INSERT INTO @tbl(Nam, SoLuong)
	SELECT YEAR(p.CreatedTime) as Nam,
					COUNT(p.PostId)
	FROM Posts as p
	WHERE YEAR(p.CreatedTime) between @FromYear and @ToYear
	GROUP BY YEAR(p.CreatedTime)

	DECLARE @y int = @FromYear;
	WHILE @y <= @ToYear
	BEGIN
		IF NOT EXISTS (SELECT * FROM @tbl WHERE Nam = @y)
		INSERT INTO @tbl(Nam, SoLuong) VALUES(@y, 0)
		SET @y = @y + 1;
	END
	RETURN;
END
GO
SELECT * FROM dbo.func_CountPostByYear(2021, 2023)