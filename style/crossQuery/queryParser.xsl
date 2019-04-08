<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Simple query parser stylesheet                                         -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<!--
   Copyright (c) 2005, Regents of the University of California
   All rights reserved.
 
   Redistribution and use in source and binary forms, with or without 
   modification, are permitted provided that the following conditions are 
   met:

   - Redistributions of source code must retain the above copyright notice, <
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

<!--
  This stylesheet implements a simple query parser which does not handle any
  complex queries (boolean and/or/not, ranges, nested queries, etc.) An
  experimental parser is available that does parse these constructs; see
  complexQueryParser.xsl.
  
  For details on the input and output expected of this stylesheet, see the
  comment section at the bottom of this file.
-->

<!-- 
  Log: $Log: queryParser.xsl,v $
  Log: Revision 1.4  2007/07/09 19:49:26  djiao
  Log: *** empty log message ***
  Log:
  Author: $Author: djiao $
  Version: $Revision: 1.4 $ $Date: 2007/07/09 19:49:26 $
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:dc="http://purl.org/dc/elements/1.1/" 
                              xmlns:mets="http://www.loc.gov/METS/"
                              xmlns:xlink="http://www.w3.org/TR/xlink" 
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:parse="http://cdlib.org/parse"
                              xmlns:iutei="http://www.dlib.indiana.edu/collections/TEIgeneral/"
                              xmlns:freeformQuery="java:org.cdlib.xtf.xslt.FreeformQuery"
                              extension-element-prefixes="freeformQuery"
                              exclude-result-prefixes="xsl dc mets xlink xs parse">
  
  <xsl:import href="/opt/etext/common/XTF-latest/style/crossQuery/queryParser/default/queryParser.xsl"/>
  <xsl:import href="../iutei.xsl"/>
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  
  <xsl:strip-space elements="*"/>
  
<!-- ====================================================================== -->
<!-- Global parameters (specified in the URL)                               -->
<!-- ====================================================================== -->
    
  <!-- style param -->
  <xsl:param name="style"/>
  
  <!-- search mode -->
  <xsl:param name="smode"/>
  
  <!-- result mode -->
  <xsl:param name="rmode"/>  
  
  <!-- brand mode -->
  <xsl:param name="brand" select="'wright'"/>

  <!-- repository -->
  <xsl:param name="repository" select="'general'"/>
  
  <!-- sort mode -->
  <xsl:param name="sort"/>

  <!-- raw XML dump flag -->
  <xsl:param name="raw"/>

  <!-- first hit on page -->
  <xsl:param name="startDoc" select="1"/>
  
  <!-- documents per page -->
  <xsl:param name="docsPerPage">
    <xsl:choose>
      <xsl:when test="($smode = 'test') or $raw">
        <xsl:value-of select="10000"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="20"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- list of keyword search fields -->
  <!-- <xsl:param name="fieldList" select="'text title creator'"/> -->
  <xsl:param name="fieldList" select="'text'"/>
   
<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->
  
  <xsl:template match="/">
    
    <xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/tei/resultFormatter.xsl'"/>

    <!-- The top-level query element tells what stylesheet will be used to
       format the results, which document to start on, and how many documents
       to display on this page. -->
    <query indexPath="index" termLimit="1000" workLimit="1000000" style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="{$docsPerPage}">

      <!-- sort attribute -->
      <xsl:if test="$sort">
        <xsl:attribute name="sortMetaFields">
          <xsl:choose>
            <xsl:when test="$sort='title'">
              <xsl:value-of select="'sort-title,sort-creator,sort-repository,sort-date'"/>
            </xsl:when>
            <xsl:when test="$sort='date'">
              <xsl:value-of select="'sort-date,sort-title,sort-creator,sort-repository'"/>
            </xsl:when>              
            <xsl:when test="$sort='creator'">
              <xsl:value-of select="'sort-creator,sort-title,sort-date,sort-repository'"/>
            </xsl:when>
            <xsl:when test="$sort='repository'">
              <xsl:value-of select="'sort-repository,sort-title,sort-creator,sort-date'"/>
            </xsl:when>              
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      
      <!-- process query -->
      <xsl:choose>
            <xsl:when test="$smode = 'addToBag'">
               <xsl:call-template name="addToBag"/>
            </xsl:when>
            <xsl:when test="$smode = 'removeFromBag'">
               <xsl:call-template name="removeFromBag"/>
            </xsl:when>
            <xsl:when test="matches($smode,'showBag|emailFolder')">
               <xsl:call-template name="showBag"/>
            </xsl:when>

        <xsl:when test="not($repository eq 'general')">
          <and maxContext="100" maxSnippets="3">
            <term field="collection"><xsl:value-of select="$repository"/></term>
            <xsl:apply-templates/>
          </and>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:call-template name="facet">
        <xsl:with-param name="field" select="'facet-publisher'"/>
        <xsl:with-param name="topGroups" select="'*[1-5]'"/>
        <xsl:with-param name="sort" select="'totalDocs'"/>
      </xsl:call-template>
      
      <xsl:call-template name="facet">
        <xsl:with-param name="field" select="'facet-Publication_Year'"/>
        <xsl:with-param name="topGroups" select="'*[1-5]'"/>
        <xsl:with-param name="sort" select="'totalDocs'"/>
      </xsl:call-template>
      
      <xsl:call-template name="facet">
        <xsl:with-param name="field" select="'facet-Author'"/>
        <xsl:with-param name="topGroups" select="'*[1-5]'"/>
        <xsl:with-param name="sort" select="'totalDocs'"/>
      </xsl:call-template>
      
      <xsl:call-template name="facet">
        <xsl:with-param name="field" select="'facet-genre'"/>
        <xsl:with-param name="topGroups" select="'*[1-5]'"/>
        <xsl:with-param name="sort" select="'totalDocs'"/>
      </xsl:call-template>
      
      

    </query>
  </xsl:template>
  
  <xsl:template match="parameters">
    <xsl:call-template name="parameters">
      <xsl:with-param name="parameters" select="param"/>
      <xsl:with-param name="maxSnippets" select="number('3')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="parameters">
    <xsl:param name="parameters"/>
    <xsl:param name="maxSnippets" select="number('3')"/>
    
    <!-- Freeform query language -->
    <xsl:if test="//param[matches(@name, '^freeformQuery$')]">
      <and maxSnippets="{$maxSnippets}" maxContext="100">
        <xsl:variable name="strQuery" select="//param[matches(@name, '^freeformQuery$')]/@value"/>
        <xsl:variable name="parsed" select="freeformQuery:parse(upper-case($strQuery))"/>
        <xsl:apply-templates select="$parsed/query/*" mode="freeform"/>
        <!-- Process special facet query params -->
        <xsl:call-template name="addFacetQuery"/>
      </and>
      
    </xsl:if>
    
    
    <!-- text field parameters -->
    <xsl:variable name="textParams"  select="$parameters[count(*) &gt; 0 and matches(@name, 'text\d')]"/>
<!--        <xsl:text>TEXT out</xsl:text>
      <xsl:for-each select="$textParams/token[@isWord='yes']">
      <term><xsl:value-of select="lower-case(@value)"/></term>
      </xsl:for-each>
      <xsl:text>TEXT out</xsl:text>
-->    
    <!-- total number of parameters -->
    <xsl:variable name="paramTotal"  select="count($textParams)"/>
    <!-- operator parameters -->
    <xsl:variable name="opParams"    select="$parameters[count(*) &gt; 0 and matches(@name, 'op\d')]"/>
    <!-- field name parameters -->
    <xsl:variable name="fieldParams" select="$parameters[count(*) &gt; 0 and matches(@name, 'field\d')]"/>
    <!-- value of fromYear field -->
    <xsl:variable name="fromYear"    select="$parameters[count(*) &gt; 0 and @name='fromYear']"/>
    <!-- value of toYear field -->
    <xsl:variable name="toYear"      select="$parameters[count(*) &gt; 0 and @name='toYear']"/>
    <!-- value of fromMonth field -->
    <xsl:variable name="fromMonth">
      <xsl:choose>
        <xsl:when test="count($parameters[count(*) &gt; 0 and @name='fromMonth']) > 0">
          <xsl:value-of select="$parameters[count(*) &gt; 0 and @name='fromMonth']/@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'01'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- value of toMonth field -->
    <xsl:variable name="toMonth">
      <xsl:choose>
        <xsl:when test="count($parameters[count(*) &gt; 0 and @name='toMonth']) > 0">
          <xsl:value-of select="$parameters[count(*) &gt; 0 and @name='toMonth']/@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'12'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable> 
    

    <xsl:if test="count($textParams) &gt; 0 or $fromYear">
      <and maxSnippets="{$maxSnippets}" maxContext="100">
        <xsl:if test="count($textParams) &gt; 0">
        <xsl:call-template name="param">
          <xsl:with-param name="textParams" select="$textParams"/>
          <xsl:with-param name="opParams" select="$opParams"/>
          <xsl:with-param name="fieldParams" select="$fieldParams"/>
          <xsl:with-param name="number" select="$paramTotal"/>
          <xsl:with-param name="maxSnippets" select="$maxSnippets"/>
        </xsl:call-template>
        </xsl:if>

        <xsl:if test="count($fromYear) = 1">
          <xsl:choose>
            <xsl:when test="count($toYear) = 1">
              <range inclusive="yes" field="sort-date" maxSnippets="{$maxSnippets}">
                <upper>
                  <xsl:value-of select="concat($toYear/@value, '-',$toMonth, '-','31')"/>
                  <!--<xsl:variable name="upper" select="concat($toYear/@value, $toMonth, '31')"/>
                  <xsl:value-of select="replace($upper, '(\d)(\d{7})', '$1.$2E7')"/>-->
                </upper>
                <lower>
                  <xsl:value-of select="concat($fromYear/@value, '-','01', '-','01')"/>
                  <!--<xsl:variable name="lower">
                    <xsl:value-of select="concat($fromYear/@value, $fromMonth, '01')"/>
                  </xsl:variable>
                  <xsl:value-of select="replace($lower, '(\d)(\d{7})', '$1.$2E7')"/>-->
                </lower>
              </range>
            </xsl:when>
            <xsl:otherwise>
              <range inclusive="yes" field="sort-date" maxSnippets="{$maxSnippets}">
                <upper>
                  <!--<xsl:variable name="upper">
                    <xsl:choose>
                      <xsl:when test="count($parameters[count(*) &gt; 0 and @name='fromMonth']) > 0">
                        <xsl:value-of select="concat($fromYear/@value, $fromMonth, '31')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="concat($fromYear/@value, '1231')"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:value-of select="replace($upper, '(\d)(\d{7})', '$1.$2E7')"/>-->
                  <xsl:value-of select="concat('1999', '-',$toMonth, '-','31')"/>
                </upper>
                <lower>
                  <xsl:value-of select="concat($fromYear/@value, '-','01', '-','01')"/>
                  <!--<xsl:variable name="lower">
                    <xsl:choose>
                      <xsl:when test="count($parameters[count(*) &gt; 0 and @name='fromMonth']) > 0">
                        <xsl:value-of select="concat($fromYear/@value, $fromMonth, '01')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="concat($fromYear/@value, '0101')"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:value-of select="replace($lower, '(\d)(\d{7})', '$1.$2E7')"/>-->
                </lower>
              </range>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <!-- Process special facet query params -->
        <xsl:call-template name="addFacetQuery"/>
      </and>
    </xsl:if>

<!--    <xsl:if test="count($textParams) = 0">
      <xsl:if test="$repository eq 'general'">
        <and>
          <term field="text">$!@$$@!$</term>
        </and>
      </xsl:if>
    </xsl:if>
-->    
    
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Single-field parameter template                                        -->
<!--                                                                        -->
<!-- Join all the terms of a single text or meta-data query together. For   -->
<!-- meta-data queries, we must also specify the field to search in.        -->
<!-- ====================================================================== -->
  <xsl:template name="param">
    <xsl:param name="textParams"/>
    <xsl:param name="opParams"/>
    <xsl:param name="fieldParams"/>
    <xsl:param name="number"/>
    <xsl:param name="maxSnippets"/>

    <xsl:variable name="opNumber"         select="$number - 1"/>
    <xsl:variable name="text"             select="$textParams[substring-after(@name, 'text') = string($number)]"/>
    
<!--    <xsl:comment>
    <xsl:text>Number of fields: </xsl:text><xsl:value-of select="$number"/>
    </xsl:comment>
-->

    <xsl:variable name="localTextParams"  select="$textParams[not(substring-after(@name, 'text') = string($number))]"/>
    <xsl:variable name="field"            select="$fieldParams[substring-after(@name, 'field') = string($number)]"/>
    <xsl:variable name="localFieldParams" select="$fieldParams[not(substring-after(@name, 'field') = string($number))]"/>
    <xsl:variable name="op"               select="$opParams[substring-after(@name, 'op') = string($opNumber)]"/>
    <xsl:variable name="localOpParams"    select="$opParams[not(substring-after(@name, 'op') = string($opNumber))]"/>

    
<!--    <xsl:text>Text Params: </xsl:text><xsl:copy-of select="$localTextParams"/>-->
     
    
    <xsl:choose>
      <xsl:when test="count($localTextParams) = 0">
        <xsl:call-template name="term">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="field" select="$field"/>
          <xsl:with-param name="maxSnippets" select="$maxSnippets"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:if test="$op/@value = 'and'">
          <and>
            <xsl:call-template name="param">
              <xsl:with-param name="fieldParams" select="$localFieldParams"/>
              <xsl:with-param name="opParams" select="$localOpParams"/>
              <xsl:with-param name="textParams" select="$localTextParams"/>
              <xsl:with-param name="number" select="$number - 1"/>
              <xsl:with-param name="maxSnippets" select="$maxSnippets"/>
            </xsl:call-template>
            <xsl:call-template name="term">
              <xsl:with-param name="text" select="$text"/>
              <xsl:with-param name="field" select="$field"/>
              <xsl:with-param name="maxSnippets" select="$maxSnippets"/>
            </xsl:call-template>
          </and>
        </xsl:if>
        <xsl:if test="$op/@value = 'or'">
          <or>
            <xsl:call-template name="param">
              <xsl:with-param name="fieldParams" select="$localFieldParams"/>
              <xsl:with-param name="opParams" select="$localOpParams"/>
              <xsl:with-param name="textParams" select="$localTextParams"/>
              <xsl:with-param name="number" select="$number - 1"/>
              <xsl:with-param name="maxSnippets" select="$maxSnippets"/>
            </xsl:call-template>
            <xsl:call-template name="term">
              <xsl:with-param name="text" select="$text"/>
              <xsl:with-param name="field" select="$field"/>
              <xsl:with-param name="maxSnippets" select="$maxSnippets"/>
            </xsl:call-template>
          </or>
        </xsl:if>
        <xsl:if test="$op/@value = 'not'">
          <and>
            <xsl:call-template name="param">
              <xsl:with-param name="fieldParams" select="$localFieldParams"/>
              <xsl:with-param name="opParams" select="$localOpParams"/>
              <xsl:with-param name="textParams" select="$localTextParams"/>
              <xsl:with-param name="number" select="$number - 1"/>
              <xsl:with-param name="maxSnippets" select="$maxSnippets"/>
            </xsl:call-template>
            <not>
              <xsl:call-template name="term">
                <xsl:with-param name="text" select="$text"/>
                <xsl:with-param name="field" select="$field"/>
              </xsl:call-template>
            </not>
          </and>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="term">
    <xsl:param name="text"/>
    <xsl:param name="field"/>
    <xsl:param name="maxSnippets"/>

    <xsl:variable name="fieldValue">
      <xsl:call-template name="field">
        <xsl:with-param name="fieldValue">
          <xsl:value-of select="$field/@value"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="sectionType">
      <xsl:call-template name="sectionType">
        <xsl:with-param name="fieldValue">
          <xsl:value-of select="$field/@value"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>    

    <xsl:choose>
      <xsl:when test="count($text/phrase) = 1">
        <xsl:element name="and">
          <xsl:if test="$maxSnippets">
            <xsl:attribute name="maxSnippets" select="$maxSnippets"/>
          </xsl:if>
          <xsl:attribute name="maxContext" select="100"/>
          <xsl:attribute name="field" select="$fieldValue"/>
          <phrase>
            <xsl:for-each select="$text/phrase/token[@isWord='yes']">
              <term><xsl:value-of select="lower-case(replace(@value, '\?', ''))"/></term>
            </xsl:for-each>
          </phrase>
          <xsl:if test="not($sectionType eq '')">
            <sectionType>
              <term><xsl:value-of select="$sectionType"/></term>
            </sectionType>
          </xsl:if>
        </xsl:element>
      </xsl:when>

      <xsl:when test="count($text/token) = 1">
        <and maxContext="100">
          <xsl:if test="$maxSnippets">
            <xsl:attribute name="maxSnippets" select="$maxSnippets"/>
          </xsl:if>
          <xsl:attribute name="field" select="$fieldValue"/>     
          <term>
            <xsl:value-of select="lower-case(replace($text/@value, '\?', ''))"/>
          </term>
	      <xsl:if test="not($sectionType eq '')">
	        <sectionType>
	          <term><xsl:value-of select="$sectionType"/></term>
	        </sectionType>
	      </xsl:if>
        </and>
      </xsl:when>

      <xsl:otherwise>
        <and>
          <xsl:if test="$maxSnippets">
            <xsl:attribute name="maxSnippets" select="$maxSnippets"/>
          </xsl:if>
          <xsl:attribute name="field" select="$fieldValue"/>
          <xsl:for-each select="$text/token[@isWord='yes']">
            <term><xsl:value-of select="lower-case(replace(@value, '\?', ''))"/></term>
          </xsl:for-each>
          <xsl:if test="not($sectionType eq '')">
            <sectionType>
              <term><xsl:value-of select="$sectionType"/></term>
            </sectionType>
          </xsl:if>          
        </and>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="field">
    <xsl:param name="fieldValue"/>
    <xsl:choose>
      <xsl:when test="iutei:isMetaField($fieldValue) eq 'true'">
        <xsl:value-of select="$fieldValue"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'text'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="sectionType">
    <xsl:param name="fieldValue"/>
    <xsl:choose>
      <xsl:when test="iutei:isMetaField($fieldValue) eq 'true'">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$fieldValue"/>
      </xsl:otherwise>
    </xsl:choose> 
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Phrase template                                                        -->
<!--                                                                        -->
<!-- A phrase consists simply of several tokens.                            -->
<!-- ====================================================================== -->
  
  <xsl:template match="phrase">
    <phrase>
      <xsl:apply-templates/>
    </phrase>
  </xsl:template>
  
  <!-- Handle multi-field keyword queries -->
  <xsl:template match="and[matches(@field, '^(serverChoice|keywords)$')] |
    or[matches(@field, '^(serverChoice|keywords)$')]"
    mode="freeform">

    <xsl:copy>
      <xsl:attribute name="maxContext" select="100"/>
<!--      <xsl:attribute name="maxSnippets" select="3"/>-->
      <xsl:attribute name="field" select="$fieldList"/>
      
<!--      <xsl:attribute name="fields" select="$fieldList"/>
      <xsl:attribute name="slop" select="10"/>
      <xsl:attribute name="maxTextSnippets" select="'3'"/>
      <xsl:attribute name="maxMetaSnippets" select="'all'"/>
-->
      <xsl:apply-templates mode="freeform"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="addFacetQuery">
  <!-- Process special facet query params -->
  <xsl:if test="//param[matches(@name,'f[0-9]+-.+')]">
    <and>
      <xsl:for-each select="//param[matches(@name,'f[0-9]+-.+')]">
        <and field="{replace(@name,'f[0-9]+-','facet-')}">
          <term><xsl:value-of select="@value"/></term>
        </and>
      </xsl:for-each>
    </and>
  </xsl:if>
  </xsl:template>
  


</xsl:stylesheet>
