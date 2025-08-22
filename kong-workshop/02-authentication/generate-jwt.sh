#!/bin/bash

# Script para gerar JWT token para demonstração

echo "🔐 Gerando JWT Token para demonstração"
echo "====================================="

# JWT Header
header='{"alg":"HS256","typ":"JWT"}'
header_b64=$(echo -n "$header" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# JWT Payload
payload='{
  "iss": "jwt-issuer-key",
  "sub": "jwt-user", 
  "aud": "kong-api",
  "exp": '$(( $(date +%s) + 3600 ))',
  "iat": '$(date +%s)',
  "nbf": '$(date +%s)'
}'
payload_b64=$(echo -n "$payload" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# JWT Signature
secret="my-jwt-secret-key"
signature_input="$header_b64.$payload_b64"

# Usando openssl para gerar assinatura HMAC SHA256
signature=$(echo -n "$signature_input" | openssl dgst -sha256 -hmac "$secret" -binary | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# JWT completo
jwt_token="$header_b64.$payload_b64.$signature"

echo ""
echo "JWT Token gerado:"
echo "=================="
echo "$jwt_token"
echo ""
echo "Para usar:"
echo "curl -H \"Authorization: Bearer $jwt_token\" http://localhost:8000/jwt/posts"
echo ""
echo "Payload decodificado:"
echo "===================="
echo "$payload" | jq
