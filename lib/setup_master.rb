require_relative "./base"

master_url = ARGV[0]
admin_email = ARGV[1]

master_name = ENV['KONTENA_MASTER_NAME']
grid_name = ENV['KONTENA_GRID_NAME']
grid_initial_size = ENV['KONTENA_GRID_INITIAL_SIZE']
grid_token = ENV['KONTENA_GRID_TOKEN']

puts "-- config --"
puts "  master name: #{master_name}"
puts "  master url: #{master_url}"
puts "  admin email: #{admin_email}"
puts "  grid name: #{grid_name}"
puts "  grid initial_size: #{grid_initial_size}"
puts "  grid token: #{grid_token}"

sleep 3

# login with initial admin code
login_k = Kommando.puts "kontena master login --name #{master_name} --code initialadmincode #{master_url}"
assert_match login_k.out, ""

# init cloud
init_cloud_k = nil
override_kommando_timeout_bug nil do
  init_cloud_k = Kommando.run_async "kontena master init-cloud --force", {
    output: true
  }
end
init_cloud_k.out.on "Press any key to continue" do
  init_cloud_k.in.writeln ""
end
init_cloud_k.wait

# invite user
master_users_invite_k = Kommando.run "kontena master users invite -r master_admin #{admin_email}", {
  output: true
}

matches = assert_match master_users_invite_k.out, /\* code:\s+(\w+)/

master_join_k = nil
override_kommando_timeout_bug nil do
  master_join_k = Kommando.run_async "kontena master join --name #{master_name} #{master_url} #{matches[1]}", {
    output: true
  }
end

master_join_k.out.on "Press any key" do
  master_join_k.in.writeln ""
end

master_join_k.wait

assert_match master_join_k.out, "Authenticated to Kontena Master"

grid_create_k = Kommando.run "kontena grid create --initial-size #{grid_initial_size} --token #{grid_token} #{grid_name}", {
  output: true
}
