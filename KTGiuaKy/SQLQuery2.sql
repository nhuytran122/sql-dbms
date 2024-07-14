--Tạo bảng.
Create Table UserAccount
(
	UserName nvarchar(50) not null primary key,
	PassWord nvarchar(50) not null,
	FullName nvarchar(100) not null,
	Email nvarchar(50) not null,
	NumOfQuestions int not null default(0),
	NumOfAnswers int not null default(0),
)
Create Table Question
( 
    QuestionId int not null identity(1,1) primary key,
	QuestionTitle nvarchar(255) not null,
	QuestionContent nvarchar(2000) not null,
	AskedTime datetime not null default(getdate()),
	UserName nvarchar(50) not null,
	NumOfAnswers int not null,
)
Create Table Answers
(
  	AnswerId int not null identity(1,1) primary key,
	QuestionId int not null,
	UserName nvarchar(50) not null,
	AnsweredTime datetime not null default(getdate()),
	AnsweredContent nvarchar(500),  
)


--Nhập dữ liệu: 
-- bảng UserAccount
INSERT INTO UserAccount(UserName,PassWord,FullName,Email,NumOfQuestions,NumOfAnswers)
VALUES(N'Nhy03','12345','Tran Nhu Y','Trannhuy03@gmail.com',0,1),
      (N'Thuuyn','29102003','Duong Thu Uyen','DuongThuUyen291003@gmail.com',1,1),
	  (N'Huyhoang01','3112','Hoang Xuan Gia Huy','Huyhoang3112@gmail.com',0,0),
	  (N'Tee','240603','Le Phuong Thao','LePhuongThao2463@gmail.com',0,1),
	  (N'PU','250511','Duong Thi Uyen Phuong','DuongThiUyenPhuong11@gmail.com',0,1)

--bảng Question
INSERT INTO Question(QuestionTitle, QuestionContent, AskedTime, UserName, NumOfAnswers)
VALUES
    ('Moi Truong', 'Giu gin ve sinh chung', '2023-01-14 12:02:00', N'Nhy03', 0),
    ('Hoc Duong', 'Bai kiem tra', '2023-08-24 15:10:00', N'Thuuyn', 0),
    ('Tin chi', 'Dang ki tin chi', '2013-01-01 08:30:00', N'Huyhoang01', 1),
    ('Lich trinh hoc tap', 'lich nghi tet nguyen dan 2024', '2013-12-30 20:00:00', N'Tee', 1),
    ('Lich thi', 'lich thi ket thuc hoc phan', '2013-12-12 06:20:00', N'PU', 0);


--bảng Answer
INSERT INTO Answer(QuestionId, UserName, AnsweredTime, AnswerContent)
VALUES  (1, N'Thuuyn','2023-01-14 18:02:00','abc'),
		(2, N'Nhy03','2023-01-16 20:30:00','abcde'),
		(3, N'Huyhoang01','2023-01-20 16:40:00','abcdefgh'),
		(4, N'Tee','2023-01-26 18:02:00','abcpwoqpdf')