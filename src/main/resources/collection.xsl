<xsl:transform version="3.0" expand-text="yes"
               xmlns:json="http://www.w3.org/2005/xpath-functions"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:mode on-no-match="shallow-skip"/>

  <xsl:output indent="yes"/>

  <xsl:param name="itemsPerPage" as="xs:integer" required="yes"/>
  <xsl:param name="name" as="xs:string" required="true"/>

  <xsl:variable name="collectionUri" as="xs:string">https://iiif.sub.uni-hamburg.de/collection/{encode-for-uri($name)}</xsl:variable>
  <xsl:variable name="collectionLabel" as="xs:string">Digitalisierte Bestände</xsl:variable>

  <xsl:template match="result[@numFound = '0']">
    <error/>
  </xsl:template>

  <xsl:template match="result[doc]">
    <xsl:variable name="page" as="xs:integer" select="1 + (@start idiv $itemsPerPage)"/>
    <json:map>
      <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      <json:string key="@id">{$collectionUri}/{$page}</json:string>
      <json:string key="@type">sc:Collection</json:string>
      <json:string key="within">{$collectionUri}</json:string>
      <xsl:if test="$page gt 1">
        <json:string key="prev">{$collectionUri}/{$page - 1}</json:string>
      </xsl:if>
      <xsl:if test="$page lt (@numFound idiv $itemsPerPage)">
        <json:string key="next">{$collectionUri}/{$page + 1}</json:string>
      </xsl:if>
      <json:array key="manifests">
        <xsl:apply-templates/>
      </json:array>
    </json:map>
  </xsl:template>

  <xsl:template match="result[empty(doc)]">
    <json:map>
      <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      <json:string key="@id">{$collectionUri}</json:string>
      <json:string key="@type">sc:Collection</json:string>
      <json:string key="label">{$collectionLabel}</json:string>
      <json:number key="total">{@numFound}</json:number>
      <json:string key="first">{$collectionUri}/1</json:string>
    </json:map>
  </xsl:template>

  <xsl:template match="doc[arr[@name = 'iiifReference_usi']/str]">
    <json:map>
      <json:string key="@id">{arr[@name = 'iiifReference_usi']/str[1]}</json:string>
      <json:string key="@type">sc:Manifest</json:string>
      <xsl:where-populated>
        <json:string key="label">{arr[@name = 'shelfmark_usi']/str[1]}</json:string>
      </xsl:where-populated>
      <xsl:where-populated>
        <json:string key="description">{arr[@name = 'title_usi']/str[1]}</json:string>
      </xsl:where-populated>
    </json:map>
  </xsl:template>

</xsl:transform>
