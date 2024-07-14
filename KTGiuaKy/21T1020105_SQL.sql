/*Câu 1: Viết các trigger sau đây (giả thiết mỗi lần bổ sung hoặc cập nhật dữ liệu chỉ tác động trên một
dòng):
a. Trigger trg_PayrollSheet_Insert bắt lệnh INSERT trên bảng PayrollSheet sao cho mỗi
khi bổ sung một bảng lương thì tự động bổ sung danh sách các nhân viên đang làm việc vào danh sách
nhân viên được hưởng lương (bảng PayrollSheetDetails)*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_PayrollSheet_Insert')
DROP TRIGGER trg_PayrollSheet_Insert;
GO

CREATE TRIGGER trg_PayrollSheet_Insert
ON PayrollSheet
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO PayrollSheetDetails (PayYear, PayMonth, EmployeeId)
    SELECT i.PayYear, i.PayMonth, E.EmployeeId
    FROM Employees AS E
    INNER JOIN inserted AS i ON E.IsWorking = 1;
END
GO
INSERT INTO PayRollSheet (PayYear, PayMonth, CreatedDate, TotalOfSalary)
VALUES (2023, 10, GETDATE() , 0);

/*b. Trigger trg_PayrollSheetDetails_Update bắt lệnh UPDATE trên bảng
PayrollSheetDetails sao cho khi thay đổi tiền công mỗi ngày (cột SalaryPerDay) hoặc số
ngày công (cột NumberOfWorkedDays) của một dòng trong bảng này thì tính lại giá trị cột
TotalOfSalary (tổng tiền lương của tháng) trong bảng PayrollSheet*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_PayrollSheetDetails_Update')
DROP TRIGGER trg_PayrollSheetDetails_Update;
GO

CREATE TRIGGER trg_PayrollSheetDetails_Update
ON PayRollSheetDetails
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ps
    SET TotalOfSalary = (SELECT SUM(psd.NumberOfWorkedDays * psd.SalaryPerDay)
                         FROM PayRollSheetDetails psd
                         WHERE psd.PayYear = ps.PayYear AND psd.PayMonth = ps.PayMonth)
    FROM PayRollSheet ps
    INNER JOIN inserted i ON ps.PayYear = i.PayYear AND ps.PayMonth = i.PayMonth;
END;
GO

UPDATE PayRollSheetDetails
SET SalaryPerDay = 120, NumberOfWorkedDays = 22
WHERE PayYear = 2023 AND PayMonth = 1 AND EmployeeId = 2;

/*Câu 2: Viết các thủ tục sau đây:
a. proc_PayrollSheet_Insert
@Year int,
@Month int,
@CreatedDate date,
@Result int output

Có chức năng bổ sung bảng lương tháng @Month năm @Year vào bảng lương (Payrollsheet).
Tham số đầu ra @Result trả về giá trị 1 nếu bổ sung bảng lương thành công; Ngược lại, tham số này
trả về giá trị nhỏ hơn hoặc bằng 0 nhằm cho biết lý do không bổ sung được dữ liệu.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_PayrollSheet_Insert')
DROP PROCEDURE proc_PayrollSheet_Insert
GO

CREATE PROCEDURE proc_PayrollSheet_Insert
    @Year INT,
    @Month INT,
    @CreatedDate DATE,
    @Result INT OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM PayrollSheet WHERE PayYear = @Year AND PayMonth = @Month)
    BEGIN
        SET @Result = 0;
    END
    ELSE
    BEGIN
        INSERT INTO PayrollSheet (PayYear, PayMonth, CreatedDate, TotalOfSalary)
        VALUES (@Year, @Month, @CreatedDate, 0);

        IF @@ROWCOUNT > 0
        BEGIN
            SET @Result = 1;
        END
        ELSE
        BEGIN
            SET @Result = 0;
        END
    END
END;
GO

DECLARE @Result int;
EXECUTE proc_PayrollSheet_Insert
					@Year = 2023,
					@Month = 12,
					@CreatedDate = '2023-12-11',
					@Result = @Result output;

SELECT @Result

/*b. proc_PayrollSheetDetails_Update
@Year int,
@Month int,
@EmployeeId int,
@SalaryPerDay money,
@NumberOfWorkedDays int

Có chức năng cập nhật giá trị tiền công mỗi ngày và số ngày công của nhân viên (bảng
PayrollSheetDetails). Lưu ý số ngày công không được nhiều hơn số ngày của tháng.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_PayrollSheetDetails_Update')
DROP PROCEDURE proc_PayrollSheetDetails_Update
GO
--proc_PayrollSheetDetails_Update
CREATE PROCEDURE proc_PayrollSheetDetails_Update
    @Year INT,
    @Month INT,
    @EmployeeId INT,
    @SalaryPerDay MONEY,
    @NumberOfWorkedDays INT
AS
BEGIN
    -- Kiểm tra số ngày công không được nhiều hơn số ngày của tháng
    IF @NumberOfWorkedDays > DAY(EOMONTH(DATEFROMPARTS(@Year, @Month, 1)))
    BEGIN
        PRINT 'Số ngày công không hợp lệ.';
        RETURN;
    END

    UPDATE PayrollSheetDetails
    SET
        SalaryPerDay = @SalaryPerDay,
        NumberOfWorkedDays = @NumberOfWorkedDays
    WHERE
        PayYear = @Year
        AND PayMonth = @Month
        AND EmployeeId = @EmployeeId;
END;
GO

DECLARE @Result INT;

EXEC proc_PayrollSheet_Insert
    @Year = 2023,
    @Month = 5,
    @CreatedDate = '2023-05-06',
    @Result = @Result OUTPUT;

IF @Result = 1
    PRINT 'Bảng lương đã được bổ sung thành công.';
ELSE
    PRINT 'Không thể bổ sung bảng lương.';

EXEC proc_PayrollSheetDetails_Update
    @Year = 2023,
    @Month = 12,
    @EmployeeId = 2,
    @SalaryPerDay = 150,
    @NumberOfWorkedDays = 18;


/*c. proc_ListEmployees

@SearchValue nvarchar(255) = N’’,
@Page int = 1,
@PageSize int = 20,
@RowCount int output

Có chức năng tìm kiếm và hiển thị danh sách nhân viên dưới dạng phân trang dữ liệu. Trong đó,
@SearchValue là giá trị cần tìm (tìm kiếm tương đối theo tên nhân viên, nếu tham số này là chuỗi
rỗng thì không tìm kiếm), @Page là trang cần hiển thị, @PageSize là số dòng dữ liệu được hiển thị
trên mỗi trang, tham số đầu ra @RowCount cho biết tổng số dòng dữ liệu.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_ListEmployees')
DROP PROCEDURE proc_ListEmployees
GO
CREATE PROCEDURE proc_ListEmployees
	@SearchValue nvarchar(255) = N'',
	@Page int = 1,
	@PageSize int = 20,
	@RowCount int output
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *, ROW_NUMBER() over(order by EmployeeId) as RowNumber
	INTO #TempEmployee
	FROM Employees

	-- @RowCount : Tổng số dòng dữ liệu tìm được
	SELECT @RowCount = COUNT(*)
	FROM Employees
	where (@SearchValue = N'') or (EmployeeName like @SearchValue);

	WITH cte AS (
        SELECT EmployeeId, EmployeeName, ROW_NUMBER() OVER (ORDER BY EmployeeId) AS RowNum
        FROM Employees
        WHERE @SearchValue = N'' or EmployeeName like @SearchValue)
    SELECT EmployeeId, EmployeeName
    FROM cte
    WHERE RowNum BETWEEN ((@Page - 1) * @PageSize + 1) AND (@Page * @PageSize);
END
GO

--TEST
DECLARE @RowCount int;

EXECUTE proc_ListEmployees
	@SearchValue = N'',
	@Page = 1,
	@PageSize = 20,
	@RowCount = @RowCount OUTPUT
GO

/*d. proc_EmployeeSalaryByYear
@EmployeeId int
@FromYear int
@ToYear int

Có chức năng thống kê tổng số tiền lương mà nhân viên có mã @EmployeeId nhận trong từng năm
trong khoảng thời gian từ năm @FromYear đến năm @ToYear. Yêu cầu kết quả thống kê phải hiển
thị đủ tất cả các năm trong khoảng thời gian trên (năm không nhận lương thì hiển thị với tổng số tiền
lương là 0).
Lưu ý: Tiền lương tính theo công thức: SalaryPerDay * NumberOfWorkedDays*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_EmployeeSalaryByYear')
DROP PROCEDURE proc_EmployeeSalaryByYear
GO

CREATE PROCEDURE proc_EmployeeSalaryByYear
    @EmployeeId INT,
    @FromYear INT,
    @ToYear INT
AS
BEGIN
    CREATE TABLE #SalaryYear (
        Nam INT,
        TotalSalary MONEY
    );

    DECLARE @tmpyear INT = @FromYear;
    WHILE @tmpyear <= @ToYear
    BEGIN
        INSERT INTO #SalaryYear (Nam, TotalSalary)
        SELECT @tmpyear, ISNULL(SUM(SalaryPerDay * NumberOfWorkedDays), 0) AS TotalSalary
        FROM PayrollSheetDetails
        WHERE   PayYear = @tmpyear
				AND EmployeeId = @EmployeeId;
        SET @tmpyear = @tmpyear + 1;
    END;
    SELECT * FROM #SalaryYear;

END;
GO

EXECUTE proc_EmployeeSalaryByYear
	@EmployeeId = 2,
    @FromYear = 2020,
    @ToYear = 2023
GO

/*Câu 3: Viết các hàm sau đây
a. func_TotalSalaryByEmployee(@EmployeeId int) có chức năng tính tổng số tiền lương
mà nhân viên có mã @EmployeeId đã nhận.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_TotalSalaryByEmployee')
	DROP FUNCTION func_TotalSalaryByEmployee;
GO

CREATE FUNCTION func_TotalSalaryByEmployee
(
    @EmployeeId INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @TtSalary MONEY;

    SELECT @TtSalary = SUM(SalaryPerDay * NumberOfWorkedDays)
    FROM PayrollSheetDetails
    WHERE EmployeeId = @EmployeeId;

    RETURN @TtSalary;
END;
GO
SELECT dbo.func_TotalSalaryByEmployee(2)
go

/*b. func_GetPayrollSheet(@Year int, @Month int) có chức năng hiển thị bảng lương của
các nhân viên trong tháng @Month năm @Year. Số liệu hiển thị bao gồm thông tin về nhân viên, tiền
công mỗi ngày, số ngày công và tiền lương được nhận.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_GetPayrollSheet')
	DROP FUNCTION func_GetPayrollSheet;
GO

CREATE FUNCTION func_GetPayrollSheet
(
    @Year INT,
    @Month INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        E.EmployeeId, E.EmployeeName, PS.SalaryPerDay, PS.NumberOfWorkedDays, PS.SalaryPerDay * PS.NumberOfWorkedDays AS TotalSalary
    FROM
        Employees as E
    LEFT JOIN
        PayrollSheetDetails PS ON E.EmployeeId = PS.EmployeeId
                                 AND PS.PayYear = @Year
                                 AND PS.PayMonth = @Month
);
GO
SELECT *
FROM dbo.func_GetPayrollSheet(2023, 12);