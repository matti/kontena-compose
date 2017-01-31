require "slop"
require "securerandom"

opts = Slop.parse do |o|
  o.separator ""
  o.separator "Generic"
  o.string '--kontena_version', "Kontena version [latest]",
    default: 'latest'
  o.string '--compose_project_name', "Compose project name (prefix for the containers) [kontena]",
    default: 'kontena'
  o.on '--help', "This help text" do
    puts o
    exit 1
  end

  o.separator ""
  o.separator "Master"
  o.string "--master_mongodb_uri", "MongoDB URI [mongodb://mongodb:27017/kontena_master]",
    default: "mongodb://mongodb:27017/kontena_master"
  o.string "--master_vault_key", "Vault key [random64]",
    default: "#{SecureRandom.hex}#{SecureRandom.hex}"
  o.string "--master_vault_iv", "Vault initialization vector [random64]",
    default: "#{SecureRandom.hex}#{SecureRandom.hex}"
  o.string "--master_initial_admin_code", "Initial admin code [initialadmincode]",
    default: "initialadmincode"
  o.string "--master_le_cert_hostname", "Generate Let's Encrypt certificate for hostname (public IP must point to the hostname)"
  o.string "--master_le_cert_email", "Email for certificate notifications"

  o.separator ""
  o.separator "Node"
  o.string "--master_uri", "WebSocket URI for connection in ws(s)://host:port format [ws://localhost]",
    default: "ws://localhost"
  o.string "--grid_token", "Token [REQUIRED]"
  o.string "--peer_interface", "The peer interface for weave [eth0]",
    default: "eth0"
end

def export_line(key, value)
  print "export ", key, '="', value, '"', "\n"
end

case (component = opts.arguments[0])
when "master"
  export_line "KONTENA_MASTER_MONGODB_URI", opts[:master_mongodb_uri]
  export_line "KONTENA_MASTER_VAULT_KEY", opts[:master_vault_key]
  export_line "KONTENA_MASTER_VAULT_IV", opts[:master_vault_iv]
  export_line "KONTENA_MASTER_INITIAL_ADMIN_CODE", opts[:master_initial_admin_code]
  export_line "KONTENA_MASTER_LE_CERT_HOSTNAME", opts[:master_le_cert_hostname]
  export_line "KONTENA_MASTER_LE_CERT_EMAIL", opts[:master_le_cert_email]
when "node"
  unless opts.grid_token?
    puts "ERROR: --grid_token must be given"
    exit 1
  end

  export_line "KONTENA_MASTER_URI", opts[:master_uri]
  export_line "KONTENA_GRID_TOKEN", opts[:grid_token]
  export_line "KONTENA_PEER_INTERFACE", opts[:peer_interface]
else
  puts opts
  exit 1
end

export_line "COMPOSE_PROJECT_NAME", opts[:compose_project_name]
export_line "KONTENA_VERSION", opts[:kontena_version]
