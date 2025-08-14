# 📚 GUIDE D'UTILISATION COMPLET

## 🎯 3 FAÇONS D'UTILISER LE SERVICE

### 1️⃣ **Interface Web (Le Plus Simple)**
Ouvrez simplement `frontend.html` dans votre navigateur:
```bash
# Windows
start frontend.html

# Ou double-cliquez sur le fichier
```

**Fonctionnalités:**
- ✅ Créer des tâches en 1 clic
- ✅ Voir l'état en temps réel
- ✅ Actions rapides pré-configurées
- ✅ Monitoring de latence

### 2️⃣ **API REST (Pour Développeurs)**

**URL de base**: https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app

#### Exemples avec cURL:
```bash
# Health check
curl https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/health

# Créer une tâche (quand l'API sera mise à jour)
curl -X POST "https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/api/v1/tasks?api_key=demo-key-12345" \
  -H "Content-Type: application/json" \
  -d '{"name":"Deploy v2","type":"deploy"}'
```

#### Exemples avec PowerShell:
```powershell
# Health check
Invoke-RestMethod -Uri "https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/health"

# Créer une tâche
$body = @{
    name = "Deploy v2"
    type = "deploy"
    config = @{
        env = "production"
    }
} | ConvertTo-Json

Invoke-RestMethod -Method Post `
    -Uri "https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/api/v1/tasks?api_key=demo-key-12345" `
    -Body $body `
    -ContentType "application/json"
```

### 3️⃣ **SDK Python (Pour Automatisation)**

Créez `client.py`:
```python
import requests
import json

class LLMOrchestratorClient:
    def __init__(self, base_url=None, api_key="demo-key-12345"):
        self.base_url = base_url or "https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app"
        self.api_key = api_key
    
    def health_check(self):
        """Vérifier l'état du service"""
        response = requests.get(f"{self.base_url}/health")
        return response.json()
    
    def create_task(self, name, task_type, config=None):
        """Créer une nouvelle tâche"""
        data = {
            "name": name,
            "type": task_type,
            "config": config or {}
        }
        response = requests.post(
            f"{self.base_url}/api/v1/tasks",
            params={"api_key": self.api_key},
            json=data
        )
        return response.json()
    
    def get_task(self, task_id):
        """Récupérer une tâche"""
        response = requests.get(f"{self.base_url}/api/v1/tasks/{task_id}")
        return response.json()
    
    def list_tasks(self, limit=10):
        """Lister les tâches"""
        response = requests.get(
            f"{self.base_url}/api/v1/tasks",
            params={"limit": limit}
        )
        return response.json()

# Utilisation
if __name__ == "__main__":
    client = LLMOrchestratorClient()
    
    # Vérifier l'état
    print("🔍 Health Check:")
    print(json.dumps(client.health_check(), indent=2))
    
    # Créer une tâche
    print("\n📦 Création d'une tâche:")
    task = client.create_task(
        name="Déploiement Python",
        task_type="deploy",
        config={"version": "3.0"}
    )
    print(json.dumps(task, indent=2))
```

## 🚀 CAS D'USAGE CONCRETS

### 1. Déploiement Automatique
```python
# deploy_auto.py
from client import LLMOrchestratorClient

client = LLMOrchestratorClient()

# Créer une tâche de déploiement
task = client.create_task(
    name=f"Deploy {datetime.now().strftime('%Y%m%d_%H%M')}",
    task_type="deploy",
    config={
        "branch": "main",
        "env": "production",
        "auto_rollback": True
    }
)
print(f"Déploiement lancé: {task['task_id']}")
```

### 2. Monitoring Continu
```python
# monitor.py
import time
from client import LLMOrchestratorClient

client = LLMOrchestratorClient()

while True:
    health = client.health_check()
    if health['status'] != 'healthy':
        # Envoyer alerte
        print(f"⚠️ Service unhealthy: {health}")
    time.sleep(30)
```

### 3. Backup Programmé
```python
# backup_schedule.py
import schedule
from client import LLMOrchestratorClient

client = LLMOrchestratorClient()

def backup():
    task = client.create_task(
        name="Backup quotidien",
        task_type="backup",
        config={"type": "full", "compress": True}
    )
    print(f"Backup lancé: {task}")

# Programmer backup tous les jours à 3h
schedule.every().day.at("03:00").do(backup)

while True:
    schedule.run_pending()
    time.sleep(60)
```

## 📊 INTÉGRATIONS

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy via Orchestrator

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger deployment
        run: |
          curl -X POST "https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/api/v1/tasks?api_key=${{ secrets.API_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{"name":"GitHub Deploy","type":"deploy","config":{"commit":"${{ github.sha }}"}}'
```

### Jenkins
```groovy
pipeline {
    agent any
    stages {
        stage('Deploy') {
            steps {
                script {
                    def response = httpRequest(
                        url: 'https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/api/v1/tasks?api_key=demo-key-12345',
                        httpMode: 'POST',
                        contentType: 'APPLICATION_JSON',
                        requestBody: '{"name":"Jenkins Deploy","type":"deploy"}'
                    )
                    echo "Task created: ${response.content}"
                }
            }
        }
    }
}
```

### Slack Webhook
```python
# slack_integration.py
import requests

def notify_slack(task_result):
    webhook_url = "YOUR_SLACK_WEBHOOK"
    message = {
        "text": f"🚀 Tâche terminée: {task_result['name']}",
        "attachments": [{
            "color": "good" if task_result['status'] == 'completed' else "danger",
            "fields": [
                {"title": "Type", "value": task_result['type'], "short": True},
                {"title": "Status", "value": task_result['status'], "short": True}
            ]
        }]
    }
    requests.post(webhook_url, json=message)
```

## 🎮 COMMANDES RAPIDES

### PowerShell One-Liners
```powershell
# Ouvrir l'interface
Start-Process frontend.html

# Health check rapide
(Invoke-WebRequest -Uri "https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/health").Content | ConvertFrom-Json

# Voir les logs Cloud Run
gcloud run logs read --service llm-devops-orchestrator --region us-central1 --limit 50
```

### Bash Aliases (.bashrc)
```bash
# Ajouter ces alias pour accès rapide
alias orch-health='curl -s https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/health | jq'
alias orch-ui='open frontend.html'
alias orch-logs='gcloud run logs read --service llm-devops-orchestrator --region us-central1'
```

## 🔧 DÉPANNAGE

| Problème | Solution |
|----------|----------|
| API ne répond pas | Vérifier https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/health |
| Erreur 401 | Vérifier l'API key: `demo-key-12345` |
| Interface ne charge pas | Ouvrir la console du navigateur (F12) |
| Latence élevée | Service en cold start, attendre 5 secondes |

## 📈 MÉTRIQUES À SURVEILLER

- **Latence**: Devrait être < 200ms
- **Uptime**: Cible 99.9%
- **Tasks/min**: Capacité max ~50
- **Erreurs**: Devrait être < 1%

## 🎯 PROCHAINES FONCTIONNALITÉS

- [ ] WebSocket pour temps réel
- [ ] Dashboard Grafana
- [ ] Notifications email
- [ ] API v2 avec GraphQL
- [ ] Mobile app

---

**Support**: jsleboeuf3@gmail.com
**Documentation API**: https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/docs
**Status Page**: https://llm-devops-orchestrator-vgs4x4beda-uc.a.run.app/health