-- Sample data for demonstration
BEGIN TRANSACTION;

-- Insert sample users
INSERT OR IGNORE INTO users (username, email, password_hash, full_name, bio) VALUES
('johndoe', 'john@example.com', 'hash1', 'John Doe', 'Software engineer and open source enthusiast'),
('janedoe', 'jane@example.com', 'hash2', 'Jane Smith', 'Digital artist and photographer'),
('alexw', 'alex@example.com', 'hash3', 'Alex Wilson', 'Travel blogger and foodie'),
('sarahm', 'sarah@example.com', 'hash4', 'Sarah Miller', 'Fitness coach and nutritionist'),
('mikeb', 'mike@example.com', 'hash5', 'Mike Brown', 'Entrepreneur and investor');

-- Insert sample posts
INSERT OR IGNORE INTO posts (user_id, content, post_type, visibility) VALUES
(1, 'Just deployed my new open source project! Check it out on GitHub.', 'text', 'public'),
(2, 'New digital painting completed! #art #digitalart', 'image', 'public'),
(3, 'Amazing sushi in Tokyo today! #food #travel', 'video', 'public'),
(4, 'Morning workout complete! 5km run and strength training. #fitness', 'text', 'public'),
(5, 'Excited to announce our Series A funding! #startup #business', 'link', 'public');

-- Create follower relationships
INSERT OR IGNORE INTO followers (follower_id, following_id) VALUES
(1, 2), (1, 3), (2, 1), (2, 4), (3, 1), (3, 5), (4, 2), (5, 1), (5, 3);

-- Add comments
INSERT OR IGNORE INTO comments (post_id, user_id, content) VALUES
(1, 2, 'Awesome work John! Looking forward to trying it out.'),
(1, 3, 'Great project! The documentation is very clear.'),
(2, 1, 'Stunning artwork Jane! The colors are amazing.');

-- Add likes
INSERT OR IGNORE INTO likes (user_id, target_type, target_id) VALUES
(1, 'post', 2), (2, 'post', 1), (3, 'post', 1), (4, 'post', 3), (5, 'post', 4);

COMMIT;