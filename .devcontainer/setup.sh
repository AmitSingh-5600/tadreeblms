#!/bin/bash
set -e
cd "$(dirname "$0")/.."

# Copy env and switch to SQLite (no MySQL needed in Codespaces)
cp -n .env.example .env 2>/dev/null || true
sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
sed -i 's|^DB_DATABASE=.*|DB_DATABASE='"$(pwd)/database/database.sqlite"'|' .env
sed -i 's/^APP_INSTALLED=.*/APP_INSTALLED=true/' .env

# Create SQLite database file
touch database/database.sqlite

# Install dependencies and setup app
composer install --no-interaction --ignore-platform-reqs 2>/dev/null || true
php artisan key:generate --force
php artisan migrate --force
php artisan db:seed --force

# Mark app as installed (skip web installer)
echo "installed" > installed

echo "Done. Run: php artisan serve"
echo "Then open the forwarded port 8000 in the browser. Login: admin@seeder.com / secret"
