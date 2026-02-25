#!/bin/bash
set -e
cd "$(dirname "$0")/.."

# MySQL only (same as upstream .env.example)
cp -n .env.example .env 2>/dev/null || true
sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env
sed -i 's/^DB_HOST=.*/DB_HOST=db/' .env
sed -i 's/^DB_PORT=.*/DB_PORT=3306/' .env
sed -i 's/^DB_DATABASE=.*/DB_DATABASE=tadreeblms/' .env
sed -i 's/^DB_USERNAME=.*/DB_USERNAME=root/' .env
sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD=secret/' .env
sed -i 's/^APP_INSTALLED=.*/APP_INSTALLED=true/' .env

echo "Waiting for MySQL (may take 1–2 min on first start)..."
sleep 45
for i in $(seq 1 60); do
  if php -r "
    try {
      new PDO('mysql:host=db;dbname=tadreeblms', 'root', 'secret');
      exit(0);
    } catch (Exception \$e) {
      exit(1);
    }
  " 2>/dev/null; then
    echo "MySQL is ready."
    break
  fi
  if [ "$i" -eq 60 ]; then
    echo "MySQL did not become ready. Last error:"
    php -r "
      try {
        new PDO('mysql:host=db;dbname=tadreeblms', 'root', 'secret');
      } catch (Exception \$e) {
        echo \$e->getMessage();
      }
    " 2>&1
    echo ""
    echo "Check: PORTS tab should show 3306. If not, the db service may not be running."
    exit 1
  fi
  sleep 2
done

composer config audit.block-insecure false 2>/dev/null || true
composer install --no-interaction --ignore-platform-reqs 2>/dev/null || true
php artisan key:generate --force
php artisan migrate:fresh --force --seed

echo "installed" > installed

echo "Done. Run: php artisan serve"
echo "Open port 8000. Login: admin@seeder.com / secret"
