USE [BTH0402_21T1020105]
GO
/****** Object:  UserDefinedFunction [dbo].[func_CountNotEndTasks]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[func_CountNotEndTasks] (@EmployeeId int)
RETURNS int
AS
BEGIN
	DECLARE @sl int;
	SELECT @sl = COUNT(TaskId)
				 FROM TaskAssignments
				 WHERE EmployeeId = @EmployeeId
				 AND EndDate IS NULL
	RETURN @sl;
END
GO
/****** Object:  UserDefinedFunction [dbo].[func_SummaryEndedTasksByDate]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[func_SummaryEndedTasksByDate]
(
	@From date,
	@To date
) 
RETURNS @tbl TABLE
(
	Ngay date primary key,
	SlCvHoanThanh int
)
BEGIN
	INSERT INTO @tbl(Ngay, SlCvHoanThanh)
		SELECT t.EndDate, COUNT(*) as SoLuong
		FROM TaskAssignments as t
		WHERE t.EndDate between @From and @To
		GROUP BY t.EndDate

	DECLARE @d date = @From;
	WHILE @d <= @To
	BEGIN
		-- Lệnh Exists chỉ để kiểm tra có hay không có data (số dòng trả về)
		IF NOT EXISTS (SELECT * FROM @tbl WHERE Ngay = @d)
		INSERT INTO @tbl(Ngay, SlCvHoanThanh) VALUES(@d, 0)
		SET @d = DATEADD(DAY, 1, @d);
	END
RETURN;
END
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[EmployeeId] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeName] [nvarchar](50) NOT NULL,
	[Birthday] [date] NOT NULL,
	[Address] [nvarchar](255) NOT NULL,
	[Phone] [nvarchar](50) NOT NULL,
	[IsWorking] [bit] NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaskAssignments]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaskAssignments](
	[TaskId] [int] NOT NULL,
	[EmployeeId] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
 CONSTRAINT [PK_TaskAssignments] PRIMARY KEY CLUSTERED 
(
	[TaskId] ASC,
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tasks]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tasks](
	[TaskId] [int] IDENTITY(1,1) NOT NULL,
	[TaskName] [nvarchar](255) NOT NULL,
	[InitDate] [date] NOT NULL,
	[NumOfAssigned] [int] NOT NULL,
	[NumOfFinished] [int] NOT NULL,
 CONSTRAINT [PK_Tasks] PRIMARY KEY CLUSTERED 
(
	[TaskId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Employees] ON 

INSERT [dbo].[Employees] ([EmployeeId], [EmployeeName], [Birthday], [Address], [Phone], [IsWorking]) VALUES (1, N'Minh', CAST(N'1999-02-08' AS Date), N'Hue', N'0123456789', 0)
INSERT [dbo].[Employees] ([EmployeeId], [EmployeeName], [Birthday], [Address], [Phone], [IsWorking]) VALUES (2, N'Khanh', CAST(N'1999-02-09' AS Date), N'Da Nang', N'0231456789', 1)
INSERT [dbo].[Employees] ([EmployeeId], [EmployeeName], [Birthday], [Address], [Phone], [IsWorking]) VALUES (3, N'Nhan', CAST(N'2000-02-10' AS Date), N'Hue', N'0456321879', 1)
INSERT [dbo].[Employees] ([EmployeeId], [EmployeeName], [Birthday], [Address], [Phone], [IsWorking]) VALUES (4, N'Binh', CAST(N'1998-02-11' AS Date), N'Ha Tinh', N'0123987456', 0)
SET IDENTITY_INSERT [dbo].[Employees] OFF
GO
INSERT [dbo].[TaskAssignments] ([TaskId], [EmployeeId], [StartDate], [EndDate]) VALUES (1, 1, CAST(N'2023-11-16' AS Date), CAST(N'2023-11-17' AS Date))
INSERT [dbo].[TaskAssignments] ([TaskId], [EmployeeId], [StartDate], [EndDate]) VALUES (1, 2, CAST(N'2023-11-17' AS Date), NULL)
INSERT [dbo].[TaskAssignments] ([TaskId], [EmployeeId], [StartDate], [EndDate]) VALUES (2, 2, CAST(N'2023-11-17' AS Date), CAST(N'2023-11-19' AS Date))
INSERT [dbo].[TaskAssignments] ([TaskId], [EmployeeId], [StartDate], [EndDate]) VALUES (3, 2, CAST(N'2023-11-17' AS Date), NULL)
INSERT [dbo].[TaskAssignments] ([TaskId], [EmployeeId], [StartDate], [EndDate]) VALUES (3, 3, CAST(N'2023-11-17' AS Date), NULL)
GO
SET IDENTITY_INSERT [dbo].[Tasks] ON 

INSERT [dbo].[Tasks] ([TaskId], [TaskName], [InitDate], [NumOfAssigned], [NumOfFinished]) VALUES (1, N'Task1', CAST(N'2023-11-18' AS Date), 3, 1)
INSERT [dbo].[Tasks] ([TaskId], [TaskName], [InitDate], [NumOfAssigned], [NumOfFinished]) VALUES (2, N'Task2', CAST(N'2023-11-21' AS Date), 1, 1)
INSERT [dbo].[Tasks] ([TaskId], [TaskName], [InitDate], [NumOfAssigned], [NumOfFinished]) VALUES (3, N'Task3', CAST(N'2023-11-25' AS Date), 2, 0)
INSERT [dbo].[Tasks] ([TaskId], [TaskName], [InitDate], [NumOfAssigned], [NumOfFinished]) VALUES (4, N'Task4', CAST(N'2023-11-27' AS Date), 0, 0)
INSERT [dbo].[Tasks] ([TaskId], [TaskName], [InitDate], [NumOfAssigned], [NumOfFinished]) VALUES (5, N'Task5', CAST(N'2023-11-28' AS Date), 0, 0)
SET IDENTITY_INSERT [dbo].[Tasks] OFF
GO
ALTER TABLE [dbo].[Tasks] ADD  CONSTRAINT [DF_Tasks_NumOfAssigned]  DEFAULT ((0)) FOR [NumOfAssigned]
GO
ALTER TABLE [dbo].[Tasks] ADD  CONSTRAINT [DF_Tasks_NumOfFinished]  DEFAULT ((0)) FOR [NumOfFinished]
GO
ALTER TABLE [dbo].[TaskAssignments]  WITH CHECK ADD  CONSTRAINT [FK_TaskAssignments_Employees] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employees] ([EmployeeId])
GO
ALTER TABLE [dbo].[TaskAssignments] CHECK CONSTRAINT [FK_TaskAssignments_Employees]
GO
ALTER TABLE [dbo].[TaskAssignments]  WITH CHECK ADD  CONSTRAINT [FK_TaskAssignments_Tasks] FOREIGN KEY([TaskId])
REFERENCES [dbo].[Tasks] ([TaskId])
GO
ALTER TABLE [dbo].[TaskAssignments] CHECK CONSTRAINT [FK_TaskAssignments_Tasks]
GO
/****** Object:  StoredProcedure [dbo].[proc_Employees_Select]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Employees_Select]
	@SearchName nvarchar(255) = N'',
	@Page int = 1,
	@PageSize int = 20,
	@RowCount int output,
	@PageCount int output
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *, ROW_NUMBER() over(order by EmployeeName) as RowNumber
	INTO #TempEmployee
	FROM Employees

	-- @RowCount : Tham số đầu ra cho biết tổng số dòng dữ liệu tìm được
	SELECT @RowCount = COUNT(*)
	FROM Employees
	where (@SearchName = N'') or (EmployeeName like @SearchName);

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
		SELECT * from #TempEmployee
		where (@SearchName = N'') or (EmployeeName like @SearchName)
	)
	SELECT * FROM cte
	-- @PageSize : Số dòng trên mỗi trang (nếu @PageSize = 0 thì hiển thị toàn bộ dữ liệu tìm được)
	where (@PageSize = 0) or
			RowNumber between (@Page - 1) * @PageSize + 1 AND @Page * @PageSize
	ORDER BY RowNumber
END
GO
/****** Object:  StoredProcedure [dbo].[proc_SummaryEndedTaskByDate]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_SummaryEndedTaskByDate]
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
		SELECT t.EndDate, COUNT(*) as SoLuong
		FROM TaskAssignments as t
		WHERE t.EndDate between @From and @To
		GROUP BY t.EndDate
	)
	SELECT t1.Ngay, ISNULL(t2.SoLuong, 0) as SoLuongCVHoanThanh
	FROM cte_Ngay as t1
		LEFT JOIN cte_ThongKe as t2 on t1.Ngay = T2.EndDate
END
GO
/****** Object:  StoredProcedure [dbo].[proc_TaskAssignments_Create]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_TaskAssignments_Create]
	@TaskId int,
	@EmployeeId int,
	@StartDate date,
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT * FROM TaskAssignments WHERE EmployeeId = @EmployeeId AND TaskId = @TaskId)
	BEGIN
		SET @Result = 'Nhan vien da duoc giao viec nay';
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM Tasks WHERE TaskId = @TaskId)
	BEGIN
		SET @Result = 'Ma cong viec nay khong ton tai';
		RETURN;
	END

	IF NOT EXISTS (SELECT * FROM Employees WHERE EmployeeId = @EmployeeId)
	BEGIN
		SET @Result = 'Nhan vien nay khong ton tai';
		RETURN;
	END

	INSERT INTO TaskAssignments(TaskId, EmployeeId, StartDate, EndDate)
	VALUES  (@TaskId, @EmployeeId, @StartDate, NULL)

	UPDATE Tasks
	SET NumOfAssigned = NumOfAssigned + 1
	WHERE TaskId = @TaskId
END
GO
/****** Object:  StoredProcedure [dbo].[proc_TaskAssignments_Update]    Script Date: 19/11/2023 09:36:02 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_TaskAssignments_Update]
	@TaskId int,
	@EmployeeId int,
	@EndDate date,
	@Result nvarchar(255) output
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE TaskAssignments
		SET EndDate = @EndDate
		WHERE EmployeeId = @EmployeeId
		AND TaskId = @TaskId
	IF(@@ROWCOUNT < 1)
	BEGIN
		SET @Result = 'EmployeeId va TaskId khong trung khop trong he thong';
		RETURN;
	END
		
	UPDATE Tasks
		SET NumOfFinished = NumOfFinished + 1
		WHERE TaskId = @TaskId 
		AND @EndDate IS NOT NULL
END
GO
