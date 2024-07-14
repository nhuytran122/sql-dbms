-- 2. Nhằm phân tích số liệu kinh doanh của các năm trong khoảng thời gian từ năm
-- @fromYear cho đến năm @toYear, ta cần bảng kết quả thống kê theo mẫu sau:
-- Năm       Doanh thu      Doanh thu lũy kế       Mức tăng giảm
-- 2010        1000              1000                     0
-- 2011        500               1500                   -500
-- 2012        700               2200                    200
--  ...        ...                ...                    ...
-- Yêu cầu số liệu thống kê phải đầy đủ các năm trong khoảng thời gian cần thống kê, trong đó:
--        - Doanh thu lũy kế = Doanh thu năm hiện tại + Doanh thu lũy kế năm trước
--        (Doanh thu lũy kế năm đầu tiên chính là doanh thu của năm đó)
--		  - Mức tăng giảm = Doanh thu năm hiện tại – Doanh thu năm trước
--        (Mức tăng giảm của năm đầu tiên là 0)

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Tinh_SoLieuDoanhThuNam')
	DROP PROCEDURE proc_Tinh_SoLieuDoanhThuNam
GO

CREATE PROCEDURE proc_Tinh_SoLieuDoanhThuNam
		@fromYear int,
		@toYear int
AS
BEGIN
	SET nocount on;
	DECLARE @tmpYear INT, @revenue MONEY, @cumulativeRevenue MONEY, @change MONEY;
	DECLARE @tbldoanhThu TABLE (
		Nam INT,
		DoanhThu MONEY,
		DoanhThuLuyKe MONEY,
		MucTangGiam MONEY
	)
	SET @revenue = ( SELECT SUM(Quantity * SalePrice)
			FROM OrderDetails AS od JOIN Orders AS o 
			ON od.OrderId = o.OrderId
			WHERE YEAR(OrderDate) = @fromYear
			GROUP BY YEAR(OrderDate));

	INSERT INTO @tbldoanhThu (Nam, DoanhThu, DoanhThuLuyKe, MucTangGiam)
	VALUES                (@fromYear, @revenue, @revenue, 0);
	SET @tmpYear = @fromYear + 1;

	WHILE (@tmpYear <= @toYear)
		BEGIN
		  -- Tính toán doanh thu cho năm hiện tại và năm trước
			SET @revenue = (SELECT SUM(od.Quantity * od.SalePrice)
							FROM Orders AS o JOIN OrderDetails AS od 
							ON o.OrderId = od.OrderId
							WHERE YEAR(o.OrderDate) = @tmpYear
							GROUP BY YEAR(o.OrderDate));
	
			SET @cumulativeRevenue = @revenue + (SELECT DoanhThuLuyKe
												FROM @tbldoanhThu
												WHERE Nam = @tmpYear - 1);

			SET @change = @revenue - (SELECT SUM(od.Quantity * od.SalePrice)
									 FROM Orders AS o JOIN OrderDetails AS od 
									 ON o.OrderId = od.OrderId
									 WHERE YEAR(o.OrderDate) = @tmpYear - 1
									 GROUP BY YEAR(o.OrderDate));
  
		  -- Lưu kết quả vào bảng
		  INSERT INTO @tbldoanhThu (Nam, DoanhThu, DoanhThuLuyKe, MucTangGiam)
		  VALUES (@tmpYear, @revenue, @cumulativeRevenue, @change);
  
		  SET @tmpYear = @tmpYear + 1;
		END;
	SELECT * FROM @tbldoanhThu;
END
GO

DECLARE @fromYear INT = 2017,
		@toYear INT = 2020;
EXECUTE proc_Tinh_SoLieuDoanhThu
		@fromYear = @fromYear,
		@toYear = @toYear
