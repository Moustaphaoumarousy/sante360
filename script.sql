-- Active: 1749678633784@@127.0.0.1@3306
CREATE DATABASE IF NOT EXISTS sante360db;

USE sante360db;

CREATE TABLE IF NOT EXISTS User_ (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(50) NOT NULL,
    nom VARCHAR(50) NOT NULL,
    date_inscription DATE NOT NULL,
    est_actif BOOLEAN NOT NULL,
    m2p_hash VARCHAR(50) NOT NULL
);


CREATE TABLE IF NOT EXISTS Profile_sante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    date_naissance DATE NOT NULL,
    sexe VARCHAR(50) NOT NULL,
    group_sanguin VARCHAR(50) NOT NULL,
    allergies TEXT,
    traitements TEXT,
    poids DECIMAL(5,2),
    taille DECIMAL(5,2),
    FOREIGN KEY (user_id) REFERENCES User_(id)
);


CREATE TABLE IF NOT EXISTS Parametre_utilisateur (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    langue VARCHAR(50) NOT NULL,
    notification_email BOOLEAN NOT NULL,
    notification_sms BOOLEAN NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User_(id)
);


CREATE TABLE IF NOT EXISTS Contact_urgence (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    nom VARCHAR(50) NOT NULL,
    telephone VARCHAR(50) NOT NULL,
    relation VARCHAR(50) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User_(id)
);


CREATE TABLE IF NOT EXISTS sos_signal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    date_heure_signal DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    statut_traitement VARCHAR(50) NOT NULL DEFAULT 'en_attente',
    FOREIGN KEY (user_id) REFERENCES User_(id),
    INDEX idx_user_date (user_id, date_heure_signal)
);


CREATE TABLE IF NOT EXISTS symptome_critique (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sos_signal_id INT NOT NULL UNIQUE,
    description VARCHAR(255) NOT NULL,
    gravite_estimee INT NOT NULL CHECK (gravite_estimee BETWEEN 1 AND 10),
    FOREIGN KEY (sos_signal_id) REFERENCES sos_signal(id)
);


CREATE TABLE IF NOT EXISTS localisation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sos_signal_id INT NOT NULL UNIQUE,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    date_enregistrement DATETIME NOT NULL,
    FOREIGN KEY (sos_signal_id) REFERENCES sos_signal(id),
    INDEX idx_coordonnees (latitude, longitude),
    INDEX idx_date (date_enregistrement)
);


CREATE TABLE IF NOT EXISTS Password_reset_token (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expiration DATETIME NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES User_(id),
    INDEX idx_token (token),
    INDEX idx_expiration (expiration),
    INDEX idx_user_active (user_id, used)  -- Index pour vérification rapide des tokens actifs
);


CREATE TABLE IF NOT EXISTS Chat_session (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_debut DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_fin DATETIME NULL,
    user_id BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User_(id),
    INDEX idx_user_session (user_id, date_debut),
    CHECK (date_fin IS NULL OR date_fin > date_debut)
);


CREATE TABLE IF NOT EXISTS message_ (
    id INT AUTO_INCREMENT PRIMARY KEY,
    emetteur BIGINT NOT NULL,  -- Changed to BIGINT to match User_(id)
    contenu TEXT NOT NULL,
    chat_session_id INT NOT NULL,
    date_d_envoi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (emetteur) REFERENCES User_(id),
    FOREIGN KEY (chat_session_id) REFERENCES Chat_session(id),
    INDEX idx_session_messages (chat_session_id, date_d_envoi),
    INDEX idx_emetteur (emetteur)
);


CREATE TABLE IF NOT EXISTS suggestion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    text_question VARCHAR(255) NOT NULL,
    est_selectionne INT NOT NULL DEFAULT 0,  -- Fixed typo in column name
    nombre_selections INT NOT NULL DEFAULT 0,  -- Added missing column
    user_id BIGINT NOT NULL,  -- Added to track creator
    chat_session_id INT NOT NULL,
    date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES User_(id),
    FOREIGN KEY (chat_session_id) REFERENCES Chat_session(id),
    INDEX idx_popular_suggestions (nombre_selections DESC),
    INDEX idx_session_suggestions (chat_session_id)
);


CREATE TABLE IF NOT EXISTS module_ (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_module VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS type_etablissement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS Etablissement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    adresse TEXT NOT NULL,
    position POINT NOT NULL COMMENT 'Spatial coordinates',
    type_id INT NOT NULL,
    telephone VARCHAR(20),
    email VARCHAR(100),
    site_web VARCHAR(255),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_maj DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (type_id) REFERENCES type_etablissement(id),
    SPATIAL INDEX idx_position (position),  -- Proper spatial index
    INDEX idx_nom (nom),
    INDEX idx_type (type_id),
    INDEX idx_contact (telephone, email)
);


CREATE TABLE IF NOT EXISTS itineraire (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,  -- Changed to BIGINT
    date_demande DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_arrivee DATETIME NULL COMMENT "Heure effective d'arrivée",
    distance_km DECIMAL(10,2) NOT NULL COMMENT 'Distance en kilomètres',
    mode_transport ENUM('marche','velo','voiture','transport_public') NOT NULL,
    etablissement_id INT NOT NULL,
    duree_estimee INT COMMENT 'Durée estimée en minutes',
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    FOREIGN KEY (etablissement_id) REFERENCES Etablissement(id),
    INDEX idx_user_date (user_id, date_demande),
    INDEX idx_etablissement (etablissement_id),
    CONSTRAINT chk_distance CHECK (distance_km > 0),
    CONSTRAINT chk_dates CHECK (date_arrivee IS NULL OR date_arrivee >= date_demande)
);


CREATE TABLE IF NOT EXISTS horaire_ouverture (
    id INT AUTO_INCREMENT PRIMARY KEY,
    etablissement_id INT NOT NULL,
    jour_semaine ENUM('lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche') NOT NULL,
    heure_ouverture TIME NOT NULL,
    heure_fermeture TIME NOT NULL,
    
    UNIQUE (etablissement_id, jour_semaine) COMMENT 'Un seul créneau par jour par établissement',
    FOREIGN KEY (etablissement_id) REFERENCES Etablissement(id) ON DELETE CASCADE,
    INDEX idx_etablissement (etablissement_id),
    INDEX idx_jour_semaine (jour_semaine),
    CONSTRAINT chk_horaires_valides CHECK (
        heure_fermeture > heure_ouverture OR
        (heure_ouverture = '00:00:00' AND heure_fermeture = '23:59:59')
    )
);

-- Table OBJECTIF_PHYSIQUE
CREATE TABLE IF NOT EXISTS objectif_physique (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_objectif ENUM('perte_de_poids','endurance','force','musculation','autre') NOT NULL,
    description TEXT,
    valeur_cible DECIMAL(10,2) COMMENT "Valeur numérique de l'objectif",
    unite_mesure VARCHAR(20) COMMENT 'kg, min, km, etc.',
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id BIGINT NOT NULL,
    est_termine BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    INDEX idx_user_objectif (user_id),
    CONSTRAINT chk_dates_obj_phys CHECK (date_fin > date_debut)
);

-- Table PLAN_EXERCICE (correction orthographique)
CREATE TABLE IF NOT EXISTS plan_exercice (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    frequence_semaine INT COMMENT 'Nombre de séances par semaine',
    duree_seance INT COMMENT 'Durée en minutes',
    niveau_difficulte ENUM('débutant','intermédiaire','avancé') DEFAULT 'débutant',
    objectif_physique_id INT NOT NULL,
    user_id BIGINT NOT NULL COMMENT 'Créateur du plan',
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    est_actif BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (objectif_physique_id) REFERENCES objectif_physique(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User_(id),
    INDEX idx_objectif_plan (objectif_physique_id),
    INDEX idx_user_plan (user_id)
);


CREATE TABLE IF NOT EXISTS exercice (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(100) NOT NULL,
    description TEXT,
    type_media ENUM('texte','video','image','lien') NOT NULL DEFAULT 'texte',
    url_media VARCHAR(255),
    niveau_difficulte ENUM('débutant','intermédiaire','avancé') DEFAULT 'débutant',
    groupe_musculaire VARCHAR(100) COMMENT 'Muscles sollicités',
    calories_par_heure DECIMAL(6,2) COMMENT 'Estimation calorique',
    materiel_requis VARCHAR(100) COMMENT 'Équipement nécessaire',
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_titre (titre),
    INDEX idx_groupe_musculaire (groupe_musculaire),
    INDEX idx_difficulte (niveau_difficulte)
);


CREATE TABLE IF NOT EXISTS plan_exercice_detail (
    plan_exercice_id INT NOT NULL,
    exercice_id INT NOT NULL,
    ordre INT NOT NULL COMMENT 'Ordre d''exécution',
    duree INT COMMENT 'Durée en secondes (pour cardio)',
    series INT COMMENT 'Nombre de séries (pour musculation)',
    repetitions INT COMMENT 'Nombre de répétitions par série',
    repos INT COMMENT 'Temps de repos en secondes',
    intensite ENUM('faible','modérée','élevée') DEFAULT 'modérée',
    notes TEXT,
    PRIMARY KEY (plan_exercice_id, exercice_id, ordre),
    FOREIGN KEY (plan_exercice_id) REFERENCES plan_exercice(id) ON DELETE CASCADE,
    FOREIGN KEY (exercice_id) REFERENCES exercice(id) ON DELETE CASCADE,
    INDEX idx_ordre (ordre),
    INDEX idx_exercice (exercice_id),
    CONSTRAINT chk_exercice_params CHECK (
        (duree IS NOT NULL) OR 
        (series IS NOT NULL AND repetitions IS NOT NULL)
    )
);

-- Table SUIVI_PROGRESSION (correction orthographique)
CREATE TABLE IF NOT EXISTS suivi_progression (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_semaine DATE NOT NULL COMMENT 'Date de début de semaine (lundi)',
    taux_completion DECIMAL(5,2) NOT NULL DEFAULT 0.00 
        CHECK (taux_completion BETWEEN 0 AND 100),
    seances_completees INT NOT NULL DEFAULT 0 COMMENT 'Nombre de séances terminées',
    seances_prevues INT NOT NULL COMMENT 'Nombre de séances prévues',
    poids_moyen DECIMAL(5,2) COMMENT 'Poids moyen en kg (le cas échéant)',
    frequence_cardiaque_moyenne INT COMMENT 'FC moyenne pendant les exercices',
    remarque TEXT,
    user_id BIGINT NOT NULL,  -- Changed to match User_(id) type
    plan_exercice_id INT NOT NULL,
    date_enregistrement DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_exercice_id) REFERENCES plan_exercice(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_plan_semaine (user_id, plan_exercice_id, date_semaine),
    INDEX idx_progression_user (user_id, date_semaine),
    INDEX idx_progression_plan (plan_exercice_id, date_semaine),
    CONSTRAINT chk_seances CHECK (seances_completees <= seances_prevues)
);


CREATE TABLE IF NOT EXISTS OBJECTIF (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_objectif ENUM('prise_de_masse', 'perte_de_poids', 'equilibre', 'performance', 'autre') NOT NULL,
    description TEXT,
    valeur_cible DECIMAL(10,2) COMMENT 'Valeur cible (kg, %, etc.)',
    unite_mesure VARCHAR(20) COMMENT 'kg, %, etc.',
    date_creation DATE NOT NULL DEFAULT (CURRENT_DATE),
    date_fin_prevue DATE COMMENT 'Date cible pour atteindre l\'objectif',
    user_id BIGINT NOT NULL,  -- Changed to match User_(id) type
    est_termine BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    INDEX idx_user_objectif (user_id),
    INDEX idx_objectif_type (type_objectif),
    CONSTRAINT chk_dates_objectif CHECK (date_fin_prevue IS NULL OR date_fin_prevue >= date_creation)
);


CREATE TABLE IF NOT EXISTS PLAN_ALIMENTAIRE (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL COMMENT 'Nom du plan alimentaire',
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    calories_journalieres INT COMMENT 'Objectif calorique quotidien',
    macros TEXT COMMENT 'Répartition macros (JSON ou texte formaté)',
    contenu TEXT NOT NULL COMMENT 'Détails du régime',
    objectif_id INT NOT NULL,
    user_id BIGINT NOT NULL COMMENT 'Créateur/associé au plan',
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (objectif_id) REFERENCES OBJECTIF(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User_(id),
    INDEX idx_plan_objectif (objectif_id),
    INDEX idx_plan_user (user_id),
    INDEX idx_plan_dates (date_debut, date_fin),
    CONSTRAINT chk_dates_valides CHECK (date_fin >= date_debut)
);


CREATE TABLE IF NOT EXISTS CONSEIL_NUTRITIONNEL (
    id INT AUTO_INCREMENT PRIMARY KEY,
    contenu TEXT NOT NULL,
    contexte ENUM('repas_principal','avant_entrainement','apres_entrainement','collation','autre') NOT NULL,
    priorite TINYINT DEFAULT 2 COMMENT '1=élevée, 2=moyenne, 3=faible',
    est_actif BOOLEAN DEFAULT TRUE,
    objectif_id INT NOT NULL,
    user_id BIGINT NOT NULL,  -- Changed to match User_(id) type
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_mise_a_jour DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (objectif_id) REFERENCES OBJECTIF(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    INDEX idx_conseil_user (user_id),
    INDEX idx_conseil_objectif (objectif_id),
    INDEX idx_conseil_contexte (contexte),
    INDEX idx_conseil_priorite (priorite)
);


CREATE TABLE IF NOT EXISTS FEEDBACK (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commentaire TEXT,
    note TINYINT NOT NULL CHECK (note BETWEEN 1 AND 5),
    type_amelioration ENUM('contenu','presentation','frequence','diversite','autre') COMMENT 'Type d\'amélioration suggérée',
    date_feedback DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id BIGINT NOT NULL,  -- Changed to match User_(id) type
    plan_alimentaire_id INT NOT NULL,
    est_traite BOOLEAN DEFAULT FALSE COMMENT 'Si le feedback a été pris en compte',
    
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_alimentaire_id) REFERENCES PLAN_ALIMENTAIRE(id) ON DELETE CASCADE,
    INDEX idx_feedback_user (user_id),
    INDEX idx_feedback_plan (plan_alimentaire_id),
    INDEX idx_feedback_date (date_feedback),
    INDEX idx_feedback_traite (est_traite)
);


CREATE TABLE IF NOT EXISTS JOURNAL_SYMPTOME (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_enregistrement DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    symptomes VARCHAR(255) NOT NULL COMMENT 'Symptômes ressentis (séparés par des virgules)',
    intensite ENUM('léger','modéré','sévère') NOT NULL,
    duree_minutes INT COMMENT 'Durée approximative des symptômes',
    localisation VARCHAR(100) COMMENT 'Partie du corps concernée',
    facteurs_declenchants VARCHAR(255) COMMENT 'Facteurs potentiels',
    commentaire TEXT,
    user_id BIGINT NOT NULL,  -- Changed to match User_(id) type
    est_urgent BOOLEAN DEFAULT FALSE COMMENT 'Nécessite une attention médicale',
    
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    INDEX idx_symptome_user (user_id),
    INDEX idx_symptome_date (date_enregistrement),
    INDEX idx_symptome_intensite (intensite),
    INDEX idx_symptome_urgence (est_urgent)
)COMMENT 'Journal des symptômes des utilisateurs';


CREATE TABLE IF NOT EXISTS RAPPELL_MEDICAMENT (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_medicament VARCHAR(100) NOT NULL,
    heure TIME NOT NULL,
    frequence ENUM('quotidien', 'hebdomadaire', 'mensuel', 'ponctuel') NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE,
    notification_active BOOLEAN NOT NULL DEFAULT TRUE,
    user_id BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    INDEX idx_rappell_user (user_id),
    INDEX idx_rappell_heure (heure),
    CONSTRAINT chk_dates_medicament CHECK (date_fin IS NULL OR date_fin >= date_debut)
) COMMENT = 'Rappels de médicaments pour les utilisateurs';


CREATE TABLE IF NOT EXISTS OBJET_CONNECTE (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_objet ENUM('montre', 'bracelet', 'thermomètre', 'tensiomètre', 'balance', 'autre') NOT NULL,
    marque VARCHAR(50) NOT NULL,
    numero_serie VARCHAR(100) UNIQUE,
    user_id BIGINT NOT NULL,
    date_association DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User_(id) ON DELETE CASCADE,
    INDEX idx_objet_user (user_id),
    INDEX idx_objet_type (type_objet)
) COMMENT = 'Objets connectés associés aux utilisateurs';


CREATE TABLE IF NOT EXISTS MESURE_CONNECTEE (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_heure DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type_mesure ENUM('cardio', 'température', 'pas', 'pression', 'glycémie', 'sommeil', 'activité') NOT NULL,
    valeur DECIMAL(10,2) NOT NULL,
    unite VARCHAR(20) NOT NULL,
    objet_connecte_id INT NOT NULL,
    FOREIGN KEY (objet_connecte_id) REFERENCES OBJET_CONNECTE(id) ON DELETE CASCADE,
    INDEX idx_mesure_objet (objet_connecte_id),
    INDEX idx_mesure_type_date (type_mesure, date_heure),
    CONSTRAINT chk_valeur_positive CHECK (valeur >= 0)
) COMMENT 'Mesures enregistrées par les objets connectés';

