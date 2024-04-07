#!/usr/bin/env bash

alias kmcp='kubectl get mcp -l mcp.upbound.io/account!=reserved -o custom-columns="CONTROL_PLANE_ID":".metadata.name","ACCOUNT":".metadata.labels.mcp\.upbound\.io/account","NAME":".metadata.labels.mcp\.upbound\.io/name","VERSION":".metadata.labels.mcp\.upbound\.io/crossplane-version"'
alias kmcpr='kubectl get mcp -l mcp.upbound.io/account=reserved -o custom-columns="CONTROL_PLANE_ID":".metadata.name","VERSION":".metadata.labels.mcp\.upbound\.io/crossplane-version"'