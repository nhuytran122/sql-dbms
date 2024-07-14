IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_GetRevenueByDateAndAmount')
	DROP FUNCTION fn_GetRevenueByDateAndAmount;
GO
CREATE FUNCTION fn_GetRevenueByDateAndAmount 
(
	@CardTypeId int,
	@FromTime datetime,
	@ToTime datetime
)
RETURNS @tblDoanhThu TABLE
(	a50k money,
	a100k money,
	a200k money,
	a500k money,
	Tong money
)
AS
BEGIN
	DECLARE @tblNgay Table
	(
		 ngay date
	)
	DECLARE @tmp date = DATEFROMPARTS(YEAR(@FromTime), MONTH(@FromTime), DAY(@ToTime))
	WHILE (DATEDIFF(dd, @tmp, @ToTime) != 0)
	BEGIN
		insert into @tblNgay values (@tmp);
		set @tmp = DATEADD(day, 1, @tmp);
	END
	-- Nếu tham số @CardTypeId = 0 thì thống kê doanh thu của tất cả loại thẻ
	IF (@CardTypeId = 0)
		BEGIN
			INSERT @tblDoanhThu
				SELECT CreatedTime AS Ngay,
						SUM(CASE WHEN Amount = 50000 THEN Amount ELSE 0 END) AS '50k',
						SUM(CASE WHEN Amount = 100000 THEN Amount ELSE 0 END) AS '100k',
						SUM(CASE WHEN Amount = 200000 THEN Amount ELSE 0 END) AS '200k',
						SUM(CASE WHEN Amount = 500000 THEN Amount ELSE 0 END) AS '500k',
						SUM(Amount) AS 'Tong doanh thu'
				FROM CardStore JOIN Invoice ON CardStore.InvoiceId = Invoice.InvoiceId
				WHERE CardStore.CardTypeId = @CardTypeId AND CreatedTime >= @FromTime  AND CreatedTime <= @ToTime
				GROUP BY CreatedTime, CardStore.CardTypeId
		END
	ELSE
		BEGIN 
			INSERT @tblDoanhThu (Ngay, DoanhThu)
				SELECT t1.ngay, ISNULL(t2.DoanhThu, 0) as Revenue
				FROM @tblNgay AS t1
				LEFT JOIN
				(
					SELECT CreatedTime, SUM(Amount) as DoanhThu
					FROM CardStore JOIN Invoice ON CardStore.InvoiceId = Invoice.InvoiceId
					WHERE CardStore.CardTypeId = @CardTypeId AND CreatedTime >= @FromTime  AND CreatedTime <= @ToTime
					GROUP BY CreatedTime, CardStore.CardTypeId
				) AS t2 
				ON t1.ngay = t2.CreatedTime
		END
	RETURN;
END
GO