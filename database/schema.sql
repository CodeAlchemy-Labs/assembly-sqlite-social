-- Professional Social Network Database Schema
-- Applying Data Engineering Principles

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000; -- 64MB cache
PRAGMA temp_store = MEMORY;

-- Users table with proper constraints and indexing
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash CHAR(64) NOT NULL, -- SHA-256
    full_name VARCHAR(100) NOT NULL,
    bio TEXT,
    profile_picture_url VARCHAR(500),
    date_of_birth DATE,
    location VARCHAR(100),
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    
    -- Constraints
    CONSTRAINT chk_username_length CHECK (LENGTH(username) >= 3),
    CONSTRAINT chk_email_format CHECK (email LIKE '%_@__%.__%'),
    CONSTRAINT chk_age CHECK (date_of_birth <= DATE('now', '-13 years'))
);

-- Posts table with content management
CREATE TABLE IF NOT EXISTS posts (
    post_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    media_url VARCHAR(500),
    post_type VARCHAR(20) DEFAULT 'text', -- text, image, video, link
    visibility VARCHAR(20) DEFAULT 'public', -- public, friends, private
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_post_type CHECK (post_type IN ('text', 'image', 'video', 'link')),
    CONSTRAINT chk_visibility CHECK (visibility IN ('public', 'friends', 'private'))
);

-- Followers/following relationship
CREATE TABLE IF NOT EXISTS followers (
    follower_id INTEGER NOT NULL,
    following_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (follower_id, following_id),
    FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_no_self_follow CHECK (follower_id != following_id)
);

-- Comments with threading capability
CREATE TABLE IF NOT EXISTS comments (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    parent_comment_id INTEGER, -- For nested comments
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    like_count INTEGER DEFAULT 0,
    
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

-- Likes table (polymorphic - can like posts or comments)
CREATE TABLE IF NOT EXISTS likes (
    like_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    target_type VARCHAR(10) NOT NULL, -- 'post' or 'comment'
    target_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, target_type, target_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_target_type CHECK (target_type IN ('post', 'comment'))
);

-- Messages table for private messaging
CREATE TABLE IF NOT EXISTS messages (
    message_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_id INTEGER NOT NULL,
    receiver_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Indexes for performance optimization
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created ON users(created_at);

CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_created ON posts(created_at);
CREATE INDEX idx_posts_visibility ON posts(visibility);

CREATE INDEX idx_followers_follower ON followers(follower_id);
CREATE INDEX idx_followers_following ON followers(following_id);

CREATE INDEX idx_comments_post ON comments(post_id);
CREATE INDEX idx_comments_user ON comments(user_id);
CREATE INDEX idx_comments_parent ON comments(parent_comment_id);

CREATE INDEX idx_likes_user ON likes(user_id);
CREATE INDEX idx_likes_target ON likes(target_type, target_id);

CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_messages_conversation ON messages(
    LEAST(sender_id, receiver_id),
    GREATEST(sender_id, receiver_id),
    created_at
);

-- Triggers for denormalized counters (for performance)
CREATE TRIGGER update_post_counters_insert
AFTER INSERT ON likes
FOR EACH ROW
WHEN NEW.target_type = 'post'
BEGIN
    UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.target_id;
END;

CREATE TRIGGER update_post_counters_delete
AFTER DELETE ON likes
FOR EACH ROW
WHEN OLD.target_type = 'post'
BEGIN
    UPDATE posts SET like_count = like_count - 1 WHERE post_id = OLD.target_id;
END;

CREATE TRIGGER update_comment_counters_insert
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    UPDATE posts SET comment_count = comment_count + 1 WHERE post_id = NEW.post_id;
END;

-- View for user statistics
CREATE VIEW user_statistics AS
SELECT 
    u.user_id,
    u.username,
    u.full_name,
    COUNT(DISTINCT p.post_id) as total_posts,
    COUNT(DISTINCT f1.following_id) as following_count,
    COUNT(DISTINCT f2.follower_id) as follower_count,
    COALESCE(SUM(p.like_count), 0) as total_likes_received
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN followers f1 ON u.user_id = f1.follower_id
LEFT JOIN followers f2 ON u.user_id = f2.following_id
GROUP BY u.user_id;

-- Insert sample admin user
INSERT OR IGNORE INTO users (username, email, password_hash, full_name, is_verified)
VALUES ('admin', 'admin@social.net', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'System Administrator', 1);