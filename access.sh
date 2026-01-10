#!/bin/bash
# This script retrieves URLs and credentials for ArgoCD, Prometheus & Grafana

echo "=== Configuring kubectl ==="
aws eks update-kubeconfig --region us-east-1 --name devops-cluster

echo ""
echo "========================================="
echo "RETRIEVING ACCESS INFORMATION"
echo "========================================="

# Wait a moment for services to be fully ready
sleep 2

# ArgoCD Access
echo ""
echo "=== ArgoCD ==="
ARGOCD_URL=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -z "$ARGOCD_URL" ]; then
    echo "⚠️  ArgoCD LoadBalancer is being provisioned..."
    echo "Run: kubectl get svc argocd-server -n argocd"
else
    echo "ArgoCD URL: https://$ARGOCD_URL"
fi

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)
if [ -z "$ARGOCD_PASSWORD" ]; then
    echo "⚠️  ArgoCD secret not found yet"
else
    echo "ArgoCD Username: admin"
    echo "ArgoCD Password: $ARGOCD_PASSWORD"
fi

# Prometheus Access
echo ""
echo "=== Prometheus ==="
PROMETHEUS_URL=$(kubectl get svc kube-prometheus-stack-prometheus -n prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -z "$PROMETHEUS_URL" ]; then
    echo "⚠️  Prometheus LoadBalancer is being provisioned..."
    echo "Run: kubectl get svc kube-prometheus-stack-prometheus -n prometheus"
else
    echo "Prometheus URL: http://$PROMETHEUS_URL:9090"
fi

# Grafana Access
echo ""
echo "=== Grafana ==="
GRAFANA_URL=$(kubectl get svc kube-prometheus-stack-grafana -n prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -z "$GRAFANA_URL" ]; then
    echo "⚠️  Grafana LoadBalancer is being provisioned..."
    echo "Run: kubectl get svc kube-prometheus-stack-grafana -n prometheus"
else
    echo "Grafana URL: http://$GRAFANA_URL"
fi

GRAFANA_PASSWORD=$(kubectl get secret kube-prometheus-stack-grafana -n prometheus -o jsonpath="{.data.admin-password}" 2>/dev/null | base64 -d)
if [ -z "$GRAFANA_PASSWORD" ]; then
    echo "⚠️  Grafana secret not found"
    echo "Default Password: prom-operator"
else
    echo "Grafana Username: admin"
    echo "Grafana Password: $GRAFANA_PASSWORD"
fi

# Application Access (if deployed)
echo ""
echo "=== Application ==="
APP_URL=$(kubectl get svc devops-app -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -z "$APP_URL" ]; then
    echo "⚠️  Application not deployed or LoadBalancer provisioning"
else
    echo "Application URL: http://$APP_URL:3000"
fi

# Cluster Info
echo ""
echo "=== Cluster Information ==="
echo "Cluster: devops-cluster"
echo "Region: us-east-1"
kubectl get nodes --no-headers 2>/dev/null | awk '{print "Node: " $1 " - Status: " $2}'

echo ""
echo "========================================="
echo "NOTE: LoadBalancers take 2-5 minutes to provision"
echo "If URLs are missing, wait a few minutes and run again"
echo "========================================="
