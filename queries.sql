-- Portfolio Analysis Queries

-- Total value per user
SELECT u.name, SUM(p.quantity * s.price) AS total_value
FROM portfolio p
JOIN users u ON p.user_id = u.id
JOIN stocks s ON p.stock_id = s.id
GROUP BY u.name;

-- Gain/loss per holding
SELECT u.name, s.ticker, p.quantity, p.purchase_price, s.price,
       (s.price - p.purchase_price) * p.quantity AS gain_loss
FROM portfolio p
JOIN users u ON p.user_id = u.id
JOIN stocks s ON p.stock_id = s.id;

-- User transaction history
SELECT u.name, s.ticker, t.transaction_type, t.quantity, t.transaction_price, t.transaction_date
FROM transactions t
JOIN users u ON t.user_id = u.id
JOIN stocks s ON t.stock_id = s.id
ORDER BY t.transaction_date;
