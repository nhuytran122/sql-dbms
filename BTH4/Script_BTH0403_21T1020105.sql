USE [BHT0403_21T1020105]
GO
/****** Object:  UserDefinedFunction [dbo].[func_CountPost]    Script Date: 19/11/2023 09:36:46 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[func_CountPost] 
(
	@From date, 
	@To date
)
RETURNS int
AS
BEGIN
	DECLARE @sl int;
	SELECT @sl = COUNT(PostId)
	FROM Posts
	WHERE CreatedTime BETWEEN @From and @To
	RETURN @sl;
END
GO
/****** Object:  UserDefinedFunction [dbo].[func_CountPostByYear]    Script Date: 19/11/2023 09:36:46 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[func_CountPostByYear] 
(
	@FromYear int, 
	@ToYear int
)
RETURNS @tbl TABLE
(
	Nam int,
	SoLuong int
)
AS
BEGIN
	INSERT INTO @tbl(Nam, SoLuong)
	SELECT YEAR(p.CreatedTime) as Nam,
					COUNT(p.PostId)
	FROM Posts as p
	WHERE YEAR(p.CreatedTime) between @FromYear and @ToYear
	GROUP BY YEAR(p.CreatedTime)

	DECLARE @y int = @FromYear;
	WHILE @y <= @ToYear
	BEGIN
		IF NOT EXISTS (SELECT * FROM @tbl WHERE Nam = @y)
		INSERT INTO @tbl(Nam, SoLuong) VALUES(@y, 0)
		SET @y = @y + 1;
	END
	RETURN;
END
GO
/****** Object:  Table [dbo].[Accounts]    Script Date: 19/11/2023 09:36:46 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Accounts](
	[AccountId] [int] IDENTITY(1,1) NOT NULL,
	[AccountName] [nvarchar](100) NULL,
	[Gender] [nvarchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL,
	[IsLocked] [bit] NULL,
	[NumOfPost] [int] NULL,
	[NumOfComments] [int] NULL,
 CONSTRAINT [PK_Accounts] PRIMARY KEY CLUSTERED 
(
	[AccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Comments]    Script Date: 19/11/2023 09:36:46 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comments](
	[CommentId] [int] IDENTITY(1,1) NOT NULL,
	[PostId] [int] NOT NULL,
	[AccountId] [int] NOT NULL,
	[CreatedTime] [datetime] NOT NULL,
	[CommentText] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_Comments] PRIMARY KEY CLUSTERED 
(
	[CommentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Posts]    Script Date: 19/11/2023 09:36:46 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Posts](
	[PostId] [int] IDENTITY(1,1) NOT NULL,
	[PostTitle] [nvarchar](255) NOT NULL,
	[PostContent] [nvarchar](2000) NOT NULL,
	[CreatedTime] [datetime] NOT NULL,
	[AccountId] [int] NOT NULL,
	[NumOfComments] [int] NOT NULL,
 CONSTRAINT [PK_Posts] PRIMARY KEY CLUSTERED 
(
	[PostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Accounts] ON 

INSERT [dbo].[Accounts] ([AccountId], [AccountName], [Gender], [Email], [Password], [IsLocked], [NumOfPost], [NumOfComments]) VALUES (1, N'NhuY', N'Nu', N'nhuytran@gmail.com', N'123', 0, 1, 0)
INSERT [dbo].[Accounts] ([AccountId], [AccountName], [Gender], [Email], [Password], [IsLocked], [NumOfPost], [NumOfComments]) VALUES (2, N'QuocMinh', N'Nam', N'qminh@gmail.com', N'456', 0, 3, 0)
INSERT [dbo].[Accounts] ([AccountId], [AccountName], [Gender], [Email], [Password], [IsLocked], [NumOfPost], [NumOfComments]) VALUES (3, N'LeMinh', N'Nam', N'leminh@gmail.com', N'789', 1, 1, 1)
INSERT [dbo].[Accounts] ([AccountId], [AccountName], [Gender], [Email], [Password], [IsLocked], [NumOfPost], [NumOfComments]) VALUES (4, N'AnhThu', N'Nu', N'anhthu@gmail.com', N'357', 0, 0, 0)
INSERT [dbo].[Accounts] ([AccountId], [AccountName], [Gender], [Email], [Password], [IsLocked], [NumOfPost], [NumOfComments]) VALUES (5, N'NhaUyen', N'Nu', N'nhauyen@gmail.com', N'490', 1, 1, 0)
SET IDENTITY_INSERT [dbo].[Accounts] OFF
GO
SET IDENTITY_INSERT [dbo].[Comments] ON 

INSERT [dbo].[Comments] ([CommentId], [PostId], [AccountId], [CreatedTime], [CommentText]) VALUES (2, 2, 3, CAST(N'2023-11-17T19:21:04.683' AS DateTime), N'ABCDE')
SET IDENTITY_INSERT [dbo].[Comments] OFF
GO
SET IDENTITY_INSERT [dbo].[Posts] ON 

INSERT [dbo].[Posts] ([PostId], [PostTitle], [PostContent], [CreatedTime], [AccountId], [NumOfComments]) VALUES (2, N'Title 2', N'Content 2', CAST(N'2023-11-17T17:55:12.130' AS DateTime), 3, 9)
INSERT [dbo].[Posts] ([PostId], [PostTitle], [PostContent], [CreatedTime], [AccountId], [NumOfComments]) VALUES (3, N'Title 1', N'Content 1', CAST(N'2023-11-17T18:05:17.403' AS DateTime), 2, 6)
INSERT [dbo].[Posts] ([PostId], [PostTitle], [PostContent], [CreatedTime], [AccountId], [NumOfComments]) VALUES (4, N'Title 3', N'Content 3', CAST(N'2023-11-17T19:19:32.960' AS DateTime), 5, 10)
INSERT [dbo].[Posts] ([PostId], [PostTitle], [PostContent], [CreatedTime], [AccountId], [NumOfComments]) VALUES (5, N'Title 5', N'Content 5', CAST(N'2023-11-17T20:07:12.690' AS DateTime), 1, 0)
INSERT [dbo].[Posts] ([PostId], [PostTitle], [PostContent], [CreatedTime], [AccountId], [NumOfComments]) VALUES (6, N'Title 6', N'Content 6', CAST(N'2023-11-17T20:09:41.787' AS DateTime), 2, 0)
SET IDENTITY_INSERT [dbo].[Posts] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UK_Accounts]    Script Date: 19/11/2023 09:36:47 CH ******/
ALTER TABLE [dbo].[Accounts] ADD  CONSTRAINT [UK_Accounts] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Accounts] ADD  CONSTRAINT [DF_Accounts_IsLocked]  DEFAULT ((0)) FOR [IsLocked]
GO
ALTER TABLE [dbo].[Accounts] ADD  CONSTRAINT [DF_Accounts_NumOfPost]  DEFAULT ((0)) FOR [NumOfPost]
GO
ALTER TABLE [dbo].[Accounts] ADD  CONSTRAINT [DF_Accounts_NumOfComments]  DEFAULT ((0)) FOR [NumOfComments]
GO
ALTER TABLE [dbo].[Comments] ADD  CONSTRAINT [DF_Comments_CreatedTime]  DEFAULT (getdate()) FOR [CreatedTime]
GO
ALTER TABLE [dbo].[Posts] ADD  CONSTRAINT [DF_Posts_CreatedTime]  DEFAULT (getdate()) FOR [CreatedTime]
GO
ALTER TABLE [dbo].[Posts] ADD  CONSTRAINT [DF_Posts_NumOfComment]  DEFAULT ((0)) FOR [NumOfComments]
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_Accounts] FOREIGN KEY([AccountId])
REFERENCES [dbo].[Accounts] ([AccountId])
GO
ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [FK_Comments_Accounts]
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_Posts] FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO
ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [FK_Comments_Posts]
GO
ALTER TABLE [dbo].[Posts]  WITH CHECK ADD  CONSTRAINT [FK_Posts_Accounts] FOREIGN KEY([AccountId])
REFERENCES [dbo].[Accounts] ([AccountId])
GO
ALTER TABLE [dbo].[Posts] CHECK CONSTRAINT [FK_Posts_Accounts]
GO
/****** Object:  StoredProcedure [dbo].[proc_Accounts_Update]    Script Date: 19/11/2023 09:36:47 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Accounts_Update]
	@AccountId int,
	@AccountName nvarchar(100),
	@Gender nvarchar(50),
	@Email nvarchar(50),
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;

	IF @Email IS NULL or @Email = N''
		BEGIN
			SET @Result = 'Email rong';
			RETURN;
		END
	IF EXISTS (SELECT * FROM Accounts WHERE Email = @Email AND AccountId <> @AccountId)
		BEGIN
			SET @Result = 'Email trung voi Email cua tai khoan khac';
			RETURN;
		END
	IF @AccountName IS NULL or @AccountName = N''
		BEGIN
			SET @Result = 'Ten tai khoan rong';
			RETURN;
		END
	IF @Gender IS NULL or @Gender = N''
		BEGIN
			SET @Result = 'Gioi tinh rong';
			RETURN;
		END

	UPDATE Accounts
	SET AccountName = @AccountName,
		Gender = @Gender,
		Email = @Email
	WHERE AccountId = @AccountId

	IF (@@ROWCOUNT < 1)
	BEGIN	
		SET @Result = 'AccountId khong ton tai';
		RETURN;
	END
END
GO
/****** Object:  StoredProcedure [dbo].[proc_CountPostByYear]    Script Date: 19/11/2023 09:36:47 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_CountPostByYear]
	@FromYear int,
	@ToYear int
AS
BEGIN
	SET NOCOUNT ON;
	CREATE table #tblNam
	(
	Nam int
	)

	DECLARE @tmpYear int = @FromYear;
	WHILE (@tmpYear <= @ToYear)
		BEGIN
			INSERT INTO #tblNam VALUES (@tmpYear);
			SET @tmpYear += 1;
		END

	SELECT t1.Nam, ISNULL(t2.SoLuongBaiViet, 0) as SoLuongBaiViet
	FROM #tblNam as t1
		LEFT JOIN 
		(
			select YEAR(p.CreatedTime) as Nam,
					COUNT(p.PostId) AS SoLuongBaiViet
			FROM Posts as p
			GROUP BY YEAR(p.CreatedTime)
		) as t2
		ON t1.Nam = t2.Nam
	DROP TABLE #tblNam
END
GO
/****** Object:  StoredProcedure [dbo].[proc_Posts_Insert]    Script Date: 19/11/2023 09:36:47 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Posts_Insert]
	@PostTitle nvarchar(255),
	@PostContent nvarchar(2000),
	@AccountId int,
	@PostId int output
AS
BEGIN
	SET NOCOUNT ON;
	IF (LEN(@PostTitle) < 0 OR LEN(@PostContent) < 0)
	BEGIN
		SET @PostId = -1;
		RETURN;
	END
	IF NOT EXISTS (SELECT * FROM Accounts WHERE AccountId = @AccountId)
	BEGIN
		SET @PostId = -2;
		RETURN;
	END

	INSERT INTO Posts(PostTitle, PostContent, CreatedTime, AccountId, NumOfComments)
	VALUES  (@PostTitle, @PostContent, GETDATE(), @AccountId, 0)
	SET @PostId = @@IDENTITY;

	UPDATE Accounts
	SET NumOfPost = NumOfPost + 1
	WHERE AccountId = @AccountId
END
GO
/****** Object:  StoredProcedure [dbo].[proc_Posts_Select]    Script Date: 19/11/2023 09:36:47 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Posts_Select]
	@SearchValue nvarchar(255) = N'',
	@Page int = 1,
	@PageSize int = 20,
	@RowCount int output,
	@PageCount int output
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *, ROW_NUMBER() over(order by PostId) as RowNumber
	INTO #TempPost
	FROM Posts

	-- @RowCount : Tham số đầu ra cho biết tổng số dòng dữ liệu tìm được
	SELECT @RowCount = COUNT(*)
	FROM Posts
	where (@SearchValue = N'') or (PostTitle like @SearchValue OR PostContent like @SearchValue);

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
		SELECT * from #TempPost
		where (@SearchValue = N'') or (PostTitle like @SearchValue OR PostContent like @SearchValue)
	)
	SELECT * FROM cte
	-- @PageSize : Số dòng trên mỗi trang (nếu @PageSize = 0 thì hiển thị toàn bộ dữ liệu tìm được)
	where (@PageSize = 0) or
			RowNumber between (@Page - 1) * @PageSize + 1 AND @Page * @PageSize
	ORDER BY RowNumber
END
GO
