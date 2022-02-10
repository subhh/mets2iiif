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

  <xsl:variable name="properties" as="element(rdf:Property)+">
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
      <json:string key="@id">{resolve-uri('sequence/' || @ID, $manifestUrl)}</json:string>
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
        <json:string key="within">{resolve-uri('sequence/' || ancestor::mets:div[@TYPE = 'physSequence']/@ID, $manifestUrl)}</json:string>
      </xsl:if>
      <json:string key="@id">{resolve-uri('canvas/' || @ID, $manifestUrl)}</json:string>
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
          <json:string key="on">{resolve-uri('canvas/' || @ID, $manifestUrl)}</json:string>
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
      <json:string key="@id">{resolve-uri('range/' || @ID, $manifestUrl)}</json:string>
      <json:string key="@type">sc:Range</json:string>
    </json:map>
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
          <xsl:call-template name="fn:metadata-label">
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
      <xsl:call-template name="fn:metadata-label">
        <xsl:with-param name="property" as="xs:string">http://purl.org/dc/elements/1.1/title</xsl:with-param>
      </xsl:call-template>
      <json:string key="value">
        <xsl:value-of select="(mods:title, mods:subTitle) ! normalize-space()" separator=" : "/>
      </json:string>
    </json:map>
  </xsl:template>

  <xsl:template match="mods:location" mode="metadata" as="element(json:map)">
    <json:map>
      <xsl:call-template name="fn:metadata-label">
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
        <xsl:call-template name="fn:metadata-label">
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

  <xsl:template name="fn:metadata-label" as="element()">
    <xsl:param name="property" as="xs:string" required="true"/>
    <xsl:choose>
      <xsl:when test="$properties[@rdf:about eq $property]">
        <json:array key="label">
          <xsl:for-each select="$properties[@rdf:about eq $property]/rdfs:label">
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

  <xsl:function name="fn:covered-canvas" as="element(mets:div)+">
    <xsl:param name="range" as="element(mets:div)"/>
    <xsl:variable name="canvasId" as="xs:string+" select="key('smLink', $range//@ID, root($range))/@xlink:to"/>
    <xsl:sequence select="key('Canvas', $canvasId, root($range))"/>
  </xsl:function>

</xsl:transform>
