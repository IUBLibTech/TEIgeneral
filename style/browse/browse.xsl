<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 This file generates a list of items of a type. The lists can be used to generate
 the HTML browse pages. (Currently it assumes there's only creator and subject browsing
 -->
<xsl:stylesheet xmlns:functx="http://www.functx.com" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" 
  xmlns:iutei="http://www.dlib.indiana.edu/collections/vwwp/" version="2.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
  <xsl:include href="../iutei.xsl"/>
  
  <xsl:param name="dir"/>
  <xsl:param name="type"/>
  
  <xsl:template match="/">
    <xsl:variable name="terms">
      <xsl:choose>
        <xsl:when test="$type = 'creator'">
          <xsl:for-each select="collection($dir)//dc/creator">
            <xsl:if test="../contentType = 'book'">
            <term eadid="{../id}">
              <xsl:call-template name="cleanTerm">
                <xsl:with-param name="term" select="."/>
              </xsl:call-template>
              <xsl:if test="../creator[@type='pseudonym'] and not(./@type='pseudonym')">
                <actualTerm>
                      <xsl:value-of select="../creator[@type='pseudonym']"/>
                </actualTerm>
              </xsl:if>
              <xsl:if test="./@type='pseudonym'">
                <actualTerm>
                  <xsl:value-of select="../creator[not(@type='pseudonym')]"/>
                </actualTerm>
              </xsl:if>
            </term>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$type = 'title'">
          <xsl:for-each select="collection($dir)//dc/title">
            <xsl:if test="../contentType = 'book'">
            <term>
              <xsl:choose>
                <xsl:when test="../filingTitle">
                  <xsl:value-of select="../filingTitle"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="cleanTerm">
                    <xsl:with-param name="term" select="."/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="../filingTitle">
                <actualTerm>
                  <xsl:value-of select="."/>
                </actualTerm>
              </xsl:if>
            </term>
            </xsl:if>
          </xsl:for-each>
          </xsl:when>
          <xsl:when test="$type = 'daterange'">
            <xsl:for-each select="collection($dir)//dc/daterange">
              <xsl:if test="../contentType = 'book'">
              <term>
                <xsl:call-template name="cleanTerm">
                  <xsl:with-param name="term" select="."/>
                </xsl:call-template>
              </term>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
        <xsl:when test="$type = 'genre'">
          <xsl:for-each select="collection($dir)//dc/genre">
            <xsl:if test="../contentType = 'book'">
            <term>
              <xsl:call-template name="cleanTerm">
                <xsl:with-param name="term" select="."/>
              </xsl:call-template>
            </term>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$type = 'subject'">
          <xsl:for-each select="collection($dir)//dc/subject">
            <xsl:if test="../contentType = 'book'">
            <term>
              <xsl:call-template name="cleanTerm">
                <xsl:with-param name="term" select="."/>
              </xsl:call-template>
            </term>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <list >
      <xsl:for-each-group select="$terms/term" group-by="upper-case(text())">
        <xsl:sort select="upper-case(text())"/>
        <xsl:element name="term">
          <xsl:attribute name="size">
            <xsl:value-of select="count(current-group())"></xsl:value-of>
          </xsl:attribute>
          <xsl:value-of select="current-group()[1]/text()"></xsl:value-of>
          <xsl:if test="./actualTerm != ''">
            <xsl:element name="actualTerm">
              <xsl:value-of select="./actualTerm"/>
            </xsl:element>
          </xsl:if>
         </xsl:element>
      </xsl:for-each-group>
    </list>
  </xsl:template>
  
  <xsl:template name="cleanTerm">
    <xsl:param name="term"/>
    <xsl:variable name="tn">
      <xsl:choose>
        <xsl:when test="$type = 'subject'">
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:comment>
          <xsl:variable name="t1" select="replace($term, '--.*$', '')"/>
          <xsl:value-of select="replace($t1, '[\s|\.]+$', '')"/>    
          </xsl:comment>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$tn"/>
  </xsl:template>
  
  <xsl:function name="functx:escape-for-regex" 
    xmlns:functx="http://www.functx.com" >
    <xsl:param name="arg" as="xs:string?"/> 
    
    <xsl:sequence select=" 
      replace($arg,
      '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
      "/>
    
  </xsl:function>
  
  
  <xsl:function name="functx:contains-word">
    <xsl:param name="arg" as="xs:string?"/> 
    <xsl:param name="word" as="xs:string"/> 
    
    <xsl:sequence select=" 
      matches(upper-case($arg),
      concat('^(.*\W)?',
      upper-case(functx:escape-for-regex($word)),
      '(\W.*)?$'))
      "/>
    
  </xsl:function>
  
</xsl:stylesheet>
