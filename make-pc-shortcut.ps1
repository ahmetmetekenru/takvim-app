# PC'de Takvim'i ayrı bir uygulama penceresinde açan kısayolu (Masaüstü + Başlat menüsü + Başlangıç) oluşturur.
# Edge'i "uygulama modunda" (--app) açar: adres çubuğu ve sekmeler olmadan, kendi penceresinde.
# Kabuğu açar (Apps Script adresini değil): böylece çevrimdışı kopya ve PC bildirimleri de çalışır.
# Başlangıç klasöründeki kısayol, bilgisayar açılınca Takvim'i küçültülmüş olarak açar (bildirimler için).
#   pwsh app/make-pc-shortcut.ps1

$appUrl = "https://ahmetmetekenru.github.io/takvim-app/"
$edge = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$iconPath = Join-Path $PSScriptRoot "takvim.ico"

# icon-512.png'yi .ico dosyasına sarar (Windows, içinde PNG olan .ico dosyalarını okuyabilir)
$png = [System.IO.File]::ReadAllBytes((Join-Path $PSScriptRoot "icon-512.png"))
$stream = [System.IO.File]::Create($iconPath)
$writer = New-Object System.IO.BinaryWriter $stream
$writer.Write([UInt16]0)            # ayrılmış
$writer.Write([UInt16]1)            # tür: ikon
$writer.Write([UInt16]1)            # ikon sayısı
$writer.Write([byte]0)              # genişlik (0 = 256 ve üstü)
$writer.Write([byte]0)              # yükseklik
$writer.Write([byte]0)              # renk sayısı
$writer.Write([byte]0)              # ayrılmış
$writer.Write([UInt16]1)            # renk düzlemi
$writer.Write([UInt16]32)           # bit derinliği
$writer.Write([UInt32]$png.Length)  # resmin boyutu
$writer.Write([UInt32]22)           # resmin dosyadaki yeri (6 + 16)
$writer.Write($png)
$writer.Close()

$shell = New-Object -ComObject WScript.Shell
$startup = [Environment]::GetFolderPath("Startup")
$folders = @([Environment]::GetFolderPath("Desktop"), [Environment]::GetFolderPath("Programs"), $startup)
foreach ($folder in $folders) {
    $shortcut = $shell.CreateShortcut((Join-Path $folder "Takvim.lnk"))
    $shortcut.TargetPath = $edge
    $shortcut.Arguments = "--app=$appUrl"
    $shortcut.IconLocation = $iconPath
    $shortcut.Description = "Takvim"
    if ($folder -eq $startup) { $shortcut.WindowStyle = 7 } # 7 = küçültülmüş
    $shortcut.Save()
    Write-Output "Kısayol oluşturuldu: $folder\Takvim.lnk"
}
