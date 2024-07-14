-- 3. Lập bảng thống kê kê doanh thu, doanh thu lũy kế và mức tăng giảm của từng tháng
-- trong năm @year theo mẫu:
-- Tháng       Doanh thu      Doanh thu lũy kế       Mức tăng giảm
--   1            1000              1000                     0
--   2            500               1500                   -500
--   3            700               2200                    200
DECLARE @year INT = 2017;
DECLARE @thang INT = 1;
DECLARE @tmpMonth INT, @revenue MONEY, @cumulativeRevenue MONEY, @change MONEY;

DECLARE @tbldoanhThuThang TABLE (
    Thang INT,
    DoanhThu MONEY,
    DoanhThuLuyKe MONEY,
    MucTangGiam MONEY
)

SET @revenue = (SELECT SUM(Quantity * SalePrice)
		FROM OrderDetails AS od JOIN Orders AS o 
		ON od.OrderId = o.OrderId
		WHERE MONTH(OrderDate) = @thang
		GROUP BY MONTH(OrderDate));
-- SELECT @revenue

INSERT INTO @tbldoanhThuThang (Thang, DoanhThu, DoanhThuLuyKe, MucTangGiam)
VALUES                (@thang, @revenue, @revenue, 0);

SET @tmpMonth = @thang + 1;

WHILE (@tmpMonth <= 12)
BEGIN
  -- Tính toán doanh thu cho năm hiện tại và năm trước
	SET @revenue = (SELECT SUM(od.Quantity * od.SalePrice)
					FROM Orders AS o JOIN OrderDetails AS od 
					ON o.OrderId = od.OrderId
					WHERE MONTH(o.OrderDate) = @tmpMonth
					GROUP BY MONTH(o.OrderDate));
	
    SET @cumulativeRevenue = @revenue + (SELECT DoanhThuLuyKe
										FROM @tbldoanhThuThang
										WHERE Thang = @tmpMonth - 1);

    SET @change = @revenue - (SELECT SUM(od.Quantity * od.SalePrice)
							 FROM Orders AS o JOIN OrderDetails AS od 
							 ON o.OrderId = od.OrderId
							 WHERE MONTH(o.OrderDate) = @tmpMonth - 1
							 GROUP BY MONTH(o.OrderDate));
  
  -- Lưu kết quả vào bảng
  INSERT INTO @tbldoanhThuThang (Thang, DoanhThu, DoanhThuLuyKe, MucTangGiam)
  VALUES (@tmpMonth, @revenue, @cumulativeRevenue, @change);
  
  SET @tmpMonth = @tmpMonth + 1;
END;

SELECT * FROM @tbldoanhThuThang;
