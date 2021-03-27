<xsl:transform version="3.0" expand-text="yes"
               xmlns:dv="http://dfg-viewer.de/"
               xmlns:fn="https://iiif.sub.uni-hamburg.de"
               xmlns:json="http://www.w3.org/2005/xpath-functions"
               xmlns:mets="http://www.loc.gov/METS/"
               xmlns:mix="http://www.loc.gov/mix/v20"
               xmlns:mods="http://www.loc.gov/mods/v3"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="manifestUrl" as="xs:string"  required="yes"/>
  <xsl:param name="entityType"  as="xs:string"  required="yes"/>
  <xsl:param name="entityId"    as="xs:string?" required="no"/>

  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode on-no-match="shallow-skip" name="metadata"/>

  <xsl:output indent="yes"/>

  <xsl:key name="Sequence" match="mets:div[@TYPE = 'physSequence']" use="@ID"/>
  <xsl:key name="Canvas" match="mets:div[@TYPE = 'page']" use="@ID"/>
  <xsl:key name="Image" match="mets:file[@MIMETYPE = 'application/vnd.kitodo.iiif']" use="@ID"/>
  <xsl:key name="Mix" match="mix:mix" use="ancestor::mets:techMD/@ID"/>

  <xsl:variable name="description" as="element(mods:mods)" select="/mets:mets/mets:dmdSec[@ID = /mets:mets/mets:structMap[@TYPE = 'LOGICAL']/mets:div/@DMDID]//mods:mods"/>
  <xsl:variable name="rights" as="element(dv:rights)" select="//dv:rights"/>

  <xsl:template match="mets:mets">
    <xsl:variable name="entity" as="element(json:map)?">
      <xsl:choose>
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
      <json:array key="sequences">
        <xsl:apply-templates select="mets:structMap/mets:div[@TYPE = 'physSequence']"/>
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
      </xsl:if>
      <json:string key="@id">{resolve-uri('Sequence/' || @ID, $manifestUrl)}</json:string>
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
      </xsl:if>
      <json:string key="@id">{resolve-uri('Canvas/' || @ID, $manifestUrl)}</json:string>
      <json:string key="@type">sc:Canvas</json:string>
      <json:string key="label">{(@ORDERLABEL, @ORDER, position())[1]}</json:string>
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
          <json:string key="on">{resolve-uri('Canvas/' || @ID, $manifestUrl)}</json:string>
        </json:map>
      </json:array>
    </json:map>
  </xsl:template>

  <xsl:template name="fn:image-dimensions" as="map(xs:string, xs:integer)">
    <xsl:param name="image" as="element(mets:file)" required="yes"/>
    <xsl:map>
      <xsl:map-entry key="'height'" select="xs:integer(key('Mix', tokenize($image/@ADMID))/mix:BasicImageInformation/mix:BasicImageCharacteristics/mix:imageWidth)"/>
      <xsl:map-entry key="'width'"  select="xs:integer(key('Mix', tokenize($image/@ADMID))/mix:BasicImageInformation/mix:BasicImageCharacteristics/mix:imageHeight)"/>
    </xsl:map>
  </xsl:template>

  <xsl:template name="fn:manifest-label" as="xs:string">
    <xsl:value-of separator=", " select="$description/mods:location/(mods:physicalLocation, mods:shelfLocator)"/>
  </xsl:template>

  <xsl:template mode="metadata" match="mods:mods" as="element(json:array)">
    <json:array key="metadata">
      <!-- Signatur -->
      <xsl:apply-templates select="mods:location" mode="metadata"/>
    </json:array>
  </xsl:template>

  <xsl:template match="mods:location" mode="metadata" as="element(json:map)">
    <json:map>
      <json:array key="label">
        <json:map>
          <json:string key="@language">de</json:string>
          <json:string key="@value">Signatur</json:string>
        </json:map>
        <json:map>
          <json:string key="@language">en</json:string>
          <json:string key="@value">Shelfmark</json:string>
        </json:map>
      </json:array>
      <json:string key="value">
        <xsl:value-of select="(mods:physicalLocation, mods:shelfLocator)" separator=", "/>
      </json:string>
    </json:map>
  </xsl:template>
    

</xsl:transform>
