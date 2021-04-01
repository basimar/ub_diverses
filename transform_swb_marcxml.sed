# Script um xml-Daten aus der Mongo-Datenbank von swissbib in korrektes MARCXML umzuwandeln
s/<header>.*<\/header>//g
s/<header status="deleted">.*<\/header>//g
s/<record>//g
s/<metadata>//g
s/<\/metadata>//g
s/<\/record>//g
s/<collection>/<marc:collection>/g
s/<\/collection>/<\/marc:collection>/g
