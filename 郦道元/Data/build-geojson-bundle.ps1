$ErrorActionPreference = "Stop"

$root = Join-Path $PSScriptRoot "geojson"
$output = Join-Path $PSScriptRoot "geojson-bundle.js"

# 仅打包网页当前使用的数据，防止已停用的旧文件进入离线数据包。
$files = @'
china/ChinaBoundline.geojson
china/ChinaBoundpoly.geojson
places/FanyangZhuozhou.geojson
places/Qingzhou.geojson
places/Luoyang.geojson
places/Hetao.geojson
places/YinshanPlace.geojson
places/Huanghuai.geojson
places/Jizhou_Hengshui.geojson
places/Dingyou.geojson
places/UpperYellowRiver.geojson
places/Luyang_Pingdingshanlushan.geojson
places/Jingzhou.geojson
places/Zhongyuan.geojson
places/Guanzhong.geojson
places/Yingpanyiting_Xianlinntong.geojson
mountains/Taihangshan.geojson
mountains/Daqingshan.geojson
mountains/Wangwushan.geojson
mountains/Funiushan.geojson
mountains/Zhongnanshan.geojson
mountains/Jishishan.geojson
mountains/Yinshan.geojson
mountains/Huashan.geojson
rivers/Huanghe.geojson
rivers/Changjiang.geojson
rivers/Taihu.geojson
rivers/Hutuohe.geojson
rivers/Zhangshui.geojson
rivers/Juyangshui.geojson
rivers/Zishui.geojson
rivers/Huaihe.geojson
rivers/Hangou.geojson
rivers/HuabeiHudian.geojson
'@ -split "`r?`n" | Where-Object { $_ }

$entries = foreach ($relativePath in $files) {
  $fullPath = Join-Path $root ($relativePath -replace "/", "\")
  $json = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)

  # 先解析一次，确保损坏的 GeoJSON 不会被写入网页离线数据包。
  $null = $json | ConvertFrom-Json
  $encodedKey = $relativePath | ConvertTo-Json -Compress
  "$encodedKey`:$json"
}

$content = "window.LDY_GEOJSON_BUNDLE = {" + ($entries -join ",") + "};`n"
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($output, $content, $utf8WithoutBom)

Write-Output "Bundled $($files.Count) GeoJSON files into $output"
