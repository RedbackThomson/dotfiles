#!/usr/bin/env bash

install_kubedebug() {
    local namespace
    namespace="$1"

    kubectl -n "$namespace" apply -f https://storage.googleapis.com/mcpdebug/v2/kubedebug.yaml
    sleep 5
    kubectl -n "$namespace" patch networkpolicy allow-ingress-to-vcluster --type=json -p=\[\{\"op\":\ \"add\",\ \"path\":\ \"/spec/ingress/0/from/-\",\ \"value\":\ \{\"podSelector\":\{\"matchLabels\":\{\"app\":\"tenant-kubedebug\"\}\}\}\}\]
    kubectl -n "$namespace" exec -it deploy/tenant-kubedebug -- bash
}