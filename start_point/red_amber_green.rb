lambda { |stdout,stderr,status|
  output = stdout + stderr
  # bats speaks TAP: a passing test is "ok N", a failing one "not ok N".
  # A bash error names its file and line, as in "./hiker.sh: line 6:", and
  # that marks a test that could not run rather than one that ran and failed.
  return :green if status == 0 && /^ok \d+/.match(output)
  return :red   if /^not ok \d+/.match(output) && !/: line \d+:/.match(output)
  return :amber
}
