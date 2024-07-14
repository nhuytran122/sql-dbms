/*Câu 1: Viết các trigger sau đây (giả thiết mỗi lần bổ sung hoặc cập nhật dữ liệu chỉ tác
động trên một dòng):
a. Trigger trg_TaskAssignments_Insert bắt lệnh INSERT trên bảng TaskAssignments
sao cho mỗi khi bổ sung một dòng dữ liệu trong bảng này thì tính lại số lượng nhân viên
đã được giao việc thực hiện công việc (cột NumOfAssigned của bảng Tasks)*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Registration_Insert')
DROP TRIGGER trg_Registration_Insert;
GO
CREATE TRIGGER trg_TaskAssignments_Insert
ON TaskAssignments
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Tasks
	SET Tasks.NumOfAssigned = Tasks.NumOfAssigned + 1
	FROM Tasks INNER JOIN inserted ON Tasks.TaskId = inserted.TaskId
END
GO

-- TEST
INSERT INTO TaskAssignments(TaskId, EmployeeId, StartDate, EndDate)
VALUES  (1, 1, GETDATE(), NULL)
GO

INSERT INTO TaskAssignments(TaskId, EmployeeId, StartDate, EndDate)
VALUES  (1, 2, GETDATE(), NULL)
GO

INSERT INTO TaskAssignments(TaskId, EmployeeId, StartDate, EndDate)
VALUES  (2, 2, GETDATE(), NULL)
GO

INSERT INTO TaskAssignments(TaskId, EmployeeId, StartDate, EndDate)
VALUES  (3, 3, GETDATE(), NULL)
GO

INSERT INTO TaskAssignments(TaskId, EmployeeId, StartDate, EndDate)
VALUES  (3, 2, GETDATE(), NULL)
GO
/*b. Trigger trg_TaskAssignments_Update bắt lệnh UPDATE trên bảng
TaskAssignments sao cho mỗi khi cập nhật giá trị cột EndDate của một dòng trong
bảng này thì tính lại số lượng nhân viên đã hoàn thành công việc được giao (cột
NumOfFinished của bảng Tasks)*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_TaskAssignments_Update')
DROP TRIGGER trg_TaskAssignments_Update;
GO
CREATE TRIGGER trg_TaskAssignments_Update
ON TaskAssignments
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF UPDATE (EndDate)
		UPDATE Tasks
		SET NumOfFinished = NumOfFinished + 1
		FROM Tasks INNER JOIN inserted ON Tasks.TaskId = inserted.TaskId
		WHERE inserted.EndDate IS NOT NULL
END
GO

UPDATE TaskAssignments
SET EndDate = '2023-11-17'
WHERE TaskId = 1
AND EmployeeId = 1

UPDATE TaskAssignments
SET EndDate = '2023-11-18'
WHERE TaskId = 1
AND EmployeeId = 2

UPDATE TaskAssignments
SET EndDate = '2023-11-19'
WHERE TaskId = 2
AND EmployeeId = 2
go

/*c. Trigger trg_TaskAssignments_Delete bắt lệnh DELETE trên bảng TaskAssignments
sao cho mỗi khi xóa một dòng trong bảng TaskAssignments thì cập nhật lại số lượng
nhân viên được giao thực hiện công việc (cột NumOfAssigned) và số lượng nhân viên
hoàn thành công việc được giao (Cột NumOfFinished) của bảng Tasks.
Lưu ý: Một công việc được giao là hoàn thành nếu giá trị của cột EndDate khác NULL*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_TaskAssignments_Delete')
DROP TRIGGER trg_TaskAssignments_Delete;
GO
CREATE TRIGGER trg_TaskAssignments_Delete
ON TaskAssignments
FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Tasks
	SET Tasks.NumOfAssigned = Tasks.NumOfAssigned - 1
	FROM Tasks INNER JOIN deleted on Tasks.TaskId = deleted.TaskId

	UPDATE Tasks
	SET Tasks.NumOfFinished = Tasks.NumOfFinished - 1
	FROM Tasks INNER JOIN deleted on Tasks.TaskId = deleted.TaskId
	WHERE deleted.EndDate IS NOT NULL
END
GO

DELETE FROM TaskAssignments 
WHERE TaskId = 1
AND EmployeeId = 2
go

/*2. a. proc_TaskAssignments_Create
@TaskId int,
@EmployeeId int,
@StartDate date
@Result nvarchar(255) output
Có chức năng giao việc có mã @TaskId cho nhân viên có mã @EmployeeId. Tham số
đầu ra @Result trả về chuỗi rỗng trong trường hợp giao việc thành công; Trong trường
hợp ngược lại, tham số @Result trả về chuỗi cho biết lý do không giao được việc*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_TaskAssignments_Create')
DROP PROCEDURE proc_TaskAssignments_Create
GO
CREATE PROCEDURE proc_TaskAssignments_Create
	@TaskId int,
	@EmployeeId int,
	@StartDate date,
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT * FROM TaskAssignments WHERE EmployeeId = @EmployeeId AND TaskId = @TaskId)
	BEGIN
		SET @Result = 'Nhan vien da duoc giao viec nay';
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM Tasks WHERE TaskId = @TaskId)
	BEGIN
		SET @Result = 'Ma cong viec nay khong ton tai';
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM Employees WHERE EmployeeId = @EmployeeId)
	BEGIN
		SET @Result = 'Nhan vien nay khong ton tai';
		RETURN;
	END

	INSERT INTO TaskAssignments(TaskId, EmployeeId, StartDate, EndDate)
	VALUES  (@TaskId, @EmployeeId, @StartDate, NULL)

	/*UPDATE Tasks
	SET NumOfAssigned = NumOfAssigned + 1
	WHERE TaskId = @TaskId*/
END
GO

-- TEST
DECLARE @Result nvarchar(255);
EXECUTE proc_TaskAssignments_Create @TaskId = 1,
							@EmployeeId = 2,
							@StartDate = '2023-11-17',
							@Result = @Result OUTPUT;
PRINT @Result;
GO

/*b. proc_TaskAssignments_Update
@TaskId int,
@EmployeeId int,
@EndDate date,
@Result nvarchar(255) output
Có chức năng cập nhật ngày hoàn thành công việc (cột EndDate của bảng
TaskAssignments). Tham số đầu ra @Result trả về chuỗi rỗng nếu việc cập nhật thành
công, ngược lại tham số này trả về chuỗi cho biết lý do không cập nhật được dữ liệu.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_TaskAssignments_Update')
DROP PROCEDURE proc_TaskAssignments_Update
GO
CREATE PROCEDURE proc_TaskAssignments_Update
	@TaskId int,
	@EmployeeId int,
	@EndDate date,
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE TaskAssignments
		SET EndDate = @EndDate
		WHERE EmployeeId = @EmployeeId
		AND TaskId = @TaskId
	IF(@@ROWCOUNT < 1)
	BEGIN
		SET @Result = 'EmployeeId va TaskId khong trung khop trong he thong';
		RETURN;
	END
		
	/*UPDATE Tasks
		SET NumOfFinished = NumOfFinished + 1
		WHERE TaskId = @TaskId 
		AND @EndDate IS NOT NULL*/
END
GO

-- TEST
DECLARE @Result nvarchar(255);
EXECUTE proc_TaskAssignments_Update @TaskId = 1,
							@EmployeeId = 2,
							@EndDate = NULL,
							@Result = @Result output;
PRINT @Result;
GO

/*c. proc_Employees_Select
@SearchName nvarchar(255) = N'',
@Page int = 1,
@PageSize int = 20,
@RowCount int output,
@PageCount int output
Có chức năng tìm kiếm và hiển thị danh sách nhân viên dưới dạng phân trang dữ liệu.
Trong đó, @SearchName là giá trị cần tìm (tìm kiếm tương đối theo họ tên, nếu tham số
này là chuỗi rỗng thì không tìm kiếm), @Page là trang cần hiển thị, @PageSize là số
dòng dữ liệu được hiển thị trên mỗi trang, tham số đầu ra @RowCount cho biết tổng số
dòng dữ liệu và tham số đầu ra @PageCount cho biết tổng số trang.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Employees_Select')
DROP PROCEDURE proc_Employees_Select
GO
CREATE PROCEDURE proc_Employees_Select
	@SearchName nvarchar(255) = N'',
	@Page int = 1,
	@PageSize int = 20,
	@RowCount int output,
	@PageCount int output
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *, ROW_NUMBER() over(order by EmployeeName) as RowNumber
	INTO #TempEmployee
	FROM Employees

	-- @RowCount : Tham số đầu ra cho biết tổng số dòng dữ liệu tìm được
	SELECT @RowCount = COUNT(*)
	FROM Employees
	where (@SearchName = N'') or (EmployeeName like @SearchName);

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
		SELECT * from #TempEmployee
		where (@SearchName = N'') or (EmployeeName like @SearchName)
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
EXECUTE proc_Employees_Select
	@Page = 1,
	@PageSize = 10,
	@SearchName = N'',
	@RowCount = @RowCount OUTPUT,
	@PageCount = @PageCount OUTPUT
GO

/*d. proc_SummaryEndedTaskByDate
@From date,
@To date
Có chức năng thống kê số lượt công việc đã được ghi nhận hoàn thành của mỗi ngày
trong khoảng thời gian từ ngày @From đến ngày @To. Yêu cầu kết quả thống kê phải
hiển thị đầy đủ tất cả các ngày trong khoảng thời gian trên (những ngày không có công
việc được ghi nhận hoàn thành thì hiển thị với số lượng là 0)*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_SummaryEndedTaskByDate')
DROP PROCEDURE proc_SummaryEndedTaskByDate
GO
CREATE PROCEDURE proc_SummaryEndedTaskByDate
	@From date,
	@To date
AS
BEGIN
	SET NOCOUNT ON;
	WITH cte_Ngay as
	(
		SELECT @From as Ngay
		UNION all
		SELECT DATEADD(DAY, 1, Ngay)
		FROM cte_Ngay
		WHERE Ngay < @To
	)
	, cte_ThongKe as
	(
		SELECT t.EndDate, COUNT(*) as SoLuong
		FROM TaskAssignments as t
		WHERE t.EndDate between @From and @To
		GROUP BY t.EndDate
	)
	SELECT t1.Ngay, ISNULL(t2.SoLuong, 0) as SoLuongCVHoanThanh
	FROM cte_Ngay as t1
		LEFT JOIN cte_ThongKe as t2 on t1.Ngay = T2.EndDate
END
GO

-- Test
DECLARE @From date = '2023-11-16',
		@To date = '2023-11-26';
EXECUTE proc_SummaryEndedTaskByDate
		@From = @From,
		@To = @To;
go

/*Câu 3: Viết các hàm sau đây
a. func_CountNotEndTasks(@EmployeeId int) có chức năng đếm số lượng công việc
mà nhân viên có mã @EmployeeId chưa hoàn thành.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_CountNotEndTasks')
DROP FUNCTION func_CountNotEndTasks;
GO
CREATE FUNCTION func_CountNotEndTasks (@EmployeeId int)
RETURNS int
AS
BEGIN
	DECLARE @sl int;
	SELECT @sl = COUNT(TaskId) 
				 FROM TaskAssignments
				 WHERE EmployeeId = @EmployeeId
				 AND EndDate IS NULL
	RETURN @sl;
END
GO

SELECT dbo.func_CountNotEndTasks(2)

/*b. func_SummaryEndedTasksByDate(@From date, @To date) có chức năng trả về
bảng thống kê số lượng công việc hoàn thành của mỗi ngày trong khoảng thời gian từ
ngày @From đến ngày @To. Yêu cầu kết quả thống kê phải hiển thị đầy đủ tất cả các
ngày trong khoảng thời gian trên (những ngày không có công việc được ghi nhận hoàn
thành thì hiển thị với số lượng là 0)*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_SummaryEndedTasksByDate')
DROP FUNCTION func_SummaryEndedTasksByDate;
GO
CREATE FUNCTION func_SummaryEndedTasksByDate
(
	@From date,
	@To date
) 
RETURNS @tbl TABLE
(
	Ngay date primary key,
	SlCvHoanThanh int
)
BEGIN
	INSERT INTO @tbl(Ngay, SlCvHoanThanh)
		SELECT t.EndDate, COUNT(*) as SoLuong
		FROM TaskAssignments as t
		WHERE t.EndDate between @From and @To
		GROUP BY t.EndDate

	DECLARE @d date = @From;
	WHILE @d <= @To
	BEGIN
		-- Lệnh Exists chỉ để kiểm tra có hay không có data (số dòng trả về)
		IF NOT EXISTS (SELECT * FROM @tbl WHERE Ngay = @d)
		INSERT INTO @tbl(Ngay, SlCvHoanThanh) VALUES(@d, 0)
		SET @d = DATEADD(DAY, 1, @d);
	END
RETURN;
END
GO
--Test
SELECT *
FROM dbo.func_SummaryEndedTasksByDate('2023-11-16', '2023-11-26')