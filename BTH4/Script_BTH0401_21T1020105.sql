USE [BTH0401_21T1020105]
GO
/****** Object:  UserDefinedFunction [dbo].[func_CountPassed]    Script Date: 19/11/2023 09:35:13 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[func_CountPassed] (@ExamineeId int)
RETURNS int
AS
BEGIN
	DECLARE @sl int;
	SELECT @sl = COUNT(CertificateId)
				 FROM Registration
				 WHERE ExamineeId = @ExamineeId
				 AND ExamResult >=5
	RETURN @sl;
END
GO
/****** Object:  UserDefinedFunction [dbo].[func_TotalByDate]    Script Date: 19/11/2023 09:35:13 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[func_TotalByDate]
(
	@From date,
	@To date
) 
RETURNS @tbl TABLE
(
	Ngay date primary key,
	Sl int
)
BEGIN
	INSERT INTO @tbl(Ngay, Sl)
		SELECT r.RegisterTime, COUNT(*) as SoLuong
		FROM Registration as r
		WHERE r.RegisterTime between @From and @To
		GROUP BY RegisterTime
	DECLARE @d date = @From;
	WHILE @d <= @To
	BEGIN
		-- Lệnh Exists chỉ để kiểm tra có hay không có data (số dòng trả về)
		IF NOT EXISTS (SELECT * FROM @tbl WHERE Ngay = @d)
		INSERT INTO @tbl(Ngay, Sl) VALUES(@d, 0)
		SET @d = DATEADD(DAY, 1, @d);
	END
RETURN;
END
GO
/****** Object:  Table [dbo].[Certificate]    Script Date: 19/11/2023 09:35:13 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Certificate](
	[CertificateId] [int] IDENTITY(1,1) NOT NULL,
	[CetificateName] [nvarchar](100) NOT NULL,
	[NumberOfRegister] [int] NOT NULL,
	[NumberOfPass] [int] NOT NULL,
 CONSTRAINT [PK_Certificate] PRIMARY KEY CLUSTERED 
(
	[CertificateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Examinee]    Script Date: 19/11/2023 09:35:13 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Examinee](
	[ExamineeId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NULL,
	[BirthDate] [date] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Examinee] PRIMARY KEY CLUSTERED 
(
	[ExamineeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Registration]    Script Date: 19/11/2023 09:35:13 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Registration](
	[ExamineeId] [int] NOT NULL,
	[CertificateId] [int] NOT NULL,
	[RegisterTime] [date] NOT NULL,
	[ExamResult] [int] NOT NULL,
 CONSTRAINT [PK_Registration] PRIMARY KEY CLUSTERED 
(
	[ExamineeId] ASC,
	[CertificateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Certificate] ON 

INSERT [dbo].[Certificate] ([CertificateId], [CetificateName], [NumberOfRegister], [NumberOfPass]) VALUES (1, N'MOS', 1, 1)
INSERT [dbo].[Certificate] ([CertificateId], [CetificateName], [NumberOfRegister], [NumberOfPass]) VALUES (2, N'TOEIC', 1, 1)
INSERT [dbo].[Certificate] ([CertificateId], [CetificateName], [NumberOfRegister], [NumberOfPass]) VALUES (3, N'IELTS', 1, 1)
INSERT [dbo].[Certificate] ([CertificateId], [CetificateName], [NumberOfRegister], [NumberOfPass]) VALUES (4, N'B1', 0, 0)
SET IDENTITY_INSERT [dbo].[Certificate] OFF
GO
SET IDENTITY_INSERT [dbo].[Examinee] ON 

INSERT [dbo].[Examinee] ([ExamineeId], [FirstName], [LastName], [BirthDate], [Email], [Address]) VALUES (1, N'Lan', N'Nguyen', CAST(N'1999-01-08' AS Date), N'lannguyen@gmail.com', N'Hue')
INSERT [dbo].[Examinee] ([ExamineeId], [FirstName], [LastName], [BirthDate], [Email], [Address]) VALUES (2, N'Minh', N'Pham', CAST(N'1999-10-09' AS Date), N'minhpham@gmail.com', N'Da Nang')
INSERT [dbo].[Examinee] ([ExamineeId], [FirstName], [LastName], [BirthDate], [Email], [Address]) VALUES (3, N'Hoang', N'Nguyen', CAST(N'1999-01-10' AS Date), N'hoangnguyen@gmail.com', N'Hue')
INSERT [dbo].[Examinee] ([ExamineeId], [FirstName], [LastName], [BirthDate], [Email], [Address]) VALUES (4, N'Phuong', N'Phan', CAST(N'2000-01-11' AS Date), N'linhphan@gmail.com', N'Ha Tinh')
INSERT [dbo].[Examinee] ([ExamineeId], [FirstName], [LastName], [BirthDate], [Email], [Address]) VALUES (5, N'Khai', N'Doan', CAST(N'2003-01-12' AS Date), N'khaidoan@gmail.com', N'Hue')
INSERT [dbo].[Examinee] ([ExamineeId], [FirstName], [LastName], [BirthDate], [Email], [Address]) VALUES (6, N'Khoa', N'Nguyen', CAST(N'2002-01-13' AS Date), N'khoanguyen@gmail.com', N'Hue')
SET IDENTITY_INSERT [dbo].[Examinee] OFF
GO
INSERT [dbo].[Registration] ([ExamineeId], [CertificateId], [RegisterTime], [ExamResult]) VALUES (1, 1, CAST(N'2023-11-16' AS Date), 6)
INSERT [dbo].[Registration] ([ExamineeId], [CertificateId], [RegisterTime], [ExamResult]) VALUES (1, 2, CAST(N'2023-11-18' AS Date), 8)
INSERT [dbo].[Registration] ([ExamineeId], [CertificateId], [RegisterTime], [ExamResult]) VALUES (2, 3, CAST(N'2023-11-16' AS Date), 5)
GO
ALTER TABLE [dbo].[Certificate] ADD  CONSTRAINT [DF_Certificate_NumberOfRegister]  DEFAULT ((0)) FOR [NumberOfRegister]
GO
ALTER TABLE [dbo].[Certificate] ADD  CONSTRAINT [DF_Certificate_NumberOfPass]  DEFAULT ((0)) FOR [NumberOfPass]
GO
ALTER TABLE [dbo].[Registration] ADD  CONSTRAINT [DF_Registration_RegisterTime]  DEFAULT (getdate()) FOR [RegisterTime]
GO
ALTER TABLE [dbo].[Registration] ADD  CONSTRAINT [DF_Registration_ExamResult]  DEFAULT ((0)) FOR [ExamResult]
GO
ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_Registration_Certificate] FOREIGN KEY([CertificateId])
REFERENCES [dbo].[Certificate] ([CertificateId])
GO
ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_Registration_Certificate]
GO
ALTER TABLE [dbo].[Registration]  WITH CHECK ADD  CONSTRAINT [FK_Registration_Examinee] FOREIGN KEY([ExamineeId])
REFERENCES [dbo].[Examinee] ([ExamineeId])
GO
ALTER TABLE [dbo].[Registration] CHECK CONSTRAINT [FK_Registration_Examinee]
GO
/****** Object:  StoredProcedure [dbo].[proc_CountRegisteringByDate]    Script Date: 19/11/2023 09:35:14 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_CountRegisteringByDate]
	@From date,
	@To date
AS
BEGIN
	SET NOCOUNT ON;
	WITH cte_Ngay as
	(
		SELECT @From as Ngay
		UNION all
		SELECT DATEADD(DAY, 1, Ngay)
		FROM cte_Ngay
		WHERE Ngay < @To
	)
	, cte_ThongKe as
	(
		SELECT r.RegisterTime, COUNT(*) as SoLuong
		FROM Registration as r
		WHERE r.RegisterTime between @From and @To
		GROUP BY RegisterTime
	)
	SELECT t1.Ngay, ISNULL(t2.SoLuong, 0) as SoLuong
	FROM cte_Ngay as t1
		LEFT JOIN cte_ThongKe as t2 on t1.Ngay = t2.RegisterTime
END
GO
/****** Object:  StoredProcedure [dbo].[proc_Examinee_Select]    Script Date: 19/11/2023 09:35:14 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Examinee_Select]
	@SearchValue nvarchar(255) = N'',
	@Page int = 1,
	@PageSize int = 20,
	@RowCount int output,
	@PageCount int output
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *, ROW_NUMBER() over(order by ExamineeId) as RowNumber
	INTO #TempExaminee
	FROM Examinee


	-- @RowCount : Tham số đầu ra cho biết tổng số dòng dữ liệu tìm được
	SELECT @RowCount = COUNT(*)
	FROM Examinee
	where (@SearchValue = N'') or (FirstName like @SearchValue or LastName like @SearchValue);

	IF(@PageSize = 0)
		SET @PageCount = 1
	ELSE
		BEGIN
		-- @PageCount : Tham số đầu ra cho biết tổng số trang.
			SET @PageCount = @RowCount / @PageSize;
			IF (@RowCount % @PageSize > 0)
				SET @PageCount += 1;
		END;
	;WITH cte as
	(
		SELECT * from #TempExaminee
		where (@SearchValue = N'') or (FirstName like @SearchValue or LastName like @SearchValue)
	)
	SELECT * FROM cte
	-- @PageSize : Số dòng trên mỗi trang (nếu @PageSize = 0 thì hiển thị toàn bộ dữ liệu tìm được)
	where (@PageSize = 0) or
			RowNumber between (@Page - 1) * @PageSize + 1 AND @Page * @PageSize
	ORDER BY RowNumber
END
GO
/****** Object:  StoredProcedure [dbo].[proc_Registration_Add]    Script Date: 19/11/2023 09:35:14 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Registration_Add]
	@ExamineeId int,
	@CertificateId int,
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT * FROM Registration WHERE ExamineeId = @ExamineeId AND CertificateId = @CertificateId)
	BEGIN
		SET @Result = 'Thi sinh da dang ki chung chi nay';
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM Certificate WHERE CertificateId = @CertificateId)
	BEGIN
		SET @Result = 'Ma chung chi nay khong ton tai';
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM Examinee WHERE ExamineeId = @ExamineeId)
	BEGIN
		SET @Result = 'Thi sinh nay khong ton tai';
		RETURN;
	END

	INSERT INTO Registration(ExamineeId, CertificateId, RegisterTime, ExamResult)
	VALUES(@ExamineeId, @CertificateId, GETDATE(), 0)

	UPDATE Certificate
	SET NumberOfRegister = NumberOfRegister + 1
	WHERE CertificateId = @CertificateId
END
GO
/****** Object:  StoredProcedure [dbo].[proc_SaveExamResult]    Script Date: 19/11/2023 09:35:14 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_SaveExamResult]
	@ExamineeId int,
	@CertificateId int,
	@ExamResult int,
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;
	IF @ExamResult < 0 OR @ExamResult > 10 
	BEGIN
		SET @Result = 'Diem thi khong hop le';
		RETURN;
	END

	UPDATE Registration
		SET ExamResult = @ExamResult
		WHERE CertificateId = @CertificateId
		AND ExamineeId = @ExamineeId
	IF(@@ROWCOUNT < 1)
	BEGIN
		SET @Result = 'ExamineeId va CertificateId khong trung khop trong he thong';
		RETURN;
	END
		
	UPDATE Certificate
		SET NumberOfPass = NumberOfPass + 1
		WHERE CertificateId = @CertificateId
		AND @ExamResult >= 5
END
GO
