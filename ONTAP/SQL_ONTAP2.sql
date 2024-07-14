/*Câu 2 (1.0 điểm) Tạo trigger có tên trg_LopHocPhan_SinhVien_Insert có chức năng
bắt lệnh INSERT trên bảng LopHocPhan_SinhVien sao cho mỗi lẫn bổ sung thêm dữ
liệu cho bảng LopHocPhan_SinhVien (tức là thêm sinh viên đăng ký học ở lớp học phần)
thì cập nhật lại giá trị của cột SoSinhVienDangKy trong bảng LopHocPhan bằng đúng
với số lượng sinh viên đã đăng ký học.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_LopHocPhan_SinhVien_Insert')
DROP TRIGGER trg_LopHocPhan_SinhVien_Insert;
GO

CREATE TRIGGER trg_LopHocPhan_SinhVien_Insert
ON LopHocPhan_SinhVien
FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE l
	SET l.SoSinhVienDangKy += 1
	FROM LopHocPhan as l inner join inserted as i
	ON l.MaLopHocPhan = i.MaLopHocPhan
END
GO

INSERT INTO LopHocPhan_SinhVien (MaLopHocPhan, MaSinhVien, NgayDangKy)
VALUES ('L0001', 'SV001', '2023-12-21')
GO

INSERT INTO LopHocPhan_SinhVien (MaLopHocPhan, MaSinhVien, NgayDangKy)
VALUES ('L0002', 'SV002', '2023-12-21')
GO

/*Câu 3: Tạo các thủ tục sau đây
a. (1.0 điểm): proc_LopHocPhan_SinhVien_Insert
@MaLopHocPhan nvarchar(50),
@MaSinhVien nvarchar(50),
@KetQua nvarchar(255) output

Có chức năng bổ sung thêm dữ liệu cho bảng LopHocPhan_SinhVien để đăng ký thêm
sinh viên có mã là @MaSinhVien vào lớp học phần có mã là @MaLopHocPhan. Ngày
đăng ký được tính là thời điểm hiện tại. Tham số đầu ra @KetQua trả về chuỗi rỗng nếu
việc bổ sung là thành công, ngược lại tham số này trả về chuỗi cho biết lý do vì sao không
bổ sung được dữ liệu.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_LopHocPhan_SinhVien_Insert')
DROP PROCEDURE proc_LopHocPhan_SinhVien_Insert;
GO

CREATE PROCEDURE proc_LopHocPhan_SinhVien_Insert
(
	@MaLopHocPhan nvarchar(50),
	@MaSinhVien nvarchar(50),
	@KetQua nvarchar(255) output
)
AS
BEGIN
	SET NOCOUNT ON; 
	IF NOT EXISTS (SELECT * FROM LopHocPhan WHERE MaLopHocPhan = @MaLopHocPhan)
	BEGIN
		SET @KetQua = 'Khong co lop ' + @MaLopHocPhan;
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM SinhVien WHERE MaSinhVien = @MaSinhVien)
	BEGIN
		SET @KetQua = 'Khong co SV ' + @MaSinhVien;
		RETURN;
	END

	IF EXISTS (SELECT * FROM LopHocPhan_SinhVien WHERE MaSinhVien = @MaSinhVien AND MaLopHocPhan = @MaLopHocPhan)
	BEGIN
		SET @KetQua = 'SV ' + @MaSinhVien + ' da dang ky lop ' + @MaLopHocPhan;
		RETURN;
	END

	INSERT INTO LopHocPhan_SinhVien (MaLopHocPhan, MaSinhVien, NgayDangKy)
	VALUES (@MaLopHocPhan, @MaSinhVien, GETDATE())
END
GO

DECLARE @KetQua nvarchar(255);
EXEC proc_LopHocPhan_SinhVien_Insert
			@MaLopHocPhan = 'L0001',
			@MaSinhVien = 'SV002',
			@KetQua = @KetQua output;
PRINT @KetQua;
GO

/*b. (1.0 điểm) : proc_LopHocPhan_SinhVien_SelectByLop
@MaLopHocPhan nvarchar(50),
@TenLop nvarchar(50)

Có chức năng hiển thị danh sách sinh viên thuộc lớp @TenLop đã đăng ký học lớp học
phần có mã @MaLopHocPhan. Thông tin hiển thị bao gồm Mã sinh viên, Họ tên, Ngày
sinh, Nơi sinh và được sắp xếp tăng dần theo Họ tên.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_LopHocPhan_SinhVien_SelectByLop')
DROP PROCEDURE proc_LopHocPhan_SinhVien_SelectByLop;
GO

CREATE PROCEDURE proc_LopHocPhan_SinhVien_SelectByLop
(
	@MaLopHocPhan nvarchar(50),
	@TenLop nvarchar(50)
)
AS
BEGIN
	SET NOCOUNT ON; 
	-- Mã sinh viên, Họ tên, Ngày sinh, Nơi sinh và được sắp xếp tăng dần theo Họ tên
	SELECT sv.MaSinhVien, sv.HoTen, sv.NgaySinh, sv.NoiSinh
	FROM SinhVien as sv inner join LopHocPhan_SinhVien as ls
	ON sv.MaSinhVien = ls.MaSinhVien
	WHERE sv.TenLop = @TenLop AND ls.MaLopHocPhan = @MaLopHocPhan
	ORDER BY sv.HoTen
END
GO

EXEC proc_LopHocPhan_SinhVien_SelectByLop
			@MaLopHocPhan = 'L0001',
			@TenLop = 'Tin K44A'
GO

/*c. (1.5 điểm) proc_SinhVien_TimKiem
@Trang int = 1,
@SoDongMoiTrang int = 20,
@HoTen nvarchar(50) = N’’,
@Tuoi int,
@SoLuong int output
Có chức năng tìm kiếm và hiển thị dữ liệu dưới dạng phân trang các sinh viên mà trong Họ
tên có chứa @HoTen và có Tuổi lớn hơn hoặc bằng @Tuoi. Lưu ý, nếu tham số @HoTen
bằng rỗng thì chỉ tìm kiếm các sinh viên có Tuổi lớn hơn hoặc bằng @Tuoi. Thông tin cần
hiển thị bao gồm: Mã sinh viên, Họ tên, Ngày sinh, Nơi sinh và Tên lớp. Tham số đầu ra
@SoLuong cho biết số lượng sinh viên tìm được.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_SinhVien_TimKiem')
DROP PROCEDURE proc_SinhVien_TimKiem
GO

CREATE PROCEDURE proc_SinhVien_TimKiem
(
	@Trang int = 1,
	@SoDongMoiTrang int = 20,
	@HoTen nvarchar(50) = N'',
	@Tuoi int,
	@SoLuong int output
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *, ROW_NUMBER() over (order by HoTen) as RowNumber
	INTO #TempSV
	FROM SinhVien

	/*các sinh viên mà trong Họ tên có chứa @HoTen và có Tuổi lớn hơn hoặc bằng @Tuoi. 
	Lưu ý, nếu tham số @HoTen bằng rỗng thì chỉ tìm kiếm các sinh viên có Tuổi lớn hơn hoặc bằng @Tuoi*/

	SELECT @SoLuong = COUNT(*)
	FROM SinhVien
	WHERE (@HoTen = N'' AND DATEDIFF(yy, NgaySinh, GETDATE()) >= @Tuoi) OR (HoTen LIKE @HoTen AND DATEDIFF(yy, NgaySinh, GETDATE()) >= @Tuoi) 
	
	; WITH cte as
	(
		SELECT * FROM #TempSV WHERE (@HoTen = N'' AND DATEDIFF(yy, NgaySinh, GETDATE()) >= @Tuoi)
		OR (HoTen LIKE @HoTen AND DATEDIFF(yy, NgaySinh, GETDATE()) >= @Tuoi) 
	)

	SELECT * FROM cte
	WHERE RowNumber BETWEEN (@Trang - 1) * @SoDongMoiTrang + 1 
	AND @Trang * @SoDongMoiTrang
	ORDER By RowNumber
END
GO

DECLARE @SoLuong int;
EXEC proc_SinhVien_TimKiem
	@Trang  = 1,
	@SoDongMoiTrang  = 20,
	@HoTen  = N'',
	@Tuoi = 1,
	@SoLuong = @SoLuong output;

	PRINT @SoLuong;
go

/*d. (1.5 điểm) proc_ThongKeDangKyHoc
@MaLopHocPhan nvarchar(50),
@TuNgay date,
@DenNgay date
Có chức năng thống kê số lượng sinh viên đăng ký học lớp học phần có mã
@MaLopHocPhan theo từng ngày đăng ký trong khoảng thời gian từ @TuNgay đến
@DenNgay. Yêu cầu kết quả thống kê phải hiển thị đầy đủ tất cả các ngày trong khoảng
thời gian cần thống kê, những ngày không có sinh viên đăng ký thì hiển thị với số lượng
đăng ký là 0. Thông cần tin hiển thị bao gồm: Ngày đăng ký và Số lượng sinh viên đăng
ký.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_ThongKeDangKyHoc')
DROP PROCEDURE proc_ThongKeDangKyHoc;
GO

CREATE PROCEDURE proc_ThongKeDangKyHoc
(
	@MaLopHocPhan nvarchar(50),
	@TuNgay date,
	@DenNgay date
)
AS
BEGIN
	SET NOCOUNT ON; 
	DECLARE @tblNgay Table
	(
		 Ngay date
	)
	DECLARE @tmp date = @TuNgay;
	WHILE (@tmp <= @DenNgay)
	BEGIN
		insert into @tblNgay values (@tmp);
		set @tmp = DATEADD(day, 1, @tmp);
	END
	SELECT t1.ngay, ISNULL(t2.SoLuongDangKy, 0) as Revenue
	FROM @tblNgay AS t1
	LEFT JOIN
	(
		SELECT  NgayDangKy, COUNT(MaSinhVien) as SoLuongDangKy
		FROM LopHocPhan_SinhVien 
		WHERE MaLopHocPhan = @MaLopHocPhan
		AND NgayDangKy BETWEEN @TuNgay AND @DenNgay
		GROUP BY NgayDangKy
	) AS t2 
	ON t1.ngay = t2.NgayDangKy
END
GO

/*
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_ThongKeDangKyHoc')
DROP PROCEDURE proc_ThongKeDangKyHoc;
GO

CREATE PROCEDURE proc_ThongKeDangKyHoc
(
	@MaLopHocPhan nvarchar(50),
	@TuNgay date,
	@DenNgay date
)
AS
BEGIN
	SET NOCOUNT ON; 
	DECLARE @tbl TABLE
	( 
	Ngay date,
	SoLuongDangKy int
	)

	INSERT INTO @tbl (Ngay, SoLuongDangKy)
	SELECT NgayDangKy, COUNT(MaSinhVien)
	FROM LopHocPhan_SinhVien 
	WHERE MaLopHocPhan = @MaLopHocPhan
	AND NgayDangKy BETWEEN @TuNgay AND @DenNgay
	GROUP BY NgayDangKy
	
	DECLARE @tmpngay date = DATEFROMPARTS(YEAR(@TuNgay), MONTH(@TuNgay), DAY(@TuNgay))
	WHILE (@tmpngay <= @DenNgay)
	BEGIN
		IF NOT EXISTS (SELECT * FROM LopHocPhan_SinhVien WHERE NgayDangKy = @tmpngay)
		INSERT INTO @tbl (Ngay, SoLuongDangKy) values (@tmpngay, 0)
		SET @tmpngay = DATEADD(dd, 1, @tmpngay)
	END

	SELECT * FROM @tbl
	ORDER BY Ngay
END
GO
*/

EXEC proc_ThongKeDangKyHoc
						@MaLopHocPhan = 'L0001',
						@TuNgay = '2023-12-01',
						@DenNgay = '2023-12-31'
GO

/*Câu 4: Tạo các hàm sau đây
a. (1.0 điểm): func_TkeKhoiLuongDangKyHoc
@MaSinhVien nvarchar(50),
@TuNam int,
@DenNam int

Có chức năng trả về một bảng thống kê tổng số tín chỉ mà sinh viên có mã @MaSinhVien
đã đăng ký học trong từng năm trong khoảng thời gian từ năm @TuNam đến năm
@DenNam (năm được xác định dựa vào ngày đăng ký học). Thông tin cần hiển thị bao
gồm Năm và Tổng số tín chỉ.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_TkeKhoiLuongDangKyHoc')
DROP FUNCTION func_TkeKhoiLuongDangKyHoc;
GO

CREATE FUNCTION func_TkeKhoiLuongDangKyHoc
(
	@MaSinhVien nvarchar(50),
	@TuNam int,
	@DenNam int
)
RETURNS @tbl TABLE (
	Nam int,
	TongSoTinChi int
)
AS
BEGIN
	INSERT INTO @tbl (Nam, TongSoTinChi)
	SELECT YEAR(ls.NgayDangKy), SUM(l.SoTinChi)
	FROM (SinhVien as sv JOIN LopHocPhan_SinhVien as ls ON sv.MaSinhVien = ls.MaSinhVien)
	JOIN LopHocPhan as l ON ls.MaLopHocPhan = l.MaLopHocPhan
	WHERE sv.MaSinhVien = @MaSinhVien
	AND YEAR(ls.NgayDangKy) BETWEEN @TuNam and @DenNam
	GROUP BY YEAR(ls.NgayDangKy)

	RETURN;
END
GO

SELECT * FROM dbo.func_TkeKhoiLuongDangKyHoc('SV001', 2021, 2024)
go

/*b. (1.5 điểm): func_TkeKhoiLuongDangKyHoc_DayDuNam
@MaSinhVien nvarchar(50)
@TuNam int,
@DenNam int

Có chức năng trả về một bảng thống kê tổng số tín chỉ mà sinh viên có mã @MaSinhVien
đã đăng ký học trong từng năm trong khoảng thời gian từ năm @TuNam đến năm
@DenNam (năm được xác định dựa vào ngày đăng ký học). Thông tin cần hiển thị bao
gồm Năm và Tổng số tín chỉ. Yêu cầu kết quả thống kê phải thể hiện được đầy đủ các năm
trong khoảng thời gian cần thống kê (tức là những năm mà sinh viên không đăng ký thì
cũng phải hiển thị với tổng số tín chỉ đăng ký là 0).*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_TkeKhoiLuongDangKyHoc_DayDuNam')
DROP FUNCTION func_TkeKhoiLuongDangKyHoc_DayDuNam;
GO

CREATE FUNCTION func_TkeKhoiLuongDangKyHoc_DayDuNam
(
	@MaSinhVien nvarchar(50),
	@TuNam int,
	@DenNam int
)
RETURNS @tbl TABLE
(
	Nam int,
	TongSoTinChi int
)
AS
BEGIN
	INSERT INTO @tbl (Nam, TongSoTinChi)
	SELECT YEAR(ls.NgayDangKy), SUM(l.SoTinChi)
	FROM (SinhVien as sv JOIN LopHocPhan_SinhVien as ls ON sv.MaSinhVien = ls.MaSinhVien)
	JOIN LopHocPhan as l ON ls.MaLopHocPhan = l.MaLopHocPhan
	WHERE sv.MaSinhVien = @MaSinhVien
	AND YEAR(ls.NgayDangKy) BETWEEN @TuNam and @DenNam
	GROUP BY YEAR(ls.NgayDangKy)

	DECLARE @tmpNam int = @TuNam;
	WHILE(@tmpNam < @DenNam)
	BEGIN
	IF NOT EXISTS (SELECT * FROM (SinhVien as sv JOIN LopHocPhan_SinhVien as ls ON sv.MaSinhVien = ls.MaSinhVien)
					JOIN LopHocPhan as l ON ls.MaLopHocPhan = l.MaLopHocPhan
					WHERE sv.MaSinhVien = @MaSinhVien
					AND YEAR(ls.NgayDangKy)= @tmpNam)
		BEGIN 
			INSERT INTO @tbl (Nam, TongSoTinChi)
			VALUES (@tmpNam, 0)
		END
	SET @tmpNam += 1
	END
	RETURN;
END
GO

SELECT * FROM dbo.func_TkeKhoiLuongDangKyHoc_DayDuNam('SV001', 2021, 2024)
go

/*Câu 5 (1.0 điểm) Viết các lệnh thực hiện các yêu cầu sau đây
- Tạo tài khoản có tên là user_MãSinhViên (ví dụ: user_21T1020001) với mật khẩu
là 123456
- Cho phép tài khoản trên được phép truy cập vào cơ sở dữ liệu đã tạo.
- Cấp phát cho tài khoản trên các quyền sau đây:
o Được phép thực hiện lệnh SELECT và UPDATE trên bảng SinhVien
o Được phép sử dụng các thủ tục và hàm đã tạo ở trên*/

use master
go
create login user_21T1020105 with password = '12345'
go

use ONTAP2_21T1020105
go
create user user_21T1020105 for login user_21T1020105;
go

grant select, update on SinhVien to user_21T1020105;

grant execute on proc_LopHocPhan_SinhVien_Insert to user_21T1020105;
grant execute on proc_LopHocPhan_SinhVien_SelectByLop to user_21T1020105
grant execute on proc_SinhVien_TimKiem to user_21T1020105
grant execute on proc_ThongKeDangKyHoc to user_21T1020105

grant select on func_TkeKhoiLuongDangKyHoc to user_21T1020105
grant select on func_TkeKhoiLuongDangKyHoc_DayDuNam to user_21T1020105

