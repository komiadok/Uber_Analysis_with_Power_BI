# 🚘 Uber Trips Analysis – USA

## 🎯 Objectifs

Ce projet vise à exploiter les données des trajets Uber aux États-Unis afin de fournir des analyses décisionnelles claires à l’aide de Power BI. 
L’objectif principal est d’identifier des tendances clés (réservations, revenus, distances, comportements horaires) et de produire des rapports interactifs pour soutenir les prises de décisions stratégiques.

Nous allons créer trois rapports : 
* **Overview Analysis** qui présente un aperçu global des données
* **Time Analysis** qui présente una analyse temporelle approfondie 
* **Details** qui donne le détail des données dans une table

Les étapes du projet incluent : 

* 📦 Chargement et stockage des données brutes dans Microsoft SQL Server
* 🧾 Pré-analyse via SQL pour explorer les tendances initiales
* 🔄 Import et transformation des données avec Power Query dans Power BI
* 🧠 Modélisation sémantique en étoile avec relations optimisées
* 📐 Création de mesures DAX dynamiques pour les indicateurs clés
* 📊 Construction de rapports interactifs et visuellement engageants

---

## 🧰 Technologies utilisées

* Microst SQL Server : stockage des données relationnelles et analyses préliminaires via requêtes SQL
* Power BI Desktop : visualisation des données, modélisation sémantique et création de rapports interactifs
* SQL : requêtage des données dans MS SQL server
* DAX : création de mesures dynamiques, et indicateurs personnalisés dans Power BI

---

## 📦 Données 

**Table - Trip Details**

| Colonnes           | Type      | Description                               |
|--------------------|-----------|-------------------------------------------|
| `Trip ID`          | Numérique | identifiant de chaque trajet Uber         |
| `Pickup Time`      | Date      | date et heure de prise en charge          |
| `Drop Off Time `   | Date      | date et heure de dépose                   |
| `Passenger Count ` | Numérique | nombre de passagers dans le trajet        |
| `Trip Distance`    | Numérique | distance parcourue                        |
| `PULocationID`     | Numérique | code indiquant le lieu de prise en charge |
| `DOLocationID`     | Numérique | code indiquant le lieu de dépose          |
| `Payment Type`     | Texte     | mode de paiement utilisé                  |
| `Fare Amount`      | Numérique | tarif de base facturé pour le trajet      |
| `Surge Fee`        | Numérique | supplément appliqué au trajet             |
| `Vehicle`          | Texte     | Type de service Uber utilisé              |

**Table - Location**

| Colonnes     | Type      | Description                                        |
|--------------|-----------|----------------------------------------------------|
| `LocationID` | Numérique | identifiant de chaque lieu                         |
| `Location`   | Texte     | nom de la zone ou du quartier où se trouve le lieu |
| `City`       | Texte     | ville dans laquelle se trouve le lieu              |

---

## 📈 Indicateurs clés (KPI)

1. 🧾 Nombre total des réservations (`Total Bookings`)
2. 💰 Coût total des réservations (`Total Booking Value`)
3. 💸 Coût moyen d'une réservation (`Average Booking Value`)
4. 📏 Distance totale de course (`Total Trip Distance`)
5. 📊 Distance moyenne de course (`Average Trip Distance`)
6. ⏱️ Durée moyenne d'un trajet (`Average Trip Time`)

### 🌍 Analyse de la localisation

1. 📍 Point de départ le plus fréquent (`Most Frequent Pickup Point`)
2. 📌 Point de dépose le plus fréquent (`Most Frequent Dropoff Point`)
3. 🛣️ Trajet le plus long (`Farthest Trip`)

---

## 📊 Visualisations

1. Graphique en anneau
    * Nombre total de réservations par type de paiement
    * Nombre total de réservations par type de course (jour/nuit)
    * Coût total des réservations par type de paiement
    * Coût total des réservations par type de course (jour/nuit)
    * Distance totale de course par type de paiement
    * Distance totale de course par type de course (jour/nuit)
2. Graphique en aires
   * Nombre total de réservations par jour du mois
   * Distance totale parcourue par intervalle de 10 minutes
3. Graphique à barres empilées
   * TOP 5 des lieux de réservation
   * TOP 5 des véhicules préférés pour la prise en charge
4. Graphique en courbes
   * Distance totale parcourue par jour de la semaine

### 📋 Les tableaux 

**Matrice**

1. Analyse sur les véhicules
   * Veleurs : `Total Bookings`, `Total Booking Value`, `Average Booking Value`, `Total Trip Distance`
   * Ligne : `Vehicle`
2. Nombre total de réservations par temps et par jour
   * Valeur : `Total Bookings`
   * Colonne : `Pickup Day Name` (colonne à créer à partir de `Pickup Time`)
   * Ligne : `Pickup Hour` (colonne à créer à partir de `Pickup Time`)
3. Coût total des réservations par temps et par jour
   * Valeur : `Total Booking Value`
   * Colonne : `Pickup Day Name` (colonne à créer à partir de `Pickup Time`)
   * Ligne : `Pickup Hour` (colonne à créer à partir de `Pickup Time`)
4. Distance totale de course par temps et par jour
   * Valeur : `Total Trip Distance`
   * Colonne : `Pickup Day Name` (colonne à créer à partir de `Pickup Time`)
   * Ligne : `Pickup Hour` (colonne à créer à partir de `Pickup Time`)

**Table** (Table de détails pour Drill Through)

  * Colonnes
    * `Trip ID`
    * `Pickup Date` (colonne à créer à partir de `Pickup Time`)
    * `Pickup Hour`
    * `Vehicle`
    * `Payment Type`
    * `Number of passengers` (colonne `Passenger Count` renommée)
    * `Trip Distance` (mesure `Total Trip Distance` renommée)
    * `Booking Value` (mesure `Total Booking Value` renommée)
    * `Pickup Location` (colonne `Location` de la table **Location**)
    * `Total Bookings`
  * Garder tous les filtres
    * `Total Bookings`
    * `Total Booking Value`
    * `Total Trip Distance`

---

## 🎚️ Les bputons, signets et les filtres

### 🔘 Les boutons

* Ajouter un navigateur de pages
* Ajouter un bouton Home sur la page d'accueil
* Ajouter un bouton d'informations sur les données sur la page d'accueil 
* Ajouter un bouton de reset sur la page d'accueil pour effacer tous les filtres
* Ajouter un bouton de reset sur le rapport **Details** pour effacer les drill through

### 🔍 Les filtres

* Ajouter un filtre sur les villes  `City` de la table **Location**
* Ajouter un filtre sur les dates `Date` de la table **Calendar Table**

### 🔖 Les signets

* Ajouter un signet **Show All Unfiltered Data** pour le bouton de reset du rapport **Details**
* Ajouter un signet **Show All Data Fields Information** pour le bouton d'informations de la page d'accueil
* Ajouter un signet **Overview Dashboard** pour le bouton Home de la page d'accueil


