@echo off
echo ===============================================
echo    LLM DevOps Orchestrator - Lanceur Rapide
echo ===============================================
echo.
echo Que voulez-vous faire?
echo.
echo 1. Ouvrir l'interface web (frontend)
echo 2. Lancer le serveur local
echo 3. Deployer sur Cloud Run
echo 4. Voir la documentation
echo 5. Tester l'API en production
echo 6. Quitter
echo.
set /p choice="Votre choix (1-6): "

if "%choice%"=="1" (
    echo.
    echo Ouverture de l'interface web...
    start frontend.html
    echo Interface ouverte dans votre navigateur!
    pause
    goto :eof
)

if "%choice%"=="2" (
    echo.
    echo Lancement du serveur local...
    echo Installation des dependances...
    pip install -r requirements-minimal.txt
    echo.
    echo Demarrage du serveur sur http://localhost:8000
    python -m uvicorn app_simple:app --reload --port 8000
    pause
    goto :eof
)

if "%choice%"=="3" (
    echo.
    echo Deploiement sur Cloud Run...
    powershell -ExecutionPolicy Bypass -File deploy-cloudrun-nobuild.ps1
    pause
    goto :eof
)

if "%choice%"=="4" (
    echo.
    echo Ouverture de la documentation...
    start GUIDE-UTILISATION.md
    pause
    goto :eof
)

if "%choice%"=="5" (
    echo.
    echo Test de l'API en production...
    echo.
    curl https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/health
    echo.
    echo.
    pause
    goto :eof
)

if "%choice%"=="6" (
    echo.
    echo Au revoir!
    exit /b
)

echo.
echo Choix invalide. Veuillez choisir entre 1 et 6.
pause