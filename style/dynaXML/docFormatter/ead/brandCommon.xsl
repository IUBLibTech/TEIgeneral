<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:mets="http://www.loc.gov/METS/"
>

 <!-- Checking the METS for brand is really just a placeholder -->
  <!-- They haven't been encoded with the appropriate behaviorSec yet -->
  <xsl:variable name="brandMechURL" select="//mets:behavior[@BTYPE='brand']/mets:mechanism/@*[local-name()='href']"/>
  <xsl:variable name="brandMech" select="document($brandMechURL)"/>

  <xsl:variable name="brandName">
    <xsl:choose>
      <xsl:when test="$brandMech//brand">
        <xsl:value-of select="$brandMech//brand/@name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'default'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>



 <!-- This is populated by whatever value is used in the URL -->
  <xsl:param name="brand" select="$brandName"/>

  <!-- Retrieve Branding Nodes -->
  <xsl:variable name="brand.file">
    <xsl:choose>
      <xsl:when test="$brand != ''">
        <xsl:copy-of select="document(concat('../../../../brand/',$brand,'.xml'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="document('../../../../brand/default.xml')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="brand.links" select="$brand.file/brand/links"/>
  <xsl:variable name="brand.header" select="$brand.file/brand/header"/>
  <xsl:variable name="brand.header.dynaxml.header" select="$brand.file/brand/header.dynaxml.header"/>
  <xsl:variable name="brand.footer" select="$brand.file/brand/footer"/>
  <xsl:variable name="brand.footerIU" select="$brand.file/brand/footerIU"/>

</xsl:stylesheet>
