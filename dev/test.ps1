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

# Run Pester tests using the configuration you've created
Invoke-Pester -Configuration $config