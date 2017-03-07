#!/usr/bin/env sh
set -e
export KONTENA_COMPOSE=noninteractive

case $1 in
  "vagrant")
    case $2 in
      "destroy")
        vagrant destroy --force
        rm -rf .vagrant
      ;;
      "up")
        vagrant up
        vagrant snapshot save vagrant-up
      ;;
      "+up")
        $0 kontena destroy
        vagrant snapshot restore vagrant-up
      ;;
      "upgrade")
        vagrant ssh -c "sudo apt-get update"
        vagrant ssh -c "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
        set +e
          vagrant ssh -c "sudo reboot"
        set -e
        while true; do
          vagrant ssh -c "uptime" && break
          printf "."
          sleep 1
        done
        vagrant snapshot save vagrant-upgrade
      ;;
      "+upgrade")
        $0 kontena destroy
        vagrant snapshot restore vagrant-upgrade
      ;;
    esac
  ;;
  "kontena")
    case $2 in
      "destroy")
        curl --connect-timeout 1 192.168.81.10:22 || exit 0

        bin/destroy vagrant node
        bin/destroy vagrant master
        kontena master rm --force vagrant
      ;;
      "master")
        bin/initialize vagrant master --kontena_version 1.1.2 --master_http_port 8080 --master_https_port 8443
        while true; do
          curl --silent 192.168.81.10:8080 && break
          printf "."
          sleep 1
        done
        echo ""
        vagrant snapshot save kontena-master
      ;;
      "+master")
        $0 kontena -node
        vagrant snapshot restore kontena-master
      ;;
      "login")
        kontena master login -e 0 -c initialadmincode -n vagrant http://192.168.81.10:8080
        kontena grid create --token vagrant vagrant
      ;;
      "node")
        bin/initialize vagrant node --kontena_version 1.1.2 --master_uri ws://localhost:8080 --grid_token vagrant
        while true; do
          if [ "$(kontena node ls | grep vagrant)" = "" ]; then
            printf "."
            sleep 1
          else
            break
          fi
        done
        kontena node ls
        echo ""
      ;;

      #NOTE: node snapshotting doesn't work because of the network interfaces (weave)...?

      "-node")
        bin/destroy vagrant node
        kontena node rm --force vagrant
      ;;
    esac
  ;;
  "stack")
    case $2 in
      "lb")
        kontena node label add vagrant lb-ingress
        kontena stack install --values-from test/lb-ingress.yml matti/lb-ingress
      ;;
      "-lb")
        kontena stack rm --force lb-ingress
      ;;
      "weavescope")
        kontena stack install --values-from test/weavescope.yml matti/weavescope
        while true; do
          curl --silent weavescope.kontena.rocks | grep "browsehappy" > /dev/null && break
          sleep 1
        done

        kontena stack logs weavescope
      ;;
      "-weavescope")
        kontena stack rm --force weavescope
      ;;
    esac
  ;;

  "all")
    $0 vagrant up
    $0 vagrant upgrade
    $0 kontena master
    $0 kontena login
    $0 kontena node
    $0 stack lb
    $0 stack weavescope
    $0 stack -weavescope
    $0 stack -lb
  ;;

  "recreate")
    case $2 in
      "all")
        $0 kontena destroy
        $0 vagrant destroy
        $0 all
      ;;
      "from-master")
        $0 kontena +master
        $0 kontena login
        $0 kontena node
      ;;
      *)
        echo "unknown recreate"
      ;;
    esac
  ;;
esac
