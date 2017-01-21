COMPONENT=$1
HOST=$2

case "$COMPONENT" in
  "master")
  ;;
  "node")
  ;;
  "docker")
  ;;
  *)
    echo "Unknown component: $COMPONENT"
    exit 1
  ;;
esac