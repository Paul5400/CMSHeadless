#!/bin/bash

BASE_URL="http://localhost:8055"
ADMIN_EMAIL="admin@example.com"
ADMIN_PASSWORD="password"

echo "Authentification..."
TOKEN=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\"}" | grep -o '"access_token": *"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Échec de l'authentification."
    exit 1
fi

echo "Token obtenu."

# Fonction pour créer une collection
create_collection() {
    local name=$1
    local fields=$2
    echo "Création de la collection: $name"
    curl -s -X POST "$BASE_URL/collections" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"collection\": \"$name\",
            \"schema\": {},
            \"fields\": $fields
        }" > /dev/null
}

# Fonction pour créer une relation
create_relation() {
    local collection=$1
    local field=$2
    local related=$3
    echo "Création de la relation: $collection.$field -> $related"
    curl -s -X POST "$BASE_URL/relations" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"collection\": \"$collection\",
            \"field\": \"$field\",
            \"related_collection\": \"$related\",
            \"schema\": {\"on_delete\": \"SET NULL\"}
        }" > /dev/null
}

# 1. Créations des collections
echo "Initialisation du modèle de données..."

SPECIALITE_FIELDS='[
    {"field": "id", "type": "integer", "schema": {"is_primary_key": true, "has_auto_increment": true}},
    {"field": "libelle", "type": "string"},
    {"field": "description", "type": "text"}
]'
create_collection "specialite" "$SPECIALITE_FIELDS"

STRUCTURE_FIELDS='[
    {"field": "id", "type": "uuid", "schema": {"is_primary_key": true}},
    {"field": "nom", "type": "string"},
    {"field": "adresse", "type": "text"},
    {"field": "ville", "type": "string"},
    {"field": "code_postal", "type": "string"},
    {"field": "telephone", "type": "string"}
]'
create_collection "structure" "$STRUCTURE_FIELDS"

PRATICIEN_FIELDS='[
    {"field": "id", "type": "uuid", "schema": {"is_primary_key": true}},
    {"field": "nom", "type": "string"},
    {"field": "prenom", "type": "string"},
    {"field": "ville", "type": "string"},
    {"field": "email", "type": "string"},
    {"field": "telephone", "type": "string"},
    {"field": "specialite_id", "type": "integer"},
    {"field": "structure_id", "type": "uuid"},
    {"field": "rpps_id", "type": "string"},
    {"field": "organisation", "type": "boolean"},
    {"field": "nouveau_patient", "type": "boolean"},
    {"field": "titre", "type": "string"}
]'
create_collection "praticien" "$PRATICIEN_FIELDS"

# 2. Création des relations
create_relation "praticien" "specialite_id" "specialite"
create_relation "praticien" "structure_id" "structure"

# 3. Import des données
echo "Import des données..."

# Spécialités
curl -s -X POST "$BASE_URL/items/specialite" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '[
        {"id": 1, "libelle": "médecine générale", "description": "Médecine Générale"},
        {"id": 3, "libelle": "pédiatrie", "description": "Maladies des enfants"},
        {"id": 4, "libelle": "ophtalmologie", "description": "Maladies des yeux"},
        {"id": 5, "libelle": "Dentiste", "description": "Bouche et dents"},
        {"id": 2, "libelle": "Imagerie médicale", "description": "radiologie, échographie, IRM"}
    ]' > /dev/null

# Structures
curl -s -X POST "$BASE_URL/items/structure" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '[
        {"id": "3444bdd2-8783-3aed-9a5e-4d298d2a2d7c", "nom": "Cabinet Bigot", "adresse": "63, rue de Mercier", "ville": "Paris", "code_postal": "75 002", "telephone": "01 02 03 04 05"},
        {"id": "e65145bb-ce57-4320-b0a8-6c0ba06def6d", "nom": "Radio Plus", "adresse": "1 rue de la santé", "ville": "Nancy", "code_postal": "54 000", "telephone": "03 43 56 65 54"}
    ]' > /dev/null

# Praticiens
curl -s -X POST "$BASE_URL/items/praticien" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '[
        {"id": "4305f5e9-be5a-4ccf-8792-7e07d7017363", "nom": "Radio Plus", "prenom": "Cabinet", "ville": "Nancy", "email": "radio.plus@sante.fr", "telephone": "03 43 56 65 54", "specialite_id": 2, "structure_id": "e65145bb-ce57-4320-b0a8-6c0ba06def6d", "titre": "Cab."},
        {"id": "af7bb2f1-cc52-3388-b9bc-c0b89e7f4c5b", "nom": "Paul", "prenom": "Marine", "ville": "Paris", "email": "Marine.Paul@hotmail.fr", "telephone": "02 36 11 25 88", "specialite_id": 1, "structure_id": "3444bdd2-8783-3aed-9a5e-4d298d2a2d7c", "rpps_id": "98537711172", "titre": "Dr."}
    ]' > /dev/null

echo "Setup terminé avec succès."
