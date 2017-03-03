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
  *)
    echo "Unknown component: $COMPONENT"
    exit 1
  ;;
esac
