-- VD: Tạo thủ tục có 2 tham số @categoryName và @description có chức năng:
-- - Bổ dung thêm một loại hàng mới nếu @categoryName chưa tồn tại
-- - Ngược lại thì cập nhật Description cho loại hàng đã tồn tại
IF EXISTS (SELECT * FROM sys.objects
					 WHERE name = 'proc_Category_InsertOrUpdate')
		DROP PROCEDURE proc_Category_InsertOrUpdate
GO

CREATE PROCEDURE proc_Category_InsertOrUpdate
		@categoryName nvarchar(255),
		@description nvarchar(255)
AS
BEGIN
		SET NOCOUNT ON; --Tắt chế độ đếm số dòng tác động bởi câu lệnh
		IF NOT EXISTS(SELECT * FROM Categories WHERE CategoryName = @categoryName)
				INSERT INTO Categories(CategoryName, Description)
				VALUES (@categoryName, @description)
		ELSE 
			UPDATE Categories
			SET Description = @description
			WHERE CategoryName = @categoryName;
END
GO

-- Thực thi thủ tục
-- C1
EXECUTE proc_Category_InsertOrUpdate N'Thực phẩm', N'Cá, thịt, mắm,…'

-- C2
EXECUTE proc_Category_InsertOrUpdate
					@description = N'Các loại hàng thực phẩm', 
					@categoryName = N'Thực phẩm';


-- Viết thủ tục proc_Order_GetDetails
--					@orderId int
-- Có chức năng hiển thị danh sách các mặt hàng được bán trong đơn hàng có mã là 
-- @orderId, thông tin cần hiển thị bao gồm: mã hàng, tên hàng, đơn vị tính, 
-- số lượng bán, giá bán và thành tiền (thành tiền = số lượng bán * giá bán)
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Order_GetDetails')
	DROP PROCEDURE proc_Order_GetDetails
GO

CREATE PROCEDURE proc_Order_GetDetails
		@orderId int
AS
BEGIN
	SET nocount on;
	SELECT *
	FROM OrderDetails AS od JOIN Products as p
		ON p.ProductId = od.ProductId
	WHERE od.OrderId = @orderId;
END
GO
-- Test
EXECUTE proc_Order_GetDetails @orderID = 10250

-- VD: Viết thủ tục: proc_GetRevenueByDates
--							@fromDate date,
--							@toDate date,
--							@totalRevenue money output
-- Có chức năng hiển thị doanh thu bán hàng từng ngày trong khoảng thời gian từ ngày 
-- @fromDate đến ngày @toDate, đồng thời cho biết tổng doanh thu trong khoảng thời gian 
-- trên thông qua tham số đầu ra @totalRevenue
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_GetRevenueByDates')
	DROP PROCEDURE proc_Order_GetDetails
GO
CREATE PROCEDURE proc_GetRevenueByDates
	@fromDate date,
	@toDate date,
	@totalRevenue money output
AS
BEGIN
	SET nocount on;
	WITH cte_Ngay as
	(
		SELECT @fromDate as SummaryDate
		UNION all
		SELECT DATEADD(DAY, 1, SummaryDate)
		FROM cte_Ngay
		WHERE SummaryDate < @toDate
	)
	, cte_ThongKe as
	(
		SELECT O.OrderDate, SUM(od.Quantity * od.SalePrice) as Revenue
		FROM Orders as o JOIN OrderDetails as od on o.OrderId = od.OrderId
		WHERE o.OrderDate between @fromDate and @toDate
		GROUP BY OrderDate
	)
	SELECT t1.SummaryDate, ISNULL(t2.Revenue, 0) as Revenue
	FROM cte_Ngay as t1
		LEFT JOIN cte_ThongKe as t2 on t1.SummaryDate = t2.OrderDate

	SELECT @totalRevenue = SUM(od.Quantity * od.SalePrice)
	FROM Orders AS o join OrderDetails as od on o.OrderId = od.OrderId
	WHERE o.OrderDate between @fromDate and @toDate;
END
GO

-- Test case
DECLARE @fromDate date = '2018/02/01',
		@toDate date = '2018/02/28',
		@totalRevenue money;
EXECUTE proc_GetRevenueByDates
		@fromDate = @fromDate,
		@toDate = @toDate,
		@totalRevenue = @totalRevenue output;
SELECT @totalRevenue AS totalRevenue

-- Tham số đầu vào kiểu bảng
-- VD: Viết thủ tục proc_Order_Create có chức năng khởi tạo một đơn hàng 
-- và danh mục được bán hàng trong đơn hàng đó. Đầu vào của thủ tục bao gồm:
--			- Ngày lập đơn hàng
--			- Danh sách các mặt hàng được bán trong đơn hàng (mỗi mặt hàng bao 
-- gồm các thông tin là mã hàng, số lượng và giá bán)
-- Tham số đầu ra cho biết mã đơn hàng được tạo và tổng số tiền của đơn hàng 
-- là bao nhiêu? (CHÚ Ý: Cột OrderID của bảng Orders có tính chất IDENTITY)
CREATE TYPE TypeOrderDetails AS TABLE
(
	ProductId int primary key,
	Quantity int,
	SalePrice money
)
GO

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_GetRevenueByDates')
	DROP PROCEDURE proc_GetRevenueByDates;  
GO

CREATE PROCEDURE proc_Order_Create 
	@orderDate date,
	@orderDatails TypeOrderDetails readonly,
	@orderID int output,
	@sumOfPrice money output
AS
BEGIN
	SET nocount on;
	-- Tạo đơn hàng mới
	INSERT INTO Orders(OrderDate) values (@orderDate);

	SET @orderID = SCOPE_IDENTITY();
	-- SET @orderID = @@IDENTITY;: lấy giá trị indentity sinh ra ở lệnh gần nhất

	-- Bổ sung chi tiết đơn hàng
	INSERT INTO OrderDetails(OrderId, ProductId, Quantity, SalePrice)
	SELECT @orderID, ProductID, Quantity, SalePrice
	FROM @orderDatails;

	-- Tính tổng tiền
	SELECT @sumOfPrice = SUM(Quantity * SalePrice)
	FROM @orderDatails

END
GO

-- test
DECLARE @orderDetails TypeOrderDetails,
		@orderID int,
		@sumOfPrice money;
INSERT INTO @orderDetails VALUES(1, 20, 20.00),
								(2, 5, 25.00),
								(3, 2, 15.00)

EXECUTE proc_Order_Create 
		@orderDate = '2023/10/09',
		@orderDatails = @orderDetails,
		@orderID = @orderID output,
		@sumOfPrice = @sumOfPrice output;

SELECT @orderID, @sumOfPrice

/* SELECT *
FROM OrderDetails as od JOIN Products as p ON od.ProductId = p.ProductId
WHERE */