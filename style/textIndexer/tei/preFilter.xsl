<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:parse="http://cdlib.org/xtf/parse"
  xmlns:xlink="http://www.w3.org/TR/xlink"
  xmlns:ead="http://www.loc.gov/EAD/"
  xmlns:iutei="http://www.dlib.indiana.edu/collections/TEIgeneral/"
  extension-element-prefixes="date"
  exclude-result-prefixes="#all">
  
  <!--
    Copyright (c) 2005, Regents of the University of California
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without 
    modification, are permitted provided that the following conditions are 
    met:
    
    - Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    - Redistributions in binary form must reproduce the above copyright 
    notice, this list of conditions and the following disclaimer in the 
    documentation and/or other materials provided with the distribution.
    - Neither the name of the University of California nor the names of its
    contributors may be used to endorse or promote products derived from 
    this software without specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
  -->
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates and Functions                                  -->
  <!-- ====================================================================== -->
  
  <xsl:import href="/opt/etext/common/XTF-latest/style/textIndexer/common/preFilterCommon.xsl"/>
  <xsl:import href="../../iutei.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Default: identity transformation                                       -->
  <!-- ====================================================================== -->
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/> 
    </xsl:copy>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/*">
    <xsl:copy>
      <xsl:namespace name="xtf" select="'http://cdlib.org/xtf'"/>
<!--      <xsl:copy-of select="@*"/> -->
      <xsl:call-template name="get-meta"/> 
      <xsl:call-template name="add-meta-keyword"/>
      <xsl:apply-templates/> 
    </xsl:copy>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- TEI Indexing                                                           -->
  <!-- ====================================================================== -->
  
  <!-- Ignored Elements -->

    <!-- Ignored Elements. -->
    <xsl:template match="*[local-name()='teiHeader']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xtf:index" select="'no'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

  
  <xsl:template match="eadheader">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:index" select="'no'"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Structural Indexing -->
  
  <xsl:template match="archdesc">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:sectionType">eadarchdesc</xsl:attribute>
      <xsl:attribute name="daoCount"><xsl:value-of select="count(//dao | //daogrp)"/></xsl:attribute>
      <xsl:attribute name="eadFirstItemID"><xsl:value-of 
        select="(*//@id[../*/dao or ../*/daogrp])[1]"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dsc">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:sectionType">eaddsc</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="archdesc/did/unittitle">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:sectionType">colltitle</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="//controlaccess//corpname[not(@encodinganalog)] 
    | //controlaccess//famname[not(@encodinganalog)]
    | //controlaccess//function[not(@encodinganalog)]
    | //controlaccess//genreform[not(@encodinganalog)]
    | //controlaccess//geogname[not(@encodinganalog)]
    | //controlaccess//name[not(@encodinganalog)]
    | //controlaccess//occupation[not(@encodinganalog)]
    | //controlaccess//persname[not(@encodinganalog)]
    | //controlaccess//subject[not(@encodinganalog)]
    | //controlaccess//title[not(@encodinganalog)]
    | //controlaccess//corpname[starts-with(@encodinganalog,'6')]
    | //controlaccess//famname[starts-with(@encodinganalog,'6')]
    | //controlaccess//function[starts-with(@encodinganalog,'6')]
    | //controlaccess//genreform[starts-with(@encodinganalog,'6')]
    | //controlaccess//geogname[starts-with(@encodinganalog,'6')]
    | //controlaccess//name[starts-with(@encodinganalog,'6')]
    | //controlaccess//occupation[starts-with(@encodinganalog,'6')]
    | //controlaccess//persname[starts-with(@encodinganalog,'6')]
    | //controlaccess//subject[starts-with(@encodinganalog,'6')]
    | //controlaccess//title[starts-with(@encodinganalog,'6')]">
    <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="xtf:sectionType">subject</xsl:attribute>
    <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="geogname">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:sectionType">geogname</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="//repository">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:sectionType">repository</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="persname|corpname">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:sectionType">name</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Metadata Indexing                                                      -->
  <!-- ====================================================================== -->
  
  <!-- Access Dublin Core Record -->
  <xsl:template name="get-meta">
    <xsl:variable name="docpath" select="saxon:system-id()"/>
    <xsl:variable name="base" select="substring-before($docpath, '.xml')"/>
    <xsl:variable name="mdpath" select="concat($base, '.xml.md')"/>
    <xsl:apply-templates select="document($mdpath)//dc" mode="inmeta"/>
  </xsl:template>
  
  <xsl:template name="add-meta-keyword">
    <xsl:variable name="docpath" select="saxon:system-id()"/>
    <xsl:variable name="base" select="substring-before($docpath, '.xml')"/>
    <xsl:variable name="mdpath" select="concat($base, '.xml.md')"/>
    <xsl:apply-templates select="document($mdpath)//dc" mode="keyword"/>
  </xsl:template>
  
  <xsl:template match="creator" mode="browse">
    <browse-creator>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:index" select="'true'"/>
      <xsl:value-of select="replace(string-join(./descendant-or-self::text(), ''), '[^0-9a-zA-Z]', '')"/>
    </browse-creator>
  </xsl:template>

  <xsl:template match="title" mode="browse">
    <browse-title>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:index" select="'true'"/>
      <xsl:value-of select="replace(string-join(./descendant-or-self::text(), ''), '[^0-9a-zA-Z]', '')"/>
    </browse-title>
  </xsl:template>
  
  <xsl:template match="genre" mode="browse">
    <browse-genre>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:index" select="'true'"/>
      <xsl:value-of select="replace(string-join(./descendant-or-self::text(), ''), '[^0-9a-zA-Z]', '')"/>
    </browse-genre>
  </xsl:template>
  
  <xsl:template match="daterange" mode="browse">
    <browse-daterange>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:index" select="'true'"/>
      <xsl:value-of select="replace(string-join(./descendant-or-self::text(), ''), '[^0-9a-zA-Z]', '')"/>
    </browse-daterange>
  </xsl:template>
  
  <!-- Process DC -->
  
  <xsl:template match="dc" mode="keyword">
<!--    This simply puts a copy of the metadata into the keyword index-->
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dc" mode="inmeta">
    <xsl:for-each select="*">
      <xsl:element name="{name()}">
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:value-of select="string()"/>
      </xsl:element>
      <xsl:if test="name() = 'creator'">
        <xsl:apply-templates select="." mode="browse"/>
      </xsl:if>
      <xsl:if test="name() = 'title'">
        <xsl:apply-templates select="." mode="browse"/>
      </xsl:if>
      <xsl:if test="name() = 'genre'">
        <xsl:apply-templates select="." mode="browse"/>
      </xsl:if>
      <xsl:if test="name() = 'daterange'">
        <xsl:apply-templates select="." mode="browse"/>
      </xsl:if>
      <xsl:if test="name() = 'creator'">
        <xsl:if test="./@type='pseudonym'">
          <xsl:element name="creatorPseudonym">
            <xsl:attribute name="xtf:meta" select="'true'"/>
            <xsl:value-of select="string()"/>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>

<!-- Place marker for calculating decade ranges for year -->
<!--            <xsl:element name="date">
                <xsl:value-of select="try/date"></xsl:value-of>
            </xsl:element>
            <xsl:variable name="date">
                <xsl:value-of select="try/date"/>
            </xsl:variable>
            <xsl:variable name="decadeLower">
                <xsl:value-of select='replace($date, "(\d{3})\d","$10")'/>
            </xsl:variable>
            <xsl:variable name="decadeUpper">
                <xsl:value-of select="$decadeLower + 10"/>
            </xsl:variable>
            <xsl:element name="daterange">
                <xsl:value-of select="$decadeLower"/><xsl:text>-</xsl:text><xsl:value-of select="$decadeUpper"/>
            </xsl:element>
-->
    

    <xsl:apply-templates select="title" mode="sort"/>    
    <xsl:apply-templates select="creator" mode="sort"/>
    <xsl:apply-templates select="collection" mode="sort"/>
    <xsl:apply-templates select="date" mode="sort"/>

<!--    Create fields for faceted browsing -->
    <xsl:apply-templates select="publisher" mode="facet"/>
    <xsl:apply-templates select="creator" mode="facet"/>
    <xsl:apply-templates select="daterange" mode="facet"/>
    <xsl:apply-templates select="genre" mode="facet"/>

    <!-- create grouping fields -->
    <xsl:apply-templates select="title" mode="group"/>
    <xsl:apply-templates select="creator" mode="group"/>
    <xsl:apply-templates select="subject" mode="group"/>
    <xsl:apply-templates select="description" mode="group"/>
<!--    <xsl:apply-templates select="publisher" mode="group"/>-->
    <xsl:apply-templates select="contributor" mode="group"/>
    <xsl:apply-templates select="date" mode="group"/>
    <xsl:apply-templates select="type" mode="group"/>
    <xsl:apply-templates select="format" mode="group"/>
    <xsl:apply-templates select="identifier" mode="group"/>
    <xsl:apply-templates select="id-previous" mode="group"/>
    <xsl:apply-templates select="source" mode="group"/>
    <xsl:apply-templates select="language" mode="group"/>
    <xsl:apply-templates select="relation" mode="group"/>
    <xsl:apply-templates select="coverage" mode="group"/>
    <xsl:apply-templates select="rights" mode="group"/>
    
    <!--<xsl:call-template name="metaMissing"/>-->
    
  </xsl:template>
  
  <!-- generate facet-publisher -->
  <xsl:template match="publisher" mode="facet">
    
    <xsl:variable name="publisher" select="string(.)"/>
    
    <facet-publisher>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:facet" select="'yes'"/>
<!--      <xsl:value-of select="string(.)"/>-->
      <xsl:value-of select="iutei:cleanFacet(.)"/>
<!--      <xsl:value-of select="replace(string-join(./descendant-or-self::text(), ''), '[^0-9a-zA-Z]', '')"/>-->
<!--      <xsl:value-of select="parse:name(.)"/>-->
<!--      <xsl:value-of select="parse:title(.)"/>-->
    </facet-publisher>
  </xsl:template>
  
  <!-- generate facet-Author -->
  <xsl:template match="creator" mode="facet">
    
    <xsl:variable name="creator" select="string(.)"/>
    
    <facet-Author>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:facet" select="'yes'"/>
<!--            <xsl:value-of select="string(.)"/>-->
      <xsl:value-of select="iutei:cleanFacet(.)"/>
<!--      <xsl:value-of select="replace(string-join(./descendant-or-self::text(), ''), '[^0-9a-zA-Z]', '')"/>-->

<!--      <xsl:value-of select="replace(./descendant-or-self::text(), '(\()|(\))',  '')"/> -->

<!--      <xsl:value-of select="parse:name(.)"/>-->
    </facet-Author>
  </xsl:template>
  
  <!-- generate facet-Publication_Year -->
  <xsl:template match="daterange" mode="facet">
    
    <xsl:variable name="daterange" select="string(.)"/>
    
    <facet-Publication_Year>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:facet" select="'yes'"/>
      <xsl:value-of select="string(.)"/>
    </facet-Publication_Year>
  </xsl:template>
  
  <!-- generate facet-publisher -->
  <xsl:template match="genre" mode="facet">
    <xsl:variable name="genre" select="string(.)"/>
    <facet-genre>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:facet" select="'yes'"/>
      <xsl:value-of select="iutei:cleanFacet(.)"/>
    </facet-genre>
  </xsl:template>

  <!-- generate sort-title -->
  <xsl:template match="title" mode="sort">
    
    <xsl:variable name="title" select="string(.)"/>
    
    <sort-title>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="parse:title($title)"/>
    </sort-title>
  </xsl:template>
  
  <!-- generate sort-creator -->
  <xsl:template match="creator" mode="sort">
    
    <xsl:variable name="creator" select="string(.)"/>
    
    <xsl:if test="number(position()) = 1">
      <sort-creator>
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:attribute name="xtf:tokenize" select="'no'"/>
        <xsl:copy-of select="parse:name($creator)"/>
      </sort-creator>
    </xsl:if>
    
  </xsl:template>
  
  <!-- generate sort-repository -->
  <xsl:template match="collection" mode="sort">
    
    <xsl:variable name="repository" select="iutei:getRepositoryName(string(.))"/>
    
    <sort-repository>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:copy-of select="$repository"/>
    </sort-repository>
  </xsl:template>
  
  <!-- generate date and sort-date -->
  <xsl:template match="date" mode="sort">
    <xsl:variable name="date" select="if (contains(string(.), '/')) then substring-before(string(.), '/') else string(.)"/>
    <xsl:variable name="pos" select="number(position())"/>
    <xsl:variable name="real-date">
      <xsl:choose>
        <xsl:when test="matches($date, '[0-9]{4}-[0-9]{2}-[0-9]{2}')">
          <xsl:value-of select="$date"/>
        </xsl:when>
        <xsl:when test="matches($date, '^[0-9]{4}$')">
          <xsl:value-of select="concat($date, '-01-01')"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <sort-date>      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/><xsl:value-of select="$real-date"/></sort-date>
  </xsl:template>
  
  <xsl:function name="iutei:cleanFacet"> 
    <xsl:param name="value"/> 
    <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace($value, 
      '%',     '%25'), 
      '[+]',   '%2B'), 
      '&amp;', 'C-AMP'), 
      ';',     '%3B'), 
      '=',     '%3D'), 
      '\(',     'C-LPAREN'),
      '\)',     'C-RPAREN'),
      '#',     '%23')"/> 
  </xsl:function>
  
</xsl:stylesheet>
