lambda { |stdout,stderr,status|
  output = stdout + stderr
  return :green if status === 0
  return :amber if /.*: line \d+:/.match(output) && status === 1
  return :red
}
