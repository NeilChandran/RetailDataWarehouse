-- Sample data for StockFlowDB

INSERT INTO users (name, email) VALUES 
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com');

INSERT INTO stocks (ticker, name, price) VALUES 
('AAPL', 'Apple Inc.', 175.00),
('GOOGL', 'Alphabet Inc.', 2800.00),
('MSFT', 'Microsoft Corp.', 315.00);

INSERT INTO portfolio (user_id, stock_id, quantity, purchase_price) VALUES 
(1, 1, 10, 170.00),
(1, 3, 5, 300.00),
(2, 2, 3, 2700.00);

INSERT INTO transactions (user_id, stock_id, transaction_type, quantity, transaction_price, transaction_date) VALUES 
(1, 1, 'BUY', 10, 170.00, '2025-06-01'),
(1, 3, 'BUY', 5, 300.00, '2025-06-10'),
(2, 2, 'BUY', 3, 2700.00, '2025-06-15');
