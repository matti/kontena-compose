function confirm() {
  printf "\n$1"
  read
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
