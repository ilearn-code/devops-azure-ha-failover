#!/bin/bash
# Test script for Azure Traffic Manager failover

echo "=========================================="
echo "Azure Traffic Manager Failover Test"
echo "=========================================="
echo ""

# Configuration
TM_URL="http://ha-failover-ha-ua-tm.trafficmanager.net"
WEST_IP="4.155.235.117"
EAST_IP="172.200.18.135"

echo "🌐 Traffic Manager FQDN: $TM_URL"
echo "📍 West AppGW IP: $WEST_IP"
echo "📍 East AppGW IP: $EAST_IP"
echo ""

# Function to test endpoint
test_endpoint() {
    local url=$1
    local name=$2
    echo "Testing $name: $url"
    response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null | tail -1)
    if [ "$response" = "200" ]; then
        echo "✅ $name is healthy (HTTP $response)"
    else
        echo "❌ $name is unhealthy or unreachable (HTTP $response)"
    fi
    echo ""
}

# Test all endpoints
echo "=========================================="
echo "1. Testing Direct Endpoints"
echo "=========================================="
test_endpoint "http://$WEST_IP" "West AppGW"
test_endpoint "http://$EAST_IP" "East AppGW"

echo "=========================================="
echo "2. Testing Traffic Manager (should route to Priority 1 - West)"
echo "=========================================="
test_endpoint "$TM_URL" "Traffic Manager"

echo "=========================================="
echo "3. Instructions for Failover Testing"
echo "=========================================="
echo ""
echo "To simulate West AppGW failure:"
echo "1. Stop West App Gateway in Azure Portal OR"
echo "2. Run: az network application-gateway stop --name ha-failover-ha-ua-west-appgw --resource-group ha-failover-ha-ua-west-rg"
echo ""
echo "Then wait 2-3 minutes and test Traffic Manager again:"
echo "curl $TM_URL"
echo ""
echo "You should see traffic failover to East region!"
echo ""
echo "To restore:"
echo "az network application-gateway start --name ha-failover-ha-ua-west-appgw --resource-group ha-failover-ha-ua-west-rg"
echo ""
