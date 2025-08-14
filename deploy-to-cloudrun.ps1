# DÉPLOIEMENT CLOUD RUN - SIMPLE ET DIRECT
param(
    [string]$ProjectId = "autoscale-ia-master",
    [string]$Region = "us-central1",
    [string]$ServiceName = "llm-orchestrator"
)

Write-Host "🚀 DÉPLOIEMENT CLOUD RUN" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

# 1. Variables
$ImageName = "gcr.io/$ProjectId/$ServiceName"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$ImageTag = "${ImageName}:${Timestamp}"

Write-Host "`nConfiguration:" -ForegroundColor Yellow
Write-Host "  Project: $ProjectId" -ForegroundColor White
Write-Host "  Region: $Region" -ForegroundColor White
Write-Host "  Service: $ServiceName" -ForegroundColor White
Write-Host "  Image: $ImageTag" -ForegroundColor White

# 2. Build Docker image
Write-Host "`n[1/4] Building Docker image..." -ForegroundColor Yellow
docker build -t $ImageTag -f Dockerfile.simple .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker image built" -ForegroundColor Green

# 3. Push to Google Container Registry
Write-Host "`n[2/4] Pushing to GCR..." -ForegroundColor Yellow
docker push $ImageTag
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker push failed" -ForegroundColor Red
    Write-Host "Run: gcloud auth configure-docker" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Image pushed to GCR" -ForegroundColor Green

# 4. Deploy to Cloud Run
Write-Host "`n[3/4] Deploying to Cloud Run..." -ForegroundColor Yellow
gcloud run deploy $ServiceName `
    --image $ImageTag `
    --platform managed `
    --region $Region `
    --allow-unauthenticated `
    --memory 512Mi `
    --cpu 1 `
    --max-instances 3 `
    --min-instances 0 `
    --port 8000 `
    --set-env-vars "DATABASE_URL=sqlite:///app/data/llm_orchestrator.db" `
    --set-env-vars "API_KEY=demo-key-12345"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Cloud Run deployment failed" -ForegroundColor Red
    exit 1
}

# 5. Get service URL
Write-Host "`n[4/4] Getting service URL..." -ForegroundColor Yellow
$ServiceUrl = gcloud run services describe $ServiceName --region $Region --format "value(status.url)"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " ✅ DÉPLOIEMENT RÉUSSI!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "URL: $ServiceUrl" -ForegroundColor Cyan
Write-Host "Health: ${ServiceUrl}/health" -ForegroundColor White
Write-Host "Docs: ${ServiceUrl}/docs" -ForegroundColor White
Write-Host "`nCoût estimé: $5-10/mois" -ForegroundColor Yellow

# Test
Write-Host "`nTest du service..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "${ServiceUrl}/health" | ConvertTo-Json