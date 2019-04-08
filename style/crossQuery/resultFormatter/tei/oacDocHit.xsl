<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- OAC docHits formatting                                                 -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

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
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:iutei="http://www.dlib.indiana.edu/collections/TEIgeneral/"
  xmlns:session="java:org.cdlib.xtf.xslt.Session">
  <xsl:import href="/opt/etext/common/XTF-latest/style/crossQuery/resultFormatter/common/resultFormatterCommon.xsl"/>
  
  <xsl:param name="text1"/>
  <xsl:param name="text2"/>
  <xsl:param name="text3"/>
  <xsl:param name="field1"/>
  <xsl:param name="field2"/>
  <xsl:param name="field3"/>
  <xsl:param name="fromYear"/>
  <xsl:param name="toYear"/>
  <xsl:param name="op1"/>
  <xsl:param name="op2"/>
  <xsl:param name="brand"/>
  <xsl:param name="freeformQuery"/>
  
  
  <xsl:param name="browseText"/>
  

  <xsl:variable name="dev">
    <xsl:choose>
      <xsl:when test="contains($root.path,'http://content.cdlib.org/')">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- ====================================================================== -->
  <!-- Normal Document Hit Template                                           -->
  <!-- ====================================================================== -->
  <xsl:template match="docHit">
    <xsl:variable name="path" select="@path"/>
   <!-- <tr class="search-row">
      <td class="search-results-number">HERE
        <xsl:call-template name="docHit-number"/>
      </td>
      <td class="search-results-text">
        <div class="search-results-text-inner"> -->
<!--    <xsl:call-template name="docHit-number"/>-->      
    <xsl:call-template name="docHit-div"/>


        <!-- </div>
    	</td>
    </tr> -->
  </xsl:template>
  
  <xsl:template name="docHit-number">
    <xsl:choose>
      <xsl:when
        test="$sort != 'title' and $sort != 'publisher' and $sort != 'date'">
        <xsl:value-of select="@rank"/>. </xsl:when>
      <xsl:otherwise>&#160;</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="docHit-div">
    <xsl:variable name="path" select="@path"/>
    <xsl:variable name="identifier" select="meta/identifier[1]"/>
    <xsl:variable name="quotedID" select="concat('&quot;', $identifier, '&quot;')"/>
    <xsl:variable name="indexId" select="replace($identifier, '.*/', '')"/>
    
    <xsl:variable name="resultClass">
    	<xsl:choose>
        	<xsl:when test="meta/contentType = 'introduction' or meta/contentType = 'biography'">
		        resultItemPAGE
		    </xsl:when>
		   	<xsl:otherwise>
		   		resultItemBOOK
		   	</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
    
    <dl id="main_{@rank}" class="{$resultClass}">
		<dt class="auraltext">Result type:</dt>
        <xsl:choose>
        	<xsl:when test="meta/contentType = 'introduction'">
		        <dd class="resultType">Introduction to Text</dd>
		    </xsl:when>
		    <xsl:when test="meta/contentType = 'biography'">
		    	<dd class="resultType">Author Biography</dd>
		   	</xsl:when>
		   	<xsl:otherwise>
		   	<!--	<dd class="resultType">Book</dd> -->
		   	</xsl:otherwise>
		</xsl:choose>        
        <dt>Title:</dt>
        
        <dd>
         <h3>
          <a>
          <xsl:attribute name="href">
            <xsl:call-template name="ead.dynaxml.url">
              <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
            <!--<xsl:if test="snippet">
	      	  <xsl:text>#1</xsl:text>
	      	</xsl:if>-->
          </xsl:attribute>
          <xsl:value-of select="normalize-space(meta/title[1])"/>
          </a>
         </h3>
        </dd>
        
<!--        <div class="metaLabel">Author:</div>-->
        <dt>Author:</dt>
      
<!--        <div class="metaValue">-->
        <dd>
          <xsl:if test="meta/creator and meta/creator != ''">
            <xsl:value-of select="normalize-space(replace(meta/creator[1], '-', '&#150;'))"/>
            <xsl:if test="meta/creatorPseudonym">
               [<xsl:value-of select="normalize-space(meta/creatorPseudonym[1])"/>]
            </xsl:if>
            <xsl:if test="not(ends-with(meta/creator[1],'.'))"></xsl:if>
          </xsl:if>
        </dd>
        
        <dt>Publication Year:</dt>
        
        <dd>
          <xsl:choose>
            <xsl:when test="meta/dateDisplay and meta/dateDisplay != ''">
              <xsl:value-of select="meta/dateDisplay"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="meta/date and meta/date != ''">
                <xsl:value-of select="meta/date"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </dd>
        

        
      <dt>Source:</dt>
      <dd>
        <xsl:if test="meta/pubPlace and meta/pubPlace != ''">
          <xsl:variable name="metaPubPlace" select="meta/pubPlace[1]"/>
            <xsl:value-of select="$metaPubPlace"/><xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:if test="meta/publisher and meta/publisher != ''">
          <xsl:variable name="metaPub" select="meta/publisher[1]"/>
            <xsl:value-of select="$metaPub"/>
            <xsl:if test="substring($metaPub,string-length($metaPub)) != ','">
              <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="meta/date and meta/date != ''">
            <xsl:value-of select="meta/date"/><xsl:text>. </xsl:text>
        </xsl:if>
        <xsl:if test="meta/extent and meta/extent != ''">
            <xsl:value-of select="meta/extent"/>  
            <xsl:if test="substring(meta/extent,string-length(meta/extent)) != '.'">
              <xsl:text>. </xsl:text>
            </xsl:if>
        </xsl:if>
      </dd>
      
      <xsl:call-template name="genre"/>
      
<!--      <dt>Genre:</dt>
      
      <dd>
        <xsl:choose>
          <xsl:when test="meta/genre and meta/genre != ''">
            <xsl:value-of select="meta/genre"/>
          </xsl:when>
        </xsl:choose>
      </dd>
      
      <dt>Subjects:</dt>
      
      <dd>
        <xsl:choose>
          <xsl:when test="meta/subject and meta/subject != ''">
            <xsl:value-of select="meta/subject"/>
          </xsl:when>
        </xsl:choose>
      </dd>
-->      
<!--        <span class="metaLabel">&#160;</span>               -->
<!--      var main = YAHOO.util.Dom.get('main_<xsl:value-of select="@rank"/>');-->
      <xsl:if test="session:isEnabled()">
        <xsl:choose>
          <xsl:when test="$smode = 'showBag'">
          <xsl:variable name="queryURL" select="session:getData('queryURL')"/>
           <dd id="remove_{@rank}">
            <script type="text/javascript">
                              remove_<xsl:value-of select="@rank"/>_f = function() {
                                 var span = YAHOO.util.Dom.get('remove_<xsl:value-of select="@rank"/>');
                                 span.innerHTML = "Removing from My Selections...";
                                 YAHOO.util.Connect.asyncRequest('GET', 
                                    '<xsl:value-of select="concat($xtfURL, $crossqueryPath, '?smode=removeFromBag;identifier=', $identifier)"/>',
                                    {  success: function(o) { 
                                          var main = YAHOO.util.Dom.get('main_<xsl:value-of select="@rank"/>');
                                          main.parentNode.removeChild(main);
                                          --(YAHOO.util.Dom.get('bagCount').innerHTML);
                                          if (YAHOO.util.Dom.get('bagCount').innerHTML == '0') {
                                          	YAHOO.util.Dom.get('results').innerHTML = 'You have removed all of your selected items.';
                                          	YAHOO.util.Dom.setStyle('emailLink', 'display', 'none');
                                          	YAHOO.util.Dom.setStyle('searchBacktrack', 'float', 'left');
                                          	YAHOO.util.Dom.setStyle('searchBacktrack', 'text-align', 'left');
                                            YAHOO.util.Dom.setStyle('mysel_pagetop', 'display', 'none');
                                            YAHOO.util.Dom.setStyle('mysel_pagebottom', 'display', 'none');
                                          }
                                       },
                                       failure: function(o) { span.innerHTML = 'Failed to delete!'; }
                                    }, null);
                              };
                           </script>
            
              <a href="javascript:remove_{@rank}_f()">[Remove<span class="auraltext"> "<xsl:value-of select="normalize-space(meta/title[1])"/>"</span> from My Selections]</a>
            </dd>
          </xsl:when>
          <xsl:when test="session:noCookie()">
            <span><a href="javascript:alert('To use the bag, you must enable cookies in your web browser.')">Requires cookie*</a></span>                                 
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="session:getData('bag')/bag/savedDoc[@id=$indexId]">
                <dd class="addToMySelection italic">Added to My Selections</dd>
              </xsl:when>
              <xsl:otherwise>
                <dd id="add_{@rank}" class="addToMySelection">
                <script type="text/javascript">
                                    add_<xsl:value-of select="@rank"/>_f = function() {
                                       var span = YAHOO.util.Dom.get('add_<xsl:value-of select="@rank"/>');
                                       span.innerHTML = "Adding...";
                                       YAHOO.util.Connect.asyncRequest('GET', 
                                          '<xsl:value-of select="concat($xtfURL, $crossqueryPath, '?smode=addToBag;identifier=', $identifier)"/>',
                                          {  success: function(o) { 
                                                span.innerHTML = o.responseText;
                                                ++(YAHOO.util.Dom.get('bagCount').innerHTML);
                                             },
                                             failure: function(o) { span.innerHTML = 'Failed to add!'; }
                                          }, null);
                                    };
                                 </script> 
                  <a href="javascript:add_{@rank}_f()">[Add<span class="auraltext"> "<xsl:value-of select="normalize-space(meta/title[1])"/>"</span> to My Selections]</a>
                </dd>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="session:setData('queryURL', concat($xtfURL, $crossqueryPath, '?', $queryString))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      
      
      
      
      
      

        <!-- <xsl:choose>
        	<xsl:when test="meta/collection and meta/collection != ''">
        		<xsl:value-of select="normalize-space(iutei:getRepositoryName(meta/collection))"/>
        		<xsl:if test="not(ends-with(iutei:getRepositoryName(meta/collection),'.'))">.</xsl:if>&#160;
        	</xsl:when>
	        <xsl:when test="meta/repository and meta/repository != ''">
	        	<xsl:value-of select="normalize-space(meta/repository)"/>
	        	<xsl:if test="not(ends-with(meta/repository,'.'))">.</xsl:if>&#160;
	        </xsl:when>
	        <xsl:otherwise/>
	    </xsl:choose> -->
	    
	    <xsl:if test="meta/callnum and meta/callnum != ''">
	    	<xsl:value-of select="normalize-space(meta/callnum)"/>
	    	<xsl:if test="not(ends-with(meta/callnum,'.'))">.</xsl:if>
	    </xsl:if>
    
    <xsl:if test="meta/abstract and meta/abstract != ''">
    <div class="indented">
    	<strong>Abstract:</strong>&#160;<xsl:apply-templates select="meta/abstract"/>
    </div>
    </xsl:if>
    
    
    <!-- <xsl:if test="snippet and $field1 = 'text'"> -->
    <xsl:if test="snippet">
    <dt class="resultSnippets">Search terms in context (<xsl:value-of select="@totalHits"/>):</dt>
    <dd class="resultSnippets">
      	<xsl:apply-templates select="snippet"/>
    </dd>
    </xsl:if>

</dl>
    
    
  </xsl:template>
  
  <xsl:template name="genre">
    <xsl:if test="meta/genre">
      <xsl:element name="dt">Genre:</xsl:element>
      <xsl:for-each select="meta/genre">
        <xsl:element name="dd"><xsl:value-of select="."/></xsl:element>
      </xsl:for-each>
    </xsl:if>
    
    <xsl:if test="meta/subject">
      <xsl:element name="dt">Subject:</xsl:element>
      <xsl:for-each select="meta/subject">
        <xsl:element name="dd"><xsl:value-of select="."/></xsl:element>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
  
  
  <!-- ====================================================================== -->
  <!-- Compact Document Hit Template                                           -->
  <!-- ====================================================================== -->
  <xsl:template match="docHit" mode="compact">
    <xsl:variable name="path" select="@path"/>
    <tr>
      <td align="left" width="5%">
        <xsl:if
          test="$sort != 'title' and $sort != 'publisher' and $sort != 'date'">
          <xsl:value-of select="@rank"/>
          <xsl:text>.</xsl:text>
        </xsl:if>
      </td>
      <td align="left" width="45%">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="ead.dynaxml.url">
              <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="meta/title[1]"/>
        </a>
      </td>
      <td align="left" width="20%">
        <xsl:apply-templates select="meta/publisher[1]"/>
      </td>
      <td align="left" width="20%">
        <xsl:apply-templates select="meta/subject[1]"/>
      </td>
      <td align="center" width="5%">
        <xsl:apply-templates select="meta/date[1]"/>
      </td>
      <td align="right" width="5%">
        <xsl:value-of select="@totalHits"/>
      </td>
    </tr>
    <tr>
      <td colspan="7">
        <hr/>
      </td>
    </tr>
  </xsl:template>
  <!-- ====================================================================== -->
  <!-- Grid Document Hit Template                                           -->
  <!-- ====================================================================== -->
  <xsl:template match="docHit" mode="grid">
    <xsl:variable name="path" select="@path"/>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="ead.dynaxml.url">
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
      </xsl:attribute>
    </a>
  </xsl:template>
  <!-- ====================================================================== -->
  <!-- Snippet Template                                                       -->
  <!-- ====================================================================== -->
  <xsl:template match="snippet[parent::docHit]">
    <xsl:text>...</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>...</xsl:text>
    <br/>
  </xsl:template>
  <!-- ====================================================================== -->
  <!-- Hit Template                                                           -->
  <!-- ====================================================================== -->
  <xsl:template match="hit">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- ====================================================================== -->
  <!-- Term Template                                                          -->
  <!-- ====================================================================== -->
  <xsl:template match="term">
    <xsl:variable name="path" select="ancestor::docHit/@path"/>
    <xsl:variable name="hit.rank">
      <xsl:value-of select="ancestor::snippet/@rank"/>
    </xsl:variable>
    <xsl:variable name="snippet.link">
      <xsl:call-template name="ead.dynaxml.url">
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
      <xsl:value-of select="concat('#', $hit.rank)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="ancestor::snippet[parent::docHit]">
        <a class="search-item" href="{$snippet.link}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="search-term">
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Building URL to dynaXML                                                -->
  <!-- ====================================================================== -->
  <xsl:template name="ead.dynaxml.url">
    
    <xsl:param name="path"/>
    
    <xsl:variable name="docId">
      <xsl:choose>
        <xsl:when test="matches($path,'^[A-Za-z0-9]+:')">
          <xsl:value-of select="replace($path, '^[A-Za-z0-9]+:', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="query">
      <xsl:choose>
        <xsl:when test="$keyword != ''">
          <xsl:value-of select="$keyword"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:value-of select="concat($dynaxmlPath, '?docId=', $docId)"/>
    <xsl:choose>
      <xsl:when test="$browseText = ''">
        <xsl:if test="$brand"><xsl:value-of select="concat('&amp;brand=', $brand)"/></xsl:if>
        <xsl:if test="$text1"><xsl:value-of select="concat('&amp;text1=', $text1)"/></xsl:if>
        <xsl:if test="$text2"><xsl:value-of select="concat('&amp;text2=', $text2)"/></xsl:if>
        <xsl:if test="$text3"><xsl:value-of select="concat('&amp;text3=', $text3)"/></xsl:if>
        <xsl:if test="$op1"><xsl:value-of select="concat('&amp;op1=', $op1)"/></xsl:if>
        <xsl:if test="$op2"><xsl:value-of select="concat('&amp;op2=', $op2)"/></xsl:if>
        <xsl:if test="$field1"><xsl:value-of select="concat('&amp;field1=', $field1)"/></xsl:if>
        <xsl:if test="$field2"><xsl:value-of select="concat('&amp;field2=', $field2)"/></xsl:if>
        <xsl:if test="$field3"><xsl:value-of select="concat('&amp;field3=', $field3)"/></xsl:if>
        <xsl:if test="$freeformQuery"><xsl:value-of select="concat('&amp;freeformQuery=', $freeformQuery)"/></xsl:if>
        <xsl:if test="$startDoc"><xsl:value-of select="concat('&amp;startDoc=', $startDoc)"/></xsl:if>
      </xsl:when>
    </xsl:choose>

  </xsl:template>  
</xsl:stylesheet>


