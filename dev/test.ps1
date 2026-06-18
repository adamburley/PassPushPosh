# Create a Pester configuration object using `New-PesterConfiguration`
$config = New-PesterConfiguration

# Set the test path to specify where your tests are located. In this example, we set the path to the current directory. Pester will look into all subdirectories.
$config.Run.Path = ".\Tests"

# Enable Code Coverage
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = ".\Output\PassPushPosh\PassPushPosh.psm1"
$config.CodeCoverage.OutputPath = ".\Tests\coverage.xml"

$config.Output.Verbosity = 'Detailed'

$config.Run.PassThru = $true

# Import environment variables
if (Test-Path '.\local.settings.json') {
    $environmentVariables = Get-Content -Path '.\local.settings.json' | ConvertFrom-Json -depth 10 | Select-Object -expandproperty Values
    $environmentVariables | Get-Member -MemberType NoteProperty | Foreach-Object {
        $name = $_.Name
        New-Item -Path "Env:\$name" -Value $environmentVariables.$name -Force | Out-Null
    }
}

# Run Pester tests using the configuration you've created
Invoke-Pester -Configuration $config