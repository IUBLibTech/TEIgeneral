<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:strip-space elements="*"/>

<xsl:template match="*"/>

  <xsl:template match="/">
  <xsl:apply-templates select="TEI"/>
</xsl:template>

<xsl:template match="TEI">
  <xsl:element name="x">
    <xsl:element name="dc">
    <xsl:apply-templates select="teiHeader"/>
    <xsl:apply-templates select="text"/>
   </xsl:element>
  </xsl:element>
</xsl:template>


  <xsl:template match="teiHeader">
    
    <xsl:apply-templates select="fileDesc">
      <xsl:with-param name="type" select="'dc'"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates select="fileDesc/publicationStmt/idno[not(@n='previous')]">
      <xsl:with-param name="type" select="'dc'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="fileDesc/publicationStmt/idno[@n='previous']">
      <xsl:with-param name="type" select="'dc-previous'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="profileDesc/textClass">
      <xsl:with-param name="type" select="'dc'"/>
    </xsl:apply-templates>

    <xsl:apply-templates select="fileDesc/sourceDesc">
      <xsl:with-param name="type" select="'dc'"/>
    </xsl:apply-templates>

  </xsl:template>
  
<xsl:template match="fileDesc">
  <xsl:param name="type"/>
<!--  Get the content type to set a meta tag and help make decisions here-->
  <xsl:variable name="content_type">
    <xsl:choose>
      <xsl:when test="sourceDesc/bibl/title">
        <xsl:value-of select="sourceDesc/bibl/title/@type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>book</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
<!--  Literally create a meta tag inline to the metadata file for use in interface-->
  <xsl:element name="contentType">
    <xsl:value-of select="$content_type"/>
  </xsl:element>

  <!--  Check for filing title in either old or ongoing books-->
  <xsl:if test="titleStmt/title[@type='filing']">
    <xsl:element name="filingTitle">
      <xsl:value-of select="titleStmt/title[@type='filing']">
      </xsl:value-of></xsl:element>
  </xsl:if>
  <xsl:choose>
    <!-- Biographies and Critical Introductions Title-->
    <xsl:when test="sourceDesc/bibl/title">
      <xsl:for-each select="sourceDesc/bibl/title[1]">
        <xsl:call-template name="dc_title"/>
      </xsl:for-each>
    </xsl:when>
    <!-- New/Ongoing Texts Title-->
    <xsl:when test="sourceDesc/biblStruct/monogr/title">
      <xsl:for-each select="sourceDesc/biblStruct/monogr">
        <xsl:call-template name="dc_title">
          <xsl:with-param name="type">ongoing</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:when>
    <!-- Old/Original Texts Title-->
    <xsl:otherwise>
      <xsl:for-each select="sourceDesc/biblFull/titleStmt/title[1]">
        <xsl:call-template name="dc_title"/>
      </xsl:for-each>
    </xsl:otherwise>	
  </xsl:choose>
  
  <xsl:choose>
    <!-- Critical Introduction Author -->
    <xsl:when test="sourceDesc/bibl/author">
      <xsl:for-each select="sourceDesc/bibl/author">
        <xsl:call-template name="dc_author"/>
      </xsl:for-each>
    </xsl:when>
    <!-- New/Ongoing Text Author -->
    <xsl:when test="sourceDesc/biblStruct/monogr/author">
      <xsl:for-each select="sourceDesc/biblStruct/monogr/author">
        <xsl:call-template name="dc_author"/>
      </xsl:for-each>
    </xsl:when>
    <!-- Old/Original Text Author -->
    <xsl:otherwise>
      <xsl:for-each select="sourceDesc/biblFull/titleStmt/author">
        <xsl:call-template name="dc_author"/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  
  <!-- Other source metadata in biblStruct/monogr -->
  <xsl:choose>
    <xsl:when test="sourceDesc/biblStruct/monogr">
      <xsl:apply-templates select="sourceDesc/biblStruct/monogr">
        <xsl:with-param name="type" select="$type"/>
      </xsl:apply-templates>
    </xsl:when>
    
    <xsl:when test="not(contains($content_type, 'book'))" >
      <xsl:apply-templates select="publicationStmt/publisher">
        <xsl:with-param name="type" select="$type"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="publicationStmt/pubPlace">
        <xsl:with-param name="type" select="$type"/>
      </xsl:apply-templates>
     </xsl:when>
    
  </xsl:choose>
  
  
</xsl:template>

  <xsl:template match="sourceDesc">
    <xsl:param name="type"/>
    <xsl:apply-templates>
      <xsl:with-param name="type" select="$type"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="monogr">
    <xsl:param name="type"/>
    <xsl:apply-templates>
      <xsl:with-param name="type" select="$type"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="profileDesc/textClass">
    <xsl:param name="type"/>
    <xsl:apply-templates>
      <xsl:with-param name="type" select="$type"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="keywords[@scheme = '#lcsh']">
    <xsl:param name="type"/>
    <xsl:for-each select="list/item">
      <xsl:element name="subject">
        <xsl:value-of select="normalize-space(replace(.,' -- ','--'))"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="keywords[@scheme = '#mla']">
    <xsl:param name="type"/>
    <xsl:for-each select="list/item">
      <xsl:element name="genre">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="biblFull">
    <xsl:param name="type"/>
    <xsl:apply-templates select="extent"/>
    <xsl:apply-templates>
      <xsl:with-param name="type" select="$type"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="bibl">
    <xsl:param name="type"/>
    <xsl:apply-templates select="extent"/>
    <xsl:apply-templates>
      <xsl:with-param name="type" select="$type"/>
    </xsl:apply-templates>
  </xsl:template>
  

<xsl:template match="titleStmt">
  <xsl:param name="type"/>
  <xsl:apply-templates >
    <xsl:with-param name="type" select="$type"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="publicationStmt">
  <xsl:param name="type"/>
  <xsl:apply-templates>
    <xsl:with-param name="type" select="$type"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="imprint">
  <xsl:param name="type"/>
  <xsl:apply-templates>
    <xsl:with-param name="type">dc</xsl:with-param>
  </xsl:apply-templates>

</xsl:template>
  

  <xsl:template match="fileDesc/titleStmt/title">
  <xsl:param name="type"/>
  <xsl:if test="not(@type='gmd')">
    <xsl:choose>
      <xsl:when test="$type='dc'">
        <xsl:call-template name="dc_title"/>
      </xsl:when>
      <xsl:when test="$type='x'">
        <xsl:call-template name="x_title"/>
      </xsl:when>
    </xsl:choose>
  </xsl:if>
  <xsl:apply-templates select="date">
    <xsl:with-param name="type" select="$type"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="date">
  <xsl:param name="type"/>
  <xsl:if test="$type='dc'">
    <xsl:call-template name="dc_date"/>
  </xsl:if>
</xsl:template>

  <xsl:template match="extent">
    <xsl:param name="type"/>
    <xsl:if test="$type='dc'">
      <xsl:call-template name="dc_extent"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="pubPlace">
    <xsl:param name="type"/>
    <xsl:if test="$type='dc'">
      <xsl:call-template name="dc_pubPlace"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="publisher">
    <xsl:param name="type"/>
    <xsl:if test="$type='dc'">
      <xsl:call-template name="dc_publisher"/>
    </xsl:if>
  </xsl:template>
  

<xsl:template match="idno">
  <xsl:param name="type"/>
  <xsl:if test="$type='dc'">
    <xsl:call-template name="dc_identifier"/>
  </xsl:if>
  <xsl:if test="$type='dc-previous'">
    <xsl:call-template name="dc_identifier-previous"/>
  </xsl:if>
</xsl:template>

  <xsl:template match="fileDesc/titleStmt/author">
    <xsl:param name="type"/>
    <xsl:if test="$type='dc'">
      <xsl:call-template name="dc_author"/>
    </xsl:if>
  </xsl:template>
  

<xsl:template name="content_type">
  <xsl:param name="type"/>
  <xsl:choose>
    <xsl:when test="$type='introBio'">
      <xsl:element name="contentType">
          <xsl:choose>
            <xsl:when test="@type='biography' or @type='introduction'">
              <xsl:value-of select="@type"/>
            </xsl:when>
          </xsl:choose>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="contentType">
        <xsl:text>book</xsl:text>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
  <xsl:template name="content_type_var">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type='introBio'">
          <xsl:choose>
            <xsl:when test="@type='biography' or @type='introduction'">
              <xsl:value-of select="@type"/>
            </xsl:when>
          </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
          <xsl:text>book</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template name="dc_title">
  <xsl:param name="type"/>
  <xsl:choose>
    <xsl:when test="$type='ongoing'">
      <xsl:element name="title">
        <xsl:for-each select="title">
          <xsl:choose>
            <xsl:when test="@type='marc245a'">
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:when test="@type='marc245c'">
              <xsl:text> </xsl:text><xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test=".[@type='filing']">
          <xsl:element name="filingTitle">
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="title">
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:element>
          <xsl:if test="starts-with(.,'The ') or starts-with(.,'A ') or starts-with(.,'An ')">
            <xsl:element name="filingTitle">
              <xsl:choose>
                <xsl:when test="matches(., '^A ')">
                  <xsl:value-of select="replace(., '^A (.+)', '$1')"/>
                </xsl:when>
                <xsl:when test="matches(., '^An ')">
                  <xsl:value-of select="replace(., '^An (.+)', '$1')"/>
                </xsl:when>
                <xsl:when test="matches(., '^The ')">
                  <xsl:value-of select="replace(., '^The (.+)', '$1')"/>
                </xsl:when>
              </xsl:choose>
            </xsl:element>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="x_title">
  <xsl:element name="xtitle">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:element>
</xsl:template>

  <xsl:template name="x_creator">
    <xsl:element name="xcreator">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
  </xsl:template>

<xsl:template name="dc_identifier">
  <xsl:element name="identifier">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:element>
  <xsl:element name="collection">
    <xsl:value-of select="normalize-space(./@type)"/>
  </xsl:element>
</xsl:template>

  <xsl:template name="dc_identifier-previous">
    <xsl:element name="id-previous">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
    <xsl:element name="col-previous">
      <xsl:value-of select="normalize-space(./@type)"/>
    </xsl:element>
  </xsl:template>
  

  <xsl:template name="dc_author">
    <xsl:element name="creator">
      <xsl:if test="./name/@type='pseudonym'">
        <xsl:attribute name="type">pseudonym</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
  </xsl:template>
  

<xsl:template name="dc_date">
  <xsl:element name="date">
    <xsl:choose>
      <xsl:when test=".[@when != '']">
        <xsl:value-of select="./@when"/>
      </xsl:when>
      <xsl:when test=".[@from != '']">
        <xsl:value-of select="./@from"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
  
  <xsl:element name="dateDisplay">
    <xsl:value-of select="."/>
  </xsl:element>


  <xsl:variable name="date">
    <xsl:value-of select="."/>
  </xsl:variable>
  <xsl:variable name="cleandate">
    <xsl:value-of select='replace($date, "\D","")'/>
  </xsl:variable>
  <xsl:choose >
    <xsl:when test="$cleandate != '' and (string-length($cleandate) > 2)">
      <xsl:variable name="decadeLower">
        <xsl:value-of select='replace($cleandate, "(\d{3})\d*","$10")'/>
      </xsl:variable>
      <xsl:variable name="decadeUpper">
        <xsl:value-of select="$decadeLower + 9"/>
      </xsl:variable>
      <xsl:element name="daterange">
        <xsl:value-of select="$decadeLower"/><xsl:text>-</xsl:text><xsl:value-of select="$decadeUpper"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="daterange">
        <xsl:text>Date Unknown</xsl:text>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
  
  
</xsl:template>

  <xsl:template name="dc_pubPlace">
    <xsl:element name="pubPlace">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="dc_publisher">
    <xsl:element name="publisher">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="dc_extent">
    <xsl:element name="extent">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
  </xsl:template>
  
  
</xsl:stylesheet>
