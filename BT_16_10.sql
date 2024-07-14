-- C1: Viết hàm fn_GetFirstDateOfWeek để lấy ngày đầu tuần của một ngày bất kỳ (đầu tuần là thứ 2)
-- VD: fn_GetFirstDateOfWeek (’2023/10/18’) —> ‘2023/10/16’
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_GetFirstDateOfWeek')
	DROP FUNCTION fn_GetFirstDateOfWeek;
GO

CREATE FUNCTION fn_GetFirstDateOfWeek
(
	@day date
)
RETURNS date
AS
BEGIN
    DECLARE @ngayDauTuan date = DATEADD(DAY
							, CHOOSE(DATEPART(WEEKDAY, @day), -6, 0, -1, -2, -3, -4, -5)
							 ,  @day); 
	RETURN @ngayDauTuan    
END
GO

SELECT DBO.fn_GetFirstDateOfWeek('2023/10/18')

-- C2: Viết hàm fn_GetRevenueByDateOfMonth có chức năng trả về một bảng cho biết doanh thu bán hàng 
-- của từng ngày trong tháng @month năm @year. Yêu cầu phải thống kê đủ tất cả các ngày trong tháng.
-- Viết bằng 2 cách:
-- Cách 1: Sử dụng inline funtion
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_GetRevenueByDateOfMonth')
	DROP FUNCTION fn_GetRevenueByDateOfMonth;
GO

CREATE FUNCTION fn_GetRevenueByDateOfMonth 
(
	@month int,
	@year int
)
RETURNS TABLE
AS 
RETURN
(
         SELECT o.OrderDate, SUM(od.Quantity * od.SalePrice) AS Revenue
		 FROM Orders as o JOIN OrderDetails as od
		 on o.OrderId = od.OrderId
		 WHERE MONTH(o.OrderDate) = @month and YEAR(o.OrderDate) = @year
		 GROUP BY o.OrderDate
)
GO

SELECT *
FROM dbo.fn_GetRevenueByDateOfMonth(12, 2017)

-- Cách 2: Sử dụng multi-statement function
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_GetRevenueByDateOfMonth')
	DROP FUNCTION fn_GetRevenueByDateOfMonth;
GO

CREATE FUNCTION fn_GetRevenueByDateOfMonth 
(
	@month int,
	@year int
)
RETURNS @DoanhThuNgay TABLE
(
        NgayOrder date,
		DoanhThu money
)
AS
BEGIN
		DECLARE @tblNgay Table
		(
			Ngay date
		)
		DECLARE @ngay date = DATEFROMPARTS(@year, @month, 1)
		WHILE (month(@ngay) = @month)
			BEGIN
				insert into @tblNgay values (@ngay);
				set @ngay = DATEADD(day, 1, @ngay);
			END
		INSERT @DoanhThuNgay (NgayOrder, DoanhThu)
			SELECT t1.Ngay, ISNULL (t2.revenue, 0) as revenue
			FROM @tblNgay AS t1
			LEFT JOIN
			(
				SELECT o.OrderDate, SUM(od.Quantity * od.SalePrice) as Revenue
				FROM Orders AS o
				join OrderDetails as od ON o.OrderId = od.OrderId
				WHERE month(o.OrderDate) = @month and YEAR(o.OrderDate) = @year
				GROUP BY o.OrderDate
			) AS t2 
			ON t1.Ngay = t2.OrderDate
        
        RETURN;
END
GO
SELECT *
FROM dbo.fn_GetRevenueByDateOfMonth(8, 2017)
-- 1. Viết hàm fn_GetUnsignString để chuyển một chuỗi ký tự có dấu (tiếng Việt) thành chuỗi không dấu
-- VD: fn_GetUnsignString (N’Trường Đại học Khoa học’)
-- —> ‘Truong Dai hoc Khoa hoc’