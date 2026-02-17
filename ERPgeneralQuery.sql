INSERT INTO [Finance].[Account] (AccountName, AccountType)
VALUES
('Cash in Hand', 'Asset'),
('Bank Account - HDFC', 'Asset'),
('Accounts Receivable', 'Asset'),
('Accounts Payable', 'Liability'),
('GST Payable', 'Liability'),
('Sales Revenue', 'Revenue'),
('Service Income', 'Revenue'),
('Office Rent Expense', 'Expense'),
('Electricity Expense', 'Expense'),
('Salary Expense', 'Expense');


INSERT INTO [Finance].[Account] (AccountName, AccountType, CreatedDate)
VALUES
('Capital Account', 'Liability', '2026-01-01'),
('Interest Income', 'Revenue', '2026-02-01');

SELECT * FROM [Finance].[Account];




