require_relative "./base"

# login with initial admin code
login_k = Kommando.puts "kontena master login --name todomaster --code initialadmincode #{ARGV[0]}"
assert_match login_k.out, "Create one now using"

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
master_users_invite_k = Kommando.run "kontena master users invite -r master_admin matti.paksula@iki.fi", {
  output: true
}

matches = assert_match master_users_invite_k.out, /\* code:\s+(\w+)/

master_join_k = nil
override_kommando_timeout_bug nil do
  master_join_k = Kommando.run_async "kontena master join --name todomaster #{ARGV[0]} #{matches[1]}", {
    output: true
  }
end

master_join_k.out.on "Press any key" do
  master_join_k.in.writeln ""
end

master_join_k.wait


assert_match master_join_k.out, "Kontena Master todomaster doesn't have any grids yet."


grid_create_k = Kommando.run "kontena grid create --initial-size 1 --token todotoken todogrid", {
  output: true
}
