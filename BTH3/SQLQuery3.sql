DECLARE @InvoiceDetails TypeInvoiceDetails

INSERT INTO @InvoiceDetails (CardTypeId, Amount, Quantity)
VALUES (1, 50000, 5), (2, 100000, 3), (6, 20000, 6)


(SELECT * FROM @InvoiceDetails as inv
					WHERE  (CardTypeId IN (SELECT CardTypeId FROM CardType) 
							AND Amount IN (SELECT Amount FROM CardStore))
							AND Quantity >   (SELECT SUM(CASE WHEN CardStatus = 1 THEN 1 ELSE 0 END) -- 'Số lượng thẻ còn tồn'									
											 FROM (CardStore as cs JOIN CardType as ct ON cs.CardTypeId = ct.CardTypeId) JOIN @InvoiceDetails ON cs.CardTypeId = @InvoiceDetails.CardTypeId
											 WHERE cs.CardTypeId = inv.CardTypeId AND cs.Amount = inv.Amount
											 GROUP BY cs.CardTypeId, CardTypeName, Amount))