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
		ngayOrder date
	)

DECLARE @tmp date = DATEFROMPARTS(YEAR(@fromDate), MONTH(@fromDate), DAY(@fromDate))
WHILE (DATEDIFF(dd, @tmp, @toDate) != 0)
	BEGIN
		insert into @tblNgay values (@tmp);
		set @tmp = DATEADD(day, 1, @tmp);
	END

select t1.ngayOrder, ISNULL (t2.revenue, 0) as revenue
from @tblNgay AS t1
LEFT JOIN
(
	select o.OrderDate, SUM(od.Quantity * od.SalePrice) as Revenue
	from Orders as o join OrderDetails as od 
	ON o.OrderId = od.OrderId
	group by o.OrderDate
) as t2 
ON t1.ngayOrder = t2.OrderDate
GO

-- 2. Nhằm phân tích số liệu kinh doanh của các năm trong khoảng thời gian từ năm
-- @fromYear cho đến năm @toYear, ta cần bảng kết quả thống kê theo mẫu sau:
-- Yêu cầu số liệu thống kê phải đầy đủ các năm trong khoảng thời gian cần thống kê, trong đó:
-- Doanh thu lũy kế = Doanh thu năm hiện tại + Doanh thu lũy kế năm trước
-- (Doanh thu lũy kế năm đầu tiên chính là doanh thu của năm đó)
-- Mức tăng giảm = Doanh thu năm hiện tại – Doanh thu năm trước
-- (Mức tăng giảm của năm đầu tiên là 0)
-- Hãy giải quyết yêu cầu trên theo các cách sau:
--      Cách 1: Sử dụng biến bảng (hoặc bảng tạm) có cấu trúc như bảng minh họa
-- ở trên, xử lý và lưu trữ kết quả xử lý được vào biến bảng (hoặc bảng tạm).
--      Cách 2: Sử dụng biểu thức bảng.
DECLARE @fromYear int = 2018,
		@toYear int = 2020;

DECLARE @tbldoanhThu TABLE (
    Nam int,
    DoanhThu int,
    DoanhThuLuyKe int,
    MucTangGiam int
)

DECLARE @tmpYear int = @fromYear,
        @tmpDthu money,
		@DthuLuyKe money,
		@tmpDthutruoc money;

SELECT @tmpDthu = SUM(Quantity * SalePrice)
    FROM OrderDetails AS od JOIN Orders AS o 
	ON od.OrderId = o.OrderId
    WHERE YEAR(OrderDate) = @fromYear
	GROUP BY YEAR(OrderDate);
-- Khởi tạo giá trị ban đầu
INSERT INTO @tbldoanhThu (Nam, DoanhThu, DoanhThuLuyKe, MucTangGiam)
VALUES                (@fromYear, @tmpDthu, @tmpDthu, 0)
	
DECLARE @prevYear int = @fromYear
SET @tmpYear = @tmpYear + 1;

WHILE @tmpYear <= @toYear
BEGIN
	SELECT @tmpDthu = SUM(Quantity * SalePrice)
    FROM OrderDetails AS od JOIN Orders AS o 
	ON od.OrderId = o.OrderId
    WHERE YEAR(OrderDate) = @tmpYear
	GROUP BY YEAR(OrderDate);

	SELECT @tmpDthutruoc = SUM(Quantity * SalePrice)
    FROM OrderDetails AS od JOIN Orders AS o 
	ON od.OrderId = o.OrderId
    WHERE YEAR(OrderDate) = @prevYear
	GROUP BY YEAR(OrderDate);

	-- Doanh thu lũy kế = Doanh thu năm hiện tại + Doanh thu lũy kế năm trước
	

	INSERT INTO @tbldoanhThu (Nam, DoanhThu, DoanhThuLuyKe, MucTangGiam)
	VALUES                (@tmpYear, @tmpDthu, @DthuLuyKe, @tmpDthu - @tmpDthutruoc)
    SET @tmpYear = @tmpYear + 1
    SET @prevYear = @prevYear + 1
END

-- Truy vấn kết quả từ biến bảng (hoặc bảng tạm)
SELECT * FROM @tbldoanhThu

-- Câu 5:
DECLARE @thang int = 2,
		@nam int = 2018;

--SELECT  o.OrderDate as Ngay,
--		SUM(od.Quantity * od.SalePrice)
--FROM Orders as o JOIN OrderDetails as od
--ON o.OrderId = od.OrderId
--GROUP BY o.OrderDate

DECLARE @ngayDauThang date = DATEFROMPARTS(@nam, @thang, 1);
DECLARE @ngayCuoiThang date = DATEADD(DAY, -1, DATEADD(MONTH, 1, @ngayDauThang));

DECLARE @ngayDauTuan date = DATEADD(DAY
							, CHOOSE(DATEPART(WEEKDAY, @ngayDauThang), -6, 0, -1, -2, -3, -4, -5)
							,  @ngayDauThang);

DECLARE @ngayCuoiTuan date = DATEADD(DAY, 6, @ngayDauTuan);

WITH cte_Tuan AS
(
	SELECT @ngayDauTuan as TuNgay, @ngayCuoiTuan as DenNgay
	UNION ALL
	SELECT DATEADD(DAY, 7, TuNgay), DATEADD(DAY, 7, DenNgay)
	FROM cte_Tuan
	WHERE DATEADD(DAY, 7, TuNgay) <= @ngayCuoiThang
)
, cte_DoanhThuNgay as
(
	SELECT o.OrderDate as Ngay,
		SUM(od.Quantity * od.SalePrice) as DoanhThu
	FROM Orders as o JOIN OrderDetails as od
	ON o.OrderId = od.OrderId
	WHERE MONTH(o.OrderDate) = @thang AND YEAR(o.OrderDate) = @nam
	GROUP BY o.OrderDate
)

SELECT  t1.TuNgay, t1.DenNgay,
		SUM(IIF(DATEPART(WEEKDAY, t2.Ngay) = 2, t2.DoanhThu, 0)) as Thu2,
		SUM(IIF(DATEPART(WEEKDAY, t2.Ngay) = 3, t2.DoanhThu, 0)) as Thu3,
		SUM(IIF(DATEPART(WEEKDAY, t2.Ngay) = 4, t2.DoanhThu, 0)) as Thu4,
		SUM(IIF(DATEPART(WEEKDAY, t2.Ngay) = 5, t2.DoanhThu, 0)) as Thu5,
		SUM(IIF(DATEPART(WEEKDAY, t2.Ngay) = 6, t2.DoanhThu, 0)) as Thu6,
		SUM(IIF(DATEPART(WEEKDAY, t2.Ngay) = 7, t2.DoanhThu, 0)) as Thu7,
		SUM(IIF(DATEPART(WEEKDAY, t2.Ngay) = 1, t2.DoanhThu, 0)) as ChuNhat,
		SUM(t2.DoanhThu) as TongTrongTuan

FROM  cte_Tuan as t1
	  LEFT JOIN cte_DoanhThuNgay AS t2
	  ON t1.TuNgay < t2.Ngay AND t1.DenNgay >= t2.Ngay
GROUP BY t1.TuNgay, t1.DenNgay
