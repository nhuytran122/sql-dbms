-- Cau 6
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Customer_Select')
DROP PROCEDURE proc_Customer_Select
GO

CREATE PROCEDURE proc_Customer_Select
(
	@Page int = 0,
	@PageSize int = 0,
	@SearchValue nvarchar(255) = N'',
	@RowCount int OUTPUT,
	@PageCount int OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *, ROW_NUMBER() over(order by CustomerName) as RowNumber
	INTO #TempCustomer
	FROM Customer

	SELECT @RowCount = COUNT(*)
	FROM Customer
	where (@SearchValue = N'') or (CustomerName like @SearchValue);

	IF(@PageSize = 0)
		SET @PageCount = 1
	ELSE
		BEGIN
			SET @PageCount = @RowCount / @PageSize;
			IF (@RowCount % @PageSize > 0)
				SET @PageCount += 1;
		END;


	;WITH cte as
	(
		SELECT * from #TempCustomer
		where (@SearchValue = N'') or (CustomerName like @SearchValue)
	)
	SELECT * FROM cte
	where (@PageSize = 0) or
			RowNumber between (@Page - 1) * @PageSize + 1 AND @Page * @PageSize
	ORDER BY RowNumber
END
GO

--TEST
DECLARE @RowCount int,
		@PageCount int 
EXECUTE proc_Customer_Select
	@Page = 1,
	@PageSize = 10,
	@SearchValue = N'',
	@RowCount = @RowCount OUTPUT,
	@PageCount = @PageCount OUTPUT
GO