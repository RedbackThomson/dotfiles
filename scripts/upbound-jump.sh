#!/usr/bin/env bash

jump_dev() {
	gcloud config set project upbound-cloud-dev
	gcloud compute start-iap-tunnel jump-dev 8888 --local-host-port=localhost:8888
}

jump_staging() {
	gcloud config set project cloud-staging-6d785a8d
	gcloud compute start-iap-tunnel jump-staging 8888 --local-host-port=localhost:8889
}

jump_prod() {
    gcloud config set project upbound-cloud-production
	gcloud compute start-iap-tunnel jump-production 8888 --local-host-port=localhost:8890
}