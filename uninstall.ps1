Write-Host "Parmana uninstall ho raha hai..." -ForegroundColor Red

# Parmana model delete
ollama rm parmana

# Parmana folder delete
Remove-Item -Recurse -Force "E:\Parmana"

# Ollama models env variable reset
[System.Environment]::SetEnvironmentVariable("OLLAMA_MODELS", $null, "User")

Write-Host "Parmana uninstall ho gaya!" -ForegroundColor Green
