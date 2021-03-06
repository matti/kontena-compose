require_relative "../lib/base"
require "byebug"

$target_host = ARGV[0]
$target_host_url = ARGV[1]
$admin_email = ARGV[2]

def cleanup
  destroy_node_k = Kommando.run "$ bin/destroy #{$target_host} node", {
    output: true
  }
  destroy_master_k = Kommando.run "$ bin/destroy #{$target_host} master", {
    output: true,
    timeout: 30
  }
end

cleanup

deploy_node_k = Kommando.puts "$ bin/deploy #{$target_host} node"
deploy_master_k = Kommando.puts "$ bin/deploy #{$target_host} master"


master_initialize_k = nil
override_kommando_timeout_bug nil do
  master_initialize_k = Kommando.run_async "$ bin/initialize #{$target_host} master", {
    output: true
  }
end

master_initialize_k.out.on /Initial Admin Code/ do
  master_initialize_k.in.write "\x03"
end

master_initialize_k.wait

Kommando.puts "$ curl #{$target_host_url}"

setup_master_k = nil
override_kommando_timeout_bug nil do
  setup_master_k = Kommando.run "$ bin/setup_master #{$target_host_url} #{$admin_email}", {
    output: true
  }
end

grid_token = (setup_master_k.out.match /grid token: (\w*)/)[1]

assert_match setup_master_k.out, /Switching scope/

node_initialize_k = nil
override_kommando_timeout_bug nil do
  node_initialize_k = Kommando.run_async "$ bin/initialize #{$target_host} node --grid_token #{grid_token}", {
    output: true
  }
end

node_initialize_k.out.on /connection established/ do
  node_initialize_k.in.write "\x03"
end

node_initialize_k.wait

loop do
  node_ls_k = Kommando.puts "$ kontena node ls"
  break if node_ls_k.out.match "online"
  sleep 1
end

# TODO: deploy a service?

cleanup

puts "OK"