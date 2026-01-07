#!/bin/bash

BASE_URL="http://localhost:8055"
EMAIL="admin@example.com"
PASSWORD="password"

# Login
TOKEN=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}" | grep -o '"access_token": *"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Login failed."
    exit 1
fi

echo "Token obtained."

echo -e "\n1. Liste des praticiens:"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/items/praticien" | jq .

echo -e "\n2. Spécialité d'ID 2:"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/items/specialite/2" | jq .

echo -e "\n3. Spécialité d'ID 2 (libellé uniquement):"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/items/specialite/2?fields=libelle" | jq .

echo -e "\n4. Praticien avec sa spécialité (libellé):"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/items/praticien?fields=*,specialite_id.libelle" | jq .

echo -e "\n5. Structure et liste des praticiens (nom, prenom):"
# Note: Requires correct aliasing or filter. We check if structure->praticien works. 
# Usually Directus adds the reverse alias if we configured it correctly, or we use deep search.
# If O2M alias 'praticiens' exists on structure:
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/items/structure?fields=*,praticiens.nom,praticiens.prenom" | jq .
# If 'praticiens' alias does not exist, this might fail or return null. 
# Attempting alternative via 'praticien' endpoint if needed, but the request implies querying structure.
# Let's assume for now we might need to manually ensure the alias exists or accept the limitation.

echo -e "\n6. Structure et liste des praticiens avec spécialité:"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/items/structure?fields=*,praticiens.nom,praticiens.prenom,praticiens.specialite_id.libelle" | jq .

echo -e "\n7. Structures dont la ville contient 'sur' avec praticiens:"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/items/structure?filter[ville][_contains]=sur&fields=*,praticiens.nom,praticiens.prenom,praticiens.specialite_id.*" | jq .
