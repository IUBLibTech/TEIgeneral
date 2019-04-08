<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Author: $Author: djiao $
  Version: $Revision: 1.57 $ $Date: 2007/08/15 19:51:54 $
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:cdlpath="http://www.cdlib.org/path/"
  xmlns:ead="urn:isbn:1-931666-22-9"
  version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:exslt="http://exslt.org/common"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all"
  >
  <xsl:import href="/opt/etext/common/2.1.1/style/dynaXML/docFormatter/common/docFormatterCommon.xsl"/>
  <xsl:import href="brandCommon.xsl"/>
  <xsl:import href="xmlverbatim.xsl"/>
  <xsl:import href="search.xsl"/>
  <xsl:import href="parameter.xsl"/>
  
  <xsl:include href="page.xsl"/>
  <xsl:include href="table.html.xsl"/>
  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" media-type="text/html" />
  
  <xsl:param name="brand" select="'general'"/>
  <xsl:param name="docId"/>
  <xsl:param name="doc.view" select="entire_text"/>
  <xsl:param name="debug"/>
  <xsl:param name="link.id"/>
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
        <xsl:value-of select="$page/archdesc/*[@id][1]/@id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="item.position">1</xsl:param>
  <xsl:param name="item.id">
    <xsl:choose>
      <xsl:when test="$page/archdesc/@eadFirstItem">
        <xsl:value-of select="$page/archdesc/@eadFirstItem"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$page/archdesc//*/@id[../*/dao or ../*/daogrp][1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="source"/>
  
  <xsl:param name="dao-count">
    <xsl:choose>
      <xsl:when test="$page/archdesc/@daoCount">
        <xsl:value-of select="$page/archdesc/@daoCount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count($page//dao | $page//daogrp)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="dao-label">
    <xsl:choose>
      <xsl:when test="$page/archdesc/did/physdesc/extent[@type='dao']">
        <xsl:value-of select="$page/archdesc/did/physdesc/extent[@type='dao']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$dao-count"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="text1"/>
  <xsl:param name="text2"/>
  <xsl:param name="text3"/>
  <xsl:param name="field1"/>
  <xsl:param name="field2"/>
  <xsl:param name="field3"/>
  <xsl:param name="op1"/>
  <xsl:param name="op2"/>
  
  <xsl:param name="fromMonth"/>
  <xsl:param name="fromYear"/>
  <xsl:param name="toMonth"/>
  <xsl:param name="toYear"/>   
  
  <xsl:param name="startDoc" select="1"/> 
  
  <xsl:param name="search">
    <xsl:if test="$text1"><xsl:value-of select="concat('&amp;text1=', $text1)"/></xsl:if>
    <xsl:if test="$text2"><xsl:value-of select="concat('&amp;text2=', $text2)"/></xsl:if>
    <xsl:if test="$text3"><xsl:value-of select="concat('&amp;text3=', $text3)"/></xsl:if>
    <xsl:if test="$op1"><xsl:value-of select="concat('&amp;op1=', $op1)"/></xsl:if>
    <xsl:if test="$op2"><xsl:value-of select="concat('&amp;op2=', $op2)"/></xsl:if>
    <xsl:if test="$field1"><xsl:value-of select="concat('&amp;field1=', $field1)"/></xsl:if>
    <xsl:if test="$field2"><xsl:value-of select="concat('&amp;field2=', $field2)"/></xsl:if>
    <xsl:if test="$field3"><xsl:value-of select="concat('&amp;field3=', $field3)"/></xsl:if>
    <xsl:if test="$fromMonth"><xsl:value-of select="concat('&amp;fromMonth=', $fromMonth)"/></xsl:if>
    <xsl:if test="$fromYear"><xsl:value-of select="concat('&amp;fromYear=', $fromYear)"/></xsl:if>
    <xsl:if test="$toMonth"><xsl:value-of select="concat('&amp;toMonth=', $toMonth)"/></xsl:if>
    <xsl:if test="$toYear"><xsl:value-of select="concat('&amp;toYear=', $toYear)"/></xsl:if>
    <xsl:if test="$startDoc"><xsl:value-of select="concat('&amp;startDoc=', $startDoc)"/></xsl:if>
  </xsl:param>      

  <xsl:variable name="page" select="/ead"/>

  <xsl:variable name="layout" select="document('template.xhtml.html')"/>
  
  <!-- Julie commented out -->
  <!-- xsl:variable name="daos" select="$page/archdesc//*[did/daogrp or did/dao] 
    | $page/archdesc/did[dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]]"/ -->
    
  <xsl:variable name="daos" select="$page/archdesc//*[did/daogrp or did/dao or (did and dao) and name(.)]"/>
    
  <!-- xsl:variable name="daos" select="
  exslt:node-set(
  ($page/archdesc//*[did/dao or did/daogrp])
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
  
  <xsl:variable name="table.exists" select="'no'"/>
  
  <xsl:template match="*[namespace-uri()='urn:isbn:1-931666-22-9']">
    <xsl:element name="{local-name()}" namespace="">
      <xsl:copy-of select="@*"/>
      <xsl:copy/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="/">
  	<xsl:choose>
  		<!-- IUFA-217 -->
  		<xsl:when test="$doc.view='print'">
        	<xsl:call-template name="print"/>
      	</xsl:when>
      	<xsl:otherwise>
  			<html xmlns="http://www.w3.org/1999/xhtml">
	    		<xsl:apply-templates select="$layout/html/*" mode="html"/>
			</html>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
  <!-- mode html -->
  
  <xsl:template match="@*|*" mode="html">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="html"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="insert-links" mode="html">
    <xsl:copy-of select="$brand.links/*"/>
  </xsl:template>
  
  <xsl:template match="insert-head" mode="html">
    <xsl:copy-of select="$brand.header/*"/>
  </xsl:template>
  
  <xsl:template match="insert-footer" mode="html">
  	<div id="footer">
    	<div class="contactinfo">
    		<p>
      			Bookmark this page at: <a href="http://purl.dlib.indiana.edu/iudl/findingaids/{$page/archdesc/did/repository/@id}/{normalize-space($page/eadheader/eadid[1])}">http://purl.dlib.indiana.edu/iudl/findingaids/<xsl:value-of select="$page/archdesc/did/repository/@id"/>/<xsl:value-of select="normalize-space($page/eadheader/eadid[1])"/></a></p>
      			<xsl:copy-of select="$brand.footer/*"/>
      	</div>
    </div>
    <div id="footerIU">
      <xsl:copy-of select="$brand.footerIU/div/*"/>
    </div>
  </xsl:template>
  
  
  <xsl:template match="insert-base" mode="html">
    <!--
    <xsl:if test="($docId)">
      <xsl:if test="not ($query)">
        <base href=""/>
      </xsl:if>
    </xsl:if>
    -->
  </xsl:template>
  
  
  <xsl:template match="insert-fa-url" mode="html">
    http://www.oac.cdlib.org/findaid/<xsl:value-of select="$page/eadheader/eadid/@identifier"/>
  </xsl:template>
  
  <xsl:template match="insert-breadcrumbs" mode="html">
    <!--
    <a href="http://www.oac.cdlib.org/search.findingaid.html">Finding Aids</a> &gt;
    <xsl:choose>
      <xsl:when test="1=2"/>
      <xsl:otherwise>
        <xsl:if test="$page/eadheader/eadid/@cdlpath:grandparent">
          <a href="http://www.oac.cdlib.org/institutions/{$page/eadheader/eadid/@cdlpath:grandparent}">
            <xsl:call-template name="institution-ark2label">
              <xsl:with-param name="ark" select="$page/eadheader/eadid/@cdlpath:grandparent"/>
            </xsl:call-template>
          </a>
          &gt;
        </xsl:if>
        <a href="http://www.oac.cdlib.org/institutions/{$page/eadheader/eadid/@cdlpath:parent}">
          <xsl:call-template name="institution-ark2label">
            <xsl:with-param name="ark" select="$page/eadheader/eadid/@cdlpath:parent"/>
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
        <ul><li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}{$lastbit}">Standard</a></li><li>Entire finding aid</li><li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;doc.view=print{$lastbit}">Printer-friendly</a></li></ul>
      </xsl:when>
      <xsl:when test="$doc.view = 'items'">
        <ul><li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}{$lastbit}">Standard</a></li>
          <li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;doc.view=entire_text">Entire finding aid</a></li><li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;doc.view=print{$lastbit}">Printer-friendly</a></li></ul>
      </xsl:when>
      <xsl:otherwise>
        <ul><li>Standard</li>
          <li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;doc.view=entire_text{$lastbit}">Entire finding aid</a></li><li><a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;doc.view=print{$lastbit}">Printer-friendly</a></li></ul>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:if test="$dao-count &gt; 0">
      <xsl:choose>
        <xsl:when test='$doc.view = "items"'>
          <div class="padded">
            <!--<img alt="" width="84" border="0" height="16" 
              src="http://www.oac.cdlib.org/images/onlineitemsbutton.gif"/>-->
            <img class="icon" alt="" width="17" border="0" height="14" 
              src="images/image_icon.gif"/>
            <xsl:value-of select="$dao-label"/> items online
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="link">/findingaids/view?docId=<xsl:value-of select="$docId"/>&#038;doc.view=items<xsl:value-of select="$lastbit"/></xsl:variable>
          
          <div class="padded">
            <!--<img alt="" width="84" border="0" height="16" 
              src="http://www.oac.cdlib.org/images/onlineitemsbutton.gif"/>-->
            <a href="{$link}"> 
              <img class="icon" alt="" width="17" border="0" height="14" 
                src="images/image_icon.gif"/></a>
            <a href="{$link}">
              <xsl:value-of select="$dao-label"/> items online</a>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="insert-searchForm" mode="html">
    <h4>Search within this document:</h4>
    <form method="get" action="{$xtfURL}{$dynaxmlPath}">
      <fieldset>
	    <input type="hidden" name="docId" value="{$docId}"/>
    	<input type="hidden" name="brand" value="{$brand}"/>
      	<input type="hidden" name="field1" value="text"/>
      	<input type="text" size="15" name="text1"/>
      	<xsl:text disable-output-escaping='yes'>&#160;</xsl:text>
      	<input type="image" name="submit" src="images/goButton.gif" id="submitSearchWithin" />
      </fieldset>
    </form>
  </xsl:template>
  
  <xsl:template match="insert-hits" mode="html">
    <!--
      <xsl:variable name="lastbit">
    <xsl:choose>
      <xsl:when test="$chunk.id">&#038;chunk.id=<xsl:value-of select="$chunk.id"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    </xsl:variable>

    <xsl:if test="$page/@xtf:hitCount">
      <p class="smaller">[<a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;{$lastbit}">Clear Hits</a>]<br/>
        <b><xsl:value-of select="$page/@xtf:hitCount"/></b> occurrences of <xsl:call-template name="queryString"/></p>
    </xsl:if>
    -->
  </xsl:template>
  
  <xsl:template match="insert-title" mode="html">
    <xsl:variable name="titleproper" select="$page/archdesc/did/unittitle"/>
    <xsl:variable name="titledate1" select="$page/archdesc/did/unitdate"/>
    <xsl:value-of select="replace(normalize-space($titleproper), '[^a-zA-Z0-9\]\)]+$', '')"/>
    <xsl:if test="$titledate1">
    	<xsl:text>, </xsl:text><xsl:value-of select="$titledate1"/>
    </xsl:if> 
  </xsl:template>
  
  <xsl:template match="insert-toc" mode="html">
    <xsl:apply-templates select="$page/archdesc/*[@id]" mode="toc"/>
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
          <hr/>
          
          <!-- xsl:for-each select="$daos[(position()&gt;=number($item.position)) and (position()&lt;(number($item.position) + 49))][1]" -->
          <xsl:for-each select="($daos[position()=xs:integer($item.position)])[1]" >
            <xsl:call-template name="series-top"/>
          </xsl:for-each>
          <!-- xsl:apply-templates select="$daos[(position()&gt;=number($item.position)) and
          (position()&lt;(number($item.position) + 49))]" mode="items"/ -->
          
          <!-- Julie commented out -->
          <!-- xsl:apply-templates select="for $i in xs:integer($item.position) to (xs:integer($item.position)+49) return $daos[$i]" mode="items"/ -->
          
          <xsl:for-each select="$daos[(position()&gt;=number($item.position)) and (position()&lt;(number($item.position) + 49))]">
            <xsl:apply-templates select="." mode="items"/>
          </xsl:for-each>
          
          <xsl:copy-of select="$pageme"/>
        </div>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$daos[(position()&gt;=number($item.position)) and
            (position()&lt;(number($item.position) + 49))]" mode="xmlverb" />
        </xsl:if>
      </xsl:when>
      
     <!-- <xsl:when test="$doc.view='entire_text'">
        <xsl:apply-templates select="$page/archdesc | $page/eadheader/filedesc/titlestmt/*[not(name()='titleproper')] | $page/eadheader/filedesc/publicationstmt | $page/eadheader/publicationstmt"/>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$page/archdesc | $page/eadheader | $page/eadheader/publicationstmt" mode="xmlverb"/>
        </xsl:if>
      </xsl:when> -->
      
      <xsl:when test="$doc.view='entire_text'">
        <xsl:apply-templates select="$page/archdesc | $page/eadheader/filedesc/titlestmt/*[not(name()='titleproper')]"/>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$page/archdesc | $page/eadheader" mode="xmlverb"/>
        </xsl:if>
      </xsl:when>
      
      <xsl:when test="$chunk.id">
        <xsl:apply-templates select="$this.chunk"/>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$this.chunk" mode="xmlverb"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$page/archdesc/*[@id][1]"/>
        <xsl:if test="$debug='xml'">
          <xsl:apply-templates select="$page/archdesc/*[@id][1]" mode="xmlverb"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="insert-institution" mode="html">
    <xsl:choose>
      <xsl:when test="$page/archdesc/did/repository[@id='archives']">
        <a>
          <xsl:attribute name="href">http://www.libraries.iub.edu/archives</xsl:attribute>
          University Archives, IU Bloomington
        </a><br/>
        Email: <a><xsl:attribute name="href">mailto:archives@indiana.edu</xsl:attribute>archives@indiana.edu</a>
        
      </xsl:when>
      <xsl:when test="$page/archdesc/did/repository[@id='lilly']">
        <a>
          <xsl:attribute name="href">http://www.indiana.edu/~liblilly/</xsl:attribute>
          Lilly Library, IU Bloomington
        </a> <br/> 
        Email: <a><xsl:attribute name="href">mailto:liblilly@indiana.edu</xsl:attribute>
          	liblilly@indiana.edu
        </a>
      </xsl:when>
      <xsl:when test="$page/archdesc/did/repository[@id='cshm']">
        <a>
          <xsl:attribute name="href">http://www.indiana.edu/~cshm/</xsl:attribute>
          Center for the Study of History and Memory, IU Bloomington
        </a> <br/> 
        Email: <a><xsl:attribute name="href">mailto:ohrc@indiana.edu</xsl:attribute>
          	ohrc@indiana.edu
        </a>
      </xsl:when>
      <xsl:when test="$page/archdesc/did/repository[@id='wmi']">
        <a>
          <xsl:attribute name="href">http://www.workingmensinstitute.org</xsl:attribute>
          Working Men's Institute
        </a> <br/> 
        Email: <a><xsl:attribute name="href">mailto:archivist@workingmensinstitute.org</xsl:attribute>
          	archivist@workingmensinstitute.org
        </a>
      </xsl:when>
      <xsl:when test="$page/archdesc/did/repository[@id='lcp']">
        <a>
          <xsl:attribute name="href">http://onliberia.org</xsl:attribute>
          Liberian Collections, IU Bloomington
        </a> <br/> 
        Email: <a><xsl:attribute name="href">mailto:liberia@indiana.edu</xsl:attribute>
          	liberia@indiana.edu
        </a>
      </xsl:when>
      <xsl:when test="$page/archdesc/did/repository[@id='folklore']">
        <a>
          <xsl:attribute name="href">http://www.libraries.iub.edu/folklore</xsl:attribute>
          Folklore Collection, IU Bloomington
        </a> <br/> 
        Email: <a><xsl:attribute name="href">mailto:molsmith@indiana.edu</xsl:attribute>
          	molsmith@indiana.edu
        </a>
      </xsl:when>
      <xsl:when test="$page/archdesc/did/repository[@id='politicalpapers']">
        <a>
          <xsl:attribute name="href">http://www.libraries.iub.edu/index.php?pageId=7508</xsl:attribute>
          Political Papers, IU Bloomington
        </a> <br/> 
        Email: <a><xsl:attribute name="href">mailto:congpprs@indiana.edu</xsl:attribute>
          	congpprs@indiana.edu
        </a>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <!-- mode toc -->
  
  <xsl:template name="camera">
    <img class="icon" alt="[Online Content]" width="17" border="0" height="14" src="images/image_icon.gif"/>
  </xsl:template>
  
  <xsl:template match="archdesc/*[@id] | c01[@id] | c02[@id][@level='series'] 
   | c02[@id][@level='subseries']" mode="toc">
    <xsl:variable name="lastbit">
      <xsl:if test="$query">&#038;query=<xsl:value-of select="$query"/></xsl:if>
      <xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if>
    </xsl:variable>
    
    <!-- IUFA-185 - changed <div> to <li> to produced nested list for TOC -->
    <xsl:choose>
      <xsl:when test="did/unittitle">
        <xsl:choose>
          <xsl:when test="$chunk.id = @id">
            <li class="otl{name()}selected">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <xsl:value-of select="did/unittitle"/>
              <xsl:if test="($text1 != '' or $text2 != '' or $text3 != '') and (@xtf:hitCount)">
                <span class="subhit">[<xsl:value-of select="@xtf:hitCount"/>
                  hit<xsl:if test="number(@xtf:hitCount) &gt; 1">s</xsl:if>]</span> <!-- IUFA-49 -->
              </xsl:if>
            </li>
          </xsl:when>
          <xsl:otherwise>
            <li>
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;chunk.id={@id}{$lastbit}{$search}{if (@xtf:firstHit) then concat('#', @xtf:firstHit) else ''}">
                <xsl:value-of select="did/unittitle"/></a>
              <xsl:if test="($text1 != '' or $text2 != '' or $text3 != '') and (@xtf:hitCount)">
                <span class="subhit">[<xsl:value-of select="@xtf:hitCount"/> 
                  hit<xsl:if test="number(@xtf:hitCount) &gt; 1">s</xsl:if>]</span>
              </xsl:if>
            </li>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>      
      <xsl:when test="head">
        <xsl:choose>
          <xsl:when test="$chunk.id = @id">
            <li class="navCategorySelected">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <xsl:value-of select="head"/>
              <xsl:if test="($text1 != '' or $text2 != '' or $text3 != '') and (@xtf:hitCount)">
                <span class="subhit">[<xsl:value-of select="@xtf:hitCount"/> 
                  hit<xsl:if test="number(@xtf:hitCount) &gt; 1">s</xsl:if>]</span>
              </xsl:if>
            </li>
          </xsl:when>
          <xsl:otherwise>
            <li>
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;chunk.id={@id}{$lastbit}{$search}{if (@xtf:firstHit) then concat('#', @xtf:firstHit) else ''}">
                <xsl:value-of select="head"/></a>
              <xsl:if test="($text1 != '' or $text2 != '' or $text3 != '') and (@xtf:hitCount)">
                <span class="subhit">[<xsl:value-of select="@xtf:hitCount"/> 
                  hit<xsl:if test="number(@xtf:hitCount) &gt; 1">s</xsl:if>]</span>
              </xsl:if>
            </li>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="name() = 'dsc'">
        <xsl:choose>
          <xsl:when test="$chunk.id = @id">
            <li class="navCategorySelected">
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <xsl:value-of select="'Content List'"/>
              <xsl:if test="($text1 != '' or $text2 != '' or $text3 != '') and (@xtf:hitCount)">
                <span class="subhit">[<xsl:value-of select="@xtf:hitCount"/> 
                  hit<xsl:if test="number(@xtf:hitCount) &gt; 1">s</xsl:if>]</span>
              </xsl:if>
            </li>
          </xsl:when>
          <xsl:otherwise>
            <li>
              <xsl:if test="key('hasContent',@id)">
                <xsl:call-template name="camera"/>
              </xsl:if>
              <a href="{$xtfURL}{$dynaxmlPath}?brand={$brand}&#038;docId={$docId}&#038;chunk.id={@id}{$lastbit}{$search}{if (@xtf:firstHit) then concat('#', @xtf:firstHit) else ''}">
                <xsl:value-of select="'Content List'"/></a>
              <xsl:if test="($text1 != '' or $text2 != '' or $text3 != '') and (@xtf:hitCount)">
                <span class="subhit">[<xsl:value-of select="@xtf:hitCount"/> 
                  hit<xsl:if test="number(@xtf:hitCount) &gt; 1">s</xsl:if>]</span>
              </xsl:if>
            </li>
          </xsl:otherwise>          
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    
    
    <xsl:if test="c01[@id] | c02[@id][@level='series'] | c02[@id][@level='subseries']">
    <li><ul><xsl:apply-templates mode="toc" select="c01[@id] | c02[@id][@level='series'] | c02[@id][@level='subseries']"/></ul></li>
    </xsl:if>
    
  </xsl:template>
    
  <xsl:template match="c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" mode="items"> 
    <xsl:choose>
      <xsl:when test="@id">
        <!--Anchor for items on "view items online" page -->
        <a name="{@id}"></a>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <div class="item">
      <xsl:variable name="my-name" select="name(.)"/>
      <xsl:if test="not(preceding-sibling::*[name() eq $my-name])">
        <xsl:call-template name="series" />
      </xsl:if>
      
      <xsl:choose>
        <xsl:when test="did[daogrp or dao]">
          <xsl:apply-templates select="did[daogrp or dao]" mode="items" />
        </xsl:when>
        <xsl:when test="did and dao">
          <xsl:apply-templates select="did" mode="items"></xsl:apply-templates>
          <xsl:apply-templates select="dao"></xsl:apply-templates>
          <hr/>
        </xsl:when>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="did" mode="items">
  	<div class="item">
      <xsl:value-of select="unittitle" />
    </div>
    <xsl:choose>
      <xsl:when test="daogrp">
        <a href="http://ark.cdlib.org/{daogrp/@poi}">
          <img class="icon" width="17" height="14" alt="[image]" src="images/image_icon.gif" />View item(s)</a>
        <hr/>
      </xsl:when>
      <xsl:when test="dao/@poi">
        <a href="{dao/@href}">
          <img class="icon" border="0" width="17" height="14" alt="[image]" src="images/image_icon.gif"/>View items(s)
        </a>
        <hr/>
      </xsl:when>
      <xsl:when test="dao/@href and dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]">
        <div>
          <a href="{dao/@href}">
            <xsl:choose>
              <xsl:when test="dao/@title"><xsl:value-of select="dao/@title"/></xsl:when>
              <xsl:otherwise>View item(s)</xsl:otherwise>
            </xsl:choose>
          </a>
        </div>
        <hr/>
      </xsl:when>
      <xsl:when test="dao/@href">
        <a href="{dao/@href}">
          	<img class="icon" width="17" height="14" alt="[image]" src="images/image_icon.gif" />View item(s)</a>
         <hr/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  
<xsl:template name="substring-before-last">
  <xsl:param name="string" />
  <xsl:param name="substring" />
  <xsl:param name="delimiter" />
  <xsl:choose>
    <xsl:when test="contains($string, $delimiter)">
      <xsl:call-template name="substring-before-last">
        <xsl:with-param name="string"
          select="substring-after($string, $delimiter)" />
        <xsl:with-param name="substring"
          select="concat($substring, substring-before($string, $delimiter), $delimiter)" />
        <xsl:with-param name="delimiter" select="$delimiter" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$substring" /></xsl:otherwise>
  </xsl:choose>
 </xsl:template>
  
  <xsl:template match="physdesc[ancestor::dsc and @label]">
   <!-- <xsl:text disable-output-escaping='yes'> <![CDATA[<p>]]></xsl:text> -->
      <span class="bold"><xsl:value-of select="@label"/></span><br/>
      <xsl:apply-templates/>
  </xsl:template>
  
  <!-- ead formatting templates -->
  <xsl:template match="*">
    <xsl:if test="@label and parent::did and not(ancestor::dsc)">
      <xsl:text disable-output-escaping='yes'> <![CDATA[<p>]]></xsl:text>
    </xsl:if>
    <xsl:if test="@label">
      <span class="bold">
        <xsl:value-of select="@label"/>
      </span>
      <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="@label and parent::did and not(ancestor::dsc)">
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
    <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
    <xsl:apply-templates mode="br"/>
  </xsl:template>
  
  <xsl:template match="/" mode="space">
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
    <xsl:apply-templates mode="space"/>
  </xsl:template>
  
  <!-- <xsl:template match="PHYSFACET | DIMENSIONS">
  <xsl:apply-templates/>
  <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
  </xsl:template> -->
  
  <!--
  <xsl:template match="dimensions">
    <span class="dimensions"><xsl:apply-templates/></span>
  </xsl:template>
  -->
  
  <!-- IUFA-18 Table based view of containers -->
  <xsl:template name="table-c0x">
    <xsl:param name="container"/>
    <xsl:param name="table"/>
    <xsl:variable name="class" select="name($container)"/>
    <xsl:choose>
      <!-- Insert table elements if table is required -->
      <xsl:when test="$table eq 'yes'">
        <table border="0" width="98%" cellspacing="1" cellpadding="0">
          <xsl:call-template name="table-c0x">
            <xsl:with-param name="container" select="$container"/>
            <xsl:with-param name="table" select="'no'"/>
          </xsl:call-template>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="descendant::*[starts-with(name(), 'c0')] or descendant::container">
            <xsl:for-each select="$container/*">
              <xsl:choose>
                <xsl:when test="not(container) and not(starts-with(name(), 'c0'))">
                  <!-- no container and not c0x, insert a line without box/folder number -->
                  <tr><td colspan="2" class="nowrap">&#160;</td><td width="81%">
                    <div class="otl{name($container)}head">
                      <xsl:apply-templates select="."/>
                    </div>
                  </td></tr>
                </xsl:when>
                <xsl:when test="container">
                  <!-- container, insert a line with box/folder number -->
                  <tr>
                    <xsl:choose>
                      <xsl:when test="count(container) eq 2">
                        <td valign="top" class="nowrap">
                          <xsl:value-of select="container[1]/@label"/>&#160;<xsl:value-of select="container[1]"/>
                        </td>
                        <td valign="top" class="nowrap">
                          <xsl:value-of select="container[2]/@label"/>&#160;<xsl:value-of select="container[2]"/>
                        </td>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="lower-case(container[1]/@type) eq 'box'">
                            <td valign="top" class="nowrap">
                              <xsl:value-of select="container[1]/@label"/>&#160;<xsl:value-of select="container[1]"/>
                            </td>
                            <td valign="top" class="nowrap">
                              &#160;
                            </td>
                          </xsl:when>
                          <xsl:when test="lower-case(container[1]/@type) eq 'folder'">
                            <td valign="top" class="nowrap">
                              &#160;
                            </td>
                            <td valign="top" class="nowrap">
                              <xsl:value-of select="container[1]/@label"/>&#160;<xsl:value-of select="container[1]"/>
                            </td>
                          </xsl:when>
                          <xsl:otherwise><!-- IUFA-77 When there is no @type, put it in the first column -->
                            <td valign="top" class="nowrap">
                              <xsl:value-of select="container[1]/@label"/>&#160;<xsl:value-of select="container[1]"/>
                            </td>
                            <td valign="top" class="nowrap">
                              &#160;
                            </td>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                    
                    <td width="81%">
                      <div class="otl{name($container)}head">
                        <xsl:for-each select="./*[not(name() eq 'container')]">
                          <xsl:apply-templates select="."/>
                        </xsl:for-each>
                      </div>
                    </td>
                  </tr>
                </xsl:when>
                <xsl:otherwise>
                  <!-- call template recursively for c0x elements -->
                  <xsl:call-template name="table-c0x">
                    <xsl:with-param name="container" select="."/>
                    <xsl:with-param name="table" select="'no'"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
              
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise> <!-- If no c0x in descendents, then simply put all of them in one row -->
            <tr><td colspan="2" class="nowrap">&#160;</td><td width="81%">
              <xsl:for-each select="*">
                <div class="otl{name($container)}head">
                  <xsl:apply-templates/>
                </div>
              </xsl:for-each>
            </td></tr>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="c01 | c02 | c03 | c04 | c05 | c06 | c07 | c08 | c09 | c10 | c11">
    <!-- IUFA-18 -->
    <!--
    <xsl:call-template name="table-c0x">
      <xsl:with-param name="container" select="."/>
      <xsl:with-param name="table" select="'yes'"/>
    </xsl:call-template>
    -->
   
      <xsl:choose>
      	<xsl:when test="@id and parent::dsc or ($chunk.id != '' and $chunk.id = @id)">
      	 <ul class="c01">
      		<!-- IUFA-174 - Anchor for items on Entire Finding Aid page -->
      		<li id="{@id}">
      			<xsl:text disable-output-escaping='yes'><![CDATA[<hr />]]></xsl:text>
      			<xsl:apply-templates/>
	  		</li>
	  	 </ul>
	  	</xsl:when>
	  	<xsl:when test="@id">
      		<!-- IUFA-174 - Anchor for items on Entire Finding Aid page -->
      		<ul>
      		<li id="{@id}">
      			<xsl:text disable-output-escaping='yes'><![CDATA[<hr />]]></xsl:text>
      			<xsl:apply-templates/>
	  		</li>
	  		</ul>
	  	</xsl:when>
	  	<xsl:when test="parent::dsc">
	  		<ul class="c01">
	  		<li>
      			<xsl:text disable-output-escaping='yes'><![CDATA[<hr />]]></xsl:text>
      			<xsl:apply-templates/>
	  		</li>
	  	  </ul>
	  	</xsl:when>
	  	<xsl:otherwise>
	  		<ul>
	  		<li>
      			<xsl:text disable-output-escaping='yes'><![CDATA[<hr />]]></xsl:text>
      			<xsl:apply-templates/>
	  		</li>
	  		</ul>
	  	</xsl:otherwise>
	 </xsl:choose>
    
  </xsl:template>
  
  <xsl:template match="odd">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*" mode="dscdid">
    <!--<br/>-->
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="did">
    <xsl:choose>
      <xsl:when test="ancestor::node()/c01">
        <!-- IUFA-189 added for-each and choose -->
        <!-- IUFA-191 added iufa-note and block classes -->
      	<xsl:for-each select="child::*">
	      			<xsl:choose>
	      				<!-- <xsl:when test="name(.)='physdesc'">
	      					<span class="iufa-note">
					    	<xsl:apply-templates select="."/></span>
	      				</xsl:when> -->
	      				<xsl:when test="name(.)='note' or name(.)='container'">
	      					<xsl:apply-templates select="."/>
	      				</xsl:when>
	      				<xsl:when test="not(name(.)='unittitle') and not(name(.)='note') and not(name(.)='head')">
			      			<p><span class="iufa-note">
					    	<xsl:apply-templates select="."/></span></p>
	      				</xsl:when>
	      				<xsl:otherwise>
	      					<span class="display-block"><xsl:apply-templates select="."/></span>
	      				</xsl:otherwise>
	      			</xsl:choose>
      	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>	
		   <xsl:apply-templates select="*[not (name(.)='unitdate')]" /> 	
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="unittitle">
    <xsl:if test="@label">
      <!-- <xsl:text disable-output-escaping='yes'> <![CDATA[<p>]]></xsl:text> -->
      <span class="bold">
        <xsl:value-of select="@label"/>
      </span>
      <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
    </xsl:if>
    <xsl:if test="contains(preceding-sibling::head, 'Series:') or contains(preceding-sibling::head, 'Subseries:')">
      <xsl:text disable-output-escaping='yes'> <![CDATA[<span class="bold">]]></xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="contains(preceding-sibling::head, 'Series:') or contains(preceding-sibling::head, 'Subseries:')">
      <xsl:text disable-output-escaping='yes'> <![CDATA[</span>]]></xsl:text>
    </xsl:if>
    <!-- IUFA-72 -->
    <xsl:if test="not(ancestor::dsc) and following-sibling::unitdate">      
      <!-- IUFA-64 -->
      <xsl:if test="not(ends-with(normalize-space(.), ','))">, </xsl:if>
      <xsl:for-each select="following-sibling::unitdate">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:if>
    <!-- IUFA-52 -->
    <xsl:if test="(not(name(parent::*) eq 'did') 
      or not(../container)) 
      and not(name(following-sibling::*[1]) eq 'physdesc') 
      and not(name(following-sibling::*[1]) eq 'note')">
     <!-- &#160; <br/>HERE4 -->
    </xsl:if>
<!-- IUFA-189 commented out -->
<!--    <xsl:if test="name(following-sibling::*[1]) eq 'physdesc'"> -->
<!--    	<xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
    </xsl:if> -->
    <!-- <xsl:if test="@label">
      <xsl:text disable-output-escaping='yes'><![CDATA[</p>]]></xsl:text>
    </xsl:if> -->
  </xsl:template>  
  
  <xsl:template match="unittitle/unitdate">
    <xsl:apply-templates/> 
    <xsl:if test="not(position() = last())">
      <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
    </xsl:if>
  </xsl:template>

 <xsl:template match="unitdate">
    <!-- IUFA-39 & IUFA-187 -->
  <xsl:choose>
      <xsl:when test="@type eq 'bulk'">&#160;<xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="eadid">
    <p><span class="bold">eadid</span><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>    <xsl:value-of select="."/></p>
  </xsl:template>
  
  <xsl:template match="dsc//list">
    <xsl:apply-templates select="head | listhead"/>

    <xsl:variable name="totalItems" select="count(item)"/>
    <xsl:variable name="element-name" select="if (@type eq 'deflist') then 'dl' 
      else if (@type='ordered' and @numeration) then 'ol' 
      else if (@type='ordered' and not( @numeration )) then 'ol'
      else if (@type='marked') then 'ul' 
      else 'ul'"/>
    <xsl:variable name="element-class" select="if (@type eq 'deflist') then 'ead-list' 
      else if (@type='ordered' and @numeration) then 'ead-{@numeration}' 
      else if (@type='ordered' and not( @numeration )) then 'ead-arabic'
      else if (@type='marked') then 'ead-list'
      else 'ead-list-unmarked'"/>
    <xsl:variable name="listid" select="generate-id(.)"/>
    <xsl:element name="{$element-name}">
      <xsl:attribute name="id" select="$listid"/>
      <xsl:attribute name="class" select="$element-class"/>
      <xsl:if test="$totalItems &gt; 10">
        <li>
          <a class="iufa-togglebutton" id="{$listid}-b" href="javascript:toggleList('{$listid}')">View All (<xsl:value-of select="$totalItems"/>)</a>
        </li>
      </xsl:if>
      <xsl:apply-templates select="defitem | item[position() &lt; 11]"/>
      <xsl:apply-templates select="defitem | item[position() &gt; 10]" mode="hidden"/>
    </xsl:element>         
    <!-- END OF IUFA-17 -->
  </xsl:template>
  
  <xsl:template match="item" mode="hidden">
    <xsl:choose>
      <xsl:when test=".//xtf:hit">
        <li><xsl:apply-templates/></li>     
      </xsl:when>
      <xsl:otherwise>
        <li style="display:none"><xsl:apply-templates/></li>     
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
  	<xsl:choose>
  		<xsl:when test="$doc.view = 'print'">
  			<!-- xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text -->
    		<xsl:text> </xsl:text>
    		<xsl:choose>
        			<xsl:when test="@label and parent::did/parent::c01">
        				<xsl:variable name="containerLabel">
        					<xsl:value-of select="@label"/><xsl:text> </xsl:text><xsl:value-of select="."/>
        				</xsl:variable>
        				<span class="print-ead-container">
          					<!-- if length of $containerLabel is more than 8 characters, find first white space and insert line break -->
	        				<xsl:choose>
	        					<xsl:when test="string-length($containerLabel) > 8">
	        						<xsl:for-each select="tokenize($containerLabel, '\s+')">
	        							<xsl:value-of select="."/><br/>
	        						</xsl:for-each>
	        					</xsl:when>
	        					<xsl:otherwise>
	        						<xsl:value-of select="$containerLabel"/>
	        					</xsl:otherwise>
	        				</xsl:choose>
          				</span>
        			</xsl:when>
        			<xsl:when test="@label">
        				<span class="print-ead-container">
	        				<xsl:value-of select="@label"/><xsl:text> </xsl:text>
	        				<xsl:apply-templates/>
	        			</span>
        			</xsl:when>
        			<xsl:otherwise>
        				<span class="print-ead-container">
        					<xsl:apply-templates/>
        				</span>
        			</xsl:otherwise>
      			</xsl:choose>
      		<xsl:choose>
      			<xsl:when test="following-sibling::container and parent::did/parent::c01">
      				<xsl:text disable-output-escaping='yes'><![CDATA[<br/><br/>]]></xsl:text>
      			</xsl:when>
      			<xsl:when test="following-sibling::container">
      				<xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
      			</xsl:when>
      			<xsl:otherwise/>
      		</xsl:choose>
        </xsl:when>
        <xsl:otherwise>
    		<!-- xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text -->
    		<xsl:text> </xsl:text>
      			<xsl:choose>
        			<xsl:when test="@label and parent::did/parent::c01">
        				<xsl:variable name="containerLabel">
        					<xsl:value-of select="@label"/><xsl:text> </xsl:text><xsl:value-of select="."/>
        				</xsl:variable>
	        			<span class="ead-container">
	        				<!-- if length of $containerLabel is more than 8 characters, find first white space and insert line break -->
	        				<xsl:choose>
	        					<xsl:when test="string-length($containerLabel) > 8">
	        						<xsl:for-each select="tokenize($containerLabel, '\s+')">
	        							<xsl:value-of select="."/><br/>
	        						</xsl:for-each>
	        					</xsl:when>
	        					<xsl:otherwise>
	        						<xsl:value-of select="$containerLabel"/>
	        					</xsl:otherwise>
	        				</xsl:choose>
	        				<!-- <xsl:value-of select="@label"/>
          					<br/>
          					<xsl:apply-templates/> -->
          				</span>
        			</xsl:when>
        			<xsl:when test="@label">
        				<span class="ead-container">
	        				<xsl:value-of select="@label"/><xsl:text> </xsl:text>
	        				<xsl:apply-templates/>
	        			</span>
        			</xsl:when>
        			<xsl:otherwise>
        				<span class="ead-container">
	        				<xsl:apply-templates/>
	        			</span>
        			</xsl:otherwise>
      			</xsl:choose>
      		<xsl:choose>
      			<xsl:when test="following-sibling::container and parent::did/parent::c01">
      				<xsl:text disable-output-escaping='yes'><![CDATA[<br/><br/>]]></xsl:text>
      			</xsl:when>
      			<xsl:when test="following-sibling::container">
      				<xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
      			</xsl:when>
      			<xsl:otherwise/>
      		</xsl:choose>
     	</xsl:otherwise>
    </xsl:choose>
<!--      xsl:if test="not(following-sibling::container)">
      	<xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
      </xsl:if -->
  </xsl:template>
  
  <xsl:template match="lb">
    <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
  </xsl:template>
  
  <xsl:template match="emph">
    <xsl:choose>
      <xsl:when test="@render eq 'doublequote'">&quot;<xsl:apply-templates/>&quot;</xsl:when>
      <xsl:when test="@render eq 'bolddoublequote'">
          <span class="ead-bold">&quot;<xsl:apply-templates/>&quot;</span>
      </xsl:when>
      <xsl:when test="@render eq 'singlequote'">&#39;<xsl:apply-templates/>&#39;</xsl:when>
      <xsl:when test="@render eq 'boldsinglequote'">
          <span class="ead-bold">&#39;<xsl:apply-templates/>&#39;</span>
      </xsl:when>
      <xsl:when test="@render">
        <span>
          <xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:otherwise><em><xsl:apply-templates/></em></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="titleproper[@type='filing']">
    <h3>
    <xsl:if test="@render">
      <xsl:choose>
          <xsl:when test="@render eq 'doublequote'">
          	&quot;<xsl:apply-templates/>&quot;
          </xsl:when>
          <xsl:when test="@render eq 'bolddoublequote'">
          	<xsl:attribute name="class">ead-bold</xsl:attribute>&quot;<xsl:apply-templates/>&quot;
          </xsl:when>
          <xsl:when test="@render eq 'singlequote'">
          	&#39;<xsl:apply-templates/>&#39;
          </xsl:when>
          <xsl:when test="@render eq 'boldsinglequote'">
          	<xsl:attribute name="class">ead-bold</xsl:attribute>&#39;<xsl:apply-templates/>&#39;
          </xsl:when>
          <xsl:otherwise>
	           <xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
	            <xsl:apply-templates/>
          </xsl:otherwise>
      </xsl:choose>
     </xsl:if>
<!--      <xsl:if test="@render">
        <xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/> -->
    </h3>
  </xsl:template>
  
  <xsl:template match="title">
    <xsl:choose>
      <!-- IUFA-82 and IUFA-176 -->
      <xsl:when test="ancestor::controlaccess">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="emph">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@render">
          	<xsl:choose>
          		<xsl:when test="@render eq 'doublequote'">
          			&quot;<xsl:apply-templates/>&quot;
          		</xsl:when>
          		<xsl:when test="@render eq 'bolddoublequote'">
          			<span class="ead-bold">&quot;<xsl:apply-templates/>&quot;</span>
          		</xsl:when>
          		<xsl:when test="@render eq 'singlequote'">
          			&#39;<xsl:apply-templates/>&#39;
          		</xsl:when>
          		<xsl:when test="@render eq 'boldsinglequote'">
          			<span class="ead-bold">&#39;<xsl:apply-templates/>&#39;</span>
          		</xsl:when>
          		<xsl:otherwise>
          			<span>
	            		<xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
	            		<xsl:apply-templates/>
        			</span>
	            </xsl:otherwise>
            </xsl:choose>
      </xsl:when>
      <xsl:when test="name(..) = 'namegrp'">
          <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="head">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::node()/c01 or not(name(../..) eq 'archdesc') or ancestor::dscgrp">
        <xsl:choose>
          <!-- IUFA-66 -->
          <!-- xsl:when test="name(..) eq 'scopecontent' and ancestor-or-self::dsc">
            <xsl:apply-templates/>
          </xsl:when -->
          <!-- IUFA-74 -->
         <!-- <xsl:when test="name(..) eq 'arrangement' and ancestor-or-self::dsc">
            <xsl:apply-templates/>
          </xsl:when> -->
          <xsl:when test="following-sibling::unittitle or following-sibling::did or parent::controlaccess">
          	<span class="bold"><xsl:apply-templates/></span>
          </xsl:when>
          <xsl:when test="ancestor::dsc">
          	<span class="boldIndent"><xsl:apply-templates/></span>
          </xsl:when>
          <!-- IUFA-57 -->
          <!-- <xsl:when test="ancestor::controlaccess/controlaccess">
        	<span class="nestedControlAccess"><xsl:apply-templates/></span>
       	  </xsl:when> -->
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <h4><xsl:apply-templates/></h4>
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
  
  <xsl:template match="P | NUM | author">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template match="subtitle">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template match="blockquote">
    <blockquote><xsl:apply-templates/></blockquote>
  </xsl:template>
  
  <xsl:template match="p">
    <xsl:choose>
      <!-- IUFA-58 -->
      <!-- IUFA-189 removed check in following xsl:when:
              not(name(..) eq 'scopecontent' and ancestor-or-self::c01) and 
      -->
      <xsl:when test="descendant::list">
		<div>
			<xsl:apply-templates/>
		</div>
	  </xsl:when>      
      <xsl:when test="ancestor::dsc">
      	<xsl:choose>
      		<xsl:when test="preceding-sibling::head">
      			<p class="indentNoTopMargin"><xsl:apply-templates/></p>
      		</xsl:when>
      		<xsl:otherwise>
      			<p class="indent"><xsl:apply-templates/></p>
      		</xsl:otherwise>
      	</xsl:choose>
      </xsl:when>
      <xsl:when test="child::text() and 
        not(name(..) eq 'arrangement' and ancestor-or-self::c01) and 
        not(name(..) eq 'acqinfo' and ancestor-or-self::c01) and
        not(ancestor::descgrp)">
        <p><xsl:apply-templates/></p>
      </xsl:when>
      <xsl:when test="ancestor::descgrp"><!-- IUFA-71 -->
        <xsl:choose>
          <xsl:when test="name(preceding-sibling::*[1]) eq 'p'">
            <p><xsl:apply-templates/></p>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 

  <xsl:template match="p" mode="note">
    <xsl:apply-templates/>
  </xsl:template> 
  
  <!-- xsl:template match="extent">
  <xsl:apply-templates mode="br"/>
  </xsl:template -->
  
  <xsl:template match="extent[preceding::dsc]">
    <h4>Extent</h4><p><xsl:apply-templates/></p>
  </xsl:template> 
  
  <xsl:template match="bibref | archref">
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
    <xsl:if test="(name(..)='bibliography') or 
      ( name(..)='otherfindaid') or
      (name(..)='separatedmaterial') or
      ( name(..)='relatedmaterial')"><!-- <br/><br/>HERE10 -->
    </xsl:if>
  </xsl:template>

<!-- Removed extref from previous bibref/archref match because &nbsp; after link was causing problems; need to probably remove &nbsp; from all of these but lcp collections making use of it now in their citations - 12/4/09 -->
  <xsl:template match="extref">
  	<xsl:choose>
      <xsl:when test="@href and not (@show='embed')">
        <a href="{@href}">
          <xsl:choose>
            <xsl:when test=".//text()">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>Link</xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      <xsl:when test="@href and (@show='embed')">
        <img src="{@href}"/>
      </xsl:when>
      <xsl:otherwise>
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
  	<xsl:variable name="lastbit">
      <xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if>
    </xsl:variable>
    <a href="/findingaids/view?docId={$docId}{$lastbit}&#038;link.id={@target}#{@target}"><xsl:apply-templates mode="ref"/></a>
  </xsl:template>
  
  <xsl:template match="ptr">
    <xsl:variable name="lastbit">
      <xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if>
    </xsl:variable>
    <a href="/findingaids/view?docId={$docId}{$lastbit}&#038;link.id={@target}#{@target}"><xsl:value-of select="@title"/></a>
  </xsl:template>
  
  <xsl:template match="repository[1]">
    <xsl:choose>
      <xsl:when test="@label">
        <p>
          <span class="bold"><xsl:value-of select="@label"/>
          </span><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
        <a>
          <xsl:attribute name="href">
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
        <xsl:otherwise>View item(s)</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:apply-templates select="daodesc/*"/>
    <a href="{@href}"><img class="icon" border="0" width="17" height="14" alt="[image]" src="images/image_icon.gif"/> 
      <xsl:value-of select="$linktext"/></a><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
  </xsl:template>
  
  <xsl:template match="daogrp">
    <p>
      <a href="http://ark.cdlib.org/{@poi}"><img class="icon" border="0" width="17" height="14" alt="[image]" src="images/image_icon.gif"/>View item(s)</a>
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
  
  <xsl:template match="event | famname | function | geogname | genreform | corpname | persname | date | name | occupation | subject ">
    <xsl:choose>
      <xsl:when test="
        name(..) = 'namegrp' 
        or         name(..) = 'index'
        or         name(..) = 'origination'
        ">
        <xsl:apply-templates/><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
      </xsl:when>
      <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- IUFA-31, IUFA-71  -->
  <xsl:template match="controlaccess">
    <xsl:choose>
      <xsl:when test="parent::controlaccess">
   	  	<ul class="controlaccessBottomMargin">
			<li><xsl:apply-templates select="head"/></li>
			<xsl:for-each select="*[not(name() eq 'head')]">
      			<xsl:choose>
      				<xsl:when test="name() eq 'list' and not(parent::controlaccess)">
      					<ul>
      						<xsl:apply-templates select="."/>
      					</ul>
      				</xsl:when>
        			<xsl:when test="name() eq 'list'"><xsl:apply-templates select="."/></xsl:when>
        			<xsl:otherwise><li><xsl:apply-templates select="."/></li></xsl:otherwise>
      			</xsl:choose>
    		</xsl:for-each>
   		</ul>
   	  </xsl:when>
      <xsl:when test="parent::archdesc or not(ancestor::dsc)">
      	<ul class="controlaccessNoMargin">
        	<li><xsl:apply-templates select="head"/></li>
        	<xsl:for-each select="*[not(name() eq 'head')]">
      			<xsl:choose>
        			<xsl:when test="name() eq 'list'"><xsl:apply-templates select="."/></xsl:when>
        			<xsl:otherwise><li><xsl:apply-templates select="."/></li></xsl:otherwise>
      			</xsl:choose>
    		</xsl:for-each>
    	</ul>
      </xsl:when>
      <xsl:when test="ancestor::dsc and not(parent::controlaccess)">
        <ul class="controlaccessIndent">
			<li><xsl:apply-templates select="head"/></li>
			<xsl:for-each select="*[not(name() eq 'head')]">
      			<xsl:choose>
      				<xsl:when test="name() eq 'list' and not(parent::controlaccess)">
      					<ul>
      						<xsl:apply-templates select="."/>
      					</ul>
      				</xsl:when>
        			<xsl:when test="name() eq 'list'"><xsl:apply-templates select="."/></xsl:when>
        			<xsl:otherwise><li><xsl:apply-templates select="."/></li></xsl:otherwise>
      			</xsl:choose>
    		</xsl:for-each>
   		</ul>
   	  </xsl:when>
      <xsl:otherwise>
      	<ul>
			<li><xsl:apply-templates select="head"/></li>
			<xsl:for-each select="*[not(name() eq 'head')]">
      			<xsl:choose>
      				<xsl:when test="name() eq 'list' and not(parent::controlaccess)">
      					<ul>
      						<xsl:apply-templates select="."/>
      					</ul>
      				</xsl:when>
        			<xsl:when test="name() eq 'list'"><xsl:apply-templates select="."/></xsl:when>
        			<xsl:otherwise><li><xsl:apply-templates select="."/></li></xsl:otherwise>
      			</xsl:choose>
    		</xsl:for-each>
   		</ul>
      </xsl:otherwise>
    </xsl:choose>
    <!-- <xsl:for-each select="*[not(name() eq 'head')]">
      <xsl:choose>
        <xsl:when test="name() eq 'controlaccess' or name() eq 'list' or name() eq 'p'"><li><xsl:apply-templates select="."/></li></xsl:when>
        <xsl:otherwise><li><xsl:apply-templates select="."/></li></xsl:otherwise>
      </xsl:choose>
    </xsl:for-each> -->
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
  
  <xsl:template name="queryString">
    <xsl:if test="$text1">
      <xsl:value-of select="$text1"/> in <xsl:value-of select="$field1"/>
    </xsl:if>
    <xsl:if test="$text2">
      &#160;<xsl:value-of select="$op1"/>&#160;<xsl:value-of select="$text2"/> in <xsl:value-of select="$field2"/>
    </xsl:if>
    <xsl:if test="$text3">
      &#160;<xsl:value-of select="$op2"/>&#160;<xsl:value-of select="$text3"/> in <xsl:value-of select="$field3"/>
    </xsl:if>
    <xsl:if test="$fromYear != '' and $fromMonth != ''">
      <xsl:choose>
        <xsl:when test="count($toYear) = 1 and count($toMonth) = 1">
          <xsl:text> [ </xsl:text>
          <xsl:value-of select="$fromYear"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="$fromMonth"/>
          <xsl:text> - </xsl:text>
          <xsl:value-of select="$toYear"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="$toMonth"/>
          <xsl:text> ]</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> [ </xsl:text>
          <xsl:value-of select="$fromYear"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="$fromMonth"/>
          <xsl:text> ]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template> 
  
<!-- code to set email address on finding aid repository -->
  
  <xsl:template match="addressline"> 
    <xsl:choose> 
      <xsl:when test="starts-with(., 'Email:')"> 
        <xsl:variable name="email"> 
          <xsl:value-of select="substring-after(., 'Email:')"/> 
        </xsl:variable> 
        <a href="mailto:{$email}"><xsl:value-of select="."/></a> 
      </xsl:when> 
      <xsl:otherwise> 
        <xsl:value-of select="."/><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
  
  <!-- Setting style for note tags in lilly -->
  <xsl:template match="note">
  		<xsl:variable name="first" select="if (preceding-sibling::note) then false() else true()"/>
  		<xsl:if test="@label">
  			<span class="boldIndent"><xsl:value-of select="@label"/></span><br/>
  		</xsl:if>
    <xsl:for-each select="child::*">
      <!-- when note not encoded in <p>, wrap it in a class iufa-note -->
     <xsl:choose>
     	<xsl:when test="name() eq 'p' and parent::note[@label]">
     		<p class="{if (not(preceding-sibling::p)) then 'iufa-note-label' else 'iufa-note'}">
            <xsl:apply-templates select="." mode="note"/>
          </p>
     	</xsl:when>
        <xsl:when test="name() eq 'p'">
          <p class="{if ($first = true() and not(preceding-sibling::p)) then 'iufa-first-note' else 'iufa-note'}">
            <xsl:apply-templates select="." mode="note"/>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="language">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <!-- 
    Fixes IUFA-55 http://bugs.dlib.indiana.edu/jira/browse/IUFA-55
  -->
  <xsl:template match="descgrp/*[not(name() eq 'head')]">
    <xsl:choose>
      <xsl:when test="head">
        <div class="head-div">
          <b class="iufa-admintitle"><xsl:value-of select="head"/></b>
          <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
          <xsl:apply-templates select="*[not(name() eq 'head')]"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- IUFA-74 -->
  <xsl:template match="arrangement[ancestor::dsc]">
    <xsl:choose>
      <xsl:when test="name(preceding-sibling::*[1]) eq 'scopecontent'">
        <xsl:apply-templates select="head"/> <!-- IUFA-204 -->
        <xsl:apply-templates select="*[not(name() eq 'head')]"/>
      </xsl:when>
      <xsl:otherwise>
      	<!-- IUFA-190 -->
        <xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text><xsl:apply-templates select="*[not(name() eq 'head')]"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template match="list">
  	<xsl:choose>
  		<xsl:when test="parent::p">
  			<ul class="divList">
  				<xsl:apply-templates/>
  			</ul>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:apply-templates/>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>
  
  <!-- IUFA-13 IUFA-67 -->
  <!-- IUFA-191 Removed extra space (&#160;) before acqinfo to even up indenting -->
  <!-- <xsl:template match="acqinfo[ancestor::dsc]">
    <span class="iufa-note">
    <xsl:value-of select="head"/>
    <xsl:apply-templates select="*[not(name() eq 'head')]"/>
    </span>
  </xsl:template> -->
  
  <xsl:template match="browse-subject|browse-creator"/>
  
  <!-- ====================================================================== -->
  <!-- Print Template - IUFA-217                                              -->
  <!-- ====================================================================== -->
  <xsl:template name="print">
      <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>
          <xsl:variable name="titleproper" select="$page/archdesc/did/unittitle"/>
    	  <xsl:variable name="titledate1" select="$page/archdesc/did/unitdate"/>
    	  <xsl:value-of select="replace(normalize-space($titleproper), '[^a-zA-Z0-9\]\)]+$', '')"/>
    	  <xsl:if test="$titledate1">
    		<xsl:text>, </xsl:text><xsl:value-of select="$titledate1"/>
    	  </xsl:if>
        </title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      <body>
      	  <div id="printPageContainer">
      	  	<h2>
      	  		<xsl:variable name="titleproper" select="$page/archdesc/did/unittitle"/>
    	  		<xsl:variable name="titledate1" select="$page/archdesc/did/unitdate"/>
    	  		<xsl:value-of select="replace(normalize-space($titleproper), '[^a-zA-Z0-9\]\)]+$', '')"/>
    	  		<xsl:if test="$titledate1">
    				<xsl:text>, </xsl:text><xsl:value-of select="$titledate1"/>
    	  		</xsl:if>
      	  	</h2>
            <xsl:apply-templates select="/ead/archdesc"/>
          </div>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
