<#
    .SYNOPSIS
    Summarises ansible-test JUnit results into the GitHub Actions job summary.

    .DESCRIPTION
    Azure Pipelines consumed the JUnit XML that ansible-test writes and rendered it in
    the build's Tests tab. GitHub Actions has no equivalent built in, so this reads the
    same XML and writes a Markdown table to the step summary, giving maintainers a
    readable pass/fail breakdown without downloading the artifacts.

    This only reports. Whether the job passes is decided by ansible-test's own exit
    code, so that a run which fell over before producing any results still fails.

    Counting failures alone is not enough to call a run good. A target that dies before
    it runs anything still writes a testsuite element, just with zero tests in it, so
    the totals can read as a clean pass while a whole target silently did not execute.
    Both that case and the outcome of the step that ran ansible-test are reported here,
    so the summary can never claim success for a job that failed.

    .EXAMPLE
    .\Write-TestSummary.ps1 -Path ./testresults -Title 'Integration (ansible-core 2.20)'

    Renders the results found under ./testresults into the job summary.

    .EXAMPLE
    .\Write-TestSummary.ps1 -Path ./testresults -Title 'Integration' -TestOutcome failure

    As above, but reports the run as failed even if the recorded tests all passed.
#>
[CmdletBinding()]
param(
    # Directory to search for JUnit XML files produced by ansible-test.
    [Parameter(Mandatory)]
    [string]
    $Path,

    # Heading to render above the results table.
    [Parameter(Mandatory)]
    [string]
    $Title,

    # Outcome of the step that ran ansible-test, as reported by GitHub Actions. When
    # this is anything other than 'success' the run is reported as failed regardless of
    # what the recorded tests say.
    [Parameter()]
    [string]
    $TestOutcome,

    # Where to write the Markdown summary. Defaults to the GitHub Actions job summary.
    [Parameter()]
    [string]
    $SummaryPath = $env:GITHUB_STEP_SUMMARY
)

$ErrorActionPreference = 'Stop'

$resultFiles = @(
    if (Test-Path -LiteralPath $Path) {
        Get-ChildItem -Path $Path -Recurse -File -Filter '*.xml'
    }
)

$summary = [System.Collections.Generic.List[string]]::new()
$summary.Add("## $Title")

if ($resultFiles.Count -eq 0) {
    $summary.Add('')
    $summary.Add("No JUnit result files were found under ``$Path``.")

    if ($SummaryPath) {
        $summary | Add-Content -Path $SummaryPath
    }

    Write-Warning "No JUnit result files were found under '$Path'."
    return
}

$suites = foreach ($file in $resultFiles) {
    foreach ($suite in ([xml](Get-Content -Path $file.FullName -Raw)).SelectNodes('//testsuite')) {
        [PSCustomObject]@{
            Name     = $suite.name
            Tests    = [int]$suite.tests
            Failures = [int]$suite.failures
            Errors   = [int]$suite.errors
            Skipped  = [int]$suite.skipped
        }
    }
}

$totals = $suites | Measure-Object -Property Tests, Failures, Errors, Skipped -Sum
$total = @{}
foreach ($measurement in $totals) { $total[$measurement.Property] = [int]$measurement.Sum }

# A target that failed before running anything still writes a testsuite element with
# no tests in it. Counting only failures would read that as a clean pass.
$emptySuites = @($suites | Where-Object { $_.Tests -eq 0 })

$problems = [System.Collections.Generic.List[string]]::new()

if ($total.Failures -gt 0 -or $total.Errors -gt 0) {
    $problems.Add("$($total.Failures) failed, $($total.Errors) errored")
}

if ($emptySuites.Count -gt 0) {
    $problems.Add("$($emptySuites.Count) suite(s) recorded no tests at all")
}

if ($TestOutcome -and $TestOutcome -ne 'success') {
    $problems.Add("the test step reported '$TestOutcome'")
}

$status = if ($problems.Count -gt 0) { ':x: Failed' } else { ':white_check_mark: Passed' }

$summary.Add('')
$summary.Add("**$status** &mdash; $($total.Tests) tests, $($total.Failures) failed, $($total.Errors) errored, $($total.Skipped) skipped.")

if ($problems.Count -gt 0) {
    $summary.Add('')
    $summary.Add("Reported as failed because $($problems -join '; ').")
}

$summary.Add('')
$summary.Add('| Suite | Tests | Failures | Errors | Skipped |')
$summary.Add('| --- | ---: | ---: | ---: | ---: |')

foreach ($suite in $suites | Sort-Object -Property Name) {
    $note = if ($suite.Tests -eq 0) { ' :warning: no tests recorded' } else { '' }
    $summary.Add("| $($suite.Name)$note | $($suite.Tests) | $($suite.Failures) | $($suite.Errors) | $($suite.Skipped) |")
}

$summary | ForEach-Object { Write-Host $_ }

if ($SummaryPath) {
    $summary | Add-Content -Path $SummaryPath
}
