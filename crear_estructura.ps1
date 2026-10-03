# ===============================
# Script: crear_estructura.ps1
# Descripción: Crea la estructura base limpia y escalable para un proyecto Flutter tipo red social educativa.
# ===============================

# Ruta base del proyecto (ajusta si es necesario)
$basePath = "lib"

# Definir estructura de carpetas
$folders = @(
    "core/errors",
    "core/usecases",
    "core/utils",
    "core/constants",
    "core/theme",

    "data/datasources/remote",
    "data/datasources/local",
    "data/models",
    "data/repositories_impl",

    "domain/entities",
    "domain/repositories",
    "domain/usecases",

    "presentation/pages/auth",
    "presentation/pages/home",
    "presentation/pages/clases",
    "presentation/pages/chat",
    "presentation/pages/profile",
    "presentation/pages/search",
    "presentation/widgets",
    "presentation/providers",
    "presentation/routes",

    "services"
)

# Crear carpetas
Write-Host "📁 Creando estructura de carpetas..."
foreach ($folder in $folders) {
    $fullPath = Join-Path $basePath $folder
    if (-not (Test-Path $fullPath)) {
        New-Item -Path $fullPath -ItemType Directory | Out-Null
        Write-Host "✅ Carpeta creada: $fullPath"
    } else {
        Write-Host "⚠️ Carpeta ya existe: $fullPath"
    }
}

# Archivos base a crear
$files = @(
    "services/firebase_service.dart",
    "services/api_client.dart",
    "services/notification_service.dart",
    "core/constants/app_constants.dart",
    "core/theme/app_theme.dart",
    "presentation/routes/app_routes.dart",
    "presentation/providers/global_provider.dart",
    "data/models/user_model.dart",
    "domain/entities/user_entity.dart",
    "domain/usecases/get_classes_usecase.dart",
    "main.dart"
)

# Crear archivos vacíos con comentarios base
Write-Host "`n📝 Creando archivos base..."
foreach ($file in $files) {
    $fullFilePath = Join-Path $basePath $file
    if (-not (Test-Path $fullFilePath)) {
        New-Item -Path $fullFilePath -ItemType File -Force | Out-Null
        Add-Content -Path $fullFilePath -Value "// Archivo: $file`n// Descripción: Archivo generado automáticamente para estructura base Flutter"
        Write-Host "✅ Archivo creado: $fullFilePath"
    } else {
        Write-Host "⚠️ Archivo ya existe: $fullFilePath"
    }
}

Write-Host "`n🎉 Estructura creada exitosamente. Ya puedes comenzar a desarrollar tu app Flutter."
