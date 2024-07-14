-- Lập bảng thống kê doanh thu, doanh thu lũy kế và mức tăng giảm của từng ngày trong
-- khoảng thời gian từ ngày @fromDate đến ngày @toDate theo mẫu:
-- 4. Lập bảng thống kê doanh thu, doanh thu lũy kế và mức tăng giảm của từng ngày trong
--khoảng thời gian từ ngày @fromDate đến ngày @toDate theo mẫu:
--    Ngày           Doanh thu        Doanh thu lũy kế       Mức tăng giảm
-- 01/02/2018           1000               1000                     0
-- 02/02/2018            500               1500                   -500
-- 03/02/2018            700               2200                    200

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Tinh_SoLieuDoanhThuNgay')
	DROP PROCEDURE proc_Tinh_SoLieuDoanhThuNgay
GO

CREATE PROCEDURE proc_Tinh_SoLieuDoanhThuNgay
		@fromDate Date,
		@toDate Date
AS
BEGIN
	SET nocount on;
	DECLARE @tmpDate date = DATEFROMPARTS(YEAR(@fromDate), MONTH(@fromDate), DAY(@fromDate)), 
			@revenue MONEY, @cumulativeRevenue MONEY, @change MONEY;

	DECLARE @tbldoanhThuNgay TABLE (
		Ngay date,
		DoanhThu MONEY,
		DoanhThuLuyKe MONEY,
		MucTangGiam MONEY
	)

	SET @revenue = (SELECT SUM(Quantity * SalePrice)
			FROM OrderDetails AS od JOIN Orders AS o 
			ON od.OrderId = o.OrderId
			WHERE DATEDIFF(dd, OrderDate, @tmpDate) = 0
			GROUP BY DAY(OrderDate));
	-- SELECT @revenue

	INSERT INTO @tbldoanhThuNgay (Ngay, DoanhThu, DoanhThuLuyKe, MucTangGiam)
	VALUES                (@tmpDate, @revenue, @revenue, 0);

	SET @tmpDate = DATEADD(DAY, 1, @tmpDate);

	WHILE (DATEDIFF(dd, @tmpDate, @toDate) != 0)
	BEGIN
	  -- Tính toán doanh thu cho năm hiện tại và năm trước
		SET @revenue = (SELECT SUM(od.Quantity * od.SalePrice)
						FROM Orders AS o JOIN OrderDetails AS od 
						ON o.OrderId = od.OrderId
						WHERE DATEDIFF(dd, OrderDate, @tmpDate) = 0
						GROUP BY DAY(OrderDate));
	
		SET @cumulativeRevenue = @revenue + (SELECT DoanhThuLuyKe
											FROM @tbldoanhThuNgay
											WHERE Ngay = DATEADD(DAY, -1, @tmpDate))

		SET @change = @revenue - (SELECT SUM(od.Quantity * od.SalePrice)
								  FROM Orders AS o JOIN OrderDetails AS od 
								  ON o.OrderId = od.OrderId
								  WHERE o.OrderDate = DATEADD(DAY, -1, @tmpDate)
								  GROUP BY DAY(o.OrderDate));
  
	  -- Lưu kết quả vào bảng
	  INSERT INTO @tbldoanhThuNgay (Ngay, DoanhThu, DoanhThuLuyKe, MucTangGiam)
	  VALUES (@tmpDate, @revenue, @cumulativeRevenue, @change);
  
	  SET @tmpDate = DATEADD(DAY, 1, @tmpDate);;
	END;

	SELECT * FROM @tbldoanhThuNgay;
END
GO
DECLARE @fromDate date = '2017-06-12',
		@toDate date = '2017-07-22';
EXECUTE proc_Tinh_SoLieuDoanhThuNgay
			@fromDate = @fromDate,
			@toDate = @toDate