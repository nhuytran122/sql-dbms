BÀI 2: LẬP TRÌNH VỚI T-SQL

(T-SQL: Transact-SQL)

2.1. Một số quy tắc chung khi lập trình với T-SQL

- Một lệnh có thể viết trên nhiều dòng.
- Kết thúc lệnh có thể có dấu chấm phẩy hoặc không đều được.
- Một khối lệnh được viết trong cặp từ khóa:
	begin

	end
- Kết thúc tập lệnh sử dụng từ khóa GO
- Không phân biệt chữ hoa và chữ thường

2.2.Khai báo biến

- Biến phải khai báo trước khi sử dụng
- Cú pháp:

	DECLARE @Tên_biến Kiểu_dữ_liệu [= Giá_trị_khởi_tạo]

- Lưu ý:
	+ Tên biến phải bắt đầu bởi 1 dấu @
	+ Có thể khai báo nhiều biến bởi cùng 1 lệnh DECLARE, phân cách
	  bởi dấu phẩy.

Ví dụ:
	DECLARE	@firstName nvarchar(50),
			@lastName nvarchar(50),
			@age int = 40;
	SELECT @firstName, @lastName, @age;

2.3. Phép gán

Trong T-SQL, có 2 cách để viết phép gán:
- Cách 1: Dùng lệnh SET theo cú pháp
		
		SET @Tên_biến = Biểu_thức
  
  (Lưu ý: Trong SQL, một câu lệnh SELECT trả về 1 cột và tối đa 1 dòng
   được xem là một biểu thức)

Ví dụ:
	
	DECLARE @name nvarchar(50),
			@id int;

	SET @id = 2;
	SET @name = (SELECT CustomerName from Customers WHERE CustomerId = @id);

	PRINT @name;
	GO

	Mỗi lệnh SET chỉ thực hiện phép gán cho 1 biến (không viết gộp)

- Cách 2: Sử dụng lệnh SELECT 
  Cú pháp:
		SELECT	@Tên_biến_1 = Biểu_thức,
				@Tên_biến_2 = Biểu_thức_2,
				....
				@Tên_biến_n = Biểu_thức_N
		FROM	...
		WHERE	...
		....
Phép gán này thường dùng để truy vấn dữ liệu và lưu kết quả vào biến

Ví dụ:

	DECLARE	@firstName nvarchar(50),
			@lastName nvarchar(50),
			@id int;

	SELECT	@id = 10;

	SELECT	@firstName = FirstName, @lastName = LastName 
	FROM	Employees
	WHERE	EmployeeID = @id;

	PRINT @firstName;
	PRINT @lastName;
	
	GO

2.4. Cấu trúc điều khiển 
Có 2 loại: rẽ nhánh và lặp

- Rẽ nhánh:
	
	IF điều_kiện
		Khối_lệnh_của_IF
	ELSE 
		Khối_lệnh_của_ELSE

- Lặp

	WHILE điều_kiện
		Khối_lệnh_của_WHILE 

  Chú ý: Có thể sử dụng lệnh BREAK và CONTINUE trong vòng lặp WHILE

Ví dụ: Viết vòng lặp chạy in ra các số từ 1 đến 10 và cho biết đó là
số lẻ hay chẵn.

	DECLARE	@i int = 1;

	WHILE @i <= 10
		BEGIN
			IF (@i % 2 = 0)
				PRINT STR(@i) + N' là số chẵn'
			ELSE 
				PRINT STR(@i) + N' là số lẻ'

			SET @i += 1;
		END
	GO

2.5. Biến kiểu bảng 

- Trong T-SQL không có các kiểu dữ liệu trừu tượng như trong các NNLT
  (struct, array, list, object,...)
- Biến kiểu bảng trong T-SQL có thể dùng để biểu diễn dữ liệu "phức tạp"

Để khai báo biến kiểu bảng, sử dụng cú pháp
	
	DECLARE @Tên_biến TABLE
	(
		Khai_báo_các_cột_của_bảng_(như_lệnh_CREATE_TABLE)
	)

- Một biến kiểu bảng sử dụng để lưu trữ dữ liệu dưới dạng tập các dòng và các
  cột.
- Không thể sử dụng các lệnh GÁN thông thường cho biến kiểu bảng.
- Trên biến kiểu bảng, chỉ dùng các lệnh SELECT, INSERT, UPDATE và DELETE 

Ví dụ: Viết một đoạn chương trình để tạo ra một biến bảng có 2 cột:
		- Ngay  date
		- Thu	nvarchar(50)
Đưa vào bảng này danh sách các ngày và thứ (tiếng Việt) của một tháng @m
năm @y nào đó.

DECLARE	@m int = 2,
		@y int = 2023;

DECLARE	@tblThuNgay TABLE
(
	Ngay Date primary key,
	Thu nvarchar(50)
)

DECLARE @ngay date,
		@ngayCuoiThang date,
		@thu nvarchar(50);

SET @ngay = DATEFROMPARTS(@y, @m, 1);
SET @ngayCuoiThang = DATEADD(DAY, -1, DATEADD(month, 1, @ngay));

WHILE @ngay <= @ngayCuoiThang 
	BEGIN
		-- Lấy thứ của @ngay
		SET @thu = CASE DATEPART(WEEKDAY, @ngay)
						WHEN 2 THEN N'Thứ hai'
						WHEN 3 THEN N'Thứ ba'
						WHEN 4 THEN N'Thứ tư'
						WHEN 5 THEN N'Thứ năm'
						WHEN 6 THEN N'Thứ sáu'
						WHEN 7 THEN N'Thứ bảy'
						ELSE N'Chủ nhật'
				   END
		
		INSERT INTO @tblThuNgay(Ngay,Thu)
		VALUES(@ngay, @thu);

		SET @ngay = DATEADD(DAY, 1, @ngay);
	END

SELECT * FROM @tblThuNgay;
GO

Ví dụ: Đoạn code sau cho biết doanh thu bán hàng của từng
ngày trong tháng @month, năm @year.

DECLARE	@month int = 2,
		@year int = 2018;

SELECT	o.OrderDate, 
		SUM(od.Quantity * od.SalePrice) AS Revenue
FROM	Orders AS o
		JOIN OrderDetails AS od ON o.OrderId = od.OrderId
WHERE	MONTH(o.OrderDate) = @month
	AND	YEAR(o.OrderDate) = @year
GROUP BY o.OrderDate
		
GO

Yêu cầu: Sửa lại đoạn code trên sao cho kết quả thống kê phải thể 
hiện đủ dữ liệu của tất cả các ngày trong tháng, những ngày không có
doanh thu thì thể hiện số số tiền doanh thu là 0.
Gợi ý:
	+ Sử dụng 1 biến bảng để lưu đủ các ngày trong tháng
	+ Dùng phép nối ngoài giữa biến bảng và câu truy vấn trên


DECLARE	@month int = 2,
		@year int = 2018;

DECLARE @tblNgay TABLE
(
	OrderDate date
)
DECLARE @ngay date = DATEFROMPARTS(@year, @month, 1);
WHILE (MONTH(@ngay) = @month)
	BEGIN
		INSERT INTO @tblNgay VALUES (@ngay);

		SET @ngay = DATEADD(DAY, 1, @ngay);
	END

SELECT	t1.OrderDate,
		ISNULL(t2.Revenue, 0) AS Revenue
FROM	@tblNgay AS t1
		LEFT JOIN
		(
			SELECT	o.OrderDate, 
					SUM(od.Quantity * od.SalePrice) AS Revenue
			FROM	Orders AS o
					JOIN OrderDetails AS od ON o.OrderId = od.OrderId
			WHERE	MONTH(o.OrderDate) = @month
				AND	YEAR(o.OrderDate) = @year
			GROUP BY o.OrderDate
		) AS t2 ON t1.OrderDate = t2.OrderDate

GO

Ví dụ: Lập trình để hiển thị số liệu thống kê doanh thu bán hàng
 của từng tháng trong năm @year.
 Yêu cầu: Số liệu phải đủ tất cả các tháng, những tháng không có
 doanh thu thì hiển thị với doanh thu là 0

 2.6. Bảng tạm (temporary table)

 Bảng tạm thường được sử dụng để lưu trữ tạm thời dữ liệu dạng
 bảng, tuy nhiên phạm vi tồn tại của bảng tạm thì "lâu" hơn so 
 với biến bảng.
 - Biến bảng: Phạm vi tồn tại trong khối lệnh mà nó được khai báo
 - Bảng tạm: Phạm vi tồn tại là trong phiên làm việc (session)

 Ví dụ:

	declare @t table
	(
		A int,
		B int
	)
	go

	select * from @t; -- Lệnh này gặp lỗi vì biến @t không tồn tại

Phiên làm việc (session) là khoảng thời gian từ khi kết nối đến
CSDL cho đến khi kết thúc/đóng kết nối.

Khác với biến bảng, bảng tạm được tạo ra bằng cách tương tự như
khi tạo ra bảng vật lý.
	- Dùng lệnh CREATE TABLE 
	- Dùng lệnh SELECT ... INTO ... (thường dùng)
Bảng tạm khi tạo ra được quản lý bởi cơ sở dữ liệu tempdb.
Tên bảng tạm phải bắt đầu bởi dấu #.

Một số tính chất cần lưu ý:
- Tên phải bắt đầu bởi dấu #
- Sử dụng được trong phiên làm việc mà tạo ra nó
- Giải phóng (xóa) khi kết thúc phiên làm việc hoặc do chúng ta
  chủ động xóa bằng lệnh DROP TABLE 
- Sử dụng bảng tạm tương tự như bảng vật lý: SELECT, INSERT, UPDATE, 
  DELETE

2.7. Common Table Expression (CTE)

- Truy vấn con (sub-query): sử dụng khi cần thực thi một câu lệnh
  SELECT và sử dụng kết quả câu lệnh đó bên trong 1 câu lệnh khác
  (SELECT, INSERT, UPDATE, DELETE)
- CTE cũng được sử dụng để thực thi 1 câu lệnh SELECT, lưu tạm thời
  để sử dụng cho một lệnh khác.

Ví dụ: 

	SELECT	p.*,
			tk.SumOfQuantity
	FROM	Products as p
			LEFT JOIN
			(
				SELECT	ProductID, SUM(Quantity) AS SumOfQuantity
				FROM	OrderDetails 
				GROUP BY ProductID
			) AS tk ON p.ProductID = tk.ProductID

Viết lại bằng cách dùng CTE

WITH cte_Products AS
(
	SELECT	ProductID, SUM(Quantity) AS SumOfQuantity
	FROM	OrderDetails 
	GROUP BY ProductID
)
SELECT	p.*, tk.SumOfQuantity 
FROM	Products AS p
		LEFT JOIN cte_Products AS tk ON p.ProductID = tk.ProductID

Cú pháp để khai báo CTE:

WITH cte_name1 AS
(
	Lệnh_SELECT
)
,cte_name2 AS
(
	Lệnh_SELECT
)
...
,cte_nameN AS
(
	Lệnh_SELECT
)
Lệnh_sử_dụng_các_CTE

Lưu ý: Lệnh SELECT để lấy dữ liệu cho các CTE dưới có thể truy vấn
dữ liệu từ các CTE đã định nghĩa trước đó.

Ví dụ:

	WITH cte_Category AS
	(
		SELECT	CategoryId, CategoryName
		FROM	Categories
	)
	,cte_Products AS
	(
		SELECT	ProductName, CategoryID, Price
		FROM	Products 
		WHERE	Price < 5
	)
	SELECT	*
	FROM	cte_Category AS t1
			JOIN cte_Products AS t2 ON t1.CategoryID = t2.CategoryID

Tình huống:
	- Thực thi câu truy vấn A
	- Thực thi câu truy vấn B dựa trên dữ liệu của A
	- Thực thi câu truy vấn C dựa trên dữ liệu của B 
	- Thực thi câu truy vấn dựa vào dữ liệu của A, B và C 

WITH cte_A AS
(
	SELECT dữ liệu cho A
)
,cte_B AS
(
	SELECT ... FROM cte_A
)
,cte_C AS
(
	SELECT ... FROM cte_C
)
SELECT ... FROM cte_A, cte_B, cte_C 

Một điểm mạnh của CTE là cho phép viết truy vấn dạng đệ quy dựa vào
đặc tính trong lệnh để lấy dữ liệu cho CTE có thể truy vấn đến
chính nó.

Ví dụ: Cho 2 ngày @date1 và @date2 (@date1 < @date2). Hiển thị 1 bảng
có đủ tất cả các ngày từ @date1 đến @date2

DECLARE	@date1 date = '2023/09/01',
		@date2 date = '2023/09/15';	-- thiếu ; sẽ lỗi

WITH cte_Ngay AS
(
	SELECT 1 AS STT, @date1 AS Ngay
	UNION ALL
	SELECT	STT + 1, DATEADD(DAY, 1, t.Ngay)
	FROM	cte_Ngay AS t
	WHERE	t.Ngay < @date2
)
,cte_ThongKe AS 
(
	SELECT	OrderDate AS Ngay, COUNT(*) AS SoLuongDonHang
	FROM	Orders
	WHERE	OrderDate BETWEEN @date1 AND @date2
	GROUP BY OrderDate
)
SELECT	t1.*, ISNULL(t2.SoLuongDonHang, 0) AS SoLuongDonHang 
FROM	cte_Ngay AS t1
		LEFT JOIN cte_ThongKe AS t2 ON t1.Ngay = t2.Ngay 

Ví dụ: Cho bảng DonVi như sau:

	CREATE TABLE DonVi
	(
		MaDonVi nvarchar(50) primary key,
		TenDonVi nvarchar(50) not null,
		MaDonViCha nvarchar(50) null
	)
	GO

	INSERT INTO DonVi
	VALUES	('DV01', N'Khoa CNTT', NULL),
			('DV02', N'Khoa Toán', NULL),
			('DV03', N'Bộ môn CNPM', 'DV01'),
			('DV04', N'Bộ môn KHMT', 'DV01'),
			('DV05', N'Bộ môn Đại số', 'DV02'),
			('DV06', N'Bộ môn Giải tích', 'DV02'),
			('DV07', N'Tổ Thuật toán', 'DV04'),
			('DV08', N'Tổ AI', 'DV04')

	SELECT * FROM DonVi;

Truy vấn dữ liệu từ bảng DonVi cho biết mỗi đơn vị là ở Cấp mấy 
(theo cây) và đường dẫn đến đơn vị đó là như thế nào

WITH cte_DonVi AS
(
	SELECT	1 AS Cap, 
			CAST(MaDonVi AS nvarchar(1000)) AS DuongDan,
			MaDonVi, TenDonVi, MaDonViCha 
	FROM	DonVi
	WHERE	MaDonViCha IS NULL 
	UNION ALL
	SELECT	dvCha.Cap + 1, 
			CAST(CONCAT(dvCha.DuongDan, '\', dvCon.MaDonVi) AS nvarchar(1000)),
			dvCon.MaDonVi, dvCon.TenDonVi, dvCon.MaDonViCha
	FROM	DonVi AS dvCon
			JOIN cte_DonVi AS dvCha ON dvCon.MaDonViCha = dvCha.MaDonVi
)
SELECT * FROM cte_DonVi
ORDER BY DuongDan;


2.8. Sử dụng con trỏ để duyệt dữ liệu

Khi truy vấn dữ liệu, chúng ta thường có nhu cầu lấy dữ liệu tại mỗi
dòng để thực hiện các phép xử lý. Điều này dẫn đến cần phép duyệt từng dòng
trong bảng. 

Trong T-SQL, con trỏ (CURSOR) dùng để duyệt dữ liệu.

Ví dụ: Truy vấn tên và giá các mặt hàng có giá nhỏ hơn 20 và in (PRINT) 
ra màn hình

-- B1: Khai báo biến con trỏ, trỏ vào kết quả truy vấn
DECLARE contro CURSOR FOR
	SELECT ProductName, Price FROM Products WHERE Price < 20;

-- B2: Mở con trỏ
OPEN contro;

-- B3: Dịch con trỏ vào dòng đầu tiên và đọc dữ liệu (lưu vào biến)
DECLARE @name nvarchar(50), 
		@price money;

FETCH NEXT FROM contro INTO @name, @price;
-- B4: Lặp và đọc các dòng tiếp theo
WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT @name;
		PRINT @price;

		FETCH NEXT FROM contro INTO @name, @price;
	END

-- B5: Đóng con trỏ (sau khi đóng, có thể OPEN lại)
CLOSE contro;

-- B6: Giải phóng con trỏ nếu không còn sử dụng
DEALLOCATE contro;

GO

Lưu ý: Chỉ nên dùng con trỏ trong trường hợp thực sự cần thiết.
Nếu có cách giải quyết bằng truy vấn (con, cte, biến bảng,...) thì 
nên ưu tiên bằng truy vấn.


















	


