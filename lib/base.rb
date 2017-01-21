require "kommando"
require "byebug"

class Kommando
  attr_reader :cmd
end

def override_kommando_timeout_bug timeout, &proc
  old_timeout = Kommando.timeout
  Kommando.timeout = timeout
  proc.call
  Kommando.timeout = old_timeout
end

Kommando.timeout = 10
Kommando.when :timeout do |k|
  puts "\nTimeout with: #{k.cmd}"
  exit 1
end
Kommando.when :error do |k|
  puts "\nError running: #{k.cmd}"
  exit 1
end


def out(level, str)
  puts "#{level.to_s}: #{str}"
end

def assert_match(str, expected)
  matches = matches = str.match expected
  unless matches
    out :fatal, "unknown reply:\n#{str}"
    exit 1
  end

  return matches
end