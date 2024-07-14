BÀI 7: GIAO TÁC VÀ XỬ LÝ TƯƠNG TRANH TRONG SQL SERVER

Nội dung:
- Giao tác (transaction) là gì? Cách sử dụng giao tác trong SQL
- Xử lý tương tranh (Concurrency Problem) trong SQL Server.

7.1. Giao tác trong SQL Server
    
Giao tác (transaction) là gì?

Tập hợp các câu lệnh (T-SQL) được thực thi như là một câu lệnh đơn.
Chuỗi các phép xử lý cần phải thực hiện một cách đồng nhất: hoặc là tất cả các câu lệnh
phải được thực thi, hoặc không câu lệnh nào được thực thi.

Ví dụ: Cần thực hiện chuyển số tiền là N từ tài khoản A sang tài khoản B

    A + B = X

    Lệnh 1: Đọc xem số tiền của A là bao nhiêu
    Lệnh 2: Đọc xem số tiền của B là bao nhiêu
    Lệnh 3: Giảm số tiền của A đi (A = A - N)
    Lệnh 4: Tăng số tiền của B (B = B + N)

    A + B = X

Giao tác có tính chất ACID
- Tính nguyên tử (A):
- Tính nhất quán (C):   
- Tính cô lập (I):
- Tính bền vững (D):

Một câu lệnh SQL đơn lẻ được xem là một giao dịch.

Một giao dịch thường qua các bước:

- Bước 1: Bắt đầu giao dịch

        BEGIN TRANSACTION 

- Bước 2: Các hoạt động xử lý bên trong giao dịch

        Các lệnh T-SQL để tiến hành xử lý dữ liệu

- Bước 3: Kết thúc giao dịch
    + Nếu giao dịch thành công, ghi nhận ủy thác giao dịch:

        COMMIT TRANSACTION

    + Nếu giao dịch không thành công, hủy bỏ giao dịch

        ROLLBACK TRANSACTION
        

7.2 Xử lý tương tranh trong SQL Server (Concurrency)

* Tương tranh là gì?

Là tình huống xảy ra khi nhiều giao dịch cùng đồng thời truy cập và xử lý cùng một mục dữ liệu, và có
thể dẫn đến sai lệch về dữ liệu.

* Có 4 vấn đề thường gặp trong xử lý tương tranh:
    
    - Dirty Reads: Đọc dữ liệu chưa được commit (dữ liệu không đúng).
    - Lost Updates: Cập nhật dữ liệu của giao dịch không đúng
    - Non-Repeatable Reads: Trong giao dịch đọc dữ liệu 2 lần trở lên
    - Phantom Reads: Đọc dữ liệu trong khi lại có giao dịch đang insert dữ liệu

* Để giải quyết các vấn đề xảy ra trong tương tranh, SQL Server cung cấp các kiểu "cô lập" giao dịch

    - READ UNCOMMITTED : Giao dịch có thể đọc được dữ liệu đang bị khóa bởi giao dịch khác.
    - READ COMMITTED: Giao dịch chỉ có thể đọc dữ liệu sau khi dữ liệu đã được mở khóa (đã commit/rollback)
                      (Mặc định)
    - REPEATABLE READ: Khóa dữ liệu đang đọc cho đến khi kết thúc giao dịch.
    - SERIALIZABLE: Là cấp độ cao nhất, khóa toàn bộ dữ liệu cho đến khi kết thúc giao dịch.

 Để thiết lập kiểu "cô lập giao dịch", sử dụng lệnh:

    SET TRANSACTION ISOLATION LEVEL <Kiểu cô lập giao dịch>


* Dirty Read:

Là tình huống khi mà một giao dịch được phép đọc dữ liệu mà chưa được commit
bởi một giao dịch khác(dữ liệu chưa xử lý xong bởi giao dịch khác).

Dirty Read xảy ra khi sử dụng chế độ "cô lập giao dịch" là read uncommitted

Ví dụ: Bảng BankAccount

Transaction 1:
     
    set transaction isolation level read uncommitted;
    
    begin transaction;
    
    update BankAccount 
    set Balance = Balance - 50
    where AccountId = 'A';

    waitfor delay '00:00:05';

    rollback transaction;

Transaction 2:

    set transaction isolation level read uncommitted;

    begin transaction;

    select * from BankAccount where AccountId = 'A';

    commit transaction;

Vậy: để tránh trường hợp "Dirty Read" thì không được sử dụng chế độ cô lập
giao dịch là READ UNCOMMITTED


* Lost Update:

Là tình huống xảy ra khi mà nhiều giao dịch cùng đọc và cập nhật cùng một
mục dữ liệu

Xét ví dụ:
- Transaction 1: Rút 50 đồng từ tài khoản A

set transaction isolation level read committed

begin transaction

    declare @balance int;

    select @balance = Balance 
    from BankAccount where AccountId = 'A';

    waitfor delay '00:00:10'     

    set @balance = @balance - 50;

    update BankAccount 
    set Balance = @balance 
    where AccountId = 'A';

commit transaction

- Transaction 2: Rút 20 đồng từ  tài khoản A

set transaction isolation level read committed

begin transaction

    declare @balance int;

    select @balance = Balance 
    from BankAccount where AccountId = 'A';

    waitfor delay '00:00:05';

    set @balance = @balance - 20;

     update BankAccount 
    set Balance = @balance 
    where AccountId = 'A';

commit transaction

Để xử lý tình huống này, sử dụng chế độ cô lập
giao dịch là REPEATABLE READ

   
* Non-Repeatable Reads:

Là tình huống xảy ra khi mà một giao dịch đọc cùng một dữ liệu 2 lần,
trong khi có một giao dịch khác cập nhật dữ liệu ở giữa khoảng thời gian
đọc của 2 lần đọc dữ liệu.

Ví dụ:
- Transaction 1:

begin transaction

select Balance from BankAccount 
where AccountId = 'A';

waitfor delay '00:00:10'

select Balance from BankAccount 
where AccountId = 'A';

commit transaction

- Transaction 2:

begin transaction

update BankAccount 
set Balance = Balance - 20
where AccountId = 'A';

commit transaction;

Giải quyết: sử dụng REPEATABLE READ


* Phantom Reads:

Là tình huống mà khi một giao dịch đang đọc dữ liệu
trong khi một giao dịch khác bổ sung thêm dữ liệu

Ví dụ:

- Transaction 1:

set transaction isolation level repeatable read

begin transaction

    select * from BankAccount
    where Balance >= 500;

    waitfor delay '00:00:10';

    select * from BankAccount
    where Balance >= 500;

commit transaction

- Transaction 2:

set transaction isolation level repeatable read

begin transaction

insert into BankAccount
values ('C', 900);

commit transaction

Cách giải quyết: sử dụng chế độ cô lập giao 
dịch SERIALIZABLE



        


    












    


