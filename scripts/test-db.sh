#!/bin/bash
echo "Testing database container..."
echo "============================="

# Wait for database to be ready
sleep 5

# Check if container is running
if docker compose ps database | grep -q "Up"; then
    echo "✓ Database container is running"
    
    # Check health status
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' social-network-db)
    echo "✓ Health status: $HEALTH"
    
    # Test database connection
    if docker compose exec database sqlite3 /data/social_network.db "SELECT 1;" 2>/dev/null; then
        echo "✓ Database connection successful"
        
        # List tables
        echo "✓ Database tables:"
        docker compose exec database sqlite3 /data/social_network.db ".tables"
        
        # Count users
        COUNT=$(docker compose exec database sqlite3 /data/social_network.db "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")
        echo "✓ Users in database: $COUNT"
    else
        echo "✗ Database connection failed"
    fi
else
    echo "✗ Database container is not running"
    docker compose logs database --tail=20
fi