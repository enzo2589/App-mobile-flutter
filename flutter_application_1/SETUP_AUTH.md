# Configuration de l'authentification - Guide d'installation

## 📋 Étapes à suivre

### 1. **Exécuter le SQL dans Supabase**

1. Allez sur votre dashboard Supabase
2. Navigez vers **SQL Editor**
3. Créez une nouvelle requête
4. Copiez tout le contenu du fichier `DATABASE_SETUP.sql`
5. Exécutez la requête

Cela va créer:
- ✅ Table `users` - Stocke les informations des utilisateurs
- ✅ Table `note` - Stocke les notes/tâches des utilisateurs
- ✅ Politiques RLS - Sécurité au niveau des lignes

### 2. **Activer l'authentification par email dans Supabase**

1. Allez à **Authentication > Providers**
2. Assurez-vous que **Email** est activé
3. Configurez les emails de confirmation si nécessaire

### 3. **Fichiers créés/modifiés**

- **`lib/pages/login_page.dart`** - Nouvelle page de login avec inscription
- **`lib/main.dart`** - Modifié pour ajouter l'authentification et le routing
- **`DATABASE_SETUP.sql`** - Script SQL pour la base de données

## 🔐 Fonctionnalités

### Page de Login
- ✅ Connexion avec email/mot de passe
- ✅ Inscription de nouveaux utilisateurs
- ✅ Gestion des erreurs
- ✅ Interface moderne avec gradient

### Page d'accueil (Notes)
- ✅ Affichage des notes de l'utilisateur connecté
- ✅ Ajout de notes
- ✅ Modification de notes
- ✅ Suppression de notes
- ✅ Bouton de déconnexion

## 📊 Structure des tables

### Table `users`
```
id          : UUID (clé primaire, correspond à auth.user.id)
email       : VARCHAR(255) - Email unique
username    : VARCHAR(100) - Nom d'utilisateur optionnel
created_at  : TIMESTAMP - Date de création
updated_at  : TIMESTAMP - Date de mise à jour
```

### Table `note`
```
id          : BIGSERIAL (clé primaire auto-incrémentée)
user_id     : UUID (référence à users.id)
text        : TEXT - Contenu de la note
date        : DATE - Date de la note
completed   : BOOLEAN - État de la tâche (optionnel)
created_at  : TIMESTAMP - Date de création
updated_at  : TIMESTAMP - Date de mise à jour
```

## 🛡️ Sécurité (Row Level Security)

Toutes les opérations sont protégées par des politiques RLS:
- Les utilisateurs ne voient que leurs propres notes
- Les utilisateurs ne peuvent modifier que leurs propres données
- Les données sont automatiquement supprimées quand un utilisateur est supprimé

## 🚀 Prochaines améliorations possibles

1. Ajouter une photo de profil
2. Ajouter des catégories/étiquettes aux notes
3. Ajouter la fonctionnalité de rappel
4. Ajouter le partage de notes entre utilisateurs
5. Ajouter la recherche et filtrage des notes
6. Ajouter la synchronisation hors ligne avec Hive ou Drift

## ⚠️ Important

- Ne partagez jamais vos clés Supabase en public
- Utilisez des variables d'environnement en production
- Testez toujours les politiques RLS en local d'abord
