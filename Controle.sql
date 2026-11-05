-- =====================================================
-- 03_controles_qualite.sql : je vérifie que mes données sont propres
-- Projet : analyse des transactions bancaires
-- =====================================================

USE banque_analyse;


-- ============ 1. COMBIEN DE LIGNES DANS CHAQUE TABLE ? ============

-- Question 1 : combien de clients ?
SELECT COUNT(*) AS nb_clients
FROM clients;


-- Question 2 : combien de transactions ?
SELECT COUNT(*) AS nb_transactions
FROM transactions;


-- Question 3 : combien de lignes dans le journal des corrections ?
SELECT COUNT(*) AS nb_corrections
FROM journal_corrections;



-- ============ 2. LES DOUBLONS ============

-- Question 4 : est-ce qu'un transaction_id apparaît plusieurs fois ?
SELECT transaction_id, COUNT(*) AS nb
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;



-- ============ 3. LES LIENS ENTRE LES TABLES ============

-- Question 5 : y a-t-il des transactions avec un client qui n'existe pas ?
-- (je relie les 2 tables, et je regarde les transactions sans client)
SELECT COUNT(*) AS transactions_sans_client
FROM transactions
LEFT JOIN clients ON transactions.client_id = clients.client_id
WHERE clients.client_id IS NULL;


-- Question 6 : y a-t-il des clients qui n'ont aucune transaction ?
SELECT clients.client_id
FROM clients
LEFT JOIN transactions ON clients.client_id = transactions.client_id
WHERE transactions.transaction_id IS NULL;


-- ============ 4. LES VALEURS MANQUANTES ============

-- Question 7 : combien de dates vides ?
SELECT COUNT(*) AS dates_vides
FROM transactions
WHERE date_transaction IS NULL;

-- Question 8 : combien de montants vides ?
SELECT COUNT(*) AS montants_vides
FROM transactions
WHERE montant IS NULL;


-- Question 9 : combien de commerçants non renseignés ?
SELECT COUNT(*) AS commercants_non_renseignes
FROM transactions
WHERE commercant = 'Non renseigné';


-- Question 10 : combien de canaux non renseignés ?
SELECT COUNT(*) AS canaux_non_renseignes
FROM transactions
WHERE canal = 'Non renseigné';


-- Question 11 : combien de statuts non renseignés ?
SELECT COUNT(*) AS statuts_non_renseignes
FROM transactions
WHERE statut = 'Non renseigné';

-- Question 12 : combien de devises non renseignées ?
SELECT COUNT(*) AS devises_non_renseignees
FROM transactions
WHERE devise = 'Non renseigné';



-- ============ 5. LES LIBELLÉS BIEN HARMONISÉS ? ============


-- Question 13 : quelles catégories et combien de lignes pour chacune ?
SELECT categorie, COUNT(*) AS nb
FROM transactions
GROUP BY categorie
ORDER BY nb DESC;

-- Question 14 : quels sens ?
SELECT sens, COUNT(*) AS nb
FROM transactions
GROUP BY sens;


-- Question 15 : quels canaux ?
SELECT canal, COUNT(*) AS nb
FROM transactions
GROUP BY canal
ORDER BY nb DESC;


-- Question 16 : quels statuts ?
SELECT statut, COUNT(*) AS nb
FROM transactions
GROUP BY statut
ORDER BY nb DESC;

-- Question 17 : quelles devises ?
SELECT devise, COUNT(*) AS nb
FROM transactions
GROUP BY devise
ORDER BY nb DESC;


-- Question 18 : reste-t-il des espaces en trop au début ou à la fin ?
-- (TRIM enlève les espaces autour d'un texte)
SELECT COUNT(*) AS lignes_avec_espaces
FROM transactions
WHERE categorie <> TRIM(categorie)
   OR sens <> TRIM(sens)
   OR canal <> TRIM(canal)
   OR statut <> TRIM(statut);



-- ============ 6. LES MONTANTS ET LES DATES ============

-- Question 19 : y a-t-il des montants négatifs ou à zéro ?
SELECT COUNT(*) AS montants_anormaux
FROM transactions
WHERE montant <= 0;


-- Question 20 : y a-t-il des dates en dehors de 2025 ?
SELECT COUNT(*) AS dates_hors_2025
FROM transactions
WHERE date_transaction < '2025-01-01'
   OR date_transaction > '2025-12-31';



-- ============ 7. LE PÉRIMÈTRE DES KPI ============

-- Question 21 : combien de transactions sont dans le périmètre et combien sont exclues ?
SELECT perimetre_kpi, COUNT(*) AS nb
FROM transactions
GROUP BY perimetre_kpi;


-- Question 22 : pourquoi les transactions sont-elles exclues ?
SELECT motif_hors_perimetre, COUNT(*) AS nb
FROM transactions
WHERE perimetre_kpi = 'Non'
GROUP BY motif_hors_perimetre
ORDER BY nb DESC;



-- ============ 8. POINTS D'ATTENTION ============

-- Question 23 : quels crédits sont bizarres ?

SELECT transaction_id, categorie, commercant, montant
FROM transactions
WHERE sens = 'Crédit'
  AND categorie <> 'Revenus'
  AND categorie <> 'Virements';


-- Question 24 : quels clients ont une ancienneté impossible par rapport à leur âge ?
SELECT COUNT(*) AS clients_incoherents
FROM clients
WHERE anciennete_mois > (age_client - 18) * 12;


-- ============ 9. LE JOURNAL DES CORRECTIONS ============

-- Question 25 : combien de corrections de chaque sorte ai-je faites ?
SELECT regle, COUNT(*) AS nb_corrections
FROM journal_corrections
GROUP BY regle
ORDER BY nb_corrections DESC;


-- Question 26 : qu'est-ce que j'ai changé sur la transaction T01291 ?
SELECT champ, valeur_avant, valeur_apres, regle
FROM journal_corrections
WHERE transaction_id = 'T01291';