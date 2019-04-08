<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:cdlpath="http://www.cdlib.org/path/"
  version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="#all"
  >
  
  <xsl:import href="/opt/etext/common/1.6.1/style/dynaXML/docFormatter/docFormatterCommon.xsl"/>  
  <xsl:import href="brandCommon.xsl"/>
  <xsl:import href="xmlverbatim.xsl"/>
  <xsl:import href="search.xsl"/>
  <xsl:import href="parameter.xsl"/>
  <xsl:include href="page.xsl"/>
  <xsl:include href="table.html.xsl"/>
  <xsl:output method="html" media-type="text/html" />
  <xsl:include href="http://voro.cdlib.org:8081/xslt/institution-ark2url.xsl"/>
  
  <xsl:param name="brand"/>
  <xsl:param name="docId"/>
  <xsl:param name="doc.view" select="entire_text"/>
  <xsl:param name="debug"/>
  <xsl:param name="link.id"/>
  <xsl:param name="dynaxmlPath" select="'view'"/>
  <xsl:param name="chunk.id">
    <xsl:choose>
      <xsl:when test="$doc.view='items'">
      </xsl:when>
      <!-- xsl:when test="not($hit.rank) and not($link.id)">
      </xsl:when -->
      <xsl:when test="$hit.rank != '0' and key('hit-rank-dynamic', $hit.rank)/ancestor-or-self::c01">
        <xsl:value-of select="key('hit-rank-dynamic', $hit.rank)/ancestor::c01[1]/@id"/>
      </xsl:when>
      <xsl:when test="$hit.rank != '0' and key('hit-rank-dynamic', $hit.rank)/ancestor-or-self::*[name(..)='archdesc'][@id]">
        <xsl:value-of select="(key('hit-rank-dynamic', $hit.rank)/ancestor-or-self::*[name(..)='archdesc'][@id])/@id"/>
      </xsl:when>
      <xsl:when test="$link.id != '0' and key('c0x', $link.id)/ancestor-or-self::c01">
        <xsl:value-of select="key('c0x', $link.id)/ancestor::c01[1]/@id"/>
      </xsl:when>
      <xsl:when test="$link.id != '0' and key('c0x', $link.id)/ancestor-or-self::*[name(..)='archdesc'][@id]">
        <xsl:value-of select="(key('c0x', $link.id)/ancestor-or-self::*[name(..)='archdesc'])[@id]/@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$page/ead/archdesc/*[@id][1]/@id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="item.position">1</xsl:param>
  <xsl:param name="item.id">
    <xsl:choose>
      <xsl:when test="$page/ead/archdesc/@eadFirstItem">
        <xsl:value-of select="$page/ead/archdesc/@eadFirstItem"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$page/ead/archdesc//*/@id[../*/dao or ../*/daogrp][1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="query"/>
  <xsl:param name="source"/>
  
  <xsl:param name="dao-count">
    <xsl:choose>
      <xsl:when test="$page/ead/archdesc/@daoCount">
        <xsl:value-of select="$page/ead/archdesc/@daoCount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count($page//dao | $page//daogrp)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="dao-label">
    <xsl:choose>
      <xsl:when test="$page/ead/archdesc/did/physdesc/extent[@type='dao']">
        <xsl:value-of select="$page/ead/archdesc/did/physdesc/extent[@type='dao']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$dao-count"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:variable name="page" select="/"/>
  <xsl:variable name="layout" select="document('template.xhtml.html')"/>
  <xsl:variable name="daos" select="$page/ead/archdesc//*[did/daogrp or did/dao] 
    | $page/ead/archdesc/did[dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]]"/>
  <!-- xsl:variable name="daos" select="
  exslt:node-set(
  ($page/ead/archdesc//*[did/dao or did/daogrp])
  [(position()&gt;=$item.position) and 
  (position()&lt;($item.position + 49))])"/ -->
  
  <xsl:key name="hit-num-dynamic" match="xtf:hit" use="@hitNum"/>
  <xsl:key name="hit-rank-dynamic" match="xtf:hit" use="@rank"/>
  <xsl:key name="item-id" match="*/did/dao | */did/daogrp" use="@id"/> 
  <xsl:key name="c0x" match="archdesc/*|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" use="@id"/> 
  <xsl:key name="hasContent" match="*[@id][.//dao|.//daogrp]" use="@id"/>
  <!-- xsl:key name="all-ids" match="*" use="@id"/ --> 
  <!-- xsl:key name="linkable.docIds" match="archdesc/*[@id] | c01[@id][@level='series'] | c01[@id][@level='collection'] | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c02[@id][@level='series'] | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']" use="@id"/ -->
  
  <xsl:variable name="this.chunk" select="key('c0x', $chunk.id)"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="$layout/*" mode="html"/>
  </xsl:template>
  
  <!-- mode html -->
  
  <xsl:template match="@*|*" mode="html">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="html"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="insert-links" mode="html">
    <xsl:copy-of select="$brand.links"/>
  </xsl:template>
  
  <xsl:template match="insert-head" mode="html">
    <xsl:copy-of select="$brand.header"/>
  </xsl:template>
  
  <xsl:template match="insert-footer" mode="html">
    <xsl:copy-of select="$brand.footer"/>
  </xsl:template>
  
  <xsl:template match="insert-base" mode="html">
    <xsl:if test="($docId)">
      <xsl:if test="not ($query)">
        <base href=""/>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="insert-fa-url" mode="html">
    http://www.oac.cdlib.org/findaid/<xsl:value-of select="$page/ead/eadheader/eadid/@identifier"/>
  </xsl:template>
  
  <xsl:template match="insert-breadcrumbs" mode="html">
    <!--
    <a href="http://www.oac.cdlib.org/search.findingaid.html">Finding Aids</a> &gt;
    <xsl:choose>
      <xsl:when test="1=2"/>
      <xsl:otherwise>
        <xsl:if test="$page/ead/eadheader/eadid/@cdlpath:grandparent">
          <a href="http://www.oac.cdlib.org/institutions/{$page/ead/eadheader/eadid/@cdlpath:grandparent}">
            <xsl:call-template name="institution-ark2label">
              <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:grandparent"/>
            </xsl:call-template>
          </a>
          &gt;
        </xsl:if>
        <a href="http://www.oac.cdlib.org/institutions/{$page/ead/eadheader/eadid/@cdlpath:parent}">
          <xsl:call-template name="institution-ark2label">
            <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:parent"/>
          </xsl:call-template>
        </a>
      </xsl:otherwise>
    </xsl:choose>
    -->
  </xsl:template>
  
  
  <xsl:template match="insert-viewOptions" mode="html">
    <xsl:variable name="lastbit">
      <xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$doc.view = 'entire_text'">
        <ul><li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}{$lastbit}">Standard</a></li><li>Entire finding aid</li></ul>
      </xsl:when>
      <xsl:when test="$doc.view = 'items'">
        <ul><li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}{$lastbit}">Standard</a></li></ul>
        <ul>
          <li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;doc.view=entire_text">Entire finding aid</a></li></ul>
      </xsl:when>
      <xsl:otherwise>
        <ul><li>Standard</li></ul><ul>
          <li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;doc.view=entire_text{$lastbit}">Entire finding aid</a></li></ul>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:if test="$dao-count &gt; 0">
      <xsl:choose>
        <xsl:when test='$doc.view = "items"'>
          <div class="padded">
            <img alt="" width="84" border="0" height="16" 
              src="http://www.oac.cdlib.org/images/onlineitemsbutton.gif"/>
            <img alt="" width="17" border="0" height="14" 
              src="http://www.oac.cdlib.org/images/image_icon.gif"/>
            <xsl:value-of select="$dao-label"/> 
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="link"><!-- /ead/view?docId=<xsl:value-of select="$docId"/>&#038;doc.view=items<xsl:value-of select="$lastbit"/ -->
            <xsl:choose>
              <xsl:when test="$page/ead/archdesc/did/dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]">
                <xsl:value-of select="$page/ead//dao[1]/@href"/>
              </xsl:when>
              <xsl:otherwise>/ead/view?docId=<xsl:value-of select="$docId"/>&#038;doc.view=items<xsl:value-of select="$lastbit"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <div class="padded">
            <img alt="" width="84" border="0" height="16" 
              src="http://www.oac.cdlib.org/images/onlineitemsbutton.gif"/>
            <a href="{$link}">
              <img alt="" width="17" border="0" height="14" 
                src="http://www.oac.cdlib.org/images/image_icon.gif"/></a>
            <a href="{$link}">
              <xsl:value-of select="$dao-label"/></a>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="insert-searchForm" mode="html">
    <h2>Search within this document:</h2>
    <form method="GET" action="/ead/view">
      <input type="hidden" name="docId" value="{$docId}"/>
      <input type="hidden" name="brand" value="{$brand}"/>
      <input type="text" size="15" name="query"/><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><input type="image" name="submit" src="http://www.oac.cdlib.org/images/goto.gif" align="middle" border="0"/>
    </form>
  </xsl:template>
  
  <xsl:template match="insert-hits" mode="html">
    <xsl:variable name="lastbit">
      <xsl:choose>
        <xsl:when test="$chunk.id">&#038;chunk.id=<xsl:value-of select="$chunk.id"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$page/ead/@xtf:hitCount">
      [<a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;{$lastbit}">Clear Hits</a>]<br/>
      <xsl:value-of select="$page/ead/@xtf:hitCount"/> occurrences of <xsl:value-of select="$query"/>
    </xsl:if>
    
    
  </xsl:template>
  
  <xsl:template match="insert-title" mode="html">
    <xsl:value-of select="$page/ead/frontmatter/titlepage/titleproper[1]"/>
  </xsl:template>
  
  <xsl:template match="insert-toc" mode="html">
    <xsl:apply-templates select="$page/ead/archdesc/*[@id]" mode="toc"/>
  </xsl:template>
  
  <xsl:template match="insert-text" mode="html">
    <xsl:variable name="lastbit">
      <xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if></xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$doc.view='items'">
        <div>
          <xsl:variable name="pageme">
            <xsl:call-template name="pagination">
              <xsl:with-param name="start" select="number($item.position)"/>
              <xsl:with-param name="pageSize" select="number(50)"/>
              <xsl:with-param name="hits" select="number($dao-count)"/>
              <xsl:with-param name="base"><xsl:value-of select="$xtfURL"/>/<xsl:value-of select="$dynaxmlPath"/>?brand=<xsl:value-of select="$brand"/>&#038;docId=<xsl:value-of select="$docId"/>&#038;doc.view=items<xsl:value-of select="$lastbit"/>&#038;item.position=</xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          
          <xsl:copy-of select="$pageme"/>
          
          <!-- xsl:for-each select="$daos[(position()&gt;=number($item.position)) and (position()&lt;(number($item.position) + 49))][1]" -->
          <xsl:for-each select="($daos[position()=xs:integer($item.position)])[1]" >
            <xsl:call-template name="series-top"/>
          </xsl:for-each>
          <!-- xsl:apply-templates select="$daos[(position()&gt;=number($item.position)) and
          (position()&lt;(number($item.position) + 49))]" mode="items"/ -->
          <xsl:apply-templates select="for $i in xs:integer($item.position) to (xs:integer($item.position)+49) return $daos[$i]" mode="items"/>
          <xsl:copy-of select="$pageme"/>
        </div>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$daos[(position()&gt;=number($item.position)) and
            (position()&lt;(number($item.position) + 49))]" mode="xmlverb" />
        </xsl:if>
      </xsl:when>
      <xsl:when test="$doc.view='entire_text'">
        <xsl:apply-templates select="$page/ead/archdesc | $page/ead/eadheader/filedesc | $page/ead/frontmatter/publicationstmt"/>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$page/ead/archdesc | $page/ead/eadheader | $page/ead/frontmatter/publicationstmt" mode="xmlverb"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$chunk.id">
        <xsl:apply-templates select="$this.chunk"/>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$this.chunk" mode="xmlverb"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$page/ead/archdesc/*[@id][1]"/>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$page/ead/archdesc/*[@id][1]" mode="xmlverb"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="insert-institution" mode="html">
    <a>
      <xsl:attribute name="href">http://www.libraries.iub.edu/archives</xsl:attribute>
      Indiana University Archives
    </a>
    <xsl:text> or </xsl:text>
    <a>
      <xsl:attribute name="href">http://www.dlib.indiana.edu</xsl:attribute>
      Indiana University Digital Library Program
    </a>
    
    
  </xsl:template>
  
  <!-- mode toc -->
  
  <xsl:template name="camera">
    <img class="icon" alt="[Online Content]" width="17" border="0" height="14" src="http://www.oac.cdlib.org/images/image_icon.gif"/>
  </xsl:template>
  
  <xsl:template match="archdesc/*[@id] | c01[@id][@level='series'] | c01[@id][@level='collection']
    | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c02[@id][@level='series'] 
    | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']" mode="toc">
    <xsl:variable name="lastbit">
      <xsl:if test="$query">&#038;query=<xsl:value-of select="$query"/></xsl:if>
      <xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="did/unittitle">
        <xsl:choose>
          <xsl:when test="$chunk.id = @id">
            <div class="otl{name()}selected">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <xsl:value-of select="did/unittitle"/>
              <xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
                <span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
              </xsl:if>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div class="otl{name()}menu">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;chunk.id={@id}{$lastbit}">
                <xsl:value-of select="did/unittitle"/></a>
              <xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
                <span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
              </xsl:if>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>      
      <xsl:when test="head">
        <xsl:choose>
          <xsl:when test="$chunk.id = @id">
            <div class="navCategorySelected">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <xsl:value-of select="head"/>
              <xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
                <span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
              </xsl:if>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div class="navCategory">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;chunk.id={@id}{$lastbit}">
                <xsl:value-of select="head"/></a>
              <xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
                <span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
              </xsl:if>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="name() = 'dsc'">
        <xsl:choose>
          <xsl:when test="$chunk.id = @id">
            <div class="navCategorySelected">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <xsl:value-of select="'Content List'"/>
              <xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
                <span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
              </xsl:if>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div class="navCategory">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;chunk.id={@id}{$lastbit}">
                <xsl:value-of select="'Content List'"/></a>
              <xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
                <span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
              </xsl:if>
            </div>
          </xsl:otherwise>          
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:apply-templates mode="toc" select="c01[@id][@level='series'] | c01[@id][@level='collection'] | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c02[@id][@level='series'] | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']"/>
  </xsl:template>
  
  <!-- mode items -->
  <!-- xsl:template match="*" mode="items">
  
  <xsl:apply-templates />
  
  </xsl:template -->
  
  <xsl:template match="c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" mode="items">
    <div class="item">
      <xsl:call-template name="series"/>
      <xsl:apply-templates select="did[daogrp or dao]" mode="items" />
    </div>
  </xsl:template>
  
  <xsl:template match="did" mode="items">
    <xsl:choose>
      <xsl:when test="daogrp">
        <a href="http://ark.cdlib.org/{daogrp/@poi}">
          <img src="http://ark.cdlib.org/{daogrp/@poi}/thumbnail"/></a>
      </xsl:when>
      <xsl:when test="dao/@poi">
        <a href="{dao/@href}">
          <img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org/images/image_icon.gif"/>
        </a>
      </xsl:when>
      <xsl:when test="dao/@href and dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]">
        <div>
          <a href="{dao/@href}">
            <xsl:choose>
              <xsl:when test="dao/@title"><xsl:value-of select="dao/@title"/></xsl:when>
              <xsl:otherwise>View items</xsl:otherwise>
            </xsl:choose>
          </a>
        </div>
      </xsl:when>
      <xsl:when test="dao/@href">
        <a href="{dao/@href}">
          <img src="{dao/@href}/thumbnail"/></a>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <div class="item">
      <xsl:value-of select="unittitle"/>
    </div>
    <hr/>
  </xsl:template>
  
  
  <!-- ead formatting templates -->
  
  <xsl:template match="*">
    <xsl:if test="@label">
      <xsl:text disable-output-escaping='yes'> <![CDATA[<p>]]></xsl:text>
      <b><xsl:value-of select="@label"/>
        <xsl:if test="
          substring(@label,string-length(@label)) != ':'
          and
          substring(@label, string-length(@label)-1) != ': '
          ">:
        </xsl:if><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
      </b>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="child::text()">
        <xsl:apply-templates/><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:if test="@LABEL">
      <xsl:text disable-output-escaping='yes'><![CDATA[</p>]]></xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="xtf:hit"><xsl:apply-imports/></xsl:template>
  <xsl:template match="xtf:term"><xsl:apply-imports/></xsl:template>
  
  <xsl:template match="CDLTITLE | NTITLE | frontmatter |CDLPATH">
  </xsl:template>
  
  <!-- xsl:template match="table">
  <xsl:apply-templates/>
  </xsl:template -->
  
  <xsl:template match="/" mode="br">
    <br><xsl:apply-templates mode="br"/></br>
  </xsl:template>
  
  <xsl:template match="/" mode="space">
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
    <xsl:apply-templates mode="space"/>
  </xsl:template>
  
  <!-- <xsl:template match="PHYSFACET | DIMENSIONS">
  <xsl:apply-templates/>
  <xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
  </xsl:template> -->
  
  <xsl:template match="c01 | c02 | c03 | c04 | c05 | c06 | c07 | c08 | c09 | c10 | c11">
    
    
    
    
    <ul>
      <xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
      <p><a name="{@id}"></a>
        <img src="http://www.oac.cdlib.org/images/black.gif" width="400" height="1"
          alt="---------------------------------------" />
      </p>
      <xsl:apply-templates/>
    </ul>
    <!--
    </xsl:when>
    <xsl:otherwise>
    <ul>
    <xsl:apply-templates/>
    </ul>
    </xsl:otherwise>
    </xsl:choose>
    -->
  </xsl:template>
  
  <xsl:template match="odd">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*" mode="dscdid">
    <br/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="did">
    <xsl:choose>
      <xsl:when test="ancestor::node()/c01">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[not (name(.)='unitdate')]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="unittitle/unitdate">
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
    <xsl:apply-templates/> 
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
  </xsl:template>
  
  <!-- xsl:choose>
  <xsl:when test="@label">
  <p><b><xsl:value-of select="@label"/>
  <xsl:if test="
  substring(@label,string-length(@label)) != ':'
  and
  substring(@label, string-length(@label)-1) != ': '
  ">:
  </xsl:if><xsl:text disable-output-escaping='yes'><![CDATA[<br />
  ]]></xsl:text>
  </b><xsl:apply-templates/></p>
  </xsl:when>
  <xsl:otherwise>
  <b><xsl:apply-templates/></b>
  <xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
  </xsl:otherwise>
  </xsl:choose>
  
  </xsl:template -->
  
  
  <xsl:template match="unitid | unittitle | unitdate">
    
    <!-- br -->
    <br/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@label">
        <p><b><xsl:value-of select="@label"/>
          <xsl:if test="
            substring(@label,string-length(@label)) != ':'
            and
            substring(@label, string-length(@label)-1) != ': '
            ">:
          </xsl:if><xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
        </b><xsl:apply-templates/> 
          <xsl:apply-templates select="following-sibling::unitdate"/>
        </p>
        
      </xsl:when>
      <xsl:when test="name()='unittitle'"> 
        <b><xsl:apply-templates/></b><xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>  
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--
  <xsl:template match="eadheader">
  <table border="1">
  <tr><th>eadheader</th></tr>
  <tr><td>
  <xsl:apply-templates/>
  </td></tr></table>
  </xsl:template>
  -->
  
  <xsl:template match="eadid">
    <p><b>eadid</b><br/>    <xsl:value-of select="."/></p>
  </xsl:template>
  
  <xsl:template match="list">
    <xsl:apply-templates select="head | listhead"/>
    <xsl:choose>
      <xsl:when test="@type='deflist'">
        <dl class="ead-list"><xsl:apply-templates select="defitem | item"/></dl>
      </xsl:when>
      <xsl:when test="@type='ordered' and @numeration">
        <ol class="ead-{@numeration}"><xsl:apply-templates select="defitem | item"/></ol>
      </xsl:when>
      <xsl:when test="@type='ordered' and not( @numeration )">
        <ol class="ead-arabic"><xsl:apply-templates select="defitem | item"/></ol>
      </xsl:when>
      <xsl:when test="@type='marked'">
        <ul class="ead-list"><xsl:apply-templates select="defitem | item"/></ul>
      </xsl:when>
      <xsl:otherwise>
        <ul class="ead-list-unmarked"><xsl:apply-templates select="defitem | item"/></ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="item">
    <li><xsl:apply-templates/></li>
  </xsl:template>
  
  <xsl:template match="defitem">
    <xsl:for-each select="label">
      <dt><xsl:apply-templates/></dt>
    </xsl:for-each>
    <xsl:for-each select="item">
      <dd><xsl:apply-templates/></dd>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="container">
    <!-- xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text -->
    <xsl:text> </xsl:text>
    <span class="ead-container">[
      <xsl:choose>
        <xsl:when test="@label">
          <xsl:value-of select="@label"/><xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="@type">
          <xsl:value-of select="@type"/>
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
      
      <xsl:apply-templates/>
      ]</span>
    <xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
  </xsl:template>
  
  <xsl:template match="lb">
    <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
  </xsl:template>
  
  <xsl:template match="emph">
    <xsl:choose>
      <xsl:when test="@render">
        <span>
          <xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:otherwise><em><xsl:apply-templates/></em></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="titleproper"/>
  <xsl:template match="titleproper[@type='filing']">
    <h2>
      <xsl:if test="@render">
        <xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>
  
  <xsl:template match="title">
    <i>
      <xsl:if test="@render">
        <xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </i>
    
    <xsl:if test="
      name(..) = 'controlaccess'
      and name(..) = 'namegrp'
      ">
      <br/>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="head">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::node()/c01">
        <h4><xsl:apply-templates/></h4>
      </xsl:when>
      <xsl:otherwise>
        <h3><xsl:apply-templates/></h3>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="address" mode="space">
    <i><xsl:apply-templates/></i>
  </xsl:template>
  
  <xsl:template match="address">
    <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- 
  <xsl:template match="P | NUM | PUBLISHER">
  <p><xsl:apply-templates/></p>
  </xsl:template> 
  -->
  
  <xsl:template match="blockquote">
    <blockquote><xsl:apply-templates/></blockquote>
  </xsl:template>
  
  <xsl:template match="p">
    <xsl:choose>
      <xsl:when test="child::text()">
        <p><xsl:apply-templates/></p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 
  
  <!-- xsl:template match="extent">
  <xsl:apply-templates mode="br"/>
  </xsl:template -->
  
  <xsl:template match="extent[preceding::dsc]">
    <h4>Extent</h4><p><xsl:apply-templates/></p>
  </xsl:template> 
  
  <xsl:template match="bibref | extref | archref">
    <xsl:if test="(name(..)='bibliography') or 
      ( name(..)='otherfindaid') or
      (name(..)='separatedmaterial') or
      ( name(..)='relatedmaterial')"><br/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@href and not (@show='embed')">
        <a href="{@href}">
          <xsl:choose>
            <xsl:when test=".//text()">
              <!-- xsl:apply-templates mode="ref"/ -->
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>Link</xsl:otherwise>
          </xsl:choose>
        </a><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
      </xsl:when>
      <xsl:when test="@href and (@show='embed')">
        <img src="{@href}"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- xsl:apply-templates mode="ref"/ -->
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="ref">
    <xsl:value-of select="text()"/><xsl:text> </xsl:text>
    <!-- xsl:apply-templates mode="ref"/><xsl:text> </xsl:text -->
  </xsl:template>
  
  <xsl:template match="extptr">
    <xsl:choose>
      <xsl:when test="@href and (@show='embed')">
        <img src="{@href}"/>
      </xsl:when>
      <xsl:otherwise>
        <a href="{@href}"><xsl:value-of select="@title"/></a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="ref">
    <a href="/ead/view?docId={$docId}&#038;link.id={@target}#{@target}"><xsl:apply-templates mode="ref"/></a>
  </xsl:template>
  
  <xsl:template match="ptr">
    <a href="/ead/view?docId={$docId}&#038;link.id={@target}#{@target}"><xsl:value-of select="@title"/></a>
  </xsl:template>
  
  <xsl:template match="repository[1]">
    <xsl:choose>
      <xsl:when test="@label">
        <p>
          <b><xsl:value-of select="@label"/>: </b><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="institution-ark2url">
                <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:parent"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>
          </a></p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="institution-ark2url">
              <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:parent"/>
            </xsl:call-template>
          </xsl:attribute>
        </a><xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="dao">
    <xsl:variable name="linktext">
      <xsl:choose>
        <xsl:when test="@title">
          <xsl:value-of select="@title"/>
        </xsl:when>
        <xsl:otherwise>view item(s)</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:apply-templates select="daodesc/*"/>
    <xsl:choose>
      <xsl:when test="@poi">
        <a href="http://ark.cdlib.org/{@poi}"><img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org/images/image_icon.gif"/> 
          <xsl:value-of select="$linktext"/></a><br/>
      </xsl:when>
      <xsl:otherwise>
        <a href="{@href}"><img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org//images/image_icon.gif"/> 
          <xsl:value-of select="$linktext"/></a><br/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="daogrp">
    <p>
      <a href="http://ark.cdlib.org/{@poi}"><img border="0" width="17" height="14" alt="[image]" src="http://www.oac.cdlib.org/images/image_icon.gif"/> view image</a>
      <xsl:apply-templates/> 
    </p>
  </xsl:template>
  
  <xsl:template match="daoloc">
    <xsl:variable name="linktext">
      <xsl:choose>
        <xsl:when test="@title">
          <xsl:value-of select="@title"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="@role"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    |       <a href="{@href}"><xsl:value-of select="$linktext"/></a>
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="chronlist">
    <table>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  
  
  <xsl:template match="chronitem">
    <xsl:choose>
      <xsl:when test="eventgrp">
        <tr>
          <td valign="top"><xsl:apply-templates select="date"/></td>
          <td><xsl:apply-templates select="eventgrp/event[1]"/></td>
        </tr>
        <xsl:for-each select="eventgrp/event[position()>1]">
          <tr><td><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text></td><td><xsl:apply-templates/></td></tr>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <tr>
          <td valign="top"><xsl:apply-templates select="date"/></td>
          <td><xsl:apply-templates select="event"/></td>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="event | famname | function | geogname | genreform | persname | corpname | date | name | occupation | subject ">
    <xsl:choose>
      <xsl:when test="
        name(..) = 'controlaccess' 
        or         name(..) = 'namegrp' 
        or         name(..) = 'index'
        or         name(..) = 'origination'
        ">
        <xsl:apply-templates/><br/>
      </xsl:when>
      <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- name series ead ++ --> 
  <xsl:template name="series-top">
    <xsl:if test="../did/unittitle and (preceding-sibling::*[did/dao or did/daogrp])">
      <xsl:for-each select=".." >
        <xsl:call-template name="series"/>
      </xsl:for-each>
      <xsl:apply-templates select="../did/unittitle" mode="series"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="series">
    <div>
      <!-- span>      <xsl:value-of select="preceding-sibling::*[1]/did"/></span >
      <span>a: <xsl:value-of select="preceding-sibling::*[did/dao]/@id"/></span>
      <span> a: <xsl:value-of select="preceding-sibling::*[1]/@id"/></span>
      <span> a: <xsl:value-of select="@id"/></span>
      <span> 2a: <xsl:value-of select="preceding-sibling::*[1]/../did/unittitle"/></span>
      <span> b: <xsl:value-of select="../@id"/></span -->
    </div>
    <xsl:if test="../did/unittitle and not ( preceding-sibling::*[did/dao or did/daogrp] )" >
      <!-- xsl:if test=" (../did/unittitle) and 
      (../did/unittitle = preceding-sibling::*[did/dao]/../did/unittitle) "  -->
      <xsl:for-each select=".." >
        <xsl:call-template name="series"/>
      </xsl:for-each>
      <xsl:apply-templates select="../did/unittitle" mode="series"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="unittitle" mode="series">
    <h4 class="h{name(../..)}">
      <xsl:apply-templates/>
    </h4>
  </xsl:template>
  
  
</xsl:stylesheet>
