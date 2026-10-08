# Task Manager

Application en ligne de commande (CLI) développée en Dart permettant de gérer une liste de tâches avec sauvegarde persistante au format JSON.

## 📌 Présentation

Task Manager est une application CLI développée dans le cadre d'un projet de certification Dart.

L'application permet de :

- créer des tâches ;
- définir une priorité (low, medium ou high) ;
- définir une date limite facultative ;
- créer des tâches urgentes ;
- afficher les tâches ;
- marquer une tâche comme terminée ;
- supprimer une tâche ;
- trier les tâches par priorité ;
- trier les tâches par date ;
- sauvegarder les tâches dans un fichier JSON ;
- recharger automatiquement les tâches au démarrage.

## ✨ Fonctionnalités

### Ajouter une tâche

Une tâche peut contenir :

- un identifiant unique ;
- un titre ;
- une priorité ;
- une date limite facultative ;
- un statut indiquant si elle est terminée ou non.

### Tâches urgentes

Les tâches urgentes sont représentées par la classe `UrgentTask`, qui hérite de la classe abstraite `Task`.

Une tâche urgente utilise automatiquement la priorité `high` depuis l'interface CLI.

### Tri

Les tâches peuvent être triées :

- par priorité ;
- par date limite.

### Persistance

Les données sont sauvegardées localement dans :

```text
data/tasks.json