Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "S Prabhanjan Kumar - Office Deployment Manager"
$form.Size = New-Object System.Drawing.Size(780, 680)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# --- UI Setup ---
$grpEdition = New-Object System.Windows.Forms.GroupBox
$grpEdition.Text = "1. Select Office Edition"
$grpEdition.Location = New-Object System.Drawing.Point(15, 15)
$grpEdition.Size = New-Object System.Drawing.Size(350, 155)
$form.Controls.Add($grpEdition)

$editions = @("O365ProPlusRetail", "ProPlus2024Retail", "ProPlus2019Retail", "ProPlus2016Retail", "ProPlus2013Retail")
$radioButtons = @()
$y = 25
foreach ($ed in $editions) {
    $rb = New-Object System.Windows.Forms.RadioButton
    $rb.Text = $ed
    $rb.Location = New-Object System.Drawing.Point(20, $y)
    $rb.Size = New-Object System.Drawing.Size(200, 20)
    $rb.Checked = ($ed -eq "O365ProPlusRetail")
    $rb.Add_CheckedChanged({ Update-Preview })
    $grpEdition.Controls.Add($rb)
    $radioButtons += $rb
    $y += 25
}

$grpApps = New-Object System.Windows.Forms.GroupBox
$grpApps.Text = "2. Select Applications"
$grpApps.Location = New-Object System.Drawing.Point(15, 185)
$grpApps.Size = New-Object System.Drawing.Size(350, 230)
$form.Controls.Add($grpApps)

$appsList = @("Word", "Excel", "Outlook", "Teams", "PowerPoint", "Access", "Bing", "Groove", "Lync", "OneDrive", "OneNote", "Publisher")
$checkBoxes = @()
$x = 20; $y = 25; $count = 0
foreach ($app in $appsList) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $app
    $cb.Location = New-Object System.Drawing.Point($x, $y)
    $cb.Size = New-Object System.Drawing.Size(120, 20)
    $cb.Checked = $true
    $cb.Add_CheckedChanged({ Update-Preview })
    $grpApps.Controls.Add($cb)
    $checkBoxes += $cb
    $y += 30; $count++
    if ($count -eq 6) { $x = 180; $y = 25 }
}

$txtPreview = New-Object System.Windows.Forms.RichTextBox
$txtPreview.Location = New-Object System.Drawing.Point(385, 35)
$txtPreview.Size = New-Object System.Drawing.Size(360, 480)
$txtPreview.ReadOnly = $true
$txtPreview.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($txtPreview)

# --- Buttons ---
$btnGetSetup = New-Object System.Windows.Forms.Button
$btnGetSetup.Text = "Download Setup.exe from GitHub"
$btnGetSetup.Location = New-Object System.Drawing.Point(15, 430)
$btnGetSetup.Size = New-Object System.Drawing.Size(350, 45)
$form.Controls.Add($btnGetSetup)

$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "Download Offline"
$btnDownload.Location = New-Object System.Drawing.Point(15, 530)
$btnDownload.Size = New-Object System.Drawing.Size(120, 45)
$form.Controls.Add($btnDownload)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Install (Offline)"
$btnInstall.Location = New-Object System.Drawing.Point(155, 530)
$btnInstall.Size = New-Object System.Drawing.Size(120, 45)
$form.Controls.Add($btnInstall)

$btnInstallOnline = New-Object System.Windows.Forms.Button
$btnInstallOnline.Text = "Install (Online)"
$btnInstallOnline.Location = New-Object System.Drawing.Point(295, 530)
$btnInstallOnline.Size = New-Object System.Drawing.Size(120, 45)
$form.Controls.Add($btnInstallOnline)

# --- Logic ---
function Get-XMLString {
    $selectedEdition = ($radioButtons | Where-Object { $_.Checked }).Text
    $excludes = ""
    foreach ($cb in $checkBoxes) {
        if (-not $cb.Checked) { $excludes += "      <ExcludeApp ID=`"$($cb.Text)`" />`r`n" }
    }
    return @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="$selectedEdition">
      <Language ID="en-us" />
$excludes
    </Product>
    <Product ID="ProofingTools">
      <Language ID="en-us" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" Channel="Current" />
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
"@
}

function Update-Preview { $txtPreview.Text = Get-XMLString }
Update-Preview

$btnGetSetup.Add_Click({
    $url = "https://raw.githubusercontent.com/itsprabhanjan369-coder/MS_Office_Deployment_Tool/main/setup.exe"
    $targetPath = Join-Path $PSScriptRoot "setup.exe"
    
    [System.Windows.Forms.MessageBox]::Show("Downloading setup.exe from GitHub...", "Status")
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $targetPath -UseBasicParsing
        [System.Windows.Forms.MessageBox]::Show("setup.exe downloaded successfully!", "Success")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Download failed: $($_.Exception.Message)", "Error")
    }
})

$btnDownload.Add_Click({ 
    Get-XMLString | Out-File -FilePath ".\configuration.xml" -Encoding utf8
    $form.Hide()
    Start-Process -FilePath ".\setup.exe" -ArgumentList "/download configuration.xml" -Wait
    [System.Windows.Forms.MessageBox]::Show("Download complete!")
    $form.Show()
})

$btnInstall.Add_Click({ 
    Get-XMLString | Out-File -FilePath ".\configuration.xml" -Encoding utf8
    $form.Hide()
    Start-Process -FilePath ".\setup.exe" -ArgumentList "/configure configuration.xml" -Wait
    [System.Windows.Forms.MessageBox]::Show("Installation complete!")
    $form.Show()
})

$btnInstallOnline.Add_Click({ 
    Get-XMLString | Out-File -FilePath ".\configuration.xml" -Encoding utf8
    $form.Hide()
    Start-Process -FilePath ".\setup.exe" -ArgumentList "/configure configuration.xml" -Wait
    [System.Windows.Forms.MessageBox]::Show("Online Installation complete!")
    $form.Show()
})

$form.ShowDialog()
