require_relative "./base"

master_url = ARGV[0]
admin_email = ARGV[1]

# login with initial admin code
login_k = Kommando.puts "kontena master login --name #{ENV['KONTENA_MASTER_NAME']} --code initialadmincode #{master_url}"
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
  master_join_k = Kommando.run_async "kontena master join --name #{ENV['KONTENA_MASTER_NAME']} #{master_url} #{matches[1]}", {
    output: true
  }
end

master_join_k.out.on "Press any key" do
  master_join_k.in.writeln ""
end

master_join_k.wait

assert_match master_join_k.out, "Authenticated to Kontena Master"

grid_create_k = Kommando.run "kontena grid create --initial-size #{ENV['KONTENA_GRID_INITIAL_SIZE']} --token #{ENV['KONTENA_GRID_TOKEN']} #{ENV['KONTENA_GRID_NAME']}", {
  output: true
}
