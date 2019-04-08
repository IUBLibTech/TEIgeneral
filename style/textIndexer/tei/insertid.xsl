<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  version="1.0">
  
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="processing-instruction('xml-stylesheet')">
    <xsl:comment><xsl:value-of select="."/></xsl:comment>
  </xsl:template>
  
  <xsl:template match="@*|node()"> <!-- copy select elements -->
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="//*[head] | /ead/archdesc/* | /ead/archdesc/dsc/c01[@level='series']
                       | /ead/archdesc/dsc/c01[@level='collection'] 
    | /ead/archdesc/dsc/c01[@level='recordgrp'] | /ead/archdesc/dsc/c01[@level='subseries'] 
    | /ead/archdesc/dsc/c02[@level='series'] | /ead/archdesc/dsc/c02[@level='collection'] 
    | /ead/archdesc/dsc/c02[@level='recordgrp'] | /ead/archdesc/dsc/c02[@level='subseries'] "> 
    <!-- copy select elements -->
    <xsl:copy>
      <xsl:if test="not(@id)">
        <xsl:attribute name="id">
          <xsl:value-of  select="generate-id()"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <!--
  <xsl:template match="comment()">
    <xsl:comment><xsl:value-of select="."/></xsl:comment>
  </xsl:template>
    -->
  
  
</xsl:stylesheet>
