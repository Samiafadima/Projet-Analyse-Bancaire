-- =====================================================
-- 04_kpi.sql 
-- =====================================================

USE banque_analyse;


-- ============ 1. LES CHIFFRES GÉNÉRAUX ============

-- Question 1 : combien de transactions j'ai au total ?
SELECT COUNT(*) AS nb_transactions
FROM transactions;

-- Question 2 : combien de transactions sont dans le périmètre ?
SELECT COUNT(*) AS nb_transactions_perimetre
FROM transactions
WHERE perimetre_kpi = 'Oui';

-- Question 3 : combien d'argent est sorti (les dépenses = les débits) ?
SELECT SUM(montant) AS total_depenses
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Débit';

-- Question 4 : combien d'argent est entré (les crédits) ?
SELECT SUM(montant) AS total_entrees
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Crédit';

-- Question 5 : quelle est la dépense moyenne ?
SELECT ROUND(AVG(montant), 2) AS depense_moyenne
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Débit';

-- Question 6 : quelle est la plus grosse dépense ?
SELECT MAX(montant) AS plus_grosse_depense
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Débit';


-- ============ 2. DÉBITS ET CRÉDITS ============

-- Question 7 : combien de débits et de crédits, et pour quel montant ?
SELECT sens,
       COUNT(*) AS nb_transactions,
       ROUND(SUM(montant), 2) AS montant_total
FROM transactions
WHERE perimetre_kpi = 'Oui'
GROUP BY sens;


-- ============ 3. L'ÉVOLUTION PAR MOIS ============

-- Question 8 : combien je dépense chaque mois ?
SELECT mois_transaction AS mois,
       COUNT(*) AS nb_depenses,
       ROUND(SUM(montant), 2) AS total_depenses
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Débit'
GROUP BY mois_transaction
ORDER BY mois_transaction;


-- ============ 4. PAR CATÉGORIE, CANAL ET COMMERÇANT ============

-- Question 9 : quelles catégories coûtent le plus cher ?
SELECT categorie,
       COUNT(*) AS nb_depenses,
       ROUND(SUM(montant), 2) AS total_depenses
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Débit'
GROUP BY categorie
ORDER BY total_depenses DESC;

-- Question 10 : quel canal est le plus utilisé (carte, virement...) ?
SELECT canal,
       COUNT(*) AS nb_depenses,
       ROUND(SUM(montant), 2) AS total_depenses
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Débit'
GROUP BY canal
ORDER BY nb_depenses DESC;

-- Question 11 : quels sont les 10 commerçants où on dépense le plus ?
SELECT commercant,
       COUNT(*) AS nb_depenses,
       ROUND(SUM(montant), 2) AS total_depenses
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Débit'
GROUP BY commercant
ORDER BY total_depenses DESC
LIMIT 10;


-- ============ 5. COMPARER LES CLIENTS ============
-- Ici je relie les 2 tables avec JOIN :

-- Question 12 : quel segment de clients dépense le plus ?
SELECT clients.segment_client,
       COUNT(*) AS nb_depenses,
       ROUND(SUM(transactions.montant), 2) AS total_depenses,
       ROUND(AVG(transactions.montant), 2) AS depense_moyenne
FROM transactions
JOIN clients ON transactions.client_id = clients.client_id
WHERE transactions.perimetre_kpi = 'Oui'
  AND transactions.sens = 'Débit'
GROUP BY clients.segment_client
ORDER BY total_depenses DESC;

-- Question 13 : et par région ?
SELECT clients.region_client,
       COUNT(*) AS nb_depenses,
       ROUND(SUM(transactions.montant), 2) AS total_depenses,
       ROUND(AVG(transactions.montant), 2) AS depense_moyenne
FROM transactions
JOIN clients ON transactions.client_id = clients.client_id
WHERE transactions.perimetre_kpi = 'Oui'
  AND transactions.sens = 'Débit'
GROUP BY clients.region_client
ORDER BY total_depenses DESC;

-- Question 14 : quels sont les 10 clients qui dépensent le plus ?
SELECT client_id,
       COUNT(*) AS nb_depenses,
       ROUND(SUM(montant), 2) AS total_depenses
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND sens = 'Débit'
GROUP BY client_id
ORDER BY total_depenses DESC
LIMIT 10;


-- ============ 6. LES STATUTS (sur toutes les transactions) ============

-- Question 15 : combien de transactions par statut ?

SELECT statut,
       COUNT(*) AS nb_transactions
FROM transactions
GROUP BY statut
ORDER BY nb_transactions DESC;

-- Question 16 : combien de transactions par devise ?
SELECT devise,
       COUNT(*) AS nb_transactions
FROM transactions
GROUP BY devise
ORDER BY nb_transactions DESC;


-- ============ 7. LES FRAIS BANCAIRES ============

-- Question 17 : combien les clients paient de frais bancaires ?
SELECT COUNT(*) AS nb_frais,
       ROUND(SUM(montant), 2) AS total_frais
FROM transactions
WHERE perimetre_kpi = 'Oui'
  AND categorie = 'Frais bancaires';