-- Câu 1: Viết các trigger sau đây (giả thiết mỗi lần bổ sung hoặc cập nhật dữ liệu chỉ tác
-- động trên một dòng):
/*a. Trigger trg_Registration_Insert bắt lệnh INSERT trên bảng Registration sao
cho mỗi khi bổ sung thêm một dòng dữ liệu trong bảng này thì cập nhật lại số
lượng người đăng ký dự thi chứng chỉ (cột NumberOfRegister) trong bảng
Certificate*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Registration_Insert')
DROP TRIGGER trg_Registration_Insert;
GO
CREATE TRIGGER trg_Registration_Insert
ON Registration
FOR INSERT
AS
BEGIN
	UPDATE Certificate
	SET Certificate.NumberOfRegister = Certificate.NumberOfRegister + 1
	FROM Certificate INNER JOIN inserted ON Certificate.CertificateId = inserted.CertificateId
END
GO
-- TEST
INSERT INTO Registration(ExamineeId, CertificateId, RegisterTime, ExamResult)
VALUES  (1, 1, GETDATE(), 0)
GO

INSERT INTO Registration(ExamineeId, CertificateId, RegisterTime, ExamResult)
VALUES  (2, 3, GETDATE(), 0)
GO

/*b. Trigger trg_Registration_Update bắt lệnh UPDATE trên bảng Registration sao
cho khi cập nhật giá trị cột ExamResult của một dòng trong bảng này thì đồng
thời cập nhật lại số lượng người đã thi đạt chứng chỉ (cột NumberOfPass) trong
bảng Certificate
*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Registration_Update')
DROP TRIGGER trg_Registration_Update;
GO
CREATE TRIGGER trg_Registration_Update
ON Registration
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF UPDATE (ExamResult)
		UPDATE Certificate
		SET Certificate.NumberOfPass = Certificate.NumberOfPass + 1
		FROM Certificate INNER JOIN inserted ON Certificate.CertificateId = inserted.CertificateId
		WHERE inserted.ExamResult >=5
END
GO
-- TEST
UPDATE Registration
SET ExamResult = 6
WHERE CertificateId = 1
AND ExamineeId = 1
GO

UPDATE Registration
SET ExamResult = 4
WHERE CertificateId = 3
AND ExamineeId = 2
GO

/*c. Trigger trg_Registration_Delete bắt lệnh UPDATE trên bảng Registration sao
cho khi xóa một dòng dữ liệu trong bảng này thì cập nhật lại số lượng người đăng
ký (cột NumberOfRegister) và số người thi đạt chứng chỉ (cột NumberOfPass)
trong bảng Certificate*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_Registration_Delete')
DROP TRIGGER trg_Registration_Delete;
GO
CREATE TRIGGER trg_Registration_Delete
ON Registration
FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Certificate
		SET Certificate.NumberOfRegister = Certificate.NumberOfRegister - 1
		FROM Certificate INNER JOIN deleted ON Certificate.CertificateId = deleted.CertificateId

	UPDATE Certificate
		SET Certificate.NumberOfPass = Certificate.NumberOfPass - 1
		FROM Certificate INNER JOIN deleted ON Certificate.CertificateId = deleted.CertificateId
		WHERE deleted.ExamResult >=5
END
GO
-- TEST
DELETE FROM Registration
WHERE CertificateId = 1
AND ExamineeId = 1

/*Câu 2: Viết các thủ tục sau đây:
a. proc_Registration_Add
@ExamineeId int,
@CertificateId int,
@Result nvarchar(255) output
Có chức năng bổ sung một hồ sơ đăng ký dự thi chứng chỉ. Nếu bổ sung thành công,
tham số @Result trả về chuỗi rỗng, ngược lại tham số này trả về chuỗi cho biết lý do
không bổ sung được đăng ký.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Registration_Add')
DROP PROCEDURE proc_Registration_Add
GO
CREATE PROCEDURE proc_Registration_Add
	@ExamineeId int,
	@CertificateId int,
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT * FROM Registration WHERE ExamineeId = @ExamineeId AND CertificateId = @CertificateId)
	BEGIN
		SET @Result = 'Thi sinh da dang ki chung chi nay';
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM Certificate WHERE CertificateId = @CertificateId)
	BEGIN
		SET @Result = 'Ma chung chi nay khong ton tai';
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM Examinee WHERE ExamineeId = @ExamineeId)
	BEGIN
		SET @Result = 'Thi sinh nay khong ton tai';
		RETURN;
	END

	INSERT INTO Registration(ExamineeId, CertificateId, RegisterTime, ExamResult)
	VALUES(@ExamineeId, @CertificateId, GETDATE(), 0)

	/*UPDATE Certificate
	SET NumberOfRegister = NumberOfRegister + 1
	WHERE CertificateId = @CertificateId*/
END
GO
-- TEST
DECLARE @Result nvarchar(255);
EXECUTE proc_Registration_Add @ExamineeId = 1,
							@CertificateId = 1,
							@Result = @Result OUTPUT;
PRINT @Result;
GO

/*b. proc_SaveExamResult
@ExamineeId int,
@CertificateId int,
@ExamResult int,
@Result nvarchar(255) output
Có chức năng cập nhật điểm thi chứng chỉ. Trong đó lưu ý điểm thi phải là giá trị từ 0
đến 10. Nếu cập nhật thành công, tham số @Result trả về chuỗi rỗng, ngược lại tham số
này trả về chuỗi cho biết lý do không cập nhật được điểm thi.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_SaveExamResult')
DROP PROCEDURE proc_SaveExamResult
GO
CREATE PROCEDURE proc_SaveExamResult
	@ExamineeId int,
	@CertificateId int,
	@ExamResult int,
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;
	IF @ExamResult < 0 OR @ExamResult > 10 
	BEGIN
		SET @Result = 'Diem thi khong hop le';
		RETURN;
	END

	UPDATE Registration
		SET ExamResult = @ExamResult
		WHERE CertificateId = @CertificateId
		AND ExamineeId = @ExamineeId
	IF(@@ROWCOUNT < 1)
	BEGIN
		SET @Result = 'ExamineeId va CertificateId khong trung khop trong he thong';
		RETURN;
	END
		
	/*UPDATE Certificate
		SET NumberOfPass = NumberOfPass + 1
		WHERE CertificateId = @CertificateId
		AND @ExamResult >= 5*/
END
GO
-- TEST
DECLARE @Result nvarchar(255);
EXECUTE proc_SaveExamResult @ExamineeId = 1,
							@CertificateId = 3,
							@ExamResult = 6,
							@Result = @Result OUTPUT;
PRINT @Result;
GO

/*c. proc_Examinee_Select
@SearchValue nvarchar(255) = N'',
@Page int = 1,
@PageSize int = 20,
@RowCount int output,
@PageCount int output
Có chức năng tìm kiếm và hiển thị danh sách người dự thi dưới dạng phân trang dữ liệu.
Trong đó, 
@SearchValue là giá trị cần tìm (tìm kiếm tương đối theo họ tên, nếu tham số
này là chuỗi rỗng thì không tìm kiếm), 
@Page là trang cần hiển thị, 
@PageSize là số
dòng dữ liệu được hiển thị trên mỗi trang, 
tham số đầu ra @RowCount cho biết tổng số dòng dữ liệu và tham số đầu ra 
@PageCount cho biết tổng số trang.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Examinee_Select')
DROP PROCEDURE proc_Examinee_Select
GO
CREATE PROCEDURE proc_Examinee_Select
	@SearchValue nvarchar(255) = N'',
	@Page int = 1,
	@PageSize int = 20,
	@RowCount int output,
	@PageCount int output
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *, ROW_NUMBER() over(order by ExamineeId) as RowNumber
	INTO #TempExaminee
	FROM Examinee

	-- @RowCount : Tham số đầu ra cho biết tổng số dòng dữ liệu tìm được
	SELECT @RowCount = COUNT(*)
	FROM Examinee
	where (@SearchValue = N'') or (FirstName like @SearchValue or LastName like @SearchValue);

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
		SELECT * from #TempExaminee
		where (@SearchValue = N'') or (FirstName like @SearchValue or LastName like @SearchValue)
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
EXECUTE proc_Examinee_Select
	@Page = 1,
	@PageSize = 10,
	@SearchValue = N'',
	@RowCount = @RowCount OUTPUT,
	@PageCount = @PageCount OUTPUT
GO

/*d. proc_CountRegisteringByDate
@From date,
@To date
Có chức năng thống kê số lượng đăng ký dự thi của mỗi ngày trong khoảng thời gian từ
ngày @From đến ngày @To. Yêu cầu kết quả thống kê phải hiển thị đầy đủ tất cả các
ngày trong khoảng thời gian trên (những ngày không có người đăng ký dự thi thì hiển thị
với số lượng là 0).*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_CountRegisteringByDate')
DROP PROCEDURE proc_CountRegisteringByDate
GO
CREATE PROCEDURE proc_CountRegisteringByDate
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
		SELECT r.RegisterTime, COUNT(*) as SoLuong
		FROM Registration as r
		WHERE r.RegisterTime between @From and @To
		GROUP BY RegisterTime
	)
	SELECT t1.Ngay, ISNULL(t2.SoLuong, 0) as SoLuong
	FROM cte_Ngay as t1
		LEFT JOIN cte_ThongKe as t2 on t1.Ngay = t2.RegisterTime
END
GO

-- Test
DECLARE @From date = '2023-11-16',
		@To date = '2023-11-26';
EXECUTE proc_CountRegisteringByDate
		@From = @From,
		@To = @To;
go
/*Câu 3: Viết các hàm sau đây
a. func_CountPassed(@ExamineeId int) có chức năng tính số lượng chứng chỉ mà
người dự thi có mã @ExamineeId đã thi đạt.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_CountPassed')
DROP FUNCTION func_CountPassed;
GO
CREATE FUNCTION func_CountPassed (@ExamineeId int)
RETURNS int
AS
BEGIN
	DECLARE @sl int;
	SELECT @sl = COUNT(CertificateId)
				 FROM Registration
				 WHERE ExamineeId = @ExamineeId
				 AND ExamResult >=5
	RETURN @sl;
END
GO

SELECT dbo.func_CountPassed(1)

/*b. func_TotalByDate(@From date, @To date) có chức năng trả về bảng thống kê số
lượng đăng ký dự thi của mỗi ngày trong khoảng thời gian từ ngày @From đến ngày
@To. Yêu cầu kết quả thống kê phải hiển thị đầy đủ tất cả các ngày trong khoảng thời
gian trên (những ngày không có người đăng ký dự thi thì hiển thị với số lượng là 0).*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_TotalByDate')
DROP FUNCTION func_TotalByDate;
GO
CREATE FUNCTION func_TotalByDate
(
	@From date,
	@To date
) 
RETURNS @tbl TABLE
(
	Ngay date primary key,
	Sl int
)
BEGIN
	INSERT INTO @tbl(Ngay, Sl)
		SELECT r.RegisterTime, COUNT(*) as SoLuong
		FROM Registration as r
		WHERE r.RegisterTime between @From and @To
		GROUP BY RegisterTime
	DECLARE @d date = @From;
	WHILE @d <= @To
	BEGIN
		-- Lệnh Exists chỉ để kiểm tra có hay không có data (số dòng trả về)
		IF NOT EXISTS (SELECT * FROM @tbl WHERE Ngay = @d)
		INSERT INTO @tbl(Ngay, Sl) VALUES(@d, 0)
		SET @d = DATEADD(DAY, 1, @d);
	END
RETURN;
END
GO
--Test
SELECT *
FROM dbo.func_TotalByDate('2023-11-16', '2023-11-26')