<xsl:transform version="3.0" expand-text="yes"
               xmlns:fn="https://iiif.dmaus.name/ns"
               xmlns:json="http://www.w3.org/2005/xpath-functions"
               xmlns:mets="http://www.loc.gov/METS/"
               xmlns:mods="http://www.loc.gov/mods/v3"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="manifestUrl" as="xs:string"  required="yes"/>
  <xsl:param name="entityType"  as="xs:string"  required="yes"/>
  <xsl:param name="entityId"    as="xs:string?" required="no"/>

  <xsl:mode on-no-match="shallow-skip"/>

  <xsl:key name="sequence" match="mets:div[@TYPE = 'physSequence']" use="@ID"/>
  <xsl:key name="canvas" match="mets:div[@TYPE = 'page']" use="@ID"/>
  <xsl:key name="image" match="mets:fileGrp[@USE = 'ZOOM']/mets:file[@MIMETYPE, 'application/vnd.kitodo.iiif']" use="@ID"/>

  <xsl:template match="/">
    <xsl:variable name="entity" as="element(json:map)?">
      <xsl:choose>
        <xsl:when test="$entityType eq 'Manifest'">
          <xsl:call-template name="Manifest"/>
        </xsl:when>
        <xsl:when test="$entityType eq 'Sequence'">
          <xsl:call-template name="Sequence">
            <xsl:with-param name="sequenceId" as="xs:string?" select="$entityId"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$entityType eq 'Canvas'">
          <xsl:call-template name="Canvas">
            <xsl:with-param name="canvasId" as="xs:string?" select="$entityId"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$entity">
        <xsl:sequence select="$entity"/>
      </xsl:when>
      <xsl:otherwise>
        <error>Unable to retrieve entity '{$entityType}' with id '{$entityId}'</error>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Return canvas -->
  <xsl:template name="Canvas" as="element(json:map)?">
    <xsl:param name="canvasId" as="xs:string" required="yes"/>
    <xsl:apply-templates select="key('canvas', $canvasId)">
      <xsl:with-param name="context" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Return sequence -->
  <xsl:template name="Sequence" as="element(json:map)?">
    <xsl:param name="sequenceId" as="xs:string" required="yes"/>
    <xsl:apply-templates select="key('sequence', $sequenceId)">
      <xsl:with-param name="context" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Return manifest -->
  <xsl:template name="Manifest" as="element(json:map)?">
    <json:map>
      <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      <json:string key="@id">{$manifestUrl}</json:string>
      <json:string key="@type">sc:Manifest</json:string>
      <xsl:call-template name="manifest-label">
        <xsl:with-param name="manifest" as="element(mets:mets)" select="/mets:mets"/>
      </xsl:call-template>
      <xsl:call-template name="manifest-metadata">
        <xsl:with-param name="manifest" as="element(mets:mets)" select="/mets:mets"/>
      </xsl:call-template>
      <json:array key="sequences">
        <xsl:apply-templates select="/mets:mets/mets:structMap/mets:div[@TYPE = 'physSequence']"/>
      </json:array>
    </json:map>
  </xsl:template>

  <xsl:template match="mets:div[@TYPE = 'physSequence'][@ID]" as="element(json:map)">
    <xsl:param name="context" as="xs:boolean" select="false()"/>
    <json:map>
      <xsl:if test="$context">
        <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      </xsl:if>
      <json:string key="@id">{resolve-uri("sequence/" || @ID, $manifestUrl)}</json:string>
      <json:string key="@type">sc:Sequence</json:string>
      <xsl:call-template name="sequence-label">
        <xsl:with-param name="sequence" as="element(mets:div)" select="."/>
      </xsl:call-template>
      <json:array key="canvases">
        <xsl:apply-templates select="mets:div[@TYPE = 'page']"/>
      </json:array>
    </json:map>
  </xsl:template>

  <xsl:template match="mets:div[@TYPE = 'page'][@ID]" as="element(json:map)">
    <xsl:param name="context" as="xs:boolean" select="false()"/>
    <xsl:variable name="canvasUrl">{resolve-uri("canvas/" || @ID, $manifestUrl)}</xsl:variable>
    <json:map>
      <xsl:if test="$context">
        <json:string key="@context">http://iiif.io/api/presentation/2/context.json</json:string>
      </xsl:if>
      <json:string key="@id">{$canvasUrl}</json:string>
      <json:string key="@type">sc:Canvas</json:string>
      <xsl:call-template name="canvas-label">
        <xsl:with-param name="canvas" as="element(mets:div)" select="."/>
      </xsl:call-template>
      <xsl:call-template name="canvas-dimensions">
        <xsl:with-param name="canvas" as="element(mets:div)" select="."/>
      </xsl:call-template>
      <!-- TODO: Dimensions! -->
      <json:array key="images">
        <xsl:for-each select="mets:fptr[exists(key('image', @FILEID))]">
          <xsl:variable name="image" as="element(mets:file)" select="key('image', @FILEID)"/>
          <json:map>
            <json:string key="@type">oa:Annotation</json:string>
            <json:string key="motivation">sc:painting</json:string>
            <json:string key="on">{$canvasUrl}</json:string>
            <json:map key="resource">
              <json:string key="@id">{$image/mets:FLocat/@xlink:href}/full/full/0/default.jpg</json:string>
              <json:string key="@type">dctypes:Image</json:string>
              <json:string key="format">image/jpeg</json:string>
              <json:map key="service">
                <json:string key="@context">http://iiif.io/api/image/2/context.json</json:string>
                <json:string key="@id">{$image/mets:FLocat/@xlink:href}</json:string>
                <json:string key="profile">https://iiif.io/api/image/2/level2.json</json:string>
              </json:map>
            </json:map>
          </json:map>
        </xsl:for-each>
      </json:array>
    </json:map>
  </xsl:template>

  <!-- Descriptive Metadata -->
  <xsl:template name="manifest-label" as="element()?">
    <xsl:param name="manifest" as="element(mets:mets)" required="yes"/>
    <json:string key="label">PLACEHOLDER</json:string>
  </xsl:template>

  <xsl:template name="sequence-label" as="element()?">
    <xsl:param name="sequence" as="element(mets:div)" required="yes"/>
    <json:string key="label">PLACEHOLDER</json:string>
  </xsl:template>

  <xsl:template name="canvas-label"   as="element(json:string)?">
    <xsl:param name="canvas" as="element(mets:div)" required="yes"/>
    <json:string key="label">PLACEHOLDER</json:string>
  </xsl:template>

  <xsl:template name="canvas-dimensions" as="element(json:number)+">
    <xsl:param name="canvas" as="element(mets:div)" required="yes"/>
    <json:number key="width">0</json:number>
    <json:number key="height">0</json:number>
  </xsl:template>

  <xsl:template name="manifest-metadata" as="element(json:array)">
    <xsl:param name="manifest" as="element(mets:mets)" required="yes"/>
    <json:array key="metadata"/>
  </xsl:template>

</xsl:transform>
