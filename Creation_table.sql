CREATE DATABASE IF NOT EXISTS banque_analyse;

-- On repart d'une base propre (enfants avant parents à cause de la clé étrangère)
DROP VIEW  IF EXISTS v_transactions_kpi;
DROP TABLE IF EXISTS journal_corrections;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS clients;

USE banque_analyse;
-- ---------------------------------------------------------------------
-- Table clients : 1 ligne par client
-- ---------------------------------------------------------------------
CREATE TABLE clients (
  client_id        CHAR(5)      NOT NULL,
  age_client       TINYINT UNSIGNED NOT NULL,
  segment_client   VARCHAR(20)  NOT NULL,
  region_client    VARCHAR(40)  NOT NULL,
  anciennete_mois  SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (client_id),
  CONSTRAINT ck_clients_segment CHECK (segment_client IN ('Essentiel', 'Confort', 'Premium'))
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Table transactions : 1 ligne par transaction_id 
-- ---------------------------------------------------------------------
CREATE TABLE transactions (
  transaction_id        CHAR(6)       NOT NULL,
  date_transaction      DATE          NULL,
  mois_transaction      VARCHAR(13)   NOT NULL COMMENT 'AAAA-MM, ou Date invalide',
  client_id             CHAR(5)       NOT NULL,
  categorie             VARCHAR(20)   NOT NULL,
  sens                  VARCHAR(6)    NOT NULL,
  commercant            VARCHAR(40)   NOT NULL,
  montant               DECIMAL(12,2) NULL,
  devise                VARCHAR(13)   NOT NULL,
  canal                 VARCHAR(13)   NOT NULL,
  statut                VARCHAR(13)   NOT NULL,
  montant_signe         DECIMAL(12,2) NULL,
  perimetre_kpi         VARCHAR(3)    NOT NULL,
  motif_hors_perimetre  VARCHAR(100)  NULL,
  remarque_qualite      VARCHAR(200)  NULL,
  PRIMARY KEY (transaction_id),
  KEY ix_tr_client   (client_id),
  KEY ix_tr_date     (date_transaction),
  KEY ix_tr_categ    (categorie),
  KEY ix_tr_perim    (perimetre_kpi),
  CONSTRAINT fk_tr_client FOREIGN KEY (client_id) REFERENCES clients (client_id),
  CONSTRAINT ck_tr_sens   CHECK (sens IN ('Crédit', 'Débit')),
  CONSTRAINT ck_tr_perim  CHECK (perimetre_kpi IN ('Oui', 'Non')),
  CONSTRAINT ck_tr_montant CHECK (montant IS NULL OR montant > 0)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Table journal_corrections : trace de chaque correction (avant / après)
-- ---------------------------------------------------------------------
CREATE TABLE journal_corrections (
  id              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  transaction_id  CHAR(6)       NOT NULL,
  ligne_brute     INT UNSIGNED  NOT NULL COMMENT 'Numéro de ligne dans Transactions_brutes (Excel)',
  champ           VARCHAR(30)   NOT NULL,
  valeur_avant    VARCHAR(60)   NULL,
  valeur_apres    VARCHAR(60)   NULL,
  regle           VARCHAR(80)   NOT NULL,
  commentaire     VARCHAR(200)  NULL,
  PRIMARY KEY (id),
  KEY ix_jc_tr (transaction_id)
) ENGINE = InnoDB;