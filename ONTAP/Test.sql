USE [master]
GO
/****** Object:  Database [ONTAP1_21T1020105]    Script Date: 26/12/2023 09:56:17 SA ******/
CREATE DATABASE [ONTAP1_21T1020105]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'21T1020105', FILENAME = N'F:\Download\MSSQL15.SQLEXPRESS01\MSSQL\DATA\21T1020105.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'21T1020105_log', FILENAME = N'F:\Download\MSSQL15.SQLEXPRESS01\MSSQL\DATA\21T1020105_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ONTAP1_21T1020105].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ONTAP1_21T1020105] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET ARITHABORT OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET  MULTI_USER 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ONTAP1_21T1020105] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ONTAP1_21T1020105] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
USE [ONTAP1_21T1020105]
GO
/****** Object:  Table [dbo].[DuAn]    Script Date: 26/12/2023 09:56:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DuAn](
	[MaDuAn] [nvarchar](50) NOT NULL,
	[TenDuAn] [nvarchar](255) NOT NULL,
	[NgayBatDau] [date] NOT NULL,
	[SoNguoiThamGia] [int] NOT NULL,
 CONSTRAINT [PK_DuAn] PRIMARY KEY CLUSTERED 
(
	[MaDuAn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NhanVien]    Script Date: 26/12/2023 09:56:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien](
	[MaNhanVien] [nvarchar](50) NOT NULL,
	[HoTen] [nvarchar](50) NOT NULL,
	[NgaySinh] [date] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[DiDong] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_NhanVien] PRIMARY KEY CLUSTERED 
(
	[MaNhanVien] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NhanVien_DuAn]    Script Date: 26/12/2023 09:56:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien_DuAn](
	[MaNhanVien] [nvarchar](50) NOT NULL,
	[MaDuAn] [nvarchar](50) NOT NULL,
	[NgayGiaoViec] [date] NOT NULL,
	[MoTaCongViec] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_NhanVien_DuAn] PRIMARY KEY CLUSTERED 
(
	[MaNhanVien] ASC,
	[MaDuAn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[func_TKeDuAn]    Script Date: 26/12/2023 09:56:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[func_TKeDuAn]
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
INSERT [dbo].[DuAn] ([MaDuAn], [TenDuAn], [NgayBatDau], [SoNguoiThamGia]) VALUES (N'DA001', N'SmartUni', CAST(N'2022-01-01' AS Date), 2)
INSERT [dbo].[DuAn] ([MaDuAn], [TenDuAn], [NgayBatDau], [SoNguoiThamGia]) VALUES (N'DA002', N'E-Shop', CAST(N'2022-05-01' AS Date), 2)
INSERT [dbo].[DuAn] ([MaDuAn], [TenDuAn], [NgayBatDau], [SoNguoiThamGia]) VALUES (N'DA003', N'LiteCMS', CAST(N'2022-09-01' AS Date), 1)
GO
INSERT [dbo].[NhanVien] ([MaNhanVien], [HoTen], [NgaySinh], [Email], [DiDong]) VALUES (N'NV001', N'Nguyễn Thanh An', CAST(N'1980-12-01' AS Date), N'thanhanh@gmail.com', N'0914422578')
INSERT [dbo].[NhanVien] ([MaNhanVien], [HoTen], [NgaySinh], [Email], [DiDong]) VALUES (N'NV002', N'Trần Chí Hiếu', CAST(N'1985-05-17' AS Date), N'hieu85@gmail.com', N'0987454125')
INSERT [dbo].[NhanVien] ([MaNhanVien], [HoTen], [NgaySinh], [Email], [DiDong]) VALUES (N'NV003', N'Vũ Thành Chung', CAST(N'1986-11-20' AS Date), N'chungvt@gmail.com', N'0935254771')
INSERT [dbo].[NhanVien] ([MaNhanVien], [HoTen], [NgaySinh], [Email], [DiDong]) VALUES (N'NV005', N'Lê Thị Hải Yến', CAST(N'1986-08-14' AS Date), N'lthyen@gmail.com', N'0983120547')
GO
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV001', N'DA001', CAST(N'2023-12-18' AS Date), N'Khong co')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV001', N'DA003', CAST(N'2023-12-25' AS Date), N'Khong co')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV002', N'DA001', CAST(N'2023-12-19' AS Date), N'Khong co')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV003', N'DA002', CAST(N'2023-12-19' AS Date), N'Khong co')
INSERT [dbo].[NhanVien_DuAn] ([MaNhanVien], [MaDuAn], [NgayGiaoViec], [MoTaCongViec]) VALUES (N'NV005', N'DA002', CAST(N'2023-12-25' AS Date), N'Khong co')
GO
ALTER TABLE [dbo].[NhanVien_DuAn]  WITH CHECK ADD  CONSTRAINT [FK_NhanVien_DuAn_DuAn1] FOREIGN KEY([MaDuAn])
REFERENCES [dbo].[DuAn] ([MaDuAn])
GO
ALTER TABLE [dbo].[NhanVien_DuAn] CHECK CONSTRAINT [FK_NhanVien_DuAn_DuAn1]
GO
ALTER TABLE [dbo].[NhanVien_DuAn]  WITH CHECK ADD  CONSTRAINT [FK_NhanVien_DuAn_NhanVien1] FOREIGN KEY([MaNhanVien])
REFERENCES [dbo].[NhanVien] ([MaNhanVien])
GO
ALTER TABLE [dbo].[NhanVien_DuAn] CHECK CONSTRAINT [FK_NhanVien_DuAn_NhanVien1]
GO
/****** Object:  StoredProcedure [dbo].[proc_Customer_Select]    Script Date: 26/12/2023 09:56:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_Customer_Select]
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
/****** Object:  StoredProcedure [dbo].[proc_NhanVien_DuAn_Insert]    Script Date: 26/12/2023 09:56:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_NhanVien_DuAn_Insert]
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
/****** Object:  StoredProcedure [dbo].[proc_NhanVien_TimKiem]    Script Date: 26/12/2023 09:56:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_NhanVien_TimKiem]
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
/****** Object:  StoredProcedure [dbo].[proc_ThongKeGiaoViec]    Script Date: 26/12/2023 09:56:17 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_ThongKeGiaoViec]
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
USE [master]
GO
ALTER DATABASE [ONTAP1_21T1020105] SET  READ_WRITE 
GO
