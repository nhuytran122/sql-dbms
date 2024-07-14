-- Câu 5: Với đầu vào là tháng @month năm @year, hãy lập một bảng thống kê tổng doanh
-- thu bán hàng trong từng ngày của hàng tuần và tổng doanh thu hàng tuần theo mẫu
-- sau (giả sử với @month = 10 và @year = 2023)
-- Trong đó: TuNgay và DenNgay là ngày đầu tuần và ngày cuối tuần (ngày đầu tuần được tính từ thứ hai)

--SELECT  o.OrderDate as Ngay,
--		SUM(od.Quantity * od.SalePrice)
--FROM Orders as o JOIN OrderDetails as od
--ON o.OrderId = od.OrderId
--GROUP BY o.OrderDate
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_proc_Tinh_SoLieuDoanhThuNgayTuan')
	DROP PROCEDURE proc_proc_Tinh_SoLieuDoanhThuNgayTuan
GO

CREATE PROCEDURE proc_proc_Tinh_SoLieuDoanhThuNgayTuan
		@month int,
		@year int
AS
BEGIN
	SET nocount on;
	DECLARE @ngayDauThang date = DATEFROMPARTS(@year, @month, 1);
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
		WHERE MONTH(o.OrderDate) = @month AND YEAR(o.OrderDate) = @year
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
END
GO

DECLARE @thang int = 2,
		@nam int = 2018;
EXECUTE proc_proc_Tinh_SoLieuDoanhThuNgayTuan
				@month = @thang,
				@year = @nam