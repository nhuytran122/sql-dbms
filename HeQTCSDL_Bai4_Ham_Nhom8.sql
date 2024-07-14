BÀI 4: HÀM

4.1. Hàm là gì?

- Tương tự như thủ tục, hàm là đối tượng của CSDL, khi có lời gọi thì các lệnh
  bên trong hàm sẽ được thực thi và trả kết quả về cho lời gọi hàm.
- Giữa hàm và thủ tục có sự khác biệt về cách sử dụng:
	+ Thủ tục được xem như một câu lệnh khi gọi và có thể sử dụng một cách độc lập.
	  Kết quả của thủ tục được trả về cho Client 
	  
	  Ví dụ: sp_who là một thủ tục của SQL Server => để thực hiện lời gọi, ta có thể
	  viết lệnh:

				sp_who
		hoặc:	execute sp_who

	+ Hàm khi sử dụng phải nằm bên trong một câu lệnh khác tại vị trí phù hợp với kiểu
	  trả về của hàm. Kết quả của hàm không trả về cho Client mà trả về cho câu lệnh
	  thực hiện lời gọi hàm (Hàm không thể sử dụng một cách độc lập như thủ tục)

	  Ví dụ: Hàm getdate() của SQL Server cho biết thời gian hiện tại của hệ thống.
	  Để sử dụng hàm này, chúng ta không thể viết như sau:

			getdate()

	  Có thể viết như sau:

			SELECT getdate()

	  hoặc:
			
			DECLARE @d date
			SET @d = getdate();
			PRINT @d;

Cũng tương tự như thủ tục, trong SQL Server có các hàm do hệ thống định nghĩa sẵn và người
sử dụng có thể tự định nghĩa hàm.

Trong SQL Server, hàm được chia thành 2 loại:
- Hàm scalar (scalar function): Kết quả trả về của hàm là một giá trị thuộc vào các kiểu
  dữ liệu chuẩn (số, ngày, chuỗi,...)
- Hàm có dữ liệu trả về dạng bảng (table-valued function): Kết quả trả về của hàm là tập
  các dòng và các cột dưới dạng bảng, chia thành 2 loại:
		+ Inline table-valued function
		+ Multi-statement table-valued function

4.2. Scalar function

- Hàm dạng này trả về một giá trị
- Có thể sử dụng tại những vị trí mà một biểu thức là được cho phép, phù hợp với kiểu
  dữ liệu trả về của hàm.

  Ví dụ: Hàm YEAR(d) trong SQL Server là hàm dạng Scalar

		SELECT YEAR('2023/10/16')

- Để tạo hàm, sử dụng lệnh CREATE FUNCTION theo cú pháp

		CREATE FUNCTION Tên_hàm(Danh_sách_tham_số)
		RETURNS Kiểu_dữ_liệu_trả_về_của_hàm
		AS
		BEGIN
			Phần thân của hàm
		END
		GO

Trong đó:
	+ Cho dù có hay không có tham số, cặp dấu () bắt buộc phải có sau tên hàm.
	+ Các tham số của hàm khai báo theo cú pháp:
			@Tên_tham_số   Kiểu_dữ_liệu
	  và phân cách nhau bởi dấu phẩy.
	+ Với hàm, không thể sử dụng tham số kiểu bảng như thủ tục.
	+ Phần thân của thủ tục: là nơi lập trình để xử lý và trả về kết quả về cho hàm, cần
	  lưu ý:
			+ Sử dụng lệnh
					RETURN Giá_trị
			  để trả dữ liệu về cho hàm.
			+ Không được sử dụng các lệnh có trả dữ liệu về cho Client bên trong phần
			  thân của hàm.
	+ Tên hàm phải duy nhất trong CSDL, vì vậy các hàm do người định nghĩa nên đặt tên
	  với tiền tố để phân biệt và tránh bị trùng tên (vd: fn_, func_, uf_,...)

Ví dụ: Viết hàm fn_GetWeekDayName có chức năng trả về tên của thứ (bằng tiếng Việt) tương
ứng với một ngày nào đó

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_GetWeekDayName')
	DROP FUNCTION fn_GetWeekDayName;
GO

CREATE FUNCTION fn_GetWeekDayName
(
	@d date
)
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @weekDayName nvarchar(50);

	SET @weekDayName = CASE DATEPART(WEEKDAY, @d) 
							WHEN 2 THEN N'Thứ hai'
							WHEN 3 THEN N'Thứ ba'
							WHEN 4 THEN N'Thứ tư'
							WHEN 5 THEN N'Thứ năm'
							WHEN 6 THEN N'Thứ sáu'
							WHEN 7 THEN N'Thứ bảy'
							ELSE N'Chủ nhật'
					   END 
	
	RETURN @weekDayName;					   
END
GO

-- Test

PRINT dbo.fn_GetWeekDayName('2023/10/16')

SELECT dbo.fn_GetWeekDayName(getdate())


Ví dụ: Viết hàm fn_GetRevenueOfMonth có chức năng tính tổng doanh bán hàng của một
tháng thuộc một năm nào đó

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'fn_GetRevenueOfMonth')
	DROP FUNCTION fn_GetRevenueOfMonth;
GO

CREATE FUNCTION fn_GetRevenueOfMonth
(
	@month int,
	@year int
)
RETURNS money
AS
BEGIN
	IF @month NOT BETWEEN 1 AND 12
		RETURN 0;

	DECLARE @fromDate date = DATEFROMPARTS(@year, @month, 1);
	DECLARE @toDate date = EOMONTH(@fromDate, 0);

	DECLARE @totalRevenue money;

	SELECT	@totalRevenue = SUM(od.Quantity * od.SalePrice)
	FROM	Orders as o
			JOIN OrderDetails as od on o.OrderId = od.OrderId
	WHERE	o.OrderDate BETWEEN @fromDate AND @toDate;

	RETURN @totalRevenue;
END
GO

-- Test:

SELECT dbo.fn_GetRevenueOfMonth(2, 2018)


4.3. Hàm với giá trị trả về kiểu bảng (table-valued function)

- Kết quả trả về của hàm là 1 bảng
- Hàm dạng này có thể sử dụng ở những vị trí mà một bảng là được cho phép
  (Sau FROM)
- Hàm dạng này chia thành 2 loại:
	+ inline function:	Là loại hàm mà kết quả trả về của hàm chỉ cần giải quyết bởi
					    duy nhất 1 câu lệnh SELECT (trong phần thân của hàm chỉ là 
						một câu lệnh SELECT)
	+ multi-statement function: là loại hàm mà bên trong phần thân của hàm có thể sử dụng
	                    kết hợp nhiều lệnh để lập trình.



4.3.1 Inline Function

Cú pháp:

			CREATE FUNCTION Tên_hàm(Danh_sách_tham_số)
			RETURNS TABLE
			AS
			RETURN
			(
				Câu_lệnh_SELECT_trả_dữ_liệu_về_cho_hàm
			)

Ví dụ: Viết hàm fn_GetRevenueByDates có chức năng trả về bảng cho biết doanh thu
bán hàng từng ngày trong khoảng thời gian từ ngày @fromDate cho đến ngày @toDate
(Chỉ cần thống kê các ngày có dữ liệu)

IF EXISTS(SELECT * FROM sys.objects WHERE name='fn_GetRevenueByDates')
	DROP FUNCTION fn_GetRevenueByDates;
GO

CREATE FUNCTION fn_GetRevenueByDates
(
	@fromDate date, 
	@toDate date
)
RETURNS TABLE
AS
RETURN 
(
	SELECT	o.OrderDate, 
			SUM(od.Quantity * od.SalePrice) AS Revenue
	FROM	Orders as o JOIN OrderDetails as od on o.OrderId = od.OrderId
	WHERE	o.OrderDate BETWEEN @fromDate AND @toDate
	GROUP BY o.OrderDate
)
GO

-- Test 
SELECT	*
FROM	dbo.fn_GetRevenueByDates('2017/12/1', '2017/12/31')


4.3.2. Multi-Statement Function

Cú pháp: 

		CREATE FUNCTION Tên_hàm(Danh_sách_tham_số)
		RETURNS @Tên_biến TABLE
		(
			Cấu_trúc_của_bảng_chứa_dữ_liệu_trả_về
		)
		AS
		BEGIN
			-- Các lệnh lập trình trong phần thân của hàm
			
			RETURN;			
		END
		GO

Lưu ý:
- Phải định nghĩa cấu trúc của bảng chứa dữ liệu trả về
- Cuối cùng của phần thân hàm phải là lệnh RETURN và chỉ có duy nhất 1 lệnh
  RETURN trong thân hàm (Dữ liệu được return chính là @Tên_biến).
- Trong quá trình lập trình trong hàm, phải đưa được dữ liệu và @Tên_biến.
- Trong thân hàm không được sử dụng lệnh có trả dữ liệu về cho Client.


Ví dụ: Viết hàm fn_GetRevenueByFullDates có chức năng trả về dữ liệu cho biết doanh thu
bán hàng từng ngày trong khoảng thời gian từ ngày @fromDate đến ngày @toDate.
Yêu cầu phải đủ tất cả các ngày (không dùng CTE)

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'fn_GetRevenueByFullDates')
	DROP FUNCTION fn_GetRevenueByFullDates;
GO

CREATE FUNCTION fn_GetRevenueByFullDates
(
	@fromDate date,
	@toDate date
)
RETURNS @tbl TABLE
(
	SummaryDate date primary key,
	Revenue money
)
AS
BEGIN
	
	INSERT INTO @tbl(SummaryDate, Revenue)
		SELECT	o.OrderDate, 
				SUM(od.Quantity * od.SalePrice)
		FROM	Orders as o JOIN OrderDetails as od on o.OrderId = od.OrderId
		WHERE	o.OrderDate BETWEEN @fromDate AND @toDate
		GROUP BY o.OrderDate

	DECLARE @d date = @fromDate;

	WHILE @d <= @toDate
		BEGIN
			IF NOT EXISTS(SELECT * FROM @tbl WHERE SummaryDate = @d)
				INSERT INTO @tbl(SummaryDate, Revenue) VALUES(@d, 0);

			SET @d = DATEADD(DAY, 1, @d);
		END

	RETURN;
END
GO

-- Test:
SELECT * FROM dbo.fn_GetRevenueByFullDates('2017/12/1','2017/12/31')





















