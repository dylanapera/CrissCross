# Azure Deployment Script for CrissCross
# This script will deploy your Tic-Tac-Toe game to Azure App Service

Write-Host "🎮 CrissCross Azure Deployment Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    az --version | Out-Null
    Write-Host "✅ Azure CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found. Please install it from: https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}

# Configuration
Write-Host ""
Write-Host "📝 Configuration" -ForegroundColor Yellow
$RESOURCE_GROUP = Read-Host "Enter Resource Group name (default: rg-crisscross)"
if ([string]::IsNullOrWhiteSpace($RESOURCE_GROUP)) {
    $RESOURCE_GROUP = "rg-crisscross"
}

$LOCATION = Read-Host "Enter Azure region (default: eastus)"
if ([string]::IsNullOrWhiteSpace($LOCATION)) {
    $LOCATION = "eastus"
}

$APP_NAME = Read-Host "Enter App name (must be globally unique, default: crisscross-$(Get-Random -Maximum 9999))"
if ([string]::IsNullOrWhiteSpace($APP_NAME)) {
    $APP_NAME = "crisscross-$(Get-Random -Maximum 9999)"
}

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "  Location: $LOCATION" -ForegroundColor White
Write-Host "  App Name: $APP_NAME" -ForegroundColor White
Write-Host "  URL: https://$APP_NAME.azurewebsites.net" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Proceed with deployment? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

# Login to Azure
Write-Host ""
Write-Host "🔐 Logging in to Azure..." -ForegroundColor Yellow
az login

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Azure login failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Logged in successfully" -ForegroundColor Green

# Create Resource Group
Write-Host ""
Write-Host "📦 Creating Resource Group..." -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location $LOCATION

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create resource group" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Resource Group created" -ForegroundColor Green

# Create App Service Plan
Write-Host ""
Write-Host "🏗️  Creating App Service Plan..." -ForegroundColor Yellow
az appservice plan create `
    --name "plan-crisscross" `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --is-linux `
    --sku B1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create App Service Plan" -ForegroundColor Red
    exit 1
}

Write-Host "✅ App Service Plan created" -ForegroundColor Green

# Create Web App
Write-Host ""
Write-Host "🌐 Creating Web App..." -ForegroundColor Yellow
az webapp create `
    --resource-group $RESOURCE_GROUP `
    --plan "plan-crisscross" `
    --name $APP_NAME `
    --runtime "PYTHON:3.11"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create Web App" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Web App created" -ForegroundColor Green

# Configure startup command
Write-Host ""
Write-Host "⚙️  Configuring startup command..." -ForegroundColor Yellow
az webapp config set `
    --resource-group $RESOURCE_GROUP `
    --name $APP_NAME `
    --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 app:app"

Write-Host "✅ Startup command configured" -ForegroundColor Green

# Enable HTTPS only
Write-Host ""
Write-Host "🔒 Enabling HTTPS only..." -ForegroundColor Yellow
az webapp update `
    --resource-group $RESOURCE_GROUP `
    --name $APP_NAME `
    --https-only true

Write-Host "✅ HTTPS enforced" -ForegroundColor Green

# Deploy application
Write-Host ""
Write-Host "📤 Deploying application..." -ForegroundColor Yellow
Write-Host "   Creating deployment package..." -ForegroundColor Gray

# Create zip file
if (Test-Path "deploy.zip") {
    Remove-Item "deploy.zip" -Force
}

Compress-Archive -Path @(
    "app.py",
    "game_logic.py",
    "requirements.txt",
    ".deployment",
    "templates",
    "static"
) -DestinationPath "deploy.zip" -Force

Write-Host "   Uploading to Azure..." -ForegroundColor Gray

az webapp deployment source config-zip `
    --resource-group $RESOURCE_GROUP `
    --name $APP_NAME `
    --src "deploy.zip"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Application deployed" -ForegroundColor Green

# Clean up
Remove-Item "deploy.zip" -Force

# Enable logging
Write-Host ""
Write-Host "📊 Enabling application logging..." -ForegroundColor Yellow
az webapp log config `
    --resource-group $RESOURCE_GROUP `
    --name $APP_NAME `
    --application-logging filesystem `
    --level information

Write-Host "✅ Logging enabled" -ForegroundColor Green

# Get URL
$appUrl = "https://$APP_NAME.azurewebsites.net"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Your app is available at:" -ForegroundColor Cyan
Write-Host "   $appUrl" -ForegroundColor White
Write-Host ""
Write-Host "📊 Azure Portal:" -ForegroundColor Cyan
Write-Host "   https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP" -ForegroundColor White
Write-Host ""
Write-Host "💡 Useful commands:" -ForegroundColor Yellow
Write-Host "   View logs:    az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME" -ForegroundColor Gray
Write-Host "   Open in browser: az webapp browse --resource-group $RESOURCE_GROUP --name $APP_NAME" -ForegroundColor Gray
Write-Host "   SSH to app:    az webapp ssh --resource-group $RESOURCE_GROUP --name $APP_NAME" -ForegroundColor Gray
Write-Host ""

# Ask if user wants to open in browser
$openBrowser = Read-Host "Open app in browser? (y/n)"
if ($openBrowser -eq 'y') {
    Start-Process $appUrl
}

Write-Host ""
Write-Host "Note: It may take 1-2 minutes for the app to fully start." -ForegroundColor Yellow
Write-Host "✨ Happy gaming! 🎮" -ForegroundColor Green
