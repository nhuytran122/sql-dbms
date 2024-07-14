insert into Shippers(ShipperId, ShipperName, Phone)
select distinct t.ShipperId, t.ShipperName, t.ShipperPhone
from SampleShopData as t

insert into Suppliers(SupplierId, SupplierName, ContactName, Address, City, PostalCode, Country, Phone)
select distinct t.SupplierID, t.SupplierName, t.SupplierContactName, t.SupplierAddress, t.SupplierCity, t.SupplierPostalCode, t.SupplierCountry, t.SupplierPhone
from SampleShopData as t

insert into Customers
select distinct t.CustomerID, t.CustomerName, t.CustomerContactName, t.CustomerAddress, t.CustomerCity, t.CustomerPostalCode, t.CustomerCountry
from SampleShopData as t

insert into Employees
select distinct t.EmployeeID, t.LastName, t.FirstName, t.BirthDate, t.Photo, t.Notes
from SampleShopData as t

insert into Categories
select distinct t.CategoryID, t.CategoryName, t.Description
from SampleShopData as t

insert into Products
select distinct t.ProductID, t.ProductName, t.SupplierID, t.CategoryID, t.Unit, t.Price
from SampleShopData as t

insert into Orders (OrderID, CustomerID, EmployeeID, OrderDate, ShipperID)
select distinct t.OrderID, t.CustomerID, t.EmployeeID, t.OrderDate, t.ShipperID
from SampleShopData as t

insert into OrderDetails (OrderID, ProductID, Quantity)
select distinct t.OrderID, t.ProductID, t.Quantity
from SampleShopData as t

select * from Shippers

--Sử dụng lệnh UPDATE để cập nhật giá trị cho các trường vừa bổ sung:
-- Cập nhật giá trị của trường Discount theo yêu cầu sau: giảm giá 10% cho những đơn hàng từ tháng 1 
-- đến tháng 3 của năm 2017, giảm giá 15% cho những đơn hàng từ tháng 10 đến tháng 12 của năm 2017, 
-- những đơn hàng còn lại không giảm giá (mức giảm giá là 0).

UPDATE Orders
SET Discount = 
    CASE 
		WHEN OrderDate >= '2017-01-01' and OrderDate <= '2017-03-31' THEN 0.1
		WHEN OrderDate >= '2017-10-01' and OrderDate <= '2017-12-31' THEN 0.1
       -- WHEN YEAR(OrderDate) = 2017 AND MONTH(OrderDate) BETWEEN 1 AND 3 THEN 0.1
       -- WHEN YEAR(OrderDate) = 2017 AND MONTH(OrderDate) BETWEEN 10 AND 12 THEN 0.15
        ELSE 0
    END

-- Căn cứ vào mức giảm giá của mỗi đơn hàng và giá niêm yết (trường Price trong bảng Products) để tính 
-- giá trị của trường SalePrice trong bảng OrderDetails.
UPDATE OrderDetails
SET SalePrice = Price - Price * Discount
from (Products inner join OrderDetails on Products.ProductId = OrderDetails.ProductId)
inner join Orders on Orders.OrderId = OrderDetails.OrderId

-- 1. Hiển thị mã hàng, tên hàng, đơn vị tính, giá và tên nhà cung cấp của các mặt hàng có giá nhỏ hơn
-- hoặc bằng 20 hoặc lớn hơn 40.
select ProductId, ProductName, Unit, Price, SupplierName
from Products inner join Suppliers 
on Products.SupplierId = Suppliers.SupplierId
where Price <= 20 or Price > 40

-- 2. Nhà cung cấp có tên là Tokyo Traders có nhu cầu tặng quà cho những khách hàng đã từng mua hàng 
-- của họ. Hãy giúp họ có được thông tin của những khách hàng này!
select Customers.*
from Suppliers, Products, OrderDetails, Orders, Customers
where Suppliers.SupplierId = Products.SupplierId 
and Products.ProductId = OrderDetails.ProductId
and OrderDetails.OrderId = Orders.OrderId
and Orders.CustomerId = Customers.CustomerId
and SupplierName = 'Tokyo Traders'

-- 3. Hãy cho biết mã hàng, tên hàng, giá và tên loại hàng của những mặt hàng có giá từ 20 đến 40.
select ProductId, ProductName, Price, CategoryName
from Products inner join Categories
on Products.CategoryId = Categories.CategoryId
where Price BETWEEN 20 AND 40

-- 4. Hãy cho biết mã hàng, tên hàng, đơn vị tính và giá của những mặt hàng được cung cấp bởi các nhà 
-- cung cấp ở USA, Germany, France và Italy.
select Products.ProductId, ProductName, Unit, Price
from Products inner join Suppliers 
on Products.SupplierId = Suppliers.SupplierId
where Country IN ('USA', 'Germany', 'France', 'Italy');

-- 5. Hiển thị mã hàng, tên hàng, đơn vị tính và giá của những mặt hàng được cung cấp bởi các nhà cung cấp 
-- có số điện thoại (Phone) thỏa một trong số các điều kiện sau đây:
-- Số điện thoại bắt đầu bởi (100).
select Products.ProductID, ProductName, Unit, Price
from Products inner join Suppliers 
on Products.SupplierID = Suppliers.SupplierID
where Phone LIKE '100%'

-- Số điện thoại bắt đầu bởi (03) và kết thúc bởi 1, 2 hoặc 5.
select Products.ProductID, ProductName, Unit, Price
from Products inner join Suppliers 
on Products.SupplierID = Suppliers.SupplierID
where Phone like '03%1' or Phone like '03%2' or Suppliers.Phone like '03%5'

-- Số điện thoại bắt đầu bởi 0, 1, 2 hoặc 3.
select Products.ProductID, ProductName, Unit, Price
from Products inner join Suppliers 
on Products.SupplierID = Suppliers.SupplierID
where Phone like '0%' or Phone like '1%' or Phone like '2%' or Phone like '3%'

-- Số điện thoại bắt đầu có dạng (xy). Trong đó:
-- ▪ x là số 0, 1, 2 hoặc 3.
--   y là 1 số bất kỳ
-- Ví dụ: (08) 3255477
select Products.ProductID, ProductName, Unit, Price
from Products inner join Suppliers 
on Products.SupplierID = Suppliers.SupplierID
where Phone like '0_' or Phone like '1_' or Phone like '2_' or Phone like '3_'

-- 6. Hiển thị danh sách mã hàng, tên hàng và đơn vị tính của những mặt hàng được bán trong tháng 7 năm 2017.
select Products.ProductId, ProductName, Unit
from (Products inner join OrderDetails on Products.ProductId = OrderDetails.ProductId)
inner join Orders on Orders.OrderId = OrderDetails.OrderId
and MONTH(OrderDate) = 7 and YEAR(OrderDate) = 2017

-- 7. Giả sử các đơn hàng của khách hàng ở Mỹ sẽ giao hàng sau 5 ngày đặt hàng, ở Canada giao hàng sau 7 ngày, 
-- còn khách hàng ở các quốc gia khác thì giao hàng sau 10 ngày. Hãy cho biết mã đơn hàng, ngày đặt hàng, ngày 
-- giao hàng, tên và địa chỉ của khách hàng của các đơn hàng được đặt trong tháng 7 năm 2017.
select OrderId, OrderDate, 
		CASE
		--	DATEADD(dangthoigian, number, thoigian)
			WHEN Country = 'USA' THEN DATEADD(DAY, 5, OrderDate)
			WHEN Country = 'Canada' THEN DATEADD(DAY, 7, OrderDate)
			ELSE DATEADD(DAY, 10, OrderDate)
		END AS 'Ngay giao hang'
	   , CustomerName, Address
from Customers inner join Orders
on Customers.CustomerId = Orders.CustomerId
where YEAR(OrderDate) = 2017 AND MONTH(OrderDate) = 7

-- 8. Thống kê số mặt hàng được cung cấp bởi mỗi nhà cung cấp.
select Suppliers.SupplierId, SupplierName, COUNT(ProductId) as 'So luong mat hang'
from Suppliers inner join Products
on Suppliers.SupplierId = Products.SupplierId
group by Suppliers.SupplierId, SupplierName

-- 9. Thống kê số mặt hàng theo mỗi loại hàng.
select Categories.CategoryId, CategoryName, COUNT(ProductID) as 'So luong mat hang'
from Products inner join Categories
on Products.CategoryId = Categories.CategoryId
group by Categories.CategoryId, CategoryName

-- 10. Hãy cho biết tổng số lượng hàng đã bán và doanh thu của mỗi mặt hàng trong năm 2017 (Số liệu thống kê phải hiển 
-- thị được cả những mặt hàng không bán được trong năm 2017)
-- Lưu ý: Doanh thu của mỗi mặt hàng trong đơn hàng được tính theo công thức:
--							Quantiy * SalePrice
select Products.ProductId, ProductName, SUM(Quantity * SalePrice) AS DoanhThu
from OrderDetails inner join Products
on Products.ProductId = OrderDetails.ProductId
GROUP BY Products.ProductId, ProductName
UNION
select ProductId, ProductName, TONGTIEN =0
from Products
where ProductId NOT IN (select distinct ProductId
						from OrderDetails)

-- 11. Giả sử, mức phí vận chuyển mà công ty phải chi trả cho các shipper trên mỗi đơn hàng được qui định như sau:
-- • Các đơn hàng của khách hàng tại USA và Canada: mức phí vận chuyển là 3% trị giá của đơn hàng.
-- • Các đơn hàng của khách hàng tại Argentina, Brazil, Mexico và Venezuela: mức phí vận chuyển là 5% trị giá của đơn hàng.
-- • Các đơn hàng của khách hàng ở các quốc gia khác: mức phí vận chuyển là 7% trị giá của đơn hàng.
-- Hãy cho biết mã đơn hàng, ngày đặt hàng, thông tin khách hàng, thông tin shipper, trị giá của đơn hàng và mức 
-- phí vận chuyển của mỗi đơn hàng.
select OrderDetails.OrderId, OrderDate, Customers.CustomerId, CustomerName, Country, Shippers.*, SUM(Quantity * SalePrice) as 'Gia tri don hang', 
		SUM(Quantity * SalePrice) * 
		CASE
			WHEN Country IN('Argentina', 'Brazil', 'Mexico', 'Venezuela') THEN 0.03
			ELSE 0.07
		END AS 'Phi van chuyen'
from OrderDetails, Orders, Customers, Shippers
where OrderDetails.OrderId = Orders.OrderId 
and Orders.CustomerId = Customers.CustomerId
and Shippers.ShipperId = Orders.ShipperId
GROUP BY OrderDetails.OrderId, OrderDate, Customers.CustomerId, CustomerName, Country, Shippers.ShipperId, ShipperName, Phone

-- 12. Dựa vào cách tính như đã qui định ở trên, hãy cho biết tổng số tiền mà công ty phải chi trả cho mỗi shipper 
-- là bao nhiêu.
select Shippers.ShipperId, ShipperName, SUM(
		CASE
			WHEN Country IN('Argentina', 'Brazil', 'Mexico', 'Venezuela') THEN ((Quantity * SalePrice)*0.03)
			ELSE ((Quantity * SalePrice)*0.07)
		END) as 'So tien chi tra'
from OrderDetails, Orders, Customers, Shippers
where OrderDetails.OrderId = Orders.OrderId 
and Orders.CustomerId = Customers.CustomerId
and Shippers.ShipperId = Orders.ShipperId
group by Shippers.ShipperId, ShipperName

-- 13. Hãy thống kê số lượng đơn hàng mà mỗi nhân viên đã bán được trong năm 2018 (Số liệu thống kê phải hiển thị 
-- cả những nhân viên không bán được hàng trong năm 2018)
select Employees.EmployeeId, LastName, FirstName, COUNT(OrderId) as SoLuongDonHang
from Employees left join Orders
on Employees.EmployeeId = Orders.EmployeeId
where YEAR(OrderDate) = 2018
group by Employees.EmployeeId, LastName, FirstName
UNION
select EmployeeId, LastName, FirstName, SoLuongDonHang = 0
from Employees
where EmployeeId NOT IN (select distinct EmployeeId
						from Orders)

-- 14. Hãy cho biết mã hàng, tên hàng và tổng doanh thu của những mặt hàng có doanh thu cao hơn mức doanh thu trung 
-- bình của các mặt hàng trong năm 2018.
select Products.ProductId, ProductName, SUM(Quantity * SalePrice) AS DoanhThu
from (Products inner join OrderDetails ON Products.ProductID = OrderDetails.ProductID)
     inner join Orders ON OrderDetails.OrderID = Orders.OrderID
where YEAR(OrderDate) = 2018
group by Products.ProductId, ProductName
having SUM(Quantity * SalePrice) > (SELECT AVG(DoanhthuS) as DoanhThuTrungBinh
									FROM (
										  SELECT ProductId, SUM(Quantity * SalePrice) as DoanhthuS
										  FROM OrderDetails
										  GROUP BY ProductId
										  ) AS RevenueSummary
									)

-- 15. Hãy cho biết trong năm 2018, những tháng nào có doanh thu bán hàng cao nhất cao nhất.
select MONTH(OrderDate) as 'Thang', SUM(Quantity * SalePrice) AS 'Doanh Thu'
from (Products inner join OrderDetails on Products.ProductId = OrderDetails.ProductId)
inner join Orders on Orders.OrderId = OrderDetails.OrderId
and YEAR(OrderDate) = 2018
group by MONTH(OrderDate)
having SUM(Quantity * SalePrice) = (select top 1 SUM(Quantity * SalePrice)
									from (Products inner join OrderDetails on Products.ProductId = OrderDetails.ProductId)
									inner join Orders on Orders.OrderId = OrderDetails.OrderId
									and YEAR(OrderDate) = 2018
									group by MONTH(OrderDate))

--!!! 16. Với mỗi loại hàng, hãy cho biết doanh thu của những mặt hàng có tổng doanh thu cao nhất trong số các mặt hàng 
-- cùng loại.



-- 17. Công ty cần thưởng cho những nhân viên có doanh thu bán hàng tốt nhất trong các tháng của năm 2018. Hãy giúp 
-- công ty có được thông tin của những nhân viên này
select Employees.EmployeeId, LastName, FirstName, SUM(Quantity * SalePrice) as 'Doanh Thu'
from (Employees inner join Orders on Employees.EmployeeId = Orders.EmployeeId) 
inner join OrderDetails on OrderDetails.OrderId = Orders.OrderId
group by Employees.EmployeeId, LastName, FirstName
having SUM(Quantity * SalePrice) = (select top 1 SUM(Quantity * SalePrice)
									from (Employees inner join Orders on Employees.EmployeeId = Orders.EmployeeId) 
									inner join OrderDetails on OrderDetails.OrderId = Orders.OrderId
									group by Employees.EmployeeId, LastName, FirstName)

-- 18. Hãy lập bảng thống kê doanh thu của mỗi mặt hàng trong năm 2017, kết quả truy vấn được hiển thị theo mẫu sau đây:

-- 19. Khách hàng thanh toán tiền các đơn hàng cho công ty có thể thanh toán bằng hình thức trả góp (tức là trả thành 
-- nhiều lần). Mỗi lần khách hàng thanh toán, dữ liệu được lưu trữ trong bảng Invoices. Bảng này có cấu trúc và quan 
-- hệ với bảng Orders như hình bên dưới:
-- Với mỗi đơn hàng, hãy cho biết: mã đơn hàng, ngày đặt hàng, thông tin khách hàng, tổng trị giá đơn hàng, tổng số 
-- tiền đã thanh toán và tổng số tiền còn nợ.
select Orders.OrderId, OrderDate, Customers.*, PaymentAmount, ((Quantity * SalePrice) - PaymentAmount) as 'So tien con no'
from ((Orders inner join Invoices on Orders.OrderId = Invoices.OrderID)
inner join OrderDetails on OrderDetails.OrderId = Orders.OrderId)
inner join Customers on Customers.CustomerId = Orders.CustomerId

-- 20. Hãy cho biết tổng doanh thu bán hàng của mỗi tháng trong năm 2018 và mức biến động (tăng/giảm) của doanh thu 
-- so với tháng trước đó (Lưu ý: Tháng 1 không cần thể hiện mức biến động doanh thu)
select MONTH(OrderDate) as 'Thang', SUM(Quantity * SalePrice) AS 'Doanh Thu'
from (Products inner join OrderDetails on Products.ProductId = OrderDetails.ProductId)
inner join Orders on Orders.OrderId = OrderDetails.OrderId
and YEAR(OrderDate) = 2018
group by MONTH(OrderDate)