param( 
    $Function,
    $Scope = 'Public'
)

# Create a Pester configuration object using `New-PesterConfiguration`
$config = New-PesterConfiguration

# Set the test path to specify where your tests are located. In this example, we set the path to the current directory. Pester will look into all subdirectories.
$config.Run.Path = ".\Tests\$Scope\$Function.Tests.ps1"

# Enable Code Coverage
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = ".\AxcientAPI\$Scope\$Function.ps1"

$config.Output.Verbosity = 'Detailed'

# Run Pester tests using the configuration you've created
Invoke-Pester -Configuration $config