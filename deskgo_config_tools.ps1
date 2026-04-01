# DeskGo 配置备份/恢复工具 (PowerShell 版本)
Write-Host "DeskGo 配置备份/恢复工具" -ForegroundColor Magenta
Write-Host "当前时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan

while ($true) {
    Write-Host ""
    Write-Host "========== 选项 ==========" -ForegroundColor Yellow
    Write-Host "1. 备份配置"
    Write-Host "2. 刷新/恢复配置"
    Write-Host "3. 退出"
    Write-Host "===========================" -ForegroundColor Yellow

    $option = Read-Host "请选择操作"

    if ($option -eq "3") {
        Write-Host "再见!" -ForegroundColor Green
        break
    }

    # 获取 DesktopMgr64 进程信息
    $process = Get-Process -Name "DesktopMgr64" -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($process) {
        $RunPath = $process.Path
        $Name = $process.ProcessName
        Write-Host "进程路径: $RunPath" -ForegroundColor Gray
        Write-Host "进程名称: $Name" -ForegroundColor Gray
    } else {
        $RunPath = $null
        $Name = "DesktopMgr"
        Write-Host "警告: DeskGo 进程未运行" -ForegroundColor Yellow
    }

    # 获取原生输出分辨率 (通过 CIM 查询显卡，等同于原版 wmic Win32_VideoController)
    $video = Get-CimInstance Win32_VideoController | 
		Where-Object { 
			$_.CurrentHorizontalResolution -gt 0 -and 
			$_.CurrentVerticalResolution -gt 0 
		} | 
		Select-Object -First 1
    $HorizontalResolution = $video.CurrentHorizontalResolution
    $VerticalResolution = $video.CurrentVerticalResolution

    Write-Host "屏幕分辨率: $HorizontalResolution x $VerticalResolution" -ForegroundColor Gray

    # 设置路径
    $DeskGoDir = "$env:APPDATA\Tencent\DeskGo"
    $BackupDir = "$DeskGoDir\Backup\$HorizontalResolution x $VerticalResolution"

    Write-Host "备份目录: $BackupDir" -ForegroundColor Gray

    # 确保备份目录存在
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        Write-Host "已创建备份目录" -ForegroundColor Green
    }

    # 要备份的文件列表
    $configFiles = @(
        "ConFile.dat",
        "DesktopMgr.lg",
        "FencesDataFile.dat"
    )

    switch ($option) {
        "1" {
            # 备份配置
            Write-Host ""
            Write-Host "正在备份配置文件..." -ForegroundColor Cyan

            foreach ($file in $configFiles) {
                $sourcePath = Join-Path $DeskGoDir $file
                $destPath = Join-Path $BackupDir $file

                if (Test-Path $sourcePath) {
                    Copy-Item -Path $sourcePath -Destination $destPath -Force
                    Write-Host "  已备份: $file" -ForegroundColor Green
                } else {
                    Write-Host "  跳过 (不存在): $file" -ForegroundColor Yellow
                }
            }

            Write-Host "备份完成!" -ForegroundColor Green
        }

        "2" {
            # 恢复配置
            Write-Host ""
            Write-Host "正在终止 DeskGo 进程..." -ForegroundColor Cyan
            Stop-Process -Name $Name -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1

            Write-Host "正在恢复配置文件..." -ForegroundColor Cyan

            foreach ($file in $configFiles) {
                $sourcePath = Join-Path $BackupDir $file
                $destPath = Join-Path $DeskGoDir $file

                if (Test-Path $sourcePath) {
                    Copy-Item -Path $sourcePath -Destination $destPath -Force
                    Write-Host "  已恢复: $file" -ForegroundColor Green
                } else {
                    Write-Host "  跳过 (备份不存在): $file" -ForegroundColor Yellow
                }
            }

            Write-Host "正在重启 DeskGo..." -ForegroundColor Cyan

            if ($RunPath -and (Test-Path $RunPath)) {
                Start-Process -FilePath $RunPath
                Write-Host "DeskGo 已启动" -ForegroundColor Green
            } else {
                Write-Host "警告: 未找到 DeskGo 路径，请手动启动程序" -ForegroundColor Yellow
            }

            Write-Host "恢复完成!" -ForegroundColor Green
        }

        default {
            Write-Host "无效选项，请输入 1、2 或 3" -ForegroundColor Red
        }
    }
}
