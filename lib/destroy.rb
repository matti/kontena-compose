require_relative "./base"

master_name = ENV['KONTENA_MASTER_NAME']

k = Kommando.run "kontena version"
matches = k.out.match /cli: (\d+.\d+.\d+)/
kontena_cli_version = matches[1]

out :info, "kontena-cli in version #{kontena_cli_version}"

# remove existing master from cloud (TODO)
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
  master_rm_k = Kommando.puts "kontena master rm --force #{ENV['KONTENA_MASTER_NAME']}"
end
