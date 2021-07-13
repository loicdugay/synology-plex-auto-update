# Auto-Update your Plex Media Server on your DMS 7 Synology NAS [French Edition]

## Description
Maintenez automatiquement votre serveur Plex à jour sur votre NAS Synology DSM 7 uniquement.

## Remerciements
Ce script est basé sur les travaux de [mj0nsplex](https://forums.plex.tv/u/j0nsplex), [martinorob](https://github.com/martinorob/plexupdate) et de [michealespinola](https://github.com/michealespinola/syno.plexupdate). J'ai traduit et modifié leurs scripts pour mettre à jour automatiquement Plex sur DSM 7. Dans un futur proche je ferai certainement un fork du script de [michealespinola](https://github.com/michealespinola/syno.plexupdate) pour le rendre multi-version de DSM.

## Pré-requis
1. Préparer un emplacement sur le NAS où stocker le fichier du script.

## Utilisation
1. Télécharger le script sur votre ordinateur.

1. Déposer votre script à l'emplacement que vous aurez précédemment défini sur votre NAS.

1. Ouvrir ```Planificateur de tâches``` via le ```Panneau de configuration``` *(uniquement visible en mode avancé)*.

1. Cliquer sur ```Créer``` > ```Tâche planifiée``` > ```Script défini par l'utilisateur```

1. Dans l'onglet ```Général```, nommer votre tâche et définissez l'utilisateur sur ```root```.

1. Dans l'onglet ```Programmer```, choissisez la fréquence d'éxécution de votre tâche.

1. Dans l'onglet ```Paramètres de tâche```, coller le code suivant ```bash /*SCRIPT_EMPLACEMENT*/plex_update.sh```.

1. Remplacer ```*SCRIPT_EMPLACEMENT*``` par l'emplacement de votre script sur votre NAS et cliquer sur OK.

1. Si vous souhaitez recevoir des courriels à chaque execution du script, cochez la case ```Envoyer les détails d'exécution par e-mail```.

1. Enjoy !
