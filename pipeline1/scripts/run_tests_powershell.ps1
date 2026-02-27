# $DebugPreference = 'Continue'
$EXPECTED = ''
$ACTUAL = ''

function RunTests {
    if (!(test-path "$WORKING_DIR/test_results")) {
        New-Item -ItemType Directory "$WORKING_DIR/test_results" | Out-Null
    }

    foreach($test in $args) {
        $Result = $(Invoke-Expression "$test")
        $exit_code = $?
        # if ($Result -eq 0 -and $ACTUAL -eq $EXPECTED) {
        # write-host "1 EXPECTED: $EXPECTED"
        # write-host "1 ACTUAL: $ACTUAL"
        if ($exit_code -eq $true -and $ACTUAL -eq $EXPECTED) {
            WriteInfo "$test $TICK_MARK"
        } else {
            WriteInfo ''
            # WriteInfo "Test Result: $Result"
            WriteInfo "$test $CROSS_MARK"
            if ($EXPECTED -and $ACTUAL) {
                Compare-Object -ReferenceObject $EXPECTED -DifferenceObject $ACTUAL
            } else {
                WriteInfo "EXPECTED: $EXPECTED"
                WriteInfo "ACTUAL: $ACTUAL"
            }
            WriteInfo "`n"
            # WriteInfo "$EXPECTED" > "$WORKING_DIR/test_results/$test`_expected.txt"
            # WriteInfo "$ACTUAL" > "$WORKING_DIR/test_results/$test`_actual.txt"
            # Compare-Object "$WORKING_DIR/test_results/$test`_expected.txt" "$WORKING_DIR/test_results/$test`_actual.txt"
        }
    }
}