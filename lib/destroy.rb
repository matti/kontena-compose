require_relative "./base"
require "slop"

opts = Slop.parse do |o|
  o.banner = "usage: bin/destroy host component"
  o.separator ""
  o.separator "Destroy: master"
  o.string "--master_name", "Master name [composemaster]",
    default: "composemaster"

  o.on '--help', "This help text" do
    puts o
    exit 1
  end
end

master_name = opts[:master_name]

k = Kommando.run "kontena version"
matches = k.out.match /cli: (\d+.\d+.\d+)/
kontena_cli_version = matches[1]

out :info, "kontena-cli in version #{kontena_cli_version}"

# remove existing master from cloud
cloud_master_ls_k = Kommando.run "kontena cloud master ls", {
  output: true
}

if (matches = cloud_master_ls_k.out.match /(\w+)\s+#{Regexp.quote(master_name)}/)
  cloud_master_rm_k = Kommando.run "kontena cloud master rm --force #{matches[1]}", {
    output: true,
  }
end

# remove existing local master
master_ls_k = Kommando.run "kontena master ls", {
  output: true
}
if (matches = master_ls_k.out.match /\* #{Regexp.quote(master_name)}/)
  master_rm_k = Kommando.puts "kontena master rm --force #{master_name}"
end
