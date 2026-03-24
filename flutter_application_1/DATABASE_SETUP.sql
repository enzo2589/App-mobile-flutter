-- Table types de notes
CREATE TABLE types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer les types de notes
INSERT INTO types (name) VALUES ('à faire');
INSERT INTO types (name) VALUES ('important');
INSERT INTO types (name) VALUES ('urgent');

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
ALTER TABLE note ADD COLUMN type_id INTEGER REFERENCES types(id) DEFAULT 1;
ALTER TABLE note ADD COLUMN completed BOOLEAN DEFAULT FALSE;
ALTER TABLE note ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE note ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Politiques Row Level Security (RLS)
-- Activer RLS sur les tables
ALTER TABLE types ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE note ENABLE ROW LEVEL SECURITY;

-- Les utilisateurs peuvent lire tous les types
CREATE POLICY "Anyone can read types"
ON types FOR SELECT USING (true);

-- Seul un administrateur peut insérer des types (bloqué pour les autres)
CREATE POLICY "No one can insert types"
ON types FOR INSERT WITH CHECK (false);

-- Seul un administrateur peut modifier des types (bloqué pour les autres)
CREATE POLICY "No one can update types"
ON types FOR UPDATE USING (false);

-- Seul un administrateur peut supprimer des types (bloqué pour les autres)
CREATE POLICY "No one can delete types"
ON types FOR DELETE USING (false);

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
