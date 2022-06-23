<xsl:transform version="3.0" expand-text="yes"
               xmlns:dv="http://dfg-viewer.de/"
               xmlns:fn="https://iiif.sub.uni-hamburg.de"
               xmlns:json="http://www.w3.org/2005/xpath-functions"
               xmlns:mets="http://www.loc.gov/METS/"
               xmlns:mix="http://www.loc.gov/mix/v20"
               xmlns:mods="http://www.loc.gov/mods/v3"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="entityType"  as="xs:string"  required="yes"/>
  <xsl:param name="entityId"    as="xs:string?" required="no"/>

  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode on-no-match="shallow-skip" name="metadata"/>

  <xsl:output indent="yes"/>

  <xsl:key name="Sequence" match="mets:div[@TYPE = 'physSequence']" use="@ID"/>
  <xsl:key name="Canvas" match="mets:div[@TYPE = 'page']" use="@ID"/>
  <xsl:key name="Image" match="mets:file[@MIMETYPE = 'application/vnd.kitodo.iiif']" use="@ID"/>
  <xsl:key name="Range" match="mets:div[ancestor::mets:structMap[@TYPE = 'LOGICAL']]" use="@ID"/>
  <xsl:key name="Mix" match="mix:mix" use="ancestor::mets:techMD/@ID"/>

  <xsl:key name="smLink" match="mets:smLink" use="@xlink:from"/>

  <xsl:variable name="vocab" as="element(rdf:RDF)">
    <rdf:RDF>
      <rdf:Property rdf:about="http://purl.org/dc/elements/1.1/identifier">
        <rdfs:label xml:lang="en">Shelfmark</rdfs:label>
        <rdfs:label xml:lang="de">Signatur</rdfs:label>
      </rdf:Property>
      <rdf:Property rdf:about="http://purl.org/dc/elements/1.1/title">
        <rdfs:label xml:lang="en">Title</rdfs:label>
        <rdfs:label xml:lang="de">Titel</rdfs:label>
      </rdf:Property>
      <rdf:Property rdf:about="http://purl.org/dc/elements/1.1/creator">
        <rdfs:label xml:lang="en">Author</rdfs:label>
        <rdfs:label xml:lang="de">Verfasser</rdfs:label>
      </rdf:Property>
      <rdf:Property rdf:about="http://purl.org/dc/elements/1.1/date">
        <rdfs:label xml:lang="en">Date</rdfs:label>
        <rdfs:label xml:lang="de">Datum</rdfs:label>
      </rdf:Property>
      <!-- DFG-Viewer Strukturdaten -->
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#section">
        <rdfs:label xml:lang="de">Abschnitt</rdfs:label>
        <rdfs:label xml:lang="en">Section</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#file">
        <rdfs:label xml:lang="de">Akte</rdfs:label>
        <rdfs:label xml:lang="en">File</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#album">
        <rdfs:label xml:lang="de">Album</rdfs:label>
        <rdfs:label xml:lang="en">Album</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#register">
        <rdfs:label xml:lang="de">Amtsbuch</rdfs:label>
        <rdfs:label xml:lang="en">Register</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#annotation">
        <rdfs:label xml:lang="de">Annotation</rdfs:label>
        <rdfs:label xml:lang="en">Annotation</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#address">
        <rdfs:label xml:lang="de">Anrede</rdfs:label>
        <rdfs:label xml:lang="en">Address</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#article">
        <rdfs:label xml:lang="de">Artikel</rdfs:label>
        <rdfs:label xml:lang="en">Article</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#atlas">
        <rdfs:label xml:lang="de">Atlas</rdfs:label>
        <rdfs:label xml:lang="en">Atlas</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#issue">
        <rdfs:label xml:lang="de">Ausgabe (auch: Heft)</rdfs:label>
        <rdfs:label xml:lang="en">Issue</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#bachelor_thesis">
        <rdfs:label xml:lang="de">Bachelorarbeit</rdfs:label>
        <rdfs:label xml:lang="en">Bachelor Thesis</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#volume">
        <rdfs:label xml:lang="de">Band</rdfs:label>
        <rdfs:label xml:lang="en">Volume</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#contained_work">
        <rdfs:label xml:lang="de">Beigefügtes oder Enthaltenes Werk</rdfs:label>
        <rdfs:label xml:lang="en">Contained Work</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#additional">
        <rdfs:label xml:lang="de">Beilage</rdfs:label>
        <rdfs:label xml:lang="en">Additional</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#report">
        <rdfs:label xml:lang="de">Bericht</rdfs:label>
        <rdfs:label xml:lang="en">Report</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#official_notification">
        <rdfs:label xml:lang="de">Bescheid</rdfs:label>
        <rdfs:label xml:lang="en">Official Notification</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#provenance">
        <rdfs:label xml:lang="de">Besitznachweis</rdfs:label>
        <rdfs:label xml:lang="en">Provenance</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#inventory">
        <rdfs:label xml:lang="de">Bestand</rdfs:label>
        <rdfs:label xml:lang="en">Inventory</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#image">
        <rdfs:label xml:lang="de">Bild</rdfs:label>
        <rdfs:label xml:lang="en">Image</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#collation">
        <rdfs:label xml:lang="de">Bogensignatur</rdfs:label>
        <rdfs:label xml:lang="en">Collation</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#ornament">
        <rdfs:label xml:lang="de">Buchschmuck</rdfs:label>
        <rdfs:label xml:lang="en">Ornament</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#letter">
        <rdfs:label xml:lang="de">Brief</rdfs:label>
        <rdfs:label xml:lang="en">Letter</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#cover">
        <rdfs:label xml:lang="de">Deckel</rdfs:label>
        <rdfs:label xml:lang="en">Cover</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#cover_front">
        <rdfs:label xml:lang="de">Vorderdeckel</rdfs:label>
        <rdfs:label xml:lang="en">Front Cover</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#cover_back">
        <rdfs:label xml:lang="de">Rückdeckel</rdfs:label>
        <rdfs:label xml:lang="en">Back Cover</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#diploma_thesis">
        <rdfs:label xml:lang="de">Diplomarbeit</rdfs:label>
        <rdfs:label xml:lang="en">Diploma Thesis</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#doctoral_thesis">
        <rdfs:label xml:lang="de">Dissertation</rdfs:label>
        <rdfs:label xml:lang="en">Doctoral Thesis</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#document">
        <rdfs:label xml:lang="de">Dokument</rdfs:label>
        <rdfs:label xml:lang="en">Document</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#printers_mark">
        <rdfs:label xml:lang="de">Druckermarke</rdfs:label>
        <rdfs:label xml:lang="en">Printers Mark</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#printed_archives">
        <rdfs:label xml:lang="de">Druckerzeugnis (Archivale)</rdfs:label>
        <rdfs:label xml:lang="en">Printed Archives</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#binding">
        <rdfs:label xml:lang="de">Einband</rdfs:label>
        <rdfs:label xml:lang="en">Binding</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#entry">
        <rdfs:label xml:lang="de">Eintrag</rdfs:label>
        <rdfs:label xml:lang="en">Entry</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#corrigenda">
        <rdfs:label xml:lang="de">Errata</rdfs:label>
        <rdfs:label xml:lang="en">Corrigenda</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#bookplate">
        <rdfs:label xml:lang="de">Exlibris</rdfs:label>
        <rdfs:label xml:lang="en">Bookplate</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#fascicle">
        <rdfs:label xml:lang="de">Faszikel</rdfs:label>
        <rdfs:label xml:lang="en">Fascicle</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#leaflet">
        <rdfs:label xml:lang="de">Flugblatt</rdfs:label>
        <rdfs:label xml:lang="en">Leaflet</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#research_paper">
        <rdfs:label xml:lang="de">Forschungsarbeit</rdfs:label>
        <rdfs:label xml:lang="en">Research Paper</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#photograph">
        <rdfs:label xml:lang="de">Fotografie</rdfs:label>
        <rdfs:label xml:lang="en">Photograph</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#fragment">
        <rdfs:label xml:lang="de">Fragment</rdfs:label>
        <rdfs:label xml:lang="en">Fragment</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#land_register">
        <rdfs:label xml:lang="de">Grundbuch</rdfs:label>
        <rdfs:label xml:lang="en">Land Register</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#ground_plan">
        <rdfs:label xml:lang="de">Grundriss</rdfs:label>
        <rdfs:label xml:lang="en">Ground Plan</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#habilitation_thesis">
        <rdfs:label xml:lang="de">Habilitation</rdfs:label>
        <rdfs:label xml:lang="en">Habilitation Thesis</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#manuscript">
        <rdfs:label xml:lang="de">Handschrift</rdfs:label>
        <rdfs:label xml:lang="en">Manuscript</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#illustration">
        <rdfs:label xml:lang="de">Illustration</rdfs:label>
        <rdfs:label xml:lang="en">Illustration</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#imprint">
        <rdfs:label xml:lang="de">Impressum</rdfs:label>
        <rdfs:label xml:lang="en">Imprint</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#contents">
        <rdfs:label xml:lang="de">Inhaltsverzeichnis</rdfs:label>
        <rdfs:label xml:lang="en">Table Of Contents</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#initial_decoration">
        <rdfs:label xml:lang="de">Initialschmuck</rdfs:label>
        <rdfs:label xml:lang="en">Initial Decoration</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#year">
        <rdfs:label xml:lang="de">Jahr</rdfs:label>
        <rdfs:label xml:lang="en">Year</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#chapter">
        <rdfs:label xml:lang="de">Kapitel</rdfs:label>
        <rdfs:label xml:lang="en">Chapter</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#map">
        <rdfs:label xml:lang="de">Karte</rdfs:label>
        <rdfs:label xml:lang="en">Map</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#cartulary">
        <rdfs:label xml:lang="de">Kartular</rdfs:label>
        <rdfs:label xml:lang="en">Cartulary</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#colophon">
        <rdfs:label xml:lang="de">Kolophon</rdfs:label>
        <rdfs:label xml:lang="en">Colophon</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#ephemera">
        <rdfs:label xml:lang="de">Konzertprogramm</rdfs:label>
        <rdfs:label xml:lang="en">Ephemera</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#engraved_titlepage">
        <rdfs:label xml:lang="de">Kupfertitel</rdfs:label>
        <rdfs:label xml:lang="en">Engraved Titlepage</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#magister_thesis">
        <rdfs:label xml:lang="de">Magisterarbeit</rdfs:label>
        <rdfs:label xml:lang="en">Magister Thesis</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#folder">
        <rdfs:label xml:lang="de">Mappe</rdfs:label>
        <rdfs:label xml:lang="en">Folder</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#master_thesis">
        <rdfs:label xml:lang="de">Masterarbeit</rdfs:label>
        <rdfs:label xml:lang="en">Master Thesis</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#multivolume_work">
        <rdfs:label xml:lang="de">Mehrbändiges Werk</rdfs:label>
        <rdfs:label xml:lang="en">Multivolume Work</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#month">
        <rdfs:label xml:lang="de">Monat</rdfs:label>
        <rdfs:label xml:lang="en">Month</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#monograph">
        <rdfs:label xml:lang="de">Monographie</rdfs:label>
        <rdfs:label xml:lang="en">Monograph</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#musical_notation">
        <rdfs:label xml:lang="de">Musiknotation</rdfs:label>
        <rdfs:label xml:lang="en">Musical Notation</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#periodical">
        <rdfs:label xml:lang="de">Periodica</rdfs:label>
        <rdfs:label xml:lang="en">Periodical</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#poster">
        <rdfs:label xml:lang="de">Plakat</rdfs:label>
        <rdfs:label xml:lang="en">Poster</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#plan">
        <rdfs:label xml:lang="de">Plan</rdfs:label>
        <rdfs:label xml:lang="en">Plan</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#privileges">
        <rdfs:label xml:lang="de">Privilegien</rdfs:label>
        <rdfs:label xml:lang="en">Privileges</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#index">
        <rdfs:label xml:lang="de">Register</rdfs:label>
        <rdfs:label xml:lang="en">Index</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#spine">
        <rdfs:label xml:lang="de">Rücken</rdfs:label>
        <rdfs:label xml:lang="en">Spine</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#scheme">
        <rdfs:label xml:lang="de">Schema</rdfs:label>
        <rdfs:label xml:lang="en">Scheme</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#edge">
        <rdfs:label xml:lang="de">Schnitt</rdfs:label>
        <rdfs:label xml:lang="en">Edge</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#seal">
        <rdfs:label xml:lang="de">Siegel</rdfs:label>
        <rdfs:label xml:lang="en">Seal</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#paste_down">
        <rdfs:label xml:lang="de">Spiegel</rdfs:label>
        <rdfs:label xml:lang="en">Paste Down</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#stamp">
        <rdfs:label xml:lang="de">Stempel</rdfs:label>
        <rdfs:label xml:lang="en">Stamp</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#study">
        <rdfs:label xml:lang="de">Studie</rdfs:label>
        <rdfs:label xml:lang="en">Study</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#table">
        <rdfs:label xml:lang="de">Tabelle</rdfs:label>
        <rdfs:label xml:lang="en">Table</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#day">
        <rdfs:label xml:lang="de">Tag</rdfs:label>
        <rdfs:label xml:lang="en">Day</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#proceeding">
        <rdfs:label xml:lang="de">Tagungsband</rdfs:label>
        <rdfs:label xml:lang="en">Proceeding</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#text">
        <rdfs:label xml:lang="de">Text</rdfs:label>
        <rdfs:label xml:lang="en">Text</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#title_page">
        <rdfs:label xml:lang="de">Titelblatt</rdfs:label>
        <rdfs:label xml:lang="en">Title Page</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#subinventory">
        <rdfs:label xml:lang="de">Unterbestannd</rdfs:label>
        <rdfs:label xml:lang="en">Subinventory</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#act">
        <rdfs:label xml:lang="de">Urkunde</rdfs:label>
        <rdfs:label xml:lang="en">Act</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#judgement">
        <rdfs:label xml:lang="de">Urteil</rdfs:label>
        <rdfs:label xml:lang="en">Judgement</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#verse">
        <rdfs:label xml:lang="de">Verse</rdfs:label>
        <rdfs:label xml:lang="en">Verse</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#note">
        <rdfs:label xml:lang="de">Vermerk</rdfs:label>
        <rdfs:label xml:lang="en">Note</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#preprint">
        <rdfs:label xml:lang="de">Vorabdruck</rdfs:label>
        <rdfs:label xml:lang="en">Preprint</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#dossier">
        <rdfs:label xml:lang="de">Vorgang</rdfs:label>
        <rdfs:label xml:lang="en">Dossier</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#lecture">
        <rdfs:label xml:lang="de">Vorlesung</rdfs:label>
        <rdfs:label xml:lang="en">Lecture</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#endsheet">
        <rdfs:label xml:lang="de">Vorsatz</rdfs:label>
        <rdfs:label xml:lang="en">Endsheet</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#paper">
        <rdfs:label xml:lang="de">Vortrag</rdfs:label>
        <rdfs:label xml:lang="en">Paper</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#preface">
        <rdfs:label xml:lang="de">Vorwort</rdfs:label>
        <rdfs:label xml:lang="en">Preface</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#dedication">
        <rdfs:label xml:lang="de">Widmung</rdfs:label>
        <rdfs:label xml:lang="en">Dedication</rdfs:label>
      </rdf:Class>
      <rdf:Class rdf:about="http://iiif.sub.uni-hamburg.de/vocab#newspaper">
        <rdfs:label xml:lang="de">Zeitung</rdfs:label>
        <rdfs:label xml:lang="en">Newspaper</rdfs:label>
      </rdf:Class>
    </rdf:RDF>
  </xsl:variable>

  <xsl:variable name="description" as="element(mods:mods)" select="/mets:mets/mets:dmdSec[@ID = (/mets:mets/mets:structMap[@TYPE = 'LOGICAL']//mets:div/@DMDID)[1]]//mods:mods"/>
  <xsl:variable name="manifestUrl" as="xs:string?" select="$description/mods:location/mods:url[@displayLabel = 'IIIF Manifest']"/>
  <xsl:variable name="rights" as="element(dv:rights)" select="//dv:rights"/>
  <xsl:variable name="links" as="element(dv:links)" select="//dv:links"/>

  <xsl:template match="mets:mets">
    <xsl:choose>
      <xsl:when test="$manifestUrl">
        <xsl:variable name="entity" as="element(json:map)?">
          <xsl:choose>
            <xsl:when test="$entityType eq 'Range'">
              <xsl:call-template name="Range">
                <xsl:with-param name="rangeId" as="xs:string" select="$entityId"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entityType eq 'Canvas'">
              <xsl:call-template name="Canvas">
                <xsl:with-param name="canvasId" as="xs:string" select="$entityId"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entityType eq 'Sequence'">
              <xsl:call-template name="Sequence">
                <xsl:with-param name="sequenceId" as="xs:string" select="$entityId"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entityType eq 'Manifest'">
              <xsl:call-template name="Manifest"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="empty($entity)">
            <error/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$entity"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <error/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Return the entire manifest. -->
  <xsl:template name="Manifest" as="element(json:map)?">
    <json:map>
      <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      <json:string key="@id">{$manifestUrl}</json:string>
      <json:string key="@type">sc:Manifest</json:string>
      <json:string key="label">
        <xsl:call-template name="fn:manifest-label"/>
      </json:string>
      <xsl:apply-templates select="$description" mode="metadata"/>
      <json:string key="attribution">{$rights/dv:owner}</json:string>
      <json:string key="logo">{$rights/dv:ownerLogo}</json:string>
      <json:map key="related">
        <json:string key="@id">{$links/dv:presentation}</json:string>
        <json:string key="format">text/html</json:string>
      </json:map>
      <json:array key="sequences">
        <xsl:apply-templates select="mets:structMap/mets:div[@TYPE = 'physSequence']"/>
      </json:array>
      <json:array key="structures">
        <xsl:apply-templates select="mets:structMap[@TYPE = 'LOGICAL']"/>
      </json:array>
    </json:map>
  </xsl:template>

  <!-- Return a single Sequence. -->
  <xsl:template name="Sequence" as="element(json:map)?">
    <xsl:param name="sequenceId" as="xs:string" required="yes"/>
    <xsl:apply-templates select="key('Sequence', $sequenceId)">
      <xsl:with-param name="provide-context" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="mets:div[@TYPE = 'physSequence']">
    <xsl:param name="provide-context" as="xs:boolean" select="false()"/>
    <json:map>
      <xsl:if test="$provide-context">
        <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
        <json:string key="within">{$manifestUrl}</json:string>
      </xsl:if>
      <json:string key="@id">{fn:sequence-uri(@ID, $manifestUrl)}</json:string>
      <json:string key="@type">sc:Sequence</json:string>
      <json:array key="canvases">
        <xsl:apply-templates select="mets:div[@TYPE = 'page']"/>
      </json:array>
    </json:map>
  </xsl:template>

  <!-- Return a single canvas. -->
  <xsl:template name="Canvas" as="element(json:map)?">
    <xsl:param name="canvasId" as="xs:string" required="yes"/>
    <xsl:apply-templates select="key('Canvas', $canvasId)">
      <xsl:with-param name="provide-context" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="mets:div[@TYPE = 'page']">
    <xsl:param name="provide-context" as="xs:boolean" select="false()"/>
    <xsl:variable name="image" as="element(mets:file)" select="key('Image', mets:fptr/@FILEID)"/>
    <xsl:variable name="dimensions" as="map(xs:string, xs:integer)">
      <xsl:call-template name="fn:image-dimensions">
        <xsl:with-param name="image" as="element(mets:file)" select="$image"/>
      </xsl:call-template>
    </xsl:variable>
    <json:map>
      <xsl:if test="$provide-context">
        <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
        <json:string key="within">{fn:sequence-uri(ancestor::mets:div[@TYPE = 'physSequence']/@ID, $manifestUrl)}</json:string>
      </xsl:if>
      <json:string key="@id">{fn:canvas-uri(@ID, $manifestUrl)}</json:string>
      <json:string key="@type">sc:Canvas</json:string>
      <json:string key="label">{(@ORDERLABEL[. ne ' - '], @ORDER, position())[1]}</json:string>
      <json:number key="width">{$dimensions?width}</json:number>
      <json:number key="height">{$dimensions?height}</json:number>
      <json:array key="images">
        <json:map>
          <json:string key="@type">oa:Annotation</json:string>
          <json:string key="motivation">sc:painting</json:string>
          <json:map key="resource">
            <json:string key="@id">{$image/mets:FLocat/@xlink:href}/full/full/0/default.jpg</json:string>
            <json:string key="@type">dctypes:Image</json:string>
            <json:string key="format">image/jpeg</json:string>
            <json:map key="service">
              <json:string key="@context">http://iiif.io/api/image/2/context.json</json:string>
              <json:string key="@id">{$image/mets:FLocat/@xlink:href}</json:string>
              <json:string key="profile">http://iiif.io/api/image/2/level2.json</json:string>
            </json:map>
            <json:number key="width">{$dimensions?width}</json:number>
            <json:number key="height">{$dimensions?height}</json:number>
          </json:map>
          <json:string key="on">{fn:canvas-uri(@ID, $manifestUrl)}</json:string>
        </json:map>
      </json:array>
    </json:map>
  </xsl:template>

  <!-- Return a single Range -->
  <xsl:template name="Range" as="element(json:map)?">
    <xsl:param name="rangeId" as="xs:string" required="yes"/>
    <xsl:apply-templates select="key('Range', $rangeId)">
      <xsl:with-param name="provide-context" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="mets:div[ancestor::mets:structMap[@TYPE = 'LOGICAL']]">
    <xsl:param name="provide-context" as="xs:boolean" select="false()"/>
    <json:map>
      <xsl:if test="$provide-context">
        <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      </xsl:if>
      <xsl:if test="parent::mets:structMap">
        <json:string key="viewingHint">top</json:string>
      </xsl:if>
      <json:string key="@id">{fn:range-uri(@ID, $manifestUrl)}</json:string>
      <json:string key="@type">sc:Range</json:string>
      <xsl:choose>
        <xsl:when test="normalize-space(@LABEL)">
          <json:string key="label">{normalize-space(@LABEL)}</json:string>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="fn:label">
            <xsl:with-param name="property" as="xs:string" select="concat('http://iiif.sub.uni-hamburg.de/vocab#', @TYPE)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:where-populated>
        <json:array key="ranges">
          <xsl:for-each select="mets:div">
            <json:string>{fn:range-uri(@ID, $manifestUrl)}</json:string>
          </xsl:for-each>
        </json:array>
      </xsl:where-populated>
      <xsl:where-populated>
        <json:array key="canvases">
          <xsl:for-each select="key('smLink', @ID)">
            <json:string>{fn:canvas-uri(@xlink:to, $manifestUrl)}</json:string>
          </xsl:for-each>
        </json:array>
      </xsl:where-populated>
    </json:map>
    <!-- If provide-context is true(), then we are requested to
         provide a single range only. -->
    <xsl:if test="not($provide-context)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="fn:image-dimensions" as="map(xs:string, xs:integer)">
    <xsl:param name="image" as="element(mets:file)" required="yes"/>
    <xsl:map>
      <xsl:map-entry key="'width'" select="xs:integer(key('Mix', tokenize($image/@ADMID))/mix:BasicImageInformation/mix:BasicImageCharacteristics/mix:imageWidth)"/>
      <xsl:map-entry key="'height'"  select="xs:integer(key('Mix', tokenize($image/@ADMID))/mix:BasicImageInformation/mix:BasicImageCharacteristics/mix:imageHeight)"/>
    </xsl:map>
  </xsl:template>

  <xsl:template name="fn:manifest-label" as="xs:string">
    <xsl:value-of separator=", " select="($description/mods:location/mods:physicalLocation, $description/mods:location/mods:shelfLocator) ! normalize-space()"/>
  </xsl:template>

  <xsl:template mode="metadata" match="mods:mods" as="element(json:array)">
    <json:array key="metadata">
      <!-- Titel -->
      <xsl:apply-templates select="mods:titleInfo" mode="metadata"/>
      <!-- Signatur -->
      <xsl:apply-templates select="mods:location" mode="metadata"/>
      <!-- Verfasser -->
      <xsl:if test="mods:name[mods:role/mods:roleTerm/string() eq 'aut']">
        <xsl:variable name="authors" as="element(json:string)+">
          <xsl:for-each select="mods:name[mods:role/mods:roleTerm/string() eq 'aut']">
            <json:string>
              <xsl:value-of select="normalize-space(mods:displayForm)"/>
            </json:string>
          </xsl:for-each>
        </xsl:variable>

        <json:map>
          <xsl:call-template name="fn:label">
            <xsl:with-param name="property" as="xs:string">http://purl.org/dc/elements/1.1/creator</xsl:with-param>
          </xsl:call-template>
          <xsl:choose>
            <xsl:when test="count($authors) gt 1">
              <json:array key="value">
                <xsl:sequence select="$authors"/>
              </json:array>
            </xsl:when>
            <xsl:otherwise>
              <json:string key="value">
                <xsl:value-of select="$authors"/>
              </json:string>
            </xsl:otherwise>
          </xsl:choose>
        </json:map>
      </xsl:if>
      <!-- Datum -->
      <xsl:apply-templates mode="metadata"
                           select="(mods:originInfo[@eventType = 'production'], mods:originInfo[@eventType = 'publication'], mods:originInfo[not(@eventType)])[1]"/>
    </json:array>
  </xsl:template>

  <xsl:template match="mods:titleInfo[not(@type)]" mode="metadata" as="element(json:map)">
    <json:map>
      <xsl:call-template name="fn:label">
        <xsl:with-param name="property" as="xs:string">http://purl.org/dc/elements/1.1/title</xsl:with-param>
      </xsl:call-template>
      <json:string key="value">
        <xsl:value-of select="(mods:title, mods:subTitle) ! normalize-space()" separator=" : "/>
      </json:string>
    </json:map>
  </xsl:template>

  <xsl:template match="mods:location" mode="metadata" as="element(json:map)">
    <json:map>
      <xsl:call-template name="fn:label">
        <xsl:with-param name="property" as="xs:string">http://purl.org/dc/elements/1.1/identifier</xsl:with-param>
      </xsl:call-template>
      <json:string key="value">
        <xsl:value-of select="(mods:physicalLocation, mods:shelfLocator) ! normalize-space()" separator=", "/>
      </json:string>
    </json:map>
  </xsl:template>

  <xsl:template match="mods:originInfo" mode="metadata" as="element(json:map)">
    <xsl:variable name="date" as="element()*">
      <xsl:choose>
        <xsl:when test="mods:dateIssued">
          <xsl:sequence select="mods:dateIssued"/>
        </xsl:when>
        <xsl:when test="mods:dateCreated">
          <xsl:sequence select="mods:dateCreated"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="exists($date)">
      <json:map>
        <xsl:call-template name="fn:label">
          <xsl:with-param name="property" as="xs:string">http://purl.org/dc/elements/1.1/date</xsl:with-param>
        </xsl:call-template>
        <json:string key="value">
          <xsl:choose>
            <xsl:when test="$date[@point = 'start'] or $date[@point = 'end']">
              <xsl:value-of select="normalize-space(concat($date[@point = 'start'], '–', $date[@point = 'end']))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($date[1])"/>
            </xsl:otherwise>
          </xsl:choose>
        </json:string>
      </json:map>
    </xsl:if>
  </xsl:template>

  <xsl:template name="fn:label" as="element()">
    <xsl:param name="property" as="xs:string" required="true"/>
    <xsl:choose>
      <xsl:when test="$vocab/rdf:*[@rdf:about eq $property]">
        <json:array key="label">
          <xsl:for-each select="$vocab/rdf:*[@rdf:about eq $property]/rdfs:label">
            <xsl:sort select="@xml:lang"/>
            <json:map>
              <json:string key="@language">
                <xsl:value-of select="@xml:lang"/>
              </json:string>
              <json:string key="@value">
                <xsl:value-of select="normalize-space(.)"/>
              </json:string>
            </json:map>
          </xsl:for-each>
        </json:array>
      </xsl:when>
      <xsl:otherwise>
        <json:string key="label">
          <xsl:value-of select="normalize-space($property)"/>
        </json:string>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="fn:canvas-uri" as="xs:string">
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="baseUrl" as="xs:string"/>
    <xsl:sequence select="resolve-uri('canvas/' || $id, $baseUrl)"/>
  </xsl:function>

  <xsl:function name="fn:sequence-uri" as="xs:string">
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="baseUrl" as="xs:string"/>
    <xsl:sequence select="resolve-uri('sequence/' || $id, $baseUrl)"/>
  </xsl:function>

  <xsl:function name="fn:range-uri" as="xs:string">
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="baseUrl" as="xs:string"/>
    <xsl:sequence select="resolve-uri('range/' || $id, $baseUrl)"/>
  </xsl:function>

  <xsl:function name="fn:range-label" as="xs:string">
    <xsl:param name="range" as="element(mets:div)"/>
    <xsl:sequence select="($range/@LABEL, $range/@TYPE, '-')[1]"/>
  </xsl:function>

</xsl:transform>
