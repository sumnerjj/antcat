select names.name from taxa join names on taxa.name_id = names.id join taxa genera on genera.id = taxa.genus_id join protonyms on taxa.protonym_id = protonyms.id join citations on protonyms.`authorship_id` = citations.id where (forms like '%m.%' or forms like '%q%') and genera.id = 429559