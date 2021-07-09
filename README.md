# METS2IIIF

## Verwendung

Die Anwendung wird für die Bereitstellung von IIIF Manifesten der Digitalen Bestände seit Mai 2021 in einem Beta-Betrieb
unter der Adresse https://iiif.sub.uni-hamburg.de eingesetzt.

## Funktionsweise

Die Anwendung beruht auf einem Isomorphismus zwischen dem METS Anwendungsprofil für digitalisierte Medien und dem [IIIF
Manifest](https://iiif.io/api/presentation). Jeder Struktureinheit eines METS-Dokuments kann eine korrespondierende
Struktureinheit im IIIF Manifest zugeordnet werden.

Die Anwendung besteht aus einer [XSL Transformation](src/main/resources/mets2iiif.xsl), die eine METS-Datei in ein
Manifest umwandelt und einer Java Anwendungsschicht, die die Adressen der IIIF Presentation API in die korrespondieren
Manifest- und METS-Strukturen übersetzt. Die Java Anwendungsschicht ruft die zu einem Objekt gehörige METS-Datei
dynamisch ab, führt die Transformation aus und sendet das Manifest an den aufrufenden Client.

| IIIF Manifest | METS                                                         | URI Template                                                      |
|---------------|--------------------------------------------------------------|-------------------------------------------------------------------|
| Manifest      | mets:mets                                                    | https://iiif.sub.uni-hamburg.de/object/{id}/manifest              |
| Sequence      | mets:structMap[@TYPE = 'PHYSICAL']                           | https://iiif.sub.uni-hamburg.de/object/{id}/sequence/{sequenceId} |
| Canvas        | mets:structMap[@TYPE = 'PHYSICAL']//mets:div[@TYPE = 'page'] | https://iiif.sub.uni-hamburg.de/object/{id}/canvas/{canvasId}     |
|---------------|--------------------------------------------------------------|-------------------------------------------------------------------|

## Installation

Die Software wird als .war-Datei paketiert und muss in das entsprechende Verzeichnis eines Servlet-Containers kopiert
werden.

## Autoren

- David Maus &lt;david.maus@sub.uni-hamburg.de&gt;

## Lizenz und Copyright

Die Anwendung ist Copyright (c) 2020,2021 Staats- und Universitätsbibliothek Hamburg und unter der MIT Lizenz veröffentlicht.
