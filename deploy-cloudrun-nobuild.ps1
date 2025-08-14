# DÉPLOIEMENT CLOUD RUN VIA CLOUD BUILD (Sans Docker Local)
param(
    [string]$ProjectId = "autoscale-ia-master",
    [string]$Region = "us-central1",
    [string]$ServiceName = "llm-orchestrator"
)

Write-Host "🚀 DÉPLOIEMENT CLOUD RUN (Cloud Build)" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Vérifier que gcloud est configuré
Write-Host "`n[1/5] Vérification de la configuration gcloud..." -ForegroundColor Yellow
$currentProject = gcloud config get-value project 2>$null
if ($currentProject -ne $ProjectId) {
    Write-Host "Configuration du projet: $ProjectId" -ForegroundColor White
    gcloud config set project $ProjectId
}

# Activer les APIs nécessaires
Write-Host "`n[2/5] Activation des APIs Cloud..." -ForegroundColor Yellow
gcloud services enable cloudbuild.googleapis.com run.googleapis.com containerregistry.googleapis.com --quiet

# Créer un fichier .gcloudignore pour optimiser l'upload
Write-Host "`n[3/5] Création du fichier .gcloudignore..." -ForegroundColor Yellow
@"
# Ignore files for Cloud Build
*.pyc
__pycache__/
.git/
.gitignore
*.md
*.ps1
*.bat
.env
.env.*
*.log
*.db
# Include only necessary files
!app_simple.py
!requirements-minimal.txt
!Dockerfile.simple
"@ | Out-File -FilePath ".gcloudignore" -Encoding UTF8

# Déployer directement avec Cloud Build
Write-Host "`n[4/5] Déploiement avec Cloud Build..." -ForegroundColor Yellow
Write-Host "Ceci va construire l'image dans le cloud et déployer directement" -ForegroundColor White

$deployCommand = @"
gcloud run deploy $ServiceName `
    --source . `
    --platform managed `
    --region $Region `
    --allow-unauthenticated `
    --memory 512Mi `
    --cpu 1 `
    --max-instances 3 `
    --min-instances 0 `
    --port 8000 `
    --set-env-vars "DATABASE_URL=sqlite:///app/data/llm_orchestrator.db,API_KEY=demo-key-12345" `
    --dockerfile Dockerfile.simple `
    --quiet
"@

Invoke-Expression $deployCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Déploiement échoué" -ForegroundColor Red
    Write-Host "Vérifiez que vous êtes authentifié: gcloud auth login" -ForegroundColor Yellow
    exit 1
}

# Obtenir l'URL du service
Write-Host "`n[5/5] Récupération de l'URL du service..." -ForegroundColor Yellow
$ServiceUrl = gcloud run services describe $ServiceName --region $Region --format "value(status.url)"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " ✅ DÉPLOIEMENT RÉUSSI!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "URL: $ServiceUrl" -ForegroundColor Cyan
Write-Host "Health: ${ServiceUrl}/health" -ForegroundColor White
Write-Host "Docs: ${ServiceUrl}/docs" -ForegroundColor White
Write-Host "`nCoût estimé: `$5-10/mois" -ForegroundColor Yellow

# Test
Write-Host "`nTest du service..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "${ServiceUrl}/health" -Method Get
    Write-Host "✅ Service opérationnel:" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "⚠️ Le service peut prendre quelques secondes pour démarrer" -ForegroundColor Yellow
    Write-Host "Testez manuellement: ${ServiceUrl}/health" -ForegroundColor White
}