-- a. Thống kê tổng doanh thu bán hàng trong từng năm trong khoảng thời gian từ năm
-- @fromYear cho đến năm @toYear. Số liệu thống kê phải đầy đủ tất cả các năm
-- trong khoảng thời gian này, những năm không có doanh thu thì hiển thị số liệu doanh thu là 0.
DECLARE @fromYear int = 2018,
		@toYear int = 2020;

CREATE table #tblNam
(
Nam int
)

DECLARE @tmpYear int = @fromYear;
WHILE (@tmpYear <= @toYear)
	BEGIN
		INSERT INTO #tblNam VALUES (@tmpYear);
		SET @tmpYear += 1;
	END
SELECT t1.Nam, ISNULL(t2.DoanhThu, 0) as DoanhThu
FROM #tblNam as t1
	LEFT JOIN 
	(
		select YEAR(o.OrderDate) as Nam,
				SUM(od.Quantity * od.SalePrice) AS DoanhThu
		FROM Orders AS o JOIN OrderDetails AS od 
		on o.OrderId = od.OrderId
		GROUP BY YEAR(o.OrderDate)
	) as t2
	ON t1.Nam = t2.Nam
DROP TABLE #tblNam
GO

-- b. Thống kê tổng doanh thu bán hàng trong từng tháng của năm @year. Số liệu
-- thống kê phải đầy đủ 12 tháng của năm, những tháng không có doanh thu thì hiển
-- thị số liệu doanh thu là 0.
DECLARE @year int = 2017, 
		@month int = 1;
DECLARE @tblThang Table
	(
		Thang int
	)
WHILE (@month <= 12)
	BEGIN
		INSERT INTO @tblThang VALUES (@month);
		SET @month += 1;
	END

SELECT t1.Thang, ISNULL(t2.DoanhThu, 0) as DoanhThu
FROM @tblThang as t1
	LEFT JOIN 
	(
		select MONTH(o.OrderDate) as thang,
				SUM(od.Quantity * od.SalePrice) AS DoanhThu
		FROM Orders AS o JOIN OrderDetails AS od 
		on o.OrderId = od.OrderId
		WHERE YEAR(o.OrderDate) = @year
		GROUP BY MONTH(o.OrderDate)
	) as t2
	ON t1.Thang = t2.thang
GO

-- c. Thống kê tổng doanh thu bán hàng trong từng ngày trong khoảng thời gian từ ngày
-- @fromDate cho đến ngày @toDate. Số liệu thống kê phải đầy đủ các ngày trong
-- khoảng thời gian này, những ngày không có doanh thu thì hiển thị số liệu doanh thu là 0.

-- DATEFROMPARTS(year, month, day)
DECLARE @fromDate date = DATEFROMPARTS(2017, 06, 12),
		@toDate date = DATEFROMPARTS(2017, 07, 22);

DECLARE @tblNgay Table
	(
		 ngay date
	)

DECLARE @tmp date = DATEFROMPARTS(YEAR(@fromDate), MONTH(@fromDate), DAY(@fromDate))
WHILE (DATEDIFF(dd, @tmp, @toDate) != 0)
	BEGIN
		insert into @tblNgay values (@tmp);
		set @tmp = DATEADD(day, 1, @tmp);
	END

select t1.ngay, ISNULL(t2.revenue, 0) as Revenue
from @tblNgay AS t1
LEFT JOIN
(
	select o.OrderDate, SUM(od.Quantity * od.SalePrice) as Revenue
	from Orders as o join OrderDetails as od 
	ON o.OrderId = od.OrderId
	group by o.OrderDate
) as t2 
ON t1.ngay = t2.OrderDate
GO
