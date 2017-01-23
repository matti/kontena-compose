require_relative "../lib/base"

destroy_master_k = Kommando.run "$ cd master && bin/destroy", {
  output: true
}
destroy_node_k = Kommando.run "$ cd node && bin/destroy", {
  output: true
}

destroy_k = Kommando.run "$ bin/destroy", {
  output: true
}

master_initialize_k = nil
override_kommando_timeout_bug nil do
  master_initialize_k = Kommando.run_async "$ cd master && bin/initialize", {
    output: true
  }
end

master_initialize_k.out.on /Initial Admin Code/ do
  master_initialize_k.in.write "\x03"
end

master_initialize_k.wait

setup_master_k = nil
override_kommando_timeout_bug nil do
  setup_master_k = Kommando.run "$ bin/setup http://192.168.99.100:9292", {
    output: true
  }
end

assert_match setup_master_k.out, /Switching scope/

node_initialize_k = nil
override_kommando_timeout_bug nil do
  node_initialize_k = Kommando.run_async "$ cd node && bin/initialize 1.0.4 ws://192.168.99.100:9292", {
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

puts "OK"