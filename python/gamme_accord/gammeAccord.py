# Liste des notes en français avec altérations
NOTES_FR = ['Do', 'Do#', 'Ré', 'Ré#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si']

def note_suivante(note, demi_tons):
    """Retourne la note située `demi_tons` demi-tons au-dessus de `note`."""
    index = NOTES_FR.index(note)
    return NOTES_FR[(index + demi_tons) % 12]

def intervalle_en_tons(fondamentale, note):
    """Calcule l'intervalle en tons entre deux notes."""
    index_fondamentale = NOTES_FR.index(fondamentale)
    index_note = NOTES_FR.index(note)
    demi_tons = (index_note - index_fondamentale) % 12
    return demi_tons / 2  # Convertir en tons

def construire_gamme(tonique, type_gamme):
    """Construit la gamme majeure ou mineure naturelle à partir de la tonique."""
    gamme = [tonique]
    if type_gamme == "majeur":
        intervalles = [2, 2, 1, 2, 2, 2, 1]  # Intervalles pour une gamme majeure
    elif type_gamme == "mineur":
        intervalles = [2, 1, 2, 2, 1, 2, 2]  # Intervalles pour une gamme mineure naturelle
    else:
        raise ValueError("Type de gamme invalide. Utilisez 'majeur' ou 'mineur'.")

    note_courante = tonique
    for intervalle in intervalles:
        note_courante = note_suivante(note_courante, intervalle)
        gamme.append(note_courante)

    return gamme

def construire_accords(gamme):
    """Construit les accords (triades) pour chaque degré de la gamme."""
    accords = []
    for degré in range(7):  # De 0 à 6 (I à VII)
        fondamentale = gamme[degré]
        tierce_index = (degré + 2) % 7
        tierce = gamme[tierce_index]
        quinte_index = (tierce_index + 2) % 7
        quinte = gamme[quinte_index]

        # Déterminer le type de tierce
        intervalle_tierce = intervalle_en_tons(fondamentale, tierce)
        type_tierce = "majeure" if intervalle_tierce == 2 else "mineure"

        # Déterminer le type de quinte
        intervalle_quinte = intervalle_en_tons(fondamentale, quinte)
        type_quinte = "juste" if intervalle_quinte == 3.5 else "diminuée"

        # Déterminer le type d'accord
        if type_tierce == "majeure" and type_quinte == "juste":
            type_accord = "majeur"
        elif type_tierce == "mineure" and type_quinte == "juste":
            type_accord = "mineur"
        else:  # type_tierce == "mineure" et type_quinte == "diminuée"
            type_accord = "diminué"

        accords.append({
            "degré": degré + 1,
            "fondamentale": fondamentale,
            "tierce": tierce,
            "type_tierce": type_tierce,
            "quinte": quinte,
            "type_quinte": type_quinte,
            "accord": f"{fondamentale}-{tierce}-{quinte}",
            "type_accord": type_accord
        })
    return accords

def afficher_gamme(gamme):
    """Affiche les notes de la gamme en français."""
    print("\nNotes de la gamme :")
    print(" – ".join(gamme))

def afficher_accords(accords):
    """Affiche les accords avec détails sur les intervalles et le type d'accord."""
    print("\nAccords de la gamme :")
    print("Degré | Fondamentale | Tierce (type)   | Quinte (type)  | Accord          | Type d'accord")
    print("------|---------------|-----------------|----------------|-----------------|---------------")
    for accord in accords:
        print(f"  {accord['degré']}  |      {accord['fondamentale']}      |   {accord['tierce']} ({accord['type_tierce']})   |   {accord['quinte']} ({accord['type_quinte']})   |  {accord['accord']}  |    {accord['type_accord']}    ")

# Demander à l'utilisateur la tonique et le type de gamme
tonique = input("Entrez la note de départ (ex. : Do, Ré#, Si♭) : ").capitalize()
type_gamme = input("Entrez le type de gamme (majeur/mineur) : ").lower()

# Construire la gamme et les accords
gamme = construire_gamme(tonique, type_gamme)
accords = construire_accords(gamme)

# Afficher les résultats
afficher_gamme(gamme)
afficher_accords(accords)
