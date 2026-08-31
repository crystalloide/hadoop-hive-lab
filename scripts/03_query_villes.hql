-- Atelier — Étape 3 : nombre de clients par ville
SELECT ville, COUNT(*) AS nb_clients
FROM clients
GROUP BY ville;
