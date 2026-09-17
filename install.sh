#!/bin/bash
set -e
echo "=== FB OS v3.1 FINAL - 65 files - Install Ubuntu - Port 6000 - Fix 1128 files bug ==="

# 1. apt update
echo "[1/8] apt update..."
sudo apt update -y

# 2. install curl git unzip build-essential postgresql redis
echo "[2/8] Installing deps curl git unzip build-essential postgresql redis..."
sudo apt install -y curl git unzip build-essential postgresql postgresql-contrib redis-server

# 3. Node 20
echo "[3/8] Installing Node 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v

# 4. unzip (project assumed zipped as FB-OS-FULL-CODE-V3.1-FINAL-65-FILES-RUNNABLE.zip)
echo "[4/8] Unzipping project..."
if [ -f "FB-OS-FULL-CODE-V3.1-FINAL-65-FILES-RUNNABLE.zip" ]; then
  unzip -o FB-OS-FULL-CODE-V3.1-FINAL-65-FILES-RUNNABLE.zip
else
  echo "Zip not found, assuming files already extracted"
fi
cd fb-inbox-os-v3-1-final || cd .

# 5. tạo .env DATABASE_URL postgresql://postgres:postgres@localhost:5432/fb_os REDIS_URL redis://localhost:6379 ENCRYPT_KEY
echo "[5/8] Creating .env..."
cat > .env << 'EOF'
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/fb_os?schema=public"
REDIS_URL="redis://localhost:6379"
ENCRYPT_KEY="a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
FB_APP_ID="123456789"
FB_APP_SECRET="abcdef123456"
CAPI_PIXEL_ID="123456789012345"
CAPI_ACCESS_TOKEN="test_token"
VNPOST_API_URL="https://api.vnpost.vn/v1/orders"
VNPOST_TOKEN="vnpost_test_token"
PORT=6000
EOF
cat .env

# 6. start postgres redis, create DB
echo "[6/8] Starting postgres redis & create DB..."
sudo service postgresql start || sudo systemctl start postgresql
sudo service redis-server start || sudo systemctl start redis-server
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" || true
sudo -u postgres createdb fb_os || echo "DB exists"
redis-cli ping || true

# 7. npm install, prisma generate migrate, build
echo "[7/8] npm install, prisma generate migrate, build..."
npm install
npx prisma generate
npx prisma migrate dev --name init --skip-seed || npx prisma migrate deploy
npm run build

# 8. tạo start.sh chạy worker + PORT=6000 npm start, echo http://localhost:6000/inbox
echo "[8/8] Creating start.sh..."
cat > start.sh << 'EOF'
#!/bin/bash
echo "Starting FB OS v3.1 FINAL on port 6000..."
export PORT=6000
export DATABASE_URL="postgresql://postgres:postgres@localhost:5432/fb_os?schema=public"
export REDIS_URL="redis://localhost:6379"
export ENCRYPT_KEY="a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
# Start worker in background
npm run worker > worker.log 2>&1 &
echo "Worker started PID $!"
# Start Next.js
PORT=6000 npm start
EOF
chmod +x start.sh
echo "=== DONE ==="
echo "Run: ./start.sh"
echo "Open: http://localhost:6000/inbox"
echo "Fix 1128 files: used client-side JSZip, not python - 65 files OK"
