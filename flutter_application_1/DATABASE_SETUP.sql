-- Table utilisateurs
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  username VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Modifier la table note existante pour ajouter les colonnes manquantes
ALTER TABLE note ADD COLUMN user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE note ADD COLUMN completed BOOLEAN DEFAULT FALSE;
ALTER TABLE note ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE note ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Politiques Row Level Security (RLS)
-- Activer RLS sur les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE note ENABLE ROW LEVEL SECURITY;

-- Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "Users can view their own profile"
ON users FOR SELECT USING (auth.uid() = id);

-- Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE USING (auth.uid() = id);

-- Les utilisateurs peuvent voir uniquement leurs propres notes
CREATE POLICY "Users can view their own notes"
ON note FOR SELECT USING (auth.uid() = user_id);

-- Les utilisateurs peuvent créer des notes
CREATE POLICY "Users can create notes"
ON note FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent mettre à jour leurs propres notes
CREATE POLICY "Users can update their own notes"
ON note FOR UPDATE USING (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leurs propres notes
CREATE POLICY "Users can delete their own notes"
ON note FOR DELETE USING (auth.uid() = user_id);

-- Créer un index pour améliorer les performances
CREATE INDEX idx_note_user_id ON note(user_id);
CREATE INDEX idx_note_date ON note(date);
