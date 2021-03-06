require_relative "./base"
require "securerandom"
require "slop"

opts = Slop.parse do |o|
  o.banner = "usage: bin/setup_master http(s)://master_host admin@email.com"
  o.separator ""
  o.separator "Setup: master"
  o.string "--initial_admin_code", "[initialadmincode]",
    default: "initialadmincode"
  o.string "--master_name", "Master name [composemaster]",
    default: "composemaster"
  o.string "--grid_name", "The first grid name [composegrid]",
    default: "composegrid"
  o.integer "--grid_initial_size", "The initial size of the first grid [1]",
    default: 1
  o.string "--grid_token", "Token [random32]",
    default: "#{SecureRandom.hex}"
  o.string "--default_affinity", "Default affinity rule for the first grid [label==status=active]",
    default: "label==status=active"
  o.on '--help', "This help text" do
    puts o
    exit 1
  end
end

master_url = opts.arguments[0]
admin_email = opts.arguments[1]

unless master_url && admin_email
  puts opts
  exit 1
end

initial_admin_code = opts[:initial_admin_code]
master_name = opts[:master_name]
grid_name = opts[:grid_name]
grid_initial_size = opts[:grid_initial_size]
grid_token = opts[:grid_token]
default_affinity = opts[:default_affinity]

puts "master name: #{master_name}"
puts "master url: #{master_url}"
puts "admin email: #{admin_email}"
puts "initial admin code: #{initial_admin_code}"
puts "grid name: #{grid_name}"
puts "grid initial_size: #{grid_initial_size}"
puts "grid token: #{grid_token}"
puts "default affinity: #{default_affinity}"

# login with initial admin code
login_k = Kommando.puts "kontena master login --name #{master_name} --code #{initial_admin_code} #{master_url}"
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

grid_create_k = Kommando.run "kontena grid create --initial-size #{grid_initial_size} --token #{grid_token} --default-affinity #{default_affinity} #{grid_name}", {
  output: true
}
