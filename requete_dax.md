# 📘 DAX Power BI

## 🔎 Contexte

Ce fichier regroupe les **mesures DAX**, **colonnes calculées** et **tables créées** dans le modèle Power BI dédié à l’analyse des courses Uber.

## 📐 Les mesures 

### Mesures principales

* **Total Bookings** 

    ```Total Bookings = COUNTA('Trip Details'[Trip ID])```

* **Total Booking Value**

    ```
    Total Booking Value = SUM('Trip Details'[fare_amount]) + SUM('Trip Details'[Surge Fee])
    ```

* **Average Booking Value**

    ```Average Booking Value = DIVIDE([Total Booking Value], [Total Bookings], BLANK())```

* **Total Trip Distance**

    ```Total Trip Distance = SUM('Trip Details'[trip_distance])```

    * **Variante formatée en "K miles" :**

        ``` 
        Total Trip Distance = 
        VAR TotalMiles = SUM('Trip Details'[trip_distance]) / 1000
        RETURN CONCATENATE(FORMAT(TotalMiles, "0"), "K miles")
        ```

* **Average Trip Distance**

    ```
    Average Trip Distance = 
    VAR AvgMiles = ROUND(AVERAGE('Trip Details'[trip_distance]), 0)
    RETURN CONCATENATE(AvgMiles, " miles")
    ```

* **Average Trip Time**

    ```
    Average Trip Time = 
    VAR AvgTripTime = AVERAGEX('Trip Details', DATEDIFF('Trip Details'[Pickup Time], 'Trip Details'[Drop Off Time], MINUTE))
    RETURN CONCATENATE(FORMAT(AvgTripTime, "0"), " min")
    ```

### 📍 Analyses géographiques

* **Most Frequent Pickup Point**

    ```
    Most Frequent Pickup Point = 
    VAR PickPoint = TOPN(1, 
                            SUMMARIZE(
                                'Trip Details',
                                'Location Table'[Location], 
                                "Pickup Point", 
                                COUNT('Trip Details'[Trip ID])
                            ), 
                        [Pickup Point], 
                        DESC
                        )
    RETURN CONCATENATEX(PickPoint, 'Location Table'[Location], ", ")
    ```

* **Most Frequent Dropoff Point**

    ```
    Most Frequent Dropoff Point = 
    VAR DropOffCounts = 
        ADDCOLUMNS(
            SUMMARIZE(
                'Trip Details',
                'Location Table'[Location]
            ),
            "DropOffCount",
            CALCULATE(
                COUNT('Trip Details'[Trip ID]),
                USERELATIONSHIP('Trip Details'[DOLocationID], 'Location Table'[LocationID])
            )
        )

    VAR RankedDropoffs = 
        ADDCOLUMNS(
            DropOffCounts,
            "Rank",
            RANKX(DropOffCounts, [DropOffCount],, DESC, DENSE)
        )

    VAR TopDropoff = 
        FILTER(RankedDropoffs, [Rank] = 1)

    RETURN CONCATENATEX(TopDropoff, 'Location Table'[Location], ", ")
    ```

* **Farthest Trip**

    ```
    Farthest Trip = 
    VAR MaxDistance = MAX('Trip Details'[trip_distance])

    VAR PickupLocation = 
        LOOKUPVALUE(
            'Location Table'[Location],
            'Location Table'[LocationID],
            CALCULATE(
                SELECTEDVALUE('Trip Details'[PULocationID]),
                'Trip Details'[trip_distance] = MaxDistance
            )
        )

    VAR DropoffLocation = 
        LOOKUPVALUE(
            'Location Table'[Location],
            'Location Table'[LocationID],
            CALCULATE(
                SELECTEDVALUE('Trip Details'[DOLocationID]),
                'Trip Details'[trip_distance] = MaxDistance
            )
        )

    RETURN
        "Pickup: " & PickupLocation & " -> Dropoff: " & DropoffLocation & " (" & FORMAT(MaxDistance, "0.0") & " miles)"
    ```

### 🏷️ Les titres

* **Title for Grid**

    ```Title for Grid = "Vehicle Type Analysis"```

* **Title for Location**

    ```Title for Location = "Location Analysis"```

* **Title for by Pickup Time**

    ```
    Title for by Pickup Time = SELECTEDVALUE('Dynamic Measure'[Dynamic Title]) & " by Pickup Time"
    ```

* **Title for by Hour & Day**

    ``` 
    Title for by Hour & Day = SELECTEDVALUE('Dynamic Measure'[Dynamic Title]) & " by Hour & Day"
    ```

* **Title for by Day Name**

    ``` 
    Title for by Day Name = SELECTEDVALUE('Dynamic Measure'[Dynamic Title]) & " by Day Name"
    ```

## 📊 Les tables

* **Date**

    ```
    Calendar Table = CALENDAR(MIN('Trip Details'[Pickup Date]), MAX('Trip Details'[Pickup Date]))
    ```

* **Dynamic Measure**

    ```
    Dynamic Measure = {
        ("Total Bookings", NAMEOF('Calendar Table'[Total Bookings]), 0),
        ("Total Booking Value", NAMEOF('Calendar Table'[Total Booking Value]), 1),
        ("Total Trip Distance", NAMEOF('Calendar Table'[Total Trip Distance Bis]), 2)
    }
    ```

### 🧮 Les colonnes calculées

* **Day Name**

    ```Day Name = FORMAT('Calendar Table'[Date], "ddd")```

* **Day Num**

    ```Day Num = WEEKDAY('Calendar Table'[Date],2)```

* **Dynamic Title**

    ```
    Dynamic Title = 
        IF('Dynamic Measure'[Dynamic Measure Order] = 0, "Total Bookings",
        IF('Dynamic Measure'[Dynamic Measure Order] = 1, "Total Booking Value",
        IF('Dynamic Measure'[Dynamic Measure Order] = 2, "Total Trip Distance",
            "Other"
        )
        )
        )
    ```

* **Pickup Date**

    ```
    Pickup Date = DATE(YEAR('Trip Details'[Pickup Time]), MONTH('Trip Details'[Pickup Time]), DAY('Trip Details'[Pickup Time]))
    ```

* **Trip (Day/Night)**

    ```
    Trip (Day/Night) = 
    VAR HourOfDay = HOUR('Trip Details'[Pickup Time])
    RETURN 
        IF(HourOfDay >= 17 || HourOfDay < 6, "Night Trip", "Day Trip")
    ```
* **Pickup Hour (HH MM SS)**

    ```
    Pickup Hour (HH MM SS) = TIME(HOUR('Trip Details'[Pickup Time]), MINUTE('Trip Details'[Pickup Time]), SECOND('Trip Details'[Pickup Time] ))
    ```

* **Pickup Hour**

```
Pickup Hour = HOUR('Trip Details'[Pickup Time])
```

## Info-bulles pour les boutons

* **Bouton Home :**  Ctrl + click to view Overview Dashboard
* **Bouton information :** Ctrl + click to view the Details of Raw Data

### Details of Raw Data

**Table - Trip Details**

La table *Trip Details* contient des informations sur chaque trajet Uber, incluant l’heure du trajet, la distance, les détails tarifaires, et le type de véhicule. Elle aide à analyser les tendances de trajets, les heures de pointe, et les revenus.

* **Trip ID :** identifiant unique attribué à chaque trajet Uber. Cela permet de suivre chaque trajet individuellement.
* **Pickup Time :** date et heure exactes de la prise en charge du passager. Utile pour analyser les tendances de trajets, les heures de pointe et la durée totale des trajets.
* **Drop Off Time :** date et l’heure exactes de la dépose du passager. Utilisée pour calculer la durée des trajets et analyser les tendances d’achèvement des trajets.
* **Passenger Count :** nombre de passagers dans le trajet. Permet de comprendre les modèles de covoiturage et la demande pour différents types de véhicules.
* **Trip Distance :** distance parcourue pendant le trajet, généralement en miles. Utilisée pour le calcul tarifaire, l’analyse d’efficacité et l’identification des trajets courts ou longs.
* **PULocationID (Pickup Location ID) :** code numérique représentant le lieu de prise en charge. Relié à une table de localisation pour obtenir le nom réel de la zone de départ.
* **DOLocationID (Drop Off Location ID) :** code numérique représentant le lieu de dépose. Utilisé pour l’analyse de destination, les modèles de trajets et la prévision de la demande.
* **Payment Type :** mode de paiement utilisé pour le trajet (ex. : carte de crédit, espèces, portefeuille). Aide à l’analyse financière et à comprendre les préférences des clients.
* **Fare Amount :** tarif de base facturé pour le trajet avant tout frais supplémentaires. Essentiel pour l’analyse des revenus et la stratégie de tarification.
* **Surge Fee :** supplément appliqué pendant les périodes de forte demande. Permet de comprendre les modèles de tarification dynamique et la demande pendant les heures de pointe.
* **Vehicle :** type de service Uber utilisé (ex. : UberX, UberXL, Uber Black). Utilisé pour analyser la demande par type de véhicule et les préférences des clients.

**Table - Location**

La table *Location* contient un LocationID pour chaque zone, associé au nom du lieu et sa ville correspondante. Cette table aide à analyser les modèles de trajets en identifiant les lieux de prise en charge et de dépose les plus fréquents. Elle permet aussi d’obtenir des informations géographiques et de suivre les tendances de la demande de trajets.

* **LocationID :** identifiant unique pour chaque lieu dans l’ensemble de données. Sert de clé pour relier les lieux aux trajets.
* **Location :** nom de la zone ou du quartier où ont lieu les prises en charge et les déposes.
* **City :** ville dans laquelle se trouve le lieu, utile pour la segmentation géographique et l’analyse.