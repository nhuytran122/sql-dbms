USE [KT_21T1020099]
GO
/****** Object:  Table [dbo].[Answer]    Script Date: 12/12/2023 09:32:32 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Answer](
	[AnswerId] [int] IDENTITY(1,1) NOT NULL,
	[QuestionId] [int] NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[AnsweredTime] [datetime] NOT NULL,
	[AnswerContent] [nvarchar](500) NULL,
 CONSTRAINT [PK_Answer] PRIMARY KEY CLUSTERED 
(
	[AnswerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Question]    Script Date: 12/12/2023 09:32:32 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Question](
	[QuestionId] [int] IDENTITY(1,1) NOT NULL,
	[QuestionTitle] [nvarchar](255) NOT NULL,
	[QuestionContent] [nvarchar](2000) NOT NULL,
	[AskedTime] [datetime] NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[NumOfAnswers] [int] NOT NULL,
 CONSTRAINT [PK_Question] PRIMARY KEY CLUSTERED 
(
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserAccount]    Script Date: 12/12/2023 09:32:32 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserAccount](
	[UserName] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
	[FullName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[NumOfQuestions] [int] NOT NULL,
	[NumOfAnswers] [int] NOT NULL,
 CONSTRAINT [PK_UserAccount] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Answer] ON 

INSERT [dbo].[Answer] ([AnswerId], [QuestionId], [UserName], [AnsweredTime], [AnswerContent]) VALUES (5, 1, N'Thuuyn', CAST(N'2023-01-14T18:02:00.000' AS DateTime), N'abc')
INSERT [dbo].[Answer] ([AnswerId], [QuestionId], [UserName], [AnsweredTime], [AnswerContent]) VALUES (6, 2, N'Nhy03', CAST(N'2023-01-16T20:30:00.000' AS DateTime), N'abcde')
INSERT [dbo].[Answer] ([AnswerId], [QuestionId], [UserName], [AnsweredTime], [AnswerContent]) VALUES (7, 3, N'Huyhoang01', CAST(N'2023-01-20T16:40:00.000' AS DateTime), N'abcdefgh')
INSERT [dbo].[Answer] ([AnswerId], [QuestionId], [UserName], [AnsweredTime], [AnswerContent]) VALUES (8, 4, N'Tee', CAST(N'2023-01-26T18:02:00.000' AS DateTime), N'abcpwoqpdf')
INSERT [dbo].[Answer] ([AnswerId], [QuestionId], [UserName], [AnsweredTime], [AnswerContent]) VALUES (9, 1, N'Nhy03', CAST(N'2023-12-12T09:13:33.643' AS DateTime), N'Ðây là câu tr? l?i c?a tôi.')
SET IDENTITY_INSERT [dbo].[Answer] OFF
GO
SET IDENTITY_INSERT [dbo].[Question] ON 

INSERT [dbo].[Question] ([QuestionId], [QuestionTitle], [QuestionContent], [AskedTime], [UserName], [NumOfAnswers]) VALUES (1, N'Moi Truong', N'Giu gin ve sinh chung', CAST(N'2023-01-14T12:02:00.000' AS DateTime), N'Nhy03', 0)
INSERT [dbo].[Question] ([QuestionId], [QuestionTitle], [QuestionContent], [AskedTime], [UserName], [NumOfAnswers]) VALUES (2, N'Hoc Duong', N'Bai kiem tra', CAST(N'2023-08-24T15:10:00.000' AS DateTime), N'Thuuyn', 0)
INSERT [dbo].[Question] ([QuestionId], [QuestionTitle], [QuestionContent], [AskedTime], [UserName], [NumOfAnswers]) VALUES (3, N'Tin chi', N'Dang ki tin chi', CAST(N'2013-01-01T08:30:00.000' AS DateTime), N'Huyhoang01', 1)
INSERT [dbo].[Question] ([QuestionId], [QuestionTitle], [QuestionContent], [AskedTime], [UserName], [NumOfAnswers]) VALUES (4, N'Lich trinh hoc tap', N'lich nghi tet nguyen dan 2024', CAST(N'2013-12-30T20:00:00.000' AS DateTime), N'Tee', 1)
INSERT [dbo].[Question] ([QuestionId], [QuestionTitle], [QuestionContent], [AskedTime], [UserName], [NumOfAnswers]) VALUES (5, N'Lich thi', N'lich thi ket thuc hoc phan', CAST(N'2013-12-12T06:20:00.000' AS DateTime), N'PU', 0)
INSERT [dbo].[Question] ([QuestionId], [QuestionTitle], [QuestionContent], [AskedTime], [UserName], [NumOfAnswers]) VALUES (6, N'Moi Truong', N'Giu gin ve sinh chung 2', CAST(N'2023-12-12T09:09:34.900' AS DateTime), N'Nhy03', 0)
SET IDENTITY_INSERT [dbo].[Question] OFF
GO
INSERT [dbo].[UserAccount] ([UserName], [Password], [FullName], [Email], [NumOfQuestions], [NumOfAnswers]) VALUES (N'Huyhoang01', N'3112', N'Hoang Xuan Gia Huy', N'Huyhoang3112@gmail.com', 0, 0)
INSERT [dbo].[UserAccount] ([UserName], [Password], [FullName], [Email], [NumOfQuestions], [NumOfAnswers]) VALUES (N'Nhy03', N'12345', N'Tran Nhu Y', N'Trannhuy03@gmail.com', 1, 2)
INSERT [dbo].[UserAccount] ([UserName], [Password], [FullName], [Email], [NumOfQuestions], [NumOfAnswers]) VALUES (N'PU', N'250511', N'Duong Thi Uyen Phuong', N'DuongThiUyenPhuong11@gmail.com', 0, 1)
INSERT [dbo].[UserAccount] ([UserName], [Password], [FullName], [Email], [NumOfQuestions], [NumOfAnswers]) VALUES (N'Tee', N'240603', N'Le Phuong Thao', N'LePhuongThao2463@gmail.com', 0, 1)
INSERT [dbo].[UserAccount] ([UserName], [Password], [FullName], [Email], [NumOfQuestions], [NumOfAnswers]) VALUES (N'Thuuyn', N'29102003', N'Duong Thu Uyen', N'DuongThuUyen291003@gmail.com', 1, 1)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UK_UserAccount]    Script Date: 12/12/2023 09:32:32 SA ******/
ALTER TABLE [dbo].[UserAccount] ADD  CONSTRAINT [UK_UserAccount] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Answer] ADD  CONSTRAINT [DF_Answer_AnsweredTime]  DEFAULT (getdate()) FOR [AnsweredTime]
GO
ALTER TABLE [dbo].[Question] ADD  CONSTRAINT [DF_Question_AskedTime]  DEFAULT (getdate()) FOR [AskedTime]
GO
ALTER TABLE [dbo].[Question] ADD  CONSTRAINT [DF_Question_NumOfAnswers]  DEFAULT ((0)) FOR [NumOfAnswers]
GO
ALTER TABLE [dbo].[UserAccount] ADD  CONSTRAINT [DF_UserAccount_NumOfQuestions]  DEFAULT ((0)) FOR [NumOfQuestions]
GO
ALTER TABLE [dbo].[UserAccount] ADD  CONSTRAINT [DF_UserAccount_NumOfAnswers]  DEFAULT ((0)) FOR [NumOfAnswers]
GO
ALTER TABLE [dbo].[Answer]  WITH CHECK ADD  CONSTRAINT [FK_Answer_Question] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Question] ([QuestionId])
GO
ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [FK_Answer_Question]
GO
ALTER TABLE [dbo].[Answer]  WITH CHECK ADD  CONSTRAINT [FK_Answer_UserAccount] FOREIGN KEY([UserName])
REFERENCES [dbo].[UserAccount] ([UserName])
GO
ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [FK_Answer_UserAccount]
GO
ALTER TABLE [dbo].[Question]  WITH CHECK ADD  CONSTRAINT [FK_Question_UserAccount] FOREIGN KEY([UserName])
REFERENCES [dbo].[UserAccount] ([UserName])
GO
ALTER TABLE [dbo].[Question] CHECK CONSTRAINT [FK_Question_UserAccount]
GO
