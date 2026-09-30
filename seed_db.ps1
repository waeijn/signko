# seed_db.ps1
# Runs the seed script inside the running backend container

Write-Host "Seeding default user into the database..." -ForegroundColor Cyan
docker compose exec backend python app/scripts/seed_user.py

Write-Host "Seeding complete." -ForegroundColor Green
