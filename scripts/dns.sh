#!/bin/bash
# Cloudflare DNS management — standalone, no marina dependency
set -euo pipefail

# Load CF_TOKEN from environment or .env file in current directory
if [[ -z "${CF_TOKEN:-}" ]] && [[ -f .env ]]; then
    source .env
fi

if [[ -z "${CF_TOKEN:-}" ]]; then
    echo "CF_TOKEN not set. Set it in environment or in a .env file." >&2
    exit 1
fi

API="https://api.cloudflare.com/client/v4"

cf_curl() {
    curl -s "$@" \
        -H "Authorization: Bearer ${CF_TOKEN}" \
        -H "Content-Type: application/json"
}

cmd="${1:-help}"
shift || true

case "$cmd" in
    list-zones)
        cf_curl -X GET "$API/zones" | \
            jq -r '.result[] | "\(.id) \(.name) \(.status)"'
        ;;
    zone-id)
        zone="${1:?Usage: dns.sh zone-id <domain>}"
        cf_curl -X GET "$API/zones?name=${zone}&status=active" | \
            jq -r '.result[0] | .id'
        ;;
    list)
        zone="${1:?Usage: dns.sh list <domain>}"
        zone_id=$(cf_curl -X GET "$API/zones?name=${zone}&status=active" | jq -r '.result[0] | .id')
        if [[ "$zone_id" == "null" ]] || [[ -z "$zone_id" ]]; then
            echo "Zone $zone not found" >&2
            exit 1
        fi
        cf_curl -X GET "$API/zones/${zone_id}/dns_records" | \
            jq -r '.result[] | "\(.id) \(.type) \(.name) \(.content)"'
        ;;
    add)
        name="${1:?Usage: dns.sh add <fqdn> <ip>}"
        ip="${2:?Usage: dns.sh add <fqdn> <ip>}"
        # Extract zone from fqdn (last two parts)
        zone=$(echo "$name" | awk -F. '{print $(NF-1)"."$NF}')
        zone_id=$(cf_curl -X GET "$API/zones?name=${zone}&status=active" | jq -r '.result[0] | .id')
        if [[ "$zone_id" == "null" ]] || [[ -z "$zone_id" ]]; then
            echo "Zone $zone not found" >&2
            exit 1
        fi
        # Check if record already exists
        record_id=$(cf_curl -X GET "$API/zones/${zone_id}/dns_records?name=${name}" | \
            jq -r '.result[0] | .id')
        payload=$(jq -n --arg name "$name" --arg ip "$ip" \
            '{type: "A", name: $name, content: $ip, ttl: 1, proxied: false}')
        if [[ "$record_id" == "null" ]] || [[ -z "$record_id" ]]; then
            echo "Creating $name -> $ip"
            cf_curl -X POST "$API/zones/${zone_id}/dns_records" -d "$payload" | jq
        else
            echo "Updating $name -> $ip (record $record_id)"
            cf_curl -X PUT "$API/zones/${zone_id}/dns_records/${record_id}" -d "$payload" | jq
        fi
        ;;
    rm)
        name="${1:?Usage: dns.sh rm <fqdn>}"
        zone=$(echo "$name" | awk -F. '{print $(NF-1)"."$NF}')
        zone_id=$(cf_curl -X GET "$API/zones?name=${zone}&status=active" | jq -r '.result[0] | .id')
        if [[ "$zone_id" == "null" ]] || [[ -z "$zone_id" ]]; then
            echo "Zone $zone not found" >&2
            exit 1
        fi
        record_id=$(cf_curl -X GET "$API/zones/${zone_id}/dns_records?name=${name}" | \
            jq -r '.result[0] | .id')
        if [[ "$record_id" == "null" ]] || [[ -z "$record_id" ]]; then
            echo "$name doesn't exist" >&2
            exit 1
        fi
        echo "Deleting $name (record $record_id)"
        cf_curl -X DELETE "$API/zones/${zone_id}/dns_records/${record_id}" | jq
        ;;
    help)
        echo "Usage: dns.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  list-zones            List all Cloudflare zones"
        echo "  zone-id <domain>      Get zone ID for a domain"
        echo "  list <domain>         List all DNS records in a zone"
        echo "  add <fqdn> <ip>       Create/update an A record"
        echo "  rm <fqdn>             Delete a DNS record"
        echo ""
        echo "Environment:"
        echo "  CF_TOKEN    Cloudflare API token (required)"
        ;;
    *)
        echo "Unknown command: $cmd" >&2
        exit 1
        ;;
esac
