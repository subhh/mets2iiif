<xsl:transform version="3.0" expand-text="yes"
               xmlns:json="http://www.w3.org/2005/xpath-functions"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:output indent="yes"/>

  <xsl:template match="result[empty(doc)]">
    <json:map>
      <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      <json:string key="@type">sc:Collection</json:string>
      <json:number key="total">{@numFound}</json:number>
    </json:map>
  </xsl:template>

  <xsl:template match="result[doc]">
    <json:map>
      <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      <json:string key="@type">sc:Collection</json:string>
      <json:number key="startIndex">{@start}</json:number>
      <json:array key="manifests">
        <xsl:apply-templates/>
      </json:array>
    </json:map>
  </xsl:template>

  <xsl:template match="doc" as="element(json:map)">
    <json:map>
      <xsl:where-populated>
        <json:string key="@id">{arr[@name = 'iiifReference_usi']/str[1]}</json:string>
        <json:string key="@type">sc:Manifest</json:string>
        <json:string key="label">Staats- und Universitätsbibliothek Hamburg, {arr[@name = 'shelfmark_usi']/str[1]}</json:string>
      </xsl:where-populated>
    </json:map>
  </xsl:template>

</xsl:transform>
