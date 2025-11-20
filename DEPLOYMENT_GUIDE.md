# Azure Deployment Guide for CrissCross Tic-Tac-Toe

This guide covers multiple deployment options for your Flask-based Tic-Tac-Toe game to Azure.

## 🎯 Recommended Option: Azure App Service (Web App)

**Why Azure App Service?**
- ✅ Fully managed platform for Python web apps
- ✅ Built-in support for Flask applications
- ✅ Easy deployment via Git, VS Code, or Azure CLI
- ✅ Auto-scaling and load balancing
- ✅ Built-in SSL certificates
- ✅ Cost-effective for small to medium applications (~$13-54/month)

**Not recommended:** Azure Static Web Apps - designed for static content with serverless APIs, not ideal for Flask apps with server-side sessions.

---

## 📋 Prerequisites

1. **Azure Account**: [Sign up for free](https://azure.microsoft.com/free/) ($200 credit)
2. **Azure CLI**: Install from [here](https://docs.microsoft.com/cli/azure/install-azure-cli)
3. **VS Code** (Optional): With Azure App Service extension

---

## 🚀 Deployment Methods

### Method 1: Azure CLI Deployment (Recommended - Fast & Simple)

#### Step 1: Prepare Your Application

Create a startup command file for Azure:

```bash
# In your project root
```

Create `.deployment` file (already done by this guide below).

#### Step 2: Login to Azure

```powershell
az login
```

#### Step 3: Create Resource Group

```powershell
# Set variables
$RESOURCE_GROUP = "rg-crisscross"
$LOCATION = "eastus"
$APP_NAME = "crisscross-tictactoe-app"  # Must be globally unique

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION
```

#### Step 4: Create App Service Plan

```powershell
# Create Linux App Service Plan (B1 tier - basic, affordable)
az appservice plan create `
  --name "plan-crisscross" `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --is-linux `
  --sku B1
```

**SKU Options:**
- **F1** (Free): Good for testing, limited resources
- **B1** (Basic): ~$13/month, 1.75GB RAM, production-ready
- **S1** (Standard): ~$54/month, auto-scaling, custom domains
- **P1V2** (Premium): ~$95/month, enhanced performance

#### Step 5: Create Web App

```powershell
az webapp create `
  --resource-group $RESOURCE_GROUP `
  --plan "plan-crisscross" `
  --name $APP_NAME `
  --runtime "PYTHON:3.11"
```

#### Step 6: Configure App Settings

```powershell
# Set startup command
az webapp config set `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 app:app"
```

#### Step 7: Deploy Your Code

```powershell
# Deploy from local Git (from your project directory)
cd c:\Users\dylanapera\r\CrissCross

# Compress your app
Compress-Archive -Path .\* -DestinationPath deploy.zip -Force

# Deploy
az webapp deployment source config-zip `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --src deploy.zip
```

#### Step 8: Verify Deployment

```powershell
# Open the app in browser
az webapp browse --resource-group $RESOURCE_GROUP --name $APP_NAME

# View logs
az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME
```

Your app will be available at: `https://<APP_NAME>.azurewebsites.net`

---

### Method 2: Azure Developer CLI (azd) Deployment

This method uses Infrastructure as Code (Bicep) for reproducible deployments.

#### Step 1: Install Azure Developer CLI

```powershell
# Install azd
winget install microsoft.azd
```

#### Step 2: Initialize azd (I'll create the necessary files)

The files will be created in the next steps.

#### Step 3: Run Deployment

```powershell
# Login
azd auth login

# Initialize and deploy
azd up
```

This single command will:
- Create all Azure resources
- Deploy your application
- Configure monitoring
- Provide the URL

---

### Method 3: Docker Container Deployment to Azure Container Apps

**Best for:** Containerized applications, microservices, advanced scaling

#### Step 1: Create Dockerfile (I'll create this)

#### Step 2: Deploy to Azure Container Apps

```powershell
# Set variables
$RESOURCE_GROUP = "rg-crisscross"
$LOCATION = "eastus"
$CONTAINER_APP_NAME = "crisscross-app"
$CONTAINER_ENV = "crisscross-env"

# Create Container Apps environment
az containerapp env create `
  --name $CONTAINER_ENV `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

# Create and deploy container app
az containerapp up `
  --name $CONTAINER_APP_NAME `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --environment $CONTAINER_ENV `
  --source . `
  --target-port 5000 `
  --ingress external
```

---

## 🔧 Required Files for Deployment

### 1. Update `requirements.txt`

```txt
flask==3.0.0
gunicorn==21.2.0
```

Gunicorn is a production-grade WSGI server (Flask's built-in server is not production-ready).

### 2. Add `.deployment` file (for Azure)

This file is created below.

---

## 📊 Comparison of Azure Services

| Feature | App Service | Container Apps | Azure Functions |
|---------|-------------|----------------|-----------------|
| **Best For** | Traditional web apps | Containerized apps | Event-driven, APIs |
| **Complexity** | Low | Medium | Low-Medium |
| **Cost (monthly)** | $13+ | $0-50+ (pay per use) | $0-20+ (consumption) |
| **Scaling** | Vertical/Horizontal | Auto-scale to zero | Auto-scale |
| **Deployment** | Code or Docker | Docker only | Code only |
| **Session State** | ✅ Persistent | ⚠️ Requires Redis | ⚠️ Requires storage |

**Recommendation for CrissCross:** Azure App Service (Web App) - simplest and most cost-effective.

---

## 🔐 Security Best Practices

1. **Enable HTTPS Only**:
```powershell
az webapp update --resource-group $RESOURCE_GROUP --name $APP_NAME --https-only true
```

2. **Add Application Insights** (monitoring):
```powershell
az monitor app-insights component create `
  --app "crisscross-insights" `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP `
  --application-type web
```

3. **Set Environment Variables** (never hardcode secrets):
```powershell
az webapp config appsettings set `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --settings SECRET_KEY="your-secret-key-here"
```

---

## 🐛 Troubleshooting

### View Application Logs
```powershell
# Enable logging
az webapp log config `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --application-logging filesystem `
  --level information

# Stream logs
az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME
```

### Common Issues

1. **App won't start**: Check startup command and Python version
2. **Static files not loading**: Ensure Flask serves static files correctly
3. **502 Bad Gateway**: Check application logs, usually a startup error

### SSH into App Service
```powershell
az webapp ssh --resource-group $RESOURCE_GROUP --name $APP_NAME
```

---

## 💰 Cost Estimation

**Basic Setup (B1 tier):**
- App Service Plan B1: ~$13/month
- Application Insights: ~$0-5/month (based on usage)
- **Total: ~$15-20/month**

**Free Tier Option (F1):**
- App Service Plan F1: $0/month
- Limitations: 60 CPU minutes/day, 1GB RAM, no custom domains
- Good for testing/demos

---

## 🎓 Next Steps After Deployment

1. **Custom Domain**: Add your own domain name
2. **Scaling**: Enable auto-scaling based on traffic
3. **CI/CD**: Set up GitHub Actions for automatic deployments
4. **Monitoring**: Configure alerts in Application Insights
5. **Database**: Add Azure PostgreSQL/MySQL if you add user accounts

---

## 📚 Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Deploy Python to Azure](https://docs.microsoft.com/azure/app-service/quickstart-python)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

---

## 🚀 Quick Start (Copy-Paste Commands)

```powershell
# 1. Login
az login

# 2. Set variables (change APP_NAME to something unique)
$RESOURCE_GROUP = "rg-crisscross"
$LOCATION = "eastus"
$APP_NAME = "crisscross-tictactoe-$(Get-Random -Maximum 9999)"

# 3. Create everything
az group create --name $RESOURCE_GROUP --location $LOCATION

az appservice plan create `
  --name "plan-crisscross" `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --is-linux `
  --sku B1

az webapp create `
  --resource-group $RESOURCE_GROUP `
  --plan "plan-crisscross" `
  --name $APP_NAME `
  --runtime "PYTHON:3.11"

az webapp config set `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 app:app"

# 4. Deploy
Compress-Archive -Path .\* -DestinationPath deploy.zip -Force

az webapp deployment source config-zip `
  --resource-group $RESOURCE_GROUP `
  --name $APP_NAME `
  --src deploy.zip

# 5. Open in browser
az webapp browse --resource-group $RESOURCE_GROUP --name $APP_NAME
```

That's it! Your Tic-Tac-Toe game should now be live on Azure! 🎉
