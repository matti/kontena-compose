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
  *)
    echo "Unknown component: $COMPONENT"
    exit 1
  ;;
esac