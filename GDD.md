# Factory Tycoon — Game Design Document (v0.1)

## 1. Pitch

Factory Tycoon est un jeu de gestion/simulation 2D en vue du dessus, dans lequel le
joueur dirige une usine : production, ressources humaines, commercial/clients,
R&D, maintenance des machines, approvisionnement/export et finances. Simulation
en temps réel avec pause, façon Factorio/RimWorld.

## 2. Piliers de design

- **Simulation d'entreprise complète** : la production n'est qu'un système parmi
  d'autres — RH, ventes, R&D, finance ont tous un poids réel sur la réussite.
- **Complexité progressive** : facile à prendre en main, profond à maîtriser.
- **Choix stratégiques structurants** : secteur d'activité, politique RH, mix
  commercial (contrats vs marché), priorités R&D.

## 3. Boucle de jeu

Temps réel avec pause et vitesses de simulation (x1/x2/x3), à la Factorio/RimWorld.
Le joueur peut à tout moment mettre en pause pour planifier (placement de
machines, recrutement, contrats) sans pression temporelle.

Boucle macro : **Produire → Vendre (contrats + marché) → Encaisser → Réinvestir
(RH / R&D / machines / expansion)**.

## 4. Secteurs d'activité

Au démarrage d'une partie, le joueur choisit un secteur (ex. électronique,
agroalimentaire, textile...). Chaque secteur définit ses propres ressources,
recettes de production et débouchés commerciaux. Objectif : rejouabilité et
identité par partie, sans multiplier le travail d'équilibrage dès la V1 (un
secteur complet d'abord, structure générique pour en ajouter d'autres ensuite).

## 5. Systèmes

### 5.1 Production & Usine
- Vue du dessus, placement de machines sur une grille.
- Pas de convoyeurs : le transport de matière entre machines/stocks est assuré
  par des **employés ou robots transporteurs** assignés à cette tâche.
- Chaque machine transforme des intrants en extrants selon une recette (temps,
  quantité, qualité).

### 5.2 Ressources humaines
Profondeur intermédiaire/avancée : recrutement, compétences par poste,
formation/progression, salaire, moral/satisfaction influençant productivité et
turnover. Postes prévus : opérateurs machine, transporteurs, commerciaux,
chercheurs, techniciens de maintenance.

### 5.3 Commercial / Ventes / Clients
Système hybride :
- **Contrats** : clients passent des commandes (quantité, délai, prix) ; les
  honorer ou non affecte la réputation et les revenus futurs.
- **Marché dynamique** : prix fluctuant selon offre/demande, pour écouler le
  surplus de production. Les commerciaux (employés) influencent la portée et
  l'efficacité commerciale.

### 5.4 R&D
Double niveau :
- **Arbre technologique global** : débloque nouvelles machines, capacités,
  secteurs/extensions.
- **R&D produit** : améliore qualité/coût/vitesse d'une recette existante ou
  crée des variantes.

### 5.5 Maintenance des machines
Usure progressive avec l'usage → risque de panne aléatoire croissant.
Entretien préventif programmable pour réduire ce risque ; réparation en cas de
panne (coût + immobilisation de la machine).

### 5.6 Approvisionnement / Import-Export
Version simplifiée en V1 :
- Fournisseurs pour les matières premières (prix, qualité, délai/fiabilité).
- Possibilité de vendre à l'export en plus du marché local.
- Pas de simulation économique internationale complète (taux de change,
  douanes détaillées) pour l'instant — à enrichir plus tard si pertinent.

### 5.7 Finances / Budget
Trésorerie, charges (salaires, entretien, achats de matières), revenus
(contrats, marché, export), emprunts/investissements. Tableau de bord central
reliant tous les autres systèmes.

## 6. Ordre de construction interne

Tous les systèmes sont prévus dès la V1, mais pour éviter de tout bloquer en
même temps, l'ordre d'implémentation technique suit ces fondations :

1. **Socle** : grille/placement, boucle temps réel + pause, budget de base.
2. **Production** : machines, recettes, transporteurs (employés/robots).
3. **RH** : recrutement, salaires, compétences/moral.
4. **Commercial** : contrats + marché.
5. **R&D** : arbre tech + R&D produit.
6. **Maintenance** : usure, pannes, entretien.
7. **Approvisionnement/Export** : fournisseurs + vente export simplifiée.
8. **Polish, secteurs additionnels, équilibrage.**

Chaque étape doit laisser le jeu dans un état jouable (vertical slice), pas
juste un système isolé.

## 7. Stack technique

- **Moteur** : Godot 4.7 (GDScript).
- **Diffusion visée** : version personnelle → démo sur itch.io → sortie Steam.
- **Localisation** : bilingue FR/EN dès le départ via le système de traduction
  de Godot (CSV).

## 8. Direction artistique

Style final **pixel art**. Développement démarré avec des **placeholders
géométriques** (formes/couleurs simples) pour prototyper le gameplay sans
attendre les assets définitifs.

## 9. Portée hors-scope pour l'instant

- Multijoueur.
- Simulation individuelle poussée des employés (carrière détaillée, syndicats).
- Marché international complet avec douanes/taux de change.

Ces pistes restent envisageables plus tard si le cœur de jeu fonctionne bien.
