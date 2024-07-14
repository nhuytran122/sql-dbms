/*Câu 2 (1.0 điểm): Tạo trigger có tên trg_NhanVien_DuAn_Insert bắt lệnh INSERT trên
bảng NhanVien_DuAn sao cho mỗi lần bổ sung thêm dữ liệu cho bảng NhanVien_DuAn
(tức là giao cho nhân viên thực hiện dự án) thì cập nhật lại cột SoNguoiThamGia của bảng
DuAn bằng đúng với số lượng nhân viên đã được giao thực hiện dự án.*/
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'trg_NhanVien_DuAn_Insert')
DROP TRIGGER trg_NhanVien_DuAn_Insert;
GO

CREATE TRIGGER trg_NhanVien_DuAn_Insert
ON NhanVien_DuAn
FOR INSERT 
AS
BEGIN
          SET NOCOUNT ON;
          UPDATE da
		  SET da.SoNguoiThamGia += 1
		  FROM DuAn as da inner join inserted as i on da.MaDuAn = i.MaDuAn
END
GO

INSERT NhanVien_DuAn (MaNhanVien, MaDuAn, NgayGiaoViec, MoTaCongViec)
VALUES ('NV001', 'DA001', '2023-12-18', 'Khong co')

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
        SET NOCOUNT ON; 
        IF NOT EXISTS (SELECT * FROM NhanVien WHERE MaNhanVien = @MaNhanVien)
		BEGIN
			SET @KetQua = 'Khong ton tai ' + @MaNhanVien + ' trong du lieu'
			RETURN;
		END

		IF NOT EXISTS (SELECT * FROM DuAn WHERE MaDuAn = @MaDuAn)
		BEGIN
			SET @KetQua = 'Khong ton tai ' + @MaDuAn + ' trong du lieu'
			RETURN;
		END

		IF EXISTS (SELECT * FROM NhanVien_DuAn WHERE MaDuAn = @MaDuAn AND MaNhanVien = @MaNhanVien)
		BEGIN
			SET @KetQua = 'Da ton tai nhan vien lam du an nay';
		END

		INSERT NhanVien_DuAn (MaNhanVien, MaDuAn, NgayGiaoViec, MoTaCongViec)
		VALUES(@MaNhanVien, @MaDuAn, GETDATE(), @MoTaCongViec)
		SET @KetQua = '';

END
GO

DECLARE @KetQua nvarchar(255);
EXEC proc_NhanVien_DuAn_Insert
	@MaNhanVien = 'NV002',
	@MaDuAn = 'DA001',
	@MoTaCongViec = 'Khong co',
	@KetQua = @KetQua output;
go

DECLARE @KetQua nvarchar(255);
EXEC proc_NhanVien_DuAn_Insert
	@MaNhanVien = 'NV003',
	@MaDuAn = 'DA002',
	@MoTaCongViec = 'Khong co',
	@KetQua = @KetQua output;
go

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
        SET NOCOUNT ON; 
        SELECT nv.MaNhanVien, nv.HoTen, nv.Email, nv.DiDong, nd.NgayGiaoViec, nd.MoTaCongViec
		FROM NhanVien as nv, NhanVien_DuAn as nd, DuAn as da
		WHERE nv.MaNhanVien = nd.MaNhanVien 
		AND nd.MaDuAn = da.MaDuAn
		AND da.TenDuAn = @TenDuAn
		AND nd.NgayGiaoViec < @NgayGiaoViec
END
GO

EXEC proc_DuAn_DanhSachNhanVien
	@TenDuAn = 'SmartUni',
	@NgayGiaoViec = '2023-12-22'
go

/*c. (1.5 điểm) proc_NhanVien_TimKiem
@Trang int = 1,
@SoDongMoiTrang int = 20,
@HoTen nvarchar(50) = N’’,
@Tuoi int,
@SoLuong int output

Có chức năng tìm kiếm và hiển thị dưới dạng phân trang các nhân viên mà trong Họ tên có
chứa @HoTen và có Tuổi lớn hơn hoặc bằng @Tuoi. Lưu ý, nếu tham số @HoTen bằng
rỗng thì chỉ tìm kiếm các nhân viên có Tuổi lớn hơn hoặc bằng @Tuoi. Thông tin cần hiển
thị bao gồm: Mã nhân viên, Họ tên, Ngày sinh, Tuổi, Email và Di động. Tham số đầu ra
@SoLuong cho biết số lượng nhân viên được tìm thấy.*/

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'proc_Customer_Select')
DROP PROCEDURE proc_Customer_Select
GO

CREATE PROCEDURE proc_Customer_Select
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
	SELECT *, ROW_NUMBER() over(order by HoTen) as RowNumber
	INTO #TmpNV
	FROM NhanVien

	-- trong Họ tên có chứa @HoTen và có Tuổi lớn hơn hoặc bằng @Tuoi
	SELECT @SoLuong = COUNT(*)
	FROM NhanVien
	where  (@HoTen = N'' AND DATEDIFF(yy, NgaySinh, GETDATE()) >= @Tuoi) OR (HoTen = @HoTen AND DATEDIFF(yy, NgaySinh, GETDATE()) >= @Tuoi);
	;

	WITH cte 
	as
	(--Mã nhân viên, Họ tên, Ngày sinh, Tuổi, Email và Di động
		SELECT RowNumber, MaNhanVien, HoTen, NgaySinh, DATEDIFF(yy, NgaySinh, GETDATE()) as Tuoi, Email, DiDong
		FROM #TmpNV
		where  (@HoTen = N'' AND DATEDIFF(yy, NgaySinh, GETDATE()) >= @Tuoi) OR (HoTen = @HoTen AND DATEDIFF(yy, NgaySinh, GETDATE()) >= @Tuoi)
	)
	SELECT *
    FROM cte
    WHERE (@SoDongMoiTrang = 0) OR
        RowNumber BETWEEN (@Trang - 1) * @SoDongMoiTrang + 1 AND @Trang * @SoDongMoiTrang
    ORDER BY RowNumber;
END
GO

--TEST
DECLARE @SoLuong int; 
EXECUTE proc_Customer_Select
	@Trang = 1,
	@SoDongMoiTrang = 20,
	@HoTen = N'',
	@Tuoi = 20,
	@SoLuong = @SoLuong output
	SELECT @SoLuong
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
		CREATE TABLE #SLNV (
        Ngay date,
        TongSL int
    );

    DECLARE @tmpdate date = @TuNgay;
    WHILE @tmpdate <= @DenNgay
    BEGIN
        INSERT INTO #SLNV (Ngay, TongSL)
        SELECT @tmpdate, ISNULL(COUNT(MaNhanVien), 0) AS SoLuongNV
        FROM NhanVien_DuAn
        WHERE   NgayGiaoViec = @tmpdate
				AND MaDuAn = @MaDuAn;
        SET @tmpdate = DATEADD(dd, 1, @tmpdate);
    END;
    SELECT * FROM #SLNV;
END
GO

EXEC proc_ThongKeGiaoViec
	@MaDuAn = 'DA001',
	@TuNgay = '2023-12-01',
	@DenNgay = '2023-12-31'
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
	DROP FUNCTION func_TKeDuAn;
GO
CREATE FUNCTION func_TKeDuAn 
(
	@TuNam int,
	@DenNam int
)
RETURNS @tbl TABLE
(
	Nam int,
	SoLuongDuAn int      
)
AS
BEGIN
		INSERT @tbl (Nam, SoLuongDuAn)
			SELECT YEAR(da.NgayBatDau) as Nam, COUNT(da.MaDuAn) as SLDA
			FROM DuAn AS da
			WHERE YEAR(da.NgayBatDau) BETWEEN @TuNam AND @DenNam
			GROUP BY YEAR(da.NgayBatDau)
			RETURN;
END
GO

SELECT * FROM dbo.func_TKeDuAn (2021, 2026)
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
	SoLuongDuAn int      
)
AS
BEGIN
		DECLARE @tblNam Table
				(
					Nam int
				)
		DECLARE @tmpNam int = @TuNam
		WHILE (@tmpNam < @DenNam)
			BEGIN
				insert into @tblNam values (@tmpNam)
				set @tmpNam += 1;
			END
		INSERT @tbl (Nam, SoLuongDuAn)
			SELECT t1.Nam, ISNULL (t2.SLDA, 0) 
			FROM @tblNam AS t1
			LEFT JOIN
			(
				SELECT YEAR(da.NgayBatDau) as Nam, COUNT(da.MaDuAn) as SLDA
				FROM DuAn AS da
				WHERE YEAR(da.NgayBatDau) BETWEEN @TuNam AND @DenNam
				GROUP BY YEAR(da.NgayBatDau)
			) AS t2 
			ON t1.Nam = t2.Nam
        RETURN;
END
GO

SELECT * FROM dbo.func_TKeDuAn_DayDuCacNam (2021, 2026)
GO


/*Câu 5 (1.0 điểm) Viết các lệnh thực hiện các yêu cầu sau đây
- Tạo tài khoản có tên là user_MãSinhViên (ví dụ: user_2T1020001) với mật khẩu là 123456
- Cho phép tài khoản trên được phép truy cập vào cơ sở dữ liệu đã tạo.
- Cấp phát cho tài khoản trên các quyền sau đây:
o Được phép thực hiện lệnh SELECT và INSERT trên bảng*/
-- Tạo tài khoản
use master
go
create login user_21T1020105 with password = '123456'
go

-- Tạo người dùng CSDL
use OnTap1_21T1020105;
go
create user user_21T1020105 for login user_21T1020105;
go

-- Cấp quyền
grant select, update on NhanVien to user_21T1020105;

grant execute on proc_NhanVien_DuAn_Insert to user_21T1020105;
grant execute on proc_DuAn_DanhSachNhanVien to user_21T1020105;
grant execute on proc_NhanVien_TimKiem to user_21T1020105;
grant execute on proc_ThongKeGiaoViec to user_21T1020105;

grant select on func_TKeDuAn to user_21T1020105;
grant select on func_TKeDuAn_DayDuCacNam to user_21T1020105