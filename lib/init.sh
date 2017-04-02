#TODO: sh wat
confirm () {
  if [ "$KONTENA_COMPOSE" = "noninteractive" ]; then
    return
  fi
  printf "\n$1"
  # TODO: sh wat
  read input
}

HOST=$1
COMPONENT=$2
shift; shift

case "$HOST" in
  "vagrant")
    SSH_CMD="ssh -F vagrant/config"
  ;;
  *)
    SSH_CMD="ssh -t"
  ;;
esac

case "$COMPONENT" in
  "master")
  ;;
  "node")
  ;;
  "docker")
  ;;
  "mongodb")
  ;;
  "mongo-backup")
  ;;
  "lb")
  ;;
  *)
    echo "Unknown component: $COMPONENT"
    exit 1
  ;;
esac
