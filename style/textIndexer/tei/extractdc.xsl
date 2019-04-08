<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="/">
      <xsl:apply-templates select="ead"/>
  </xsl:template>
  
  <xsl:template match="ead">
    <x>
      <dc>
        <creator>
          <xsl:value-of select="archdesc/did/origination/corpname"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="archdesc/did/origination/persname"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="archdesc/did/origination/title"/>
        </creator>
        <title>
          <xsl:value-of select="string(frontmatter/titlepage/titleproper)"/>
        </title>
        <coverage>
          <xsl:value-of select="archdesc/did/unittitle/unitdate/@normal"/>
        </coverage>
        <identifier>
          <xsl:value-of select="eadheader/eadid"/>
        </identifier>
        <contributor>
          <xsl:value-of select="eadheader/filedesc/titlestmt/author"/>
        </contributor>
        <publisher>
          <xsl:value-of select="eadheader/filedesc/publicationstmt/publisher"/>
        </publisher>
        <date>
          <xsl:value-of select="archdesc/did/unittitle/unitdate/@normal"/>
        </date>
      </dc>
    </x>
  </xsl:template>
  
  <xsl:template match="*"/>
</xsl:stylesheet>
