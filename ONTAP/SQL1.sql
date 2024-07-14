/*Câu 2 (1.0 điểm): Tạo trigger có tên trg_NhanVien_DuAn_Insert bắt lệnh INSERT trên
bảng NhanVien_DuAn sao cho mỗi lần bổ sung thêm dữ liệu cho bảng NhanVien_DuAn
(tức là giao cho nhân viên thực hiện dự án) thì cập nhật lại cột SoNguoiThamGia của bảng
DuAn bằng đúng với số lượng nhân viên đã được giao thực hiện dự án.*/
IF EXISTS (SELECT * FROM sys.objects where name = 'trg_NhanVien_DuAn_Insert')
DROP TRIGGER trg_NhanVien_DuAn_Insert
GO

CREATE TRIGGER trg_NhanVien_DuAn_Insert
ON NhanVien_DuAn
FOR INSERT
AS
BEGIN
	UPDATE da
	SET SoNguoiThamGia += 1
	FROM DuAn as da inner join inserted as i
	ON da.MaDuAn = i.MaDuAn
END
GO

INSERT INTO NhanVien_DuAn (MaNhanVien, MaDuAn, NgayGiaoViec, MoTaCongViec)
VALUES ('NV002', 'DA001', GETDATE(), 'Khong co')
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
IF EXISTS (SELECT * FROM sys.objects where name = 'proc_NhanVien_DuAn_Insert')
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
		SET	@KetQua = 'Khong ton tai ' + @MaNhanVien
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM DuAn WHERE MaDuAn = @MaDuAn)
	BEGIN
		SET	@KetQua = 'Khong ton tai ' + @MaDuAn
		RETURN;
	END

	IF EXISTS (SELECT * FROM NhanVien_DuAn WHERE MaNhanVien = @MaNhanVien AND MaDuAn = @MaDuAn)
	BEGIN
		SET	@KetQua = 'Nhan vien ' + @MaNhanVien + ' da tham gia du an ' + @MaDuAn;
		RETURN;
	END

	INSERT INTO NhanVien_DuAn (MaNhanVien, MaDuAn, NgayGiaoViec, MoTaCongViec)
	VALUES (@MaNhanVien, @MaDuAn, GETDATE(), @MoTaCongViec)
END
GO

DECLARE @KetQua nvarchar(255);
EXEC proc_NhanVien_DuAn_Insert
@MaNhanVien = 'NV003',
@MaDuAn = 'DA004',
@MoTaCongViec = 'Khong co',
@KetQua = @KetQua output;
GO

/*b. (1.0 điểm) proc_DuAn_DanhSachNhanVien
@TenDuAn nvarchar(255),
@NgayGiaoViec date

Có chức năng hiển thị danh sách các nhân viên được giao thực hiện dự án có tên
@TenDuAn trước ngày @NgayGiaoViec. Thông tin hiển thị bao gồm: Mã nhân viên, Họ
tên, Email, Di động, Ngày giao việc và Mô tả công việc được giao.*/

IF EXISTS (SELECT * FROM sys.objects where name = 'proc_DuAn_DanhSachNhanVien')
DROP PROCEDURE proc_DuAn_DanhSachNhanVien
GO

CREATE PROCEDURE proc_DuAn_DanhSachNhanVien
	@TenDuAn nvarchar(255),
	@NgayGiaoViec date
AS
BEGIN
	SELECT nv.MaNhanVien, nv.HoTen, nv.Email, nv.DiDong, nd.NgayGiaoViec, nd.MoTaCongViec
	FROM (NhanVien as nv JOIN NhanVien_DuAn as nd ON nv.MaNhanVien = nd.MaNhanVien) JOIN DuAn as da ON nd.MaDuAn = da.MaDuAn
	WHERE TenDuAn = @TenDuAn
	AND nd.NgayGiaoViec < @NgayGiaoViec
END
GO

EXEC proc_DuAn_DanhSachNhanVien
		@TenDuAn = 'E-Shop',
		@NgayGiaoViec = '2023-12-25';
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
IF EXISTS (SELECT * FROM sys.objects where name = 'proc_NhanVien_TimKiem')
DROP PROCEDURE proc_NhanVien_TimKiem
GO

CREATE PROCEDURE proc_NhanVien_TimKiem
	@Trang int = 1,
	@SoDongMoiTrang int = 20,
	@HoTen nvarchar(50) = N'',
	@Tuoi int,
	@SoLuong int output
AS
BEGIN
	SELECT *, ROW_NUMBER() OVER (order by TenNhanVien) as RowNumber
	INTO #TempNV
	FROM NhanVien

	SELECT @SoLuong = SELECT COUNT(*)
	FROM NhanVien
	WHERE (@HoTen = N'') OR (
END
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

/*Câu 4: Tạo các hàm sau đây:
a. (1 điểm) func_TKeDuAn
@TuNam int,
@DenNam int

Có chức năng trả về một bảng thống kê số lượng dự án được thực hiện trong mỗi năm trong
khoảng thời gian từ năm @TuNam đến năm @DenNam (năm thực hiện dự án được xác
định dựa vào Ngày bắt đầu của dự án). Thông tin cần hiển thị bao gồm: Năm thực hiện và
Số lượng dự án.*/

/*b. (1.5 điểm) func_TKeDuAn_DayDuCacNam

@TuNam int,
@DenNam int

Có chức năng trả về một bảng thống kê số lượng dự án được thực hiện trong mỗi năm trong
khoảng thời gian từ năm @TuNam đến năm @DenNam (năm thực hiện dự án được xác
định dựa vào Ngày bắt đầu của dự án). Thông tin cần hiển thị bao gồm: Năm thực hiện và
Số lượng dự án. Yêu cầu kết quả phải thể hiện đầy đủ tất cả các năm trong khoảng thời
gian cần thống kê (tức là những năm không có dự án nào được thực hiện thì cũng hiển thị
với số lượng dự án là 0).*/

/*Câu 5 (1.0 điểm) Viết các lệnh thực hiện các yêu cầu sau đây
- Tạo tài khoản có tên là user_MãSinhViên (ví dụ: user_2T1020001) với mật khẩu
là 123456
- Cho phép tài khoản trên được phép truy cập vào cơ sở dữ liệu đã tạo.
- Cấp phát cho tài khoản trên các quyền sau đây:
o Được phép thực hiện lệnh SELECT và INSERT trên bảng NhanVien
o Được phép sử dụng các thủ tục và hàm đã tạo ở trên*/

