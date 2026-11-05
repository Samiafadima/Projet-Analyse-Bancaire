-- =====================================================
-- 05_vues_powerbi.sql : mes vues pour Power BI
-- Projet : analyse des transactions bancaires
-- =====================================================

USE banque_analyse;


-- ============ VUE 1 : toutes les transactions avec les infos du client ============
-- J'ajoute à chaque transaction le segment, la région, l'âge...

CREATE OR REPLACE VIEW v_transactions_clients AS
SELECT transactions.transaction_id,
       transactions.date_transaction,
       transactions.mois_transaction,
       transactions.client_id,
       clients.segment_client,
       clients.region_client,
       clients.age_client,
       transactions.categorie,
       transactions.sens,
       transactions.commercant,
       transactions.montant,
       transactions.montant_signe,
       transactions.devise,
       transactions.canal,
       transactions.statut,
       transactions.perimetre_kpi,
       transactions.motif_hors_perimetre
FROM transactions
JOIN clients ON transactions.client_id = clients.client_id;


-- ============ VUE 2 : seulement les transactions utilisées pour les KPI ============


CREATE OR REPLACE VIEW v_transactions_kpi AS
SELECT *
FROM v_transactions_clients
WHERE perimetre_kpi = 'Oui';


-- ============ VUE 3 : le résumé par mois ============
-- Pour chaque mois : combien est entré, combien est sorti, et le solde
-- Je pars de la vue 2, donc seulement les transactions utilisées

CREATE OR REPLACE VIEW v_resume_par_mois AS
SELECT mois_transaction AS mois,
       COUNT(*) AS nb_transactions,
       ROUND(SUM(CASE WHEN sens = 'Crédit' THEN montant ELSE 0 END), 2) AS total_entrees,
       ROUND(SUM(CASE WHEN sens = 'Débit' THEN montant ELSE 0 END), 2) AS total_depenses,
       ROUND(SUM(montant_signe), 2) AS solde
FROM v_transactions_kpi
GROUP BY mois_transaction
ORDER BY mois_transaction;


-- ============ POUR VÉRIFIER QUE ÇA MARCHE ============

-- Combien de lignes dans chaque vue ?
SELECT COUNT(*) AS nb_lignes FROM v_transactions_clients;
SELECT COUNT(*) AS nb_lignes FROM v_transactions_kpi;

-- Le résumé par mois (12 lignes attendues)
SELECT * FROM v_resume_par_mois;
