<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- dynaXML Stylesheet                                                     -->
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

<xsl:stylesheet version="2.0"
				xmlns="http://www.w3.org/1999/xhtml"
                xmlns:none="http://www.dlib.indiana.edu"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xtf="http://cdlib.org/xtf"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:session="java:org.cdlib.xtf.xslt.Session"
                exclude-result-prefixes="xtf">

<!-- ====================================================================== -->
<!-- Import reference implementation stylesheet                             -->
<!-- ====================================================================== -->


<xsl:import href="../tei/docFormatter.xsl"/>

<!-- ======================================================================
	 indent="no" is required:
	 indent set to "no" on xsl:output so text strings that 
	 receive internal rendering (ex. L<hi rend="sc">EWIS</hi>) do not end up
	 rendering in the browser with extra space before the internal tag
====================================================================== -->  
<xsl:output method="xhtml"
            indent="no"
            encoding="utf-8"
            media-type="text/html"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
  
<!-- ====================================================================== -->
<!-- Strip Space                                                            -->
<!-- ====================================================================== -->

<xsl:strip-space elements="*"/>

<!-- ====================================================================== -->
<!-- Include stylesheets to override reference implementation               -->
<!-- ====================================================================== -->

<!--<xsl:include href="./autotoc-TEIgeneral.xsl"/> -->
<xsl:include href="./component-TEIgeneral.xsl"/>

<xsl:param name="brand" select="'TEIgeneral'"/>

<xsl:param name="pageImageBrand" select="'TEIgeneral'"/>
<xsl:param name="pageImageId-length" select="8"/>
<xsl:param name="pageImageId-page" select="9"/>
<xsl:param name="brandName" select="'TEIgeneral'"/>
<!-- formatQualifier = blank '' or 'large' - decides what page image size to serve from derivatives; PURL can either contain 'large' for the LARGE size or nothing for the SCREEN size -->
<!-- <xsl:param name="formatQualifier" select="'large'"/> -->
<xsl:param name="formatQualifier" select="''"/>

<xsl:param name="contentType">
 	<xsl:choose>
 		<xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title/@type">
		 	<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title/@type"/>
		</xsl:when>
		<xsl:otherwise>
			book
		</xsl:otherwise>
 	</xsl:choose>
 </xsl:param>
  

<!-- ====================================================================== -->
<!-- Define templates to override reference implementation                  -->
<!-- ====================================================================== -->
  
  <xsl:template name="generateDocInfo">
      <xsl:param name="smode"/>
      <xsl:variable name="myselection_identifier">
      		<xsl:value-of select="$idno"/>
      </xsl:variable>
      <xsl:variable name="myselection_identifier_string">
	    	<xsl:text>identifier=</xsl:text><xsl:value-of select="$myselection_identifier"/>
      </xsl:variable>
      
    <!-- Title, Author -->
    <strong class="chunkTitle">
    	<xsl:choose>
    		<!-- Critical Introduction Titles -->
    		<xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title">
    			<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title[1]"/>.
    		</xsl:when>
    		<!-- New/Ongoing Text Titles -->
      		<xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
      			<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
      				<xsl:if test="@type='marc245a'">
      					<xsl:value-of select="."/>
      				</xsl:if>
      				<xsl:if test="@type='marc245b'">
      					<xsl:text>&#160;</xsl:text><xsl:value-of select="."/>
      				</xsl:if>
      			</xsl:for-each>.
      		</xsl:when>
      		<!-- Old/Original Text Titles -->
      		<xsl:otherwise>
      			<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:title[1]" />.
      		</xsl:otherwise>	
      	</xsl:choose>
    <!-- Author -->
    	<xsl:choose>
    		<!-- Critical Introduction Author -->
    		<xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:author">
    			<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:author">
    				<xsl:value-of select="replace(.[not(name/@type)],'-','&#150;')"/>
    				<xsl:if test="name/@type='pseudonym'">[<xsl:value-of select="name[@type='pseudonym']"/>]</xsl:if><xsl:text>. </xsl:text>
    			</xsl:for-each>
    		</xsl:when>
    		<!-- New/Ongoing Text Author -->
    		<xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author">
    			<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author">
    				<xsl:value-of select="replace(.[not(name/@type)],'-','&#150;')"/>
    				<xsl:if test="name/@type='pseudonym'">[<xsl:value-of select="name[@type='pseudonym']"/>]</xsl:if><xsl:text>. </xsl:text>
    			</xsl:for-each>
    		</xsl:when>
    		<!-- Old/Original Text Author -->
    		<xsl:otherwise>
    			<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:author">
    				<xsl:value-of select="replace(.[not(name/@type)],'-','&#150;')"/>
    				<xsl:if test="name/@type='pseudonym'">[<xsl:value-of select="name[@type='pseudonym']"/>]</xsl:if><xsl:text>. </xsl:text>
    			</xsl:for-each>
    		</xsl:otherwise>
    	</xsl:choose>
    </strong>
    <xsl:if test="$doc.view!='print'">
    <div class="print_myselections">
    	<xsl:if test="session:isEnabled() and $contentType != 'chronology'">
        <xsl:choose>
          <xsl:when test="session:noCookie()">
            <span><a href="javascript:alert('To use the bag, you must enable cookies in your web browser.')">Requires cookie*</a></span>                                 
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="session:getData('bag')/bag/savedDoc[@id=$myselection_identifier]">
                <span class="addToMySelection italic">Added to My Selections</span>
              </xsl:when>
              <xsl:otherwise> 
                <span id="add" class="addToMySelection">
                <script type="text/javascript">
                                    add_f = function() {
                                       var span = YAHOO.util.Dom.get('add');
                                       span.innerHTML = "Adding...";
                                       YAHOO.util.Connect.asyncRequest('GET', 
                                          '<xsl:value-of select="concat($xtfURL, $crossqueryPath, '?smode=addToBag;', $myselection_identifier_string)"/>',
                                          {  success: function(o) { 
                                                span.innerHTML = o.responseText;
                                              //  ++(YAHOO.util.Dom.get('bagCount').innerHTML);
                                             },
                                             failure: function(o) { span.innerHTML = 'Failed to add!'; }
                                          }, null);
                                    };
                                 </script> 
                  <a href="javascript:add_f()">[Add<span class="auraltext"> "<xsl:value-of select="$doc.title"/>"</span> to My Selections]</a>
                </span>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      
    	<a href="javascript:window.print()" class="print">[Print]</a>
    </div>
    </xsl:if>
  </xsl:template>
  
  <!--  Here's a sample test we can do for existence and punctuation, probably will need this -->
  <!--  <xsl:if test="meta/creator and meta/creator != ''">
    <xsl:value-of select="normalize-space(meta/creator[1])"/>
    <xsl:if test="not(ends-with(meta/creator[1],'.'))"></xsl:if>
    </xsl:if>-->
  
  <xsl:template match="/tei:TEI/tei:teiHeader/tei:fileDesc">
    <dl class="resultItem">
      <xsl:element name="dt">Title:</xsl:element>
      <xsl:element name="dd">
      	<xsl:choose>
      		<!-- Critical Introductions -->
    		<xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title">
    			<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title[1]"/>.
    		</xsl:when>
      		<!-- New/Ongoing Texts -->
      		<xsl:when test="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
      			<xsl:for-each select="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
      				<xsl:if test="@type='marc245a'">
      					<xsl:value-of select="."/>
      				</xsl:if>
      				<xsl:if test="@type='marc245b'">
      					<xsl:text>&#160;</xsl:text><xsl:value-of select="."/>
      				</xsl:if>
      			</xsl:for-each>.	
      		</xsl:when>
      		<!-- Old/Original Texts -->
      		<xsl:otherwise>
      			<xsl:value-of select="tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:title[1]" />.
      		</xsl:otherwise>	
      	</xsl:choose>
      </xsl:element>
      <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title/@type!='chronology'">
      	<xsl:element name="dt">Author:</xsl:element>
      	<xsl:element name="dd">
      		<xsl:choose>
    			<!-- Critical Introduction Author -->
    			<xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:author">
    				<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:author">
    					<xsl:value-of select="replace(.[not(name/@type)],'-','&#150;')"/>
    					<xsl:if test="name/@type='pseudonym'">[<xsl:value-of select="name[@type='pseudonym']"/>]</xsl:if><xsl:text>. </xsl:text>
    				</xsl:for-each>
    			</xsl:when>
	    		<!-- New/Ongoing Text Author -->
    			<xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author">
    				<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author">
    					<xsl:value-of select="replace(.[not(name/@type)],'-','&#150;')"/>
    					<xsl:if test="name/@type='pseudonym'">[<xsl:value-of select="name[@type='pseudonym']"/>]</xsl:if><xsl:text>. </xsl:text>
	    			</xsl:for-each>
    			</xsl:when>
    			<!-- Old/Original Text Author -->
    			<xsl:otherwise>
    				<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:author">
    					<xsl:value-of select="replace(.[not(name/@type)],'-','&#150;')"/>
	    				<xsl:if test="name/@type='pseudonym'">[<xsl:value-of select="name[@type='pseudonym']"/>]</xsl:if><xsl:text>. </xsl:text>
    				</xsl:for-each>
    			</xsl:otherwise>
    		</xsl:choose>
      	</xsl:element>
      </xsl:if>
      <xsl:if test="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title/@type='marc245c'">
      	<xsl:element name="dt">Contributor:</xsl:element>
      	<xsl:element name="dd">
      		<xsl:value-of select="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type='marc245c']"/>.
      	</xsl:element>
      </xsl:if>
      <xsl:element name="dt">Publication Year:</xsl:element>
      <xsl:element name="dd">
      	<xsl:choose>
      		<xsl:when test="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date">
      			<xsl:value-of select="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date[1]"/>
      		</xsl:when>
      		<xsl:when test="tei:sourceDesc/tei:bibl/tei:date">
      			<xsl:value-of select="tei:sourceDesc/tei:bibl/tei:date[1]"/>
      		</xsl:when>
      		<xsl:otherwise>
		      	<xsl:value-of select="tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:date"/>
		    </xsl:otherwise>
      	</xsl:choose>
      </xsl:element>
      <xsl:element name="dt">Source:</xsl:element>
      <xsl:choose>
      	<xsl:when test="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace">
      		<xsl:element name="dd">
       			 <xsl:value-of select="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace"/><xsl:text>: </xsl:text>
        		 <xsl:value-of select="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:publisher"/><xsl:text>, </xsl:text>
        		 <xsl:value-of select="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date"/><xsl:text>. </xsl:text>
        		 <xsl:value-of select="tei:sourceDesc/tei:biblStruct/tei:monogr/tei:extent"/>
      		</xsl:element>
      	</xsl:when>
      	<xsl:when test="tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:pubPlace">
      		<xsl:element name="dd">
    	    	<xsl:value-of select="tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:pubPlace"/><xsl:text>: </xsl:text>
        		<xsl:value-of select="tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:publisher"/><xsl:text>, </xsl:text>
	        	<xsl:value-of select="tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:date"/><xsl:text>. </xsl:text>
    	    	<xsl:value-of select="tei:sourceDesc/tei:biblFull/tei:extent"/>
      	  </xsl:element>
      	</xsl:when>
      	<xsl:otherwise>
      	  	<xsl:element name="dd">
       		 	<xsl:value-of select="tei:publicationStmt/tei:pubPlace"/><xsl:text>: </xsl:text>
        	 	<xsl:value-of select="tei:publicationStmt/tei:publisher"/><xsl:text>, </xsl:text>
        	 	<xsl:value-of select="tei:sourceDesc/tei:bibl/tei:date[1]"/><xsl:text>. </xsl:text>
      	  	</xsl:element>
      	</xsl:otherwise>
      </xsl:choose>
      
      <xsl:call-template name="genre"/>
      
      <xsl:element name="dt">Bookmark:</xsl:element>
	  <xsl:element name="dd">
		<a href="http://purl.dlib.indiana.edu/iudl/{$pageImageBrand}/{$idno}">http://purl.dlib.indiana.edu/iudl/<xsl:value-of select="$pageImageBrand"/>/<xsl:value-of select="$idno"/></a>
	  </xsl:element>
<!--      <xsl:if test="tei:publicationStmt/tei:availability/@status eq 'free'">
        <dt>Rights:</dt>
        <xsl:for-each select="tei:publicationStmt/tei:availability">
          <xsl:if test="@status eq 'free'">
            <dd><xsl:value-of select="."/></dd>
          </xsl:if>
        </xsl:for-each>
      </xsl:if> -->
    </dl>
  </xsl:template>  
  
  <xsl:template name="topPageLink">
		<xsl:if test="$chunk.id != '0' and $doc.view != 'pagedImage' and $this.page.number != ''">
            <div class="pbRight">
            	page: <xsl:value-of select="$this.page.number"/>
  				<xsl:if test="$doc.view!='print' and $hasPageImage = 'yes'">
  					<span class="pageImageLink"><a href="javascript:showPageImage('{$pageImageBrand}', '{$this.image.id}', '{$formatQualifier}');" title="[View Page Image]" class="run-head" aria-controls="showPageImage-{$this.image.id}" id="view-{$this.image.id}">[View Page: <xsl:value-of select="$this.page.number"/>]</a></span>
  					<span id="showPageImage-{$this.image.id}" class="showPageImage" style="display:none;position:absolute;" aria-expanded="false">
        				<a href="{$doc.path}&amp;brand={$brand}&amp;doc.view=pagedImage&amp;image.id={$this.image.id}" class="left">Switch to Image Mode</a>
     					<a href="javascript:closePageImage('{$this.image.id}');" aria-controls="showPageImage-{$this.image.id}">CLOSE Page <xsl:value-of select="$this.page.number"/></a>
	       				<img src="" id="overlay-{$this.image.id}" class="overlay" style="display:none;" alt="Page {substring($this.image.id, $pageImageId-page)}"/>
    				</span>
    			</xsl:if>
 			</div>
 		</xsl:if>
 	</xsl:template>
 	
 	<xsl:template name="genre">
 	  <xsl:if test="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/@scheme='#mla'">
      	<xsl:element name="dt">Genre:</xsl:element>
    	  	<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords[@scheme='#mla']/tei:list/tei:item/tei:term">
      			<xsl:element name="dd"><xsl:value-of select="."/></xsl:element>
      		</xsl:for-each>
      </xsl:if>
      
      <xsl:if test="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/@scheme='#lcsh'">
      	<xsl:element name="dt">Subject:</xsl:element>
      		<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords[@scheme='#lcsh']/tei:list/tei:item">
	      		<xsl:element name="dd"><xsl:value-of select="."/></xsl:element>
	      	</xsl:for-each>
      </xsl:if>
 	</xsl:template>
 	
 	<xsl:template name="relatedMaterials">
 		<xsl:choose>
 			<xsl:when test="$contentType = 'biography' or $contentType = 'introduction'">
 			  <div id="relatedMaterials" class="toc">
        		<h2>Related Materials</h2>
        		<hr/>
 				<ul>
 					<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@type='relatedItem']/tei:listBibl/tei:bibl">
 						<li>
 							<a href="http://webapp-devel.dlib.indiana.edu/TEIgeneral/view?docId={substring-after(tei:title/@ref, 'http://purl.dlib.indiana.edu/iudl/TEIgeneral/')}.xml&amp;brand=general"><xsl:value-of select="tei:title"/></a>
 							<!-- PURL for title -->
 							<!-- <a href="{tei:title/@ref}"><xsl:value-of select="tei:title"/></a> -->
 						</li>
 					</xsl:for-each>
 				</ul>
 			  </div>
 			</xsl:when>
 			<xsl:when test="$contentType = 'chronology'">
 				<div id="relatedMaterials" class="toc">
        		<h2>Related Materials</h2>
        		<hr/>
 				<ul>
 					<li>
 						<a href="/TEIgeneral/timeline.do">Interactive Timeline</a>
 					</li>
 				</ul>
 			  </div>
 			</xsl:when>
 			<xsl:otherwise>
 			  <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note/@subtype='bio' or /tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note/@subtype='critical_intro'">
 			  	<div id="relatedMaterials" class="toc">
        			<h2>Related Materials</h2>
        			<hr/>
 					<ul>
 						<xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note/@subtype='bio'">
 							<li><a href="http://webapp-devel.dlib.indiana.edu/TEIgeneral/view?docId={substring-after(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@subtype='bio']/tei:bibl/tei:title/@ref, 'http://purl.dlib.indiana.edu/iudl/TEIgeneral/')}&amp;brand=general">Author Biography</a></li>
 						</xsl:if>
 						<xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note/@subtype='critical_intro'">
 							<li><a href="http://webapp-devel.dlib.indiana.edu/TEIgeneral/view?docId={substring-after(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@subtype='critical_intro']/tei:bibl/tei:title/@ref, 'http://purl.dlib.indiana.edu/iudl/TEIgeneral/')}&amp;brand=general">Introduction to Text</a></li>
 						</xsl:if>
 					</ul>
 				</div>
 			  </xsl:if>
 			</xsl:otherwise>
 		</xsl:choose>
 	</xsl:template>

</xsl:stylesheet>
