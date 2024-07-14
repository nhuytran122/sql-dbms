/*Câu 2 (1.0 điểm): Tạo trigger có tên trg_NhanVien_DuAn_Insert bắt lệnh INSERT trên
bảng NhanVien_DuAn sao cho mỗi lần bổ sung thêm dữ liệu cho bảng NhanVien_DuAn
(tức là giao cho nhân viên thực hiện dự án) thì cập nhật lại cột SoNguoiThamGia của bảng
DuAn bằng đúng với số lượng nhân viên đã được giao thực hiện dự án.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_NhanVien_DuAn_Insert')
DROP TRIGGER trg_NhanVien_DuAn_Insert
GO
CREATE TRIGGER trg_NhanVien_DuAn_Insert
ON NhanVien_DuAn
FOR INSERT
AS
BEGIN
/*cập nhật lại cột SoNguoiThamGia của bảng
DuAn bằng đúng với số lượng nhân viên đã được giao thực hiện dự án*/
	UPDATE da
	SET da.SoNguoiThamGia += 1
	FROM DuAn as da INNER JOIN inserted as i
	ON da.MaDuAn = i.MaDuAn
END
GO

-- Test
INSERT INTO NhanVien_DuAn (MaNhanVien, MaDuAn, MoTaCongViec, NgayGiaoViec)
VALUES ('NV005', 'DA002', 'Khong co', '2023-12-25')
GO

/*Câu 3: Tạo các thủ tục sau đây
a. (1.0 điểm) proc_NhanVien_DuAn_Insert
@MaNhanVien nvarchar(50),
@MaDuAn nvarchar(50),
@MoTaCongViec nvarchar(255),
@KetQua nvarchar(255) output

Có chức năng bổ sung dữ liệu cho bảng NhanVien_DuAn nhằm giao việc cho nhân viên
có mã @MaNhanVien thực hiện dự án có mã @MaDuAn. Ngày giao việc được tính là
thời điểm hiện tại. Tham số đầu ra @KetQua trả về chuỗi rỗng nếu bổ sung thành công,
ngược lại tham số này trả về chuỗi cho biết lý do vì sao không bổ sung được dữ liệu.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_NhanVien_DuAn_Insert')
DROP PROCEDURE proc_NhanVien_DuAn_Insert
GO

CREATE PROCEDURE proc_NhanVien_DuAn_Insert
	@MaNhanVien nvarchar(50),
	@MaDuAn nvarchar(50),
	@MoTaCongViec nvarchar(255),
	@KetQua nvarchar(255) output
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM NhanVien WHERE MaNhanVien = @MaNhanVien)
	BEGIN
		SET	@KetQua = 'Khong co nhan vien ' + @MaNhanVien;
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM DuAn WHERE MaDuAn = @MaDuAn)
	BEGIN
		SET	@KetQua = 'Khong co du an ' + @MaDuAn;
		RETURN;
	END

	IF EXISTS (SELECT * FROM NhanVien_DuAn WHERE MaDuAn = @MaDuAn AND MaNhanVien = @MaNhanVien)
	BEGIN
		SET	@KetQua = 'Nhan vien ' + @MaNhanVien + ' da tham gia du an ' + @MaNhanVien;
		RETURN;
	END

	INSERT NhanVien_DuAn(MaNhanVien, MaDuAn, MoTaCongViec, NgayGiaoViec)
	VALUES (@MaNhanVien, @MaDuAn, @MoTaCongViec, GETDATE())
	SET @KetQua = ''
END
GO

DECLARE @KetQua nvarchar(255); 
EXEC proc_NhanVien_DuAn_Insert 
	@MaNhanVien = 'NV001',
	@MaDuAn = 'DA003',
	@MoTaCongViec = 'Khong co',
	@KetQua = @KetQua output;
	PRINT @KetQua;
GO

/*b. (1.0 điểm) proc_DuAn_DanhSachNhanVien
@TenDuAn nvarchar(255),
@NgayGiaoViec date

Có chức năng hiển thị danh sách các nhân viên được giao thực hiện dự án có tên
@TenDuAn trước ngày @NgayGiaoViec. Thông tin hiển thị bao gồm: Mã nhân viên, Họ
tên, Email, Di động, Ngày giao việc và Mô tả công việc được giao.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_DuAn_DanhSachNhanVien')
DROP PROCEDURE proc_DuAn_DanhSachNhanVien
GO

CREATE PROCEDURE proc_DuAn_DanhSachNhanVien
	@TenDuAn nvarchar(255),
	@NgayGiaoViec date
AS
BEGIN
	SELECT nv.MaNhanVien, nv.HoTen, nv.Email, nv.DiDong, nd.NgayGiaoViec
	FROM (NhanVien as nv JOIN NhanVien_DuAn as nd ON nv.MaNhanVien = nd.MaNhanVien) JOIN DuAn as da ON nd.MaDuAn = da.MaDuAn
	WHERE da.TenDuAn = @TenDuAn
	AND nd.NgayGiaoViec < @NgayGiaoViec
END
GO

EXEC proc_DuAn_DanhSachNhanVien
	@TenDuAn = 'SmartUni',
	@NgayGiaoViec = '2023-12-25'
GO

/*c. (1.5 điểm) proc_NhanVien_TimKiem
@Trang int = 1,
@SoDongMoiTrang int = 20,
@HoTen nvarchar(50) = N'',
@Tuoi int,
@SoLuong int output

Có chức năng tìm kiếm và hiển thị dưới dạng phân trang các nhân viên mà trong Họ tên có
chứa @HoTen và có Tuổi lớn hơn hoặc bằng @Tuoi. Lưu ý, nếu tham số @HoTen bằng
rỗng thì chỉ tìm kiếm các nhân viên có Tuổi lớn hơn hoặc bằng @Tuoi. Thông tin cần hiển
thị bao gồm: Mã nhân viên, Họ tên, Ngày sinh, Tuổi, Email và Di động. Tham số đầu ra
@SoLuong cho biết số lượng nhân viên được tìm thấy.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_DuAn_DanhSachNhanVien')
DROP PROCEDURE proc_DuAn_DanhSachNhanVien
GO

CREATE PROCEDURE proc_NhanVien_TimKiem
	@Trang int = 1,
	@SoDongMoiTrang int = 20,
	@HoTen nvarchar(50) = N'',
	@Tuoi int,
	@SoLuong int output
AS
BEGIN
	SELECT *, ROW_NUMBER() OVER (order by HoTen) AS RowNumber
	INTO #TmpNV
	FROM NhanVien

	SELECT @SoLuong = COUNT(*)
	FROM NhanVien
	--nếu tham số @HoTen bằng rỗng thì chỉ tìm kiếm các nhân viên có Tuổi lớn hơn hoặc bằng @Tuoi
	WHERE (@HoTen = N'') OR HoTen like @HoTen AND DATEDIFF(YY, NgaySinh, GETDATE()) >= @Tuoi

	; WITH cte as
	(
	SELECT *
	FROM #TmpNV
	WHERE (@HoTen = N'') OR HoTen like @HoTen AND DATEDIFF(YY, NgaySinh, GETDATE()) >= @Tuoi
	)

	SELECT * from cte
	WHERE (@SoDongMoiTrang = 0) or
			RowNumber between (@Trang - 1) * @SoDongMoiTrang + 1 AND @Trang * @SoDongMoiTrang
	ORDER BY RowNumber

END
GO

DECLARE @SoLuong INT;
EXEC proc_NhanVien_TimKiem
@Trang = 1,
	@SoDongMoiTrang = 20,
	@HoTen  = N'',
	@Tuoi = 10,
	@SoLuong = @SoLuong output
GO


/*d. (1.5 điểm) proc_ThongKeGiaoViec
@MaDuAn nvarchar(50),
@TuNgay date,
@DenNgay date

Có chức năng thống kê số lượng nhân viên được giao thực hiện dự án có mã @MaDuAn
theo từng ngày giao việc trong khoảng thời gian @TuNgay đến @DenNgay. Yêu cầu kết
quả thống kê phải hiển thị đầy đủ tất cả các ngày trong khoảng thời gian cần thống kê,
những ngày không có nhân viên được giao việc thì hiển thị với số lượng là 0. Thông tin
cần hiển thị bao gồm: Ngày giao việc và Số nhân viên được giao việc.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_ThongKeGiaoViec')
DROP PROCEDURE proc_ThongKeGiaoViec
GO

CREATE PROCEDURE proc_ThongKeGiaoViec
	@MaDuAn nvarchar(50),
	@TuNgay date,
	@DenNgay date
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @tblNgay TABLE
	( 
		Ngay date
	)

	DECLARE @tmpNgay date = @TuNgay;
	WHILE (@tmpNgay <= @DenNgay)
	BEGIN
		INSERT INTO @tblNgay(Ngay)
		VALUES (@tmpNgay);
		SET @tmpNgay =  DATEADD(dd, 1, @tmpNgay);
	END


	SELECT t1.Ngay, ISNULL(t2.SoLuong, 0) as SL
	FROM @tblNgay as t1
	LEFT JOIN
	(
		SELECT NgayGiaoViec, COUNT(MaNhanVien) as SoLuong
		FROM NhanVien_DuAn
		WHERE MaDuAn = @MaDuAn
		AND NgayGiaoViec BETWEEN @TuNgay AND @DenNgay
		GROUP BY NgayGiaoViec
	) AS t2
	ON t1.Ngay = t2.NgayGiaoViec
END
GO

EXEC proc_ThongKeGiaoViec 
	@MaDuAn = 'DA001',
	@TuNgay = '2023-12-01',
	@DenNgay = '2023-12-31';
GO

/*Câu 4: Tạo các hàm sau đây:
a. (1 điểm) func_TKeDuAn
@TuNam int,
@DenNam int

Có chức năng trả về một bảng thống kê số lượng dự án được thực hiện trong mỗi năm trong
khoảng thời gian từ năm @TuNam đến năm @DenNam (năm thực hiện dự án được xác
định dựa vào Ngày bắt đầu của dự án). Thông tin cần hiển thị bao gồm: Năm thực hiện và
Số lượng dự án.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_TKeDuAn')
DROP FUNCTION func_TKeDuAn
GO

CREATE FUNCTION func_TKeDuAn
(
	@TuNam int,
	@DenNam int
)
RETURNS TABLE
AS
RETURN
	SELECT YEAR(NgayBatDau) as Nam, COUNT(MaDuAn) AS SoLuong
	FROM DuAn
	WHERE YEAR(NgayBatDau) BETWEEN @TuNam AND @DenNam
	GROUP BY YEAR(NgayBatDau)
GO

SELECT * from dbo.func_TKeDuAn(2021, 2023)
GO

/*b. (1.5 điểm) func_TKeDuAn_DayDuCacNam

@TuNam int,
@DenNam int
Có chức năng trả về một bảng thống kê số lượng dự án được thực hiện trong mỗi năm trong
khoảng thời gian từ năm @TuNam đến năm @DenNam (năm thực hiện dự án được xác
định dựa vào Ngày bắt đầu của dự án). Thông tin cần hiển thị bao gồm: Năm thực hiện và
Số lượng dự án. Yêu cầu kết quả phải thể hiện đầy đủ tất cả các năm trong khoảng thời
gian cần thống kê (tức là những năm không có dự án nào được thực hiện thì cũng hiển thị
với số lượng dự án là 0).*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'func_TKeDuAn_DayDuCacNam')
	DROP FUNCTION func_TKeDuAn_DayDuCacNam;
GO
CREATE FUNCTION func_TKeDuAn_DayDuCacNam 
(
	@TuNam int,
	@DenNam int
)
RETURNS @tbl TABLE
(
	Nam int,
	SoLuong int
)
AS
BEGIN
	INSERT INTO @tbl(Nam, SoLuong)
		SELECT YEAR(NgayBatDau) as Nam, COUNT(MaDuAn) AS SoLuong
		FROM DuAn
		WHERE YEAR(NgayBatDau) BETWEEN @TuNam AND @DenNam
		GROUP BY YEAR(NgayBatDau)

	DECLARE @tmpNam int = @TuNam;
	WHILE(@tmpNam <= @DenNam)
	BEGIN
		IF NOT EXISTS (SELECT * FROM DuAn WHERE YEAR(NgayBatDau)  = @tmpNam)
			INSERT INTO @tbl(Nam, SoLuong) VALUES (@tmpNam, 0)
		SET @tmpNam += 1
	END
	RETURN;
END
GO

/*Câu 5 (1.0 điểm) Viết các lệnh thực hiện các yêu cầu sau đây
- Tạo tài khoản có tên là user_MãSinhViên (ví dụ: user_2T1020001) với mật khẩu
là 123456
- Cho phép tài khoản trên được phép truy cập vào cơ sở dữ liệu đã tạo.
- Cấp phát cho tài khoản trên các quyền sau đây:
o Được phép thực hiện lệnh SELECT và INSERT trên bảng NhanVien
o Được phép sử dụng các thủ tục và hàm đã tạo ở trên*/

use master
go

create login user_21T1020105 with password = '123456'
GO

use ONTAP1_21T1020105
go 

create user user_21T1020105 for login user_21T1020105
go

grant select, insert on NhanVien to user_21T1020105

grant execute on proc_ThongKeGiaoViec to user_21T1020105

grant select on func_TKeDuAn_DayDuCacNam to user_21T1020105


BACKUP DATABASE ONTAP1_21T1020105
TO DISK = 'F:\HK5\Các HQTCSDL\ONTAP\ONTAP1.bak'
