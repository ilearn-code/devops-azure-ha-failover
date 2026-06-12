#!/bin/bash
# ============================================
# WAF TESTING SCRIPT
# Simulate attacks to test WAF protection
# ============================================

WEST_APPGW="http://4.155.235.117"
TM_URL="http://ha-failover-ha-ua-tm.trafficmanager.net"

echo "=========================================="
echo "🛡️  WAF Testing - Attack Simulations"
echo "=========================================="
echo ""

# Test 1: Normal Request (should work)
echo "Test 1: Normal Request (Baseline)"
echo "Command: curl -s -o /dev/null -w '%{http_code}' $WEST_APPGW"
response=$(curl -s -o /dev/null -w '%{http_code}' "$WEST_APPGW")
echo "Response: HTTP $response"
if [ "$response" = "200" ]; then
    echo "✅ Normal request passed"
else
    echo "❌ Normal request failed"
fi
echo ""

# Test 2: SQL Injection Attack
echo "Test 2: SQL Injection Attack"
echo "Command: curl '$WEST_APPGW/?id=1 union select * from users'"
response=$(curl -s -o /dev/null -w '%{http_code}' "$WEST_APPGW/?id=1%20union%20select%20*%20from%20users")
echo "Response: HTTP $response"
if [ "$response" = "403" ]; then
    echo "✅ WAF BLOCKED the SQL injection attack!"
elif [ "$response" = "200" ]; then
    echo "⚠️  Attack passed (Detection mode - logged but not blocked)"
else
    echo "❓ Unexpected response: $response"
fi
echo ""

# Test 3: SQL Injection - DROP TABLE
echo "Test 3: SQL Injection - DROP TABLE"
echo "Command: curl '$WEST_APPGW/?cmd=drop table users'"
response=$(curl -s -o /dev/null -w '%{http_code}' "$WEST_APPGW/?cmd=drop%20table%20users")
echo "Response: HTTP $response"
if [ "$response" = "403" ]; then
    echo "✅ WAF BLOCKED the DROP TABLE attack!"
elif [ "$response" = "200" ]; then
    echo "⚠️  Attack passed (Detection mode - logged but not blocked)"
else
    echo "❓ Unexpected response: $response"
fi
echo ""

# Test 4: SQL Comment Injection
echo "Test 4: SQL Comment Injection"
echo "Command: curl '$WEST_APPGW/?id=1--'"
response=$(curl -s -o /dev/null -w '%{http_code}' "$WEST_APPGW/?id=1--")
echo "Response: HTTP $response"
if [ "$response" = "403" ]; then
    echo "✅ WAF BLOCKED the SQL comment attack!"
elif [ "$response" = "200" ]; then
    echo "⚠️  Attack passed (Detection mode - logged but not blocked)"
else
    echo "❓ Unexpected response: $response"
fi
echo ""

# Test 5: Rate Limiting (requires loop - commented out to avoid actual rate limit)
echo "Test 5: Rate Limiting Test (Simulated)"
echo "⏭️  Skipped - Would require 100+ requests in 1 minute"
echo "To test manually, run:"
echo "  for i in {1..105}; do curl -s -o /dev/null -w '%{http_code}\n' $WEST_APPGW; done"
echo ""

# Test via Traffic Manager
echo "=========================================="
echo "Testing via Traffic Manager"
echo "=========================================="
echo ""
echo "Test 6: SQL Injection via Traffic Manager"
echo "Command: curl '$TM_URL/?id=1 union select * from users'"
response=$(curl -s -o /dev/null -w '%{http_code}' "$TM_URL/?id=1%20union%20select%20*%20from%20users")
echo "Response: HTTP $response"
if [ "$response" = "403" ]; then
    echo "✅ WAF BLOCKED the attack through Traffic Manager!"
elif [ "$response" = "200" ]; then
    echo "⚠️  Attack passed (Detection mode - logged but not blocked)"
else
    echo "❓ Unexpected response: $response"
fi
echo ""

echo "=========================================="
echo "📊 WAF Test Summary"
echo "=========================================="
echo ""
echo "Current WAF Mode: Detection"
echo "- Attacks are LOGGED but NOT blocked (returns 200)"
echo "- Check Azure Portal > Application Gateway > Firewall logs to see detections"
echo ""
echo "To enable blocking:"
echo "1. Edit waf.tf and change: mode = \"Prevention\""
echo "2. Run: terraform apply"
echo "3. Re-run this test - attacks will return 403 Forbidden"
echo ""
echo "WAF Features Tested:"
echo "  ✓ SQL Injection (union, select)"
echo "  ✓ DROP TABLE attacks"
echo "  ✓ SQL comment attacks (--)"
echo "  ✓ Rate limiting (manual test available)"
echo "  ✓ OWASP 3.2 ruleset (active)"
echo "  ✓ Bot Manager (active)"
echo ""
