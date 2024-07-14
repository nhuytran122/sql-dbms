IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Tour_Search')
DROP PROCEDURE proc_Tour_Search
GO

CREATE PROCEDURE proc_Tour_Search
(
	@MaPhuongTien nvarchar(10),
	@LichTrinh nvarchar(50),
	@SoDong int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *, ROW_NUMBER() over(order by MaTour) as RowNumber
	INTO #TempTour
	FROM [21T1020080_Tour]

	SELECT @SoDong = COUNT(*)
	FROM [21T1020080_Tour]
	where (@MaPhuongTien = N'' AND MaPhuongTien = @MaPhuongTien) 
	AND (LichTrinh like @LichTrinh);

	;WITH cte as
	(
		SELECT * from #TempTour
		where (@MaPhuongTien = N'' AND MaPhuongTien = @MaPhuongTien) 
		AND (LichTrinh like @LichTrinh)
	)
	SELECT * FROM cte
	ORDER BY RowNumber
END
GO

--TEST
DECLARE @SoDong int;
EXECUTE proc_Tour_Search
	@MaPhuongTien = N'',
	@LichTrinh = N'abc',
	@SoDong = @SoDong OUTPUT;
	PRINT @SoDong;
GO

CREATE PROCEDURE HienThiTourCaoNhat
    @n INT,
    @TenTour NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    WITH cteTour AS (
        SELECT MaTour, TenTour, LichTrinh, GiaTour, lt.TenLoaiTour, 
			ROW_NUMBER() OVER (ORDER BY GiaTour DESC) AS RowNumber
        FROM [21T1020080_Tour] as t JOIN [21T1020080_LoaiTour] as lt
		ON t.MaLoaiTour = lt.MaLoaiTour
        WHERE TenTour LIKE '%' + @TenTour + '%'
    )
    SELECT MaTour, TenTour, LichTrinh, GiaTour, TenLoaiTour    
    FROM cteTour
    WHERE RowNumber <= @n;
END
