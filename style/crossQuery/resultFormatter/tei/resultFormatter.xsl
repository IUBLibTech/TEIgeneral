<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
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
  xmlns:session="java:org.cdlib.xtf.xslt.Session"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:editURL="http://cdlib.org/xtf/editURL"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:iutei="http://www.dlib.indiana.edu/collections/TEIgeneral/">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="/opt/etext/common/XTF-latest/style/crossQuery/resultFormatter/common/resultFormatterCommon.xsl"/>
  <xsl:import href="oacDocHit.xsl"/>
  <xsl:import href="../../../iutei.xsl"/>
  <xsl:param name="brand" select="'general'" />
  <xsl:param name="repository" select="''" />
  <xsl:variable name="brand.file">
    <xsl:copy-of select="document(concat('../../../../brand/',$brand,'.xml'))"/>
  </xsl:variable>
  <xsl:param name="brand.brandName" select="$brand.file//brandName"/>
  <xsl:param name="brand.links" select="$brand.file//links/*"/>
  <xsl:param name="brand.headerIU" select="$brand.file//headerIU/*"/>
  <xsl:param name="brand.header" select="$brand.file//header/*"/>
  <xsl:param name="brand.footer" select="$brand.file//footer/*"/>
  <xsl:param name="brand.footerIU" select="$brand.file//footerIU/*"/>
  <xsl:param name="icon.path" select="concat($xtfURL, 'icons/default/')"/>
  <xsl:param name="docHits" select="/crossQueryResult/docHit"/>
  <xsl:param name="email"/>
  <xsl:param name="purl"/>
  <xsl:param name="freeformQuery">
    <xsl:value-of select="//param[@name='freeformQuery']/@value"></xsl:value-of>
  </xsl:param>
  
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" media-type="text/html" 
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="contains($smode, 'resolve')">
        <xsl:call-template name="resolve"/>
      </xsl:when>
      <xsl:when test="contains($smode, '-modify')">
        <xsl:apply-templates select="crossQueryResult" mode="results-form"/>
      </xsl:when>      
      <xsl:when test="$text1 or $text2 or $text3 or $fromYear">
        <xsl:apply-templates select="crossQueryResult" mode="results"/>
      </xsl:when>
      <xsl:when test="not($text1 or $text2 or $text3) and not($repository eq '')">
        <xsl:apply-templates select="crossQueryResult" mode="repository"/>
      </xsl:when>
      <xsl:when test="$smode = 'showBag'">
        <xsl:apply-templates select="crossQueryResult" mode="results"/>
      </xsl:when>
      <xsl:when test="$smode = 'addToBag'">
        <span class="italic">Added to My Selections</span>
      </xsl:when>
      <xsl:when test="$smode = 'removeFromBag'">
        <!-- no output needed -->
      </xsl:when>
      <xsl:when test="$smode='getAddress'">
        <xsl:call-template name="getAddress"/>
      </xsl:when>
      <xsl:when test="$smode='emailFolder'">
        <xsl:apply-templates select="crossQueryResult" mode="emailFolder"/>
      </xsl:when>
      <xsl:when test="//param[@name='freeformQuery']">
        <xsl:apply-templates select="crossQueryResult" mode="results"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Results Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template name="resolve">
    
    <xsl:variable name="itemId">
      <!-- incoming purl will have the full item id, like iudl/collectionid/VABXXXXX, so take the last part -->
      <xsl:value-of select="tokenize($purl, '/')[last()]"/>
    </xsl:variable>
    
<!--    Extract the current identifier from search result metadata (should be one result but just take the first to be safe)-->
    <xsl:variable name="currentID">
      <xsl:value-of select="//docHit[1]/meta/collection"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="//docHit[1]/meta/identifier"/>
    </xsl:variable>
    
<!--    Build a full PURL in case you want to do a full roundtrip redirect -->
    <xsl:variable name="currentPURL">
      <xsl:text>http://purl.dlib.indiana.edu/iudl/</xsl:text>
      <xsl:value-of select="$currentID"></xsl:value-of>
    </xsl:variable>
    
    <!--The $filePath and $realFileName variables are here to show how you could match and resolve disparity
    between actual filenames and identifiers by looking directly in the library directory-->     
    <xsl:variable name="filePath">
      <!--Target file path needs to look something like ../../../../data/?select=*VAB7193*.xml-->
      <xsl:text>../../../../data/?select=*</xsl:text>
      <!-- Get the base name of the file to look for by splitting on dashes and looking for the base VA? part-->
      <xsl:for-each select="tokenize($itemId,'-')">
        <xsl:if test="matches(.,'^V[A-Z]{2}[0-9]{4,}')">
          <xsl:value-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>*.xml</xsl:text>
    </xsl:variable>
    <xsl:variable name="realFileName">
       <!--Use collection() to get a dir listing using filePath variable. 
       There SHOULD only be one match here, but literally take the first one just in case,
       even though we have no way of knowing if it's really the one we are after. i.e., someone
       could have incorrectly renamed/copied a file to version it.-->
      <xsl:for-each select="collection($filePath)[1]" > 
        <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
      </xsl:for-each>
    </xsl:variable>
    
<!--    Currently set to redirect to new document ID using $currentID    -->
    <xsl:variable name="redirect">
      <xsl:value-of select="$xtfURL"/>
      <xsl:text>view?docId=</xsl:text><xsl:value-of select="$currentID"/>
      <xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/>
    </xsl:variable>

    <redirect:send url="{$redirect}"
      xmlns:redirect="java:/org.cdlib.xtf.saxonExt.Redirect"
      xsl:extension-element-prefixes="redirect"/>
  
  </xsl:template>


  <xsl:template match="crossQueryResult" mode="results">

    <xsl:variable name="modifyString">
    	<xsl:choose>
    	  <xsl:when test="contains($queryString,'smode=')">
    		<xsl:value-of select="replace($queryString, '(smode=[A-Za-z0-9]*)', '$1-modify')"/>
    	  </xsl:when>
    	  <xsl:otherwise>
    		<xsl:value-of select="$queryString"/><xsl:text>&amp;smode=-modify</xsl:text>
    	  </xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>
    <xsl:variable name="pageTitle">
    	<xsl:choose>
    		<xsl:when test="$browseText != '' and $type = 'creator'">
    			Browse by Author
    		</xsl:when>
    		<xsl:when test="$browseText != '' and $type = 'title'">
    			Browse by Title
    		</xsl:when>
    		<xsl:when test="$browseText != '' and $type = 'daterange'">
    			Browse by Year
    		</xsl:when>
    		<xsl:when test="$smode = 'showBag'">
    			My Selections
    		</xsl:when>
    		<xsl:otherwise>
    			Search Results
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>
    <html lang="en" xml:lang="en">
      
      <head>
      	<meta name="viewport" content="width = 320" />
		<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />
        <title><xsl:value-of select="$brand.brandName"/> - <xsl:value-of select="$pageTitle"/></title>
        <xsl:copy-of select="$brand.links"/>
        <script src="js/yui/yahoo-dom-event.js" type="text/javascript"/> 
        <script src="js/yui/connection-min.js" type="text/javascript"/> 
        

      </head>
      
      <body>
        <xsl:copy-of select="$brand.headerIU"/>
        <div id="site_container">
        <xsl:copy-of select="$brand.header"/>
<!--        <xsl:if test="$smode != 'showBag'">
            <xsl:variable name="bag" select="session:getData('bag')"/>
            <a href="{$xtfURL}{$crossqueryPath}?smode=showBag&amp;brand={$brand}">My Selections</a>
            (<span id="bagCount"><xsl:value-of select="count($bag/bag/savedDoc)"/></span>)
        </xsl:if>
-->        <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>
          <div id="content" class="clearfix">
          <!--<xsl:if test="$smode = 'showBag'">
            
            <a>
              <xsl:attribute name="href">javascript://</xsl:attribute>
              <xsl:attribute name="onclick">
                <xsl:text>javascript:window.open('</xsl:text><xsl:value-of
                  select="$xtfURL"/>search?smode=getAddress&amp;brand={$brand}<xsl:text>','popup','width=500,height=200,resizable=no,scrollbars=no')</xsl:text>
              </xsl:attribute>
              <xsl:text>E-mail My Selections</xsl:text>
            </a>
          </xsl:if>-->  

            <h2 class="searchFor">
              <xsl:choose>
                <xsl:when test="$browseText = '' and $smode != 'showBag'">Search for: </xsl:when>
                <xsl:when test="$smode = 'showBag'">My Selections
                
                </xsl:when>
                <xsl:otherwise>
<!--                  Browse <xsl:value-of select="if ($field1 = 'browse-subject') then 'Subject' else 'Authorr'"/>: <xsl:value-of select="$browseText"/>-->
                  Browse 
                  <xsl:choose>
                    <xsl:when test="$field1 = 'browse-title'">Title</xsl:when>
                    <xsl:when test="$field1 = 'browse-creator'">Author</xsl:when>
                    <xsl:when test="$field1 = 'browse-daterange'">Publication Year</xsl:when>
                    <xsl:when test="$field1 = 'genre'">Genre</xsl:when>
                  </xsl:choose>
                  : <xsl:value-of select="$browseText"/>
                </xsl:otherwise>
              </xsl:choose>
            </h2>
          <xsl:choose>
            <xsl:when test="$browseText = '' and $smode != 'showBag'">
              
              <strong class="searchTerms">
<!--                <xsl:text>Your </xsl:text><xsl:value-of select="if ($browseText != '') then 'Browse' else 'Search'"/><xsl:text> for </xsl:text>-->
                <xsl:apply-templates select="parameters" mode="search"/>
                <xsl:variable name="blah">
                	<xsl:apply-templates select="parameters" mode="search"/>
                </xsl:variable>
                <xsl:if test="$freeformQuery != ''">
                  <xsl:value-of select="$freeformQuery"></xsl:value-of>
                  <a class="top-link" href="{$xtfURL}{$crossqueryPath}?smode=advanced&amp;brand={$brand}"><img src="images/remove.png" alt="Remove '{$freeformQuery}' as Keyword" title="Remove '{$freeformQuery}' as Keyword"/></a>
                  in <em>Keyword</em>
                </xsl:if>

                <xsl:if test="@totalDocs = '0'">
                  <script type="text/javascript">
                    /* <![CDATA[ */
                      Ext.onReady(function() {
                       Ext.Ajax.request({
                       url: 'http://webapp2.dlib.indiana.edu/noresult.do',
                       params: location.search,
                       method: 'GET',
                       success: function(response, opts) {
                       //var obj = Ext.decode(response.responseText);
                       //console.dir(obj);
                       },
                       failure: function(response, opts) {
                       //console.log('server-side failure with status code ' + response.status);
                       }
                       });
                     });
                     /* ]]> */
                  </script>
                </xsl:if>
<!--                TODO - Can turn the following back on if desired if we want links to modify search-->
<!--                <xsl:choose>
                  <xsl:when test="($text1 or $text2 or $text3)">
                    <a class="top-link" href="{$xtfURL}{$crossqueryPath}">
                      <xsl:text>New Search</xsl:text>
                    </a>
                    <a class="top-link" href="{$xtfURL}{$crossqueryPath}?{$modifyString}">
                      <xsl:text>Modify Search</xsl:text>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>&#160;</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
-->              </strong>
              
            </xsl:when>
          </xsl:choose>
          <xsl:text disable-output-escaping='yes'> <![CDATA[<![if !IE]>]]></xsl:text>
          <p id="myselections_total" aria-live="polite">
            <xsl:variable name="bag" select="session:getData('bag')"/>
            <a href="{$xtfURL}{$crossqueryPath}?smode=showBag&amp;brand={$brand}">My Selections</a>
            (<span id="bagCount"><xsl:value-of select="count($bag/bag/savedDoc)"/></span>)
          </p>
          <xsl:text disable-output-escaping='yes'> <![CDATA[<![endif]>]]></xsl:text>
          
          <xsl:text disable-output-escaping='yes'> <![CDATA[<!--[if IE]>]]></xsl:text>
          <p id="myselections_total">
            <xsl:variable name="bag" select="session:getData('bag')"/>
            <a href="{$xtfURL}{$crossqueryPath}?smode=showBag">My Selections</a>
            (<span id="bagCount"><xsl:value-of select="count($bag/bag/savedDoc)"/></span>)
          </p>
          <xsl:text disable-output-escaping='yes'> <![CDATA[<![endif]-->]]></xsl:text>
                    
          <xsl:if test="$smode != 'showBag'">
            <h2 class="searchResults">
              <xsl:text>Results: </xsl:text>
              <xsl:value-of select="@totalDocs"/>
              <xsl:text> item(s)</xsl:text>
            </h2>
          </xsl:if>
          
          

          
<!--          <div class="number-items">
            <xsl:call-template name="page-summary">
                <xsl:with-param name="object-type" select="'items'"/>
            </xsl:call-template>
          </div>
-->          
          <xsl:if test="@totalDocs eq 0">
          <div class="noresults">
            <xsl:choose>
              <xsl:when test="not($smode='showBag')">
            
            
            <h3>Suggestions for revising your search:</h3>
          	<ul>
          		<li class="bullet">Check the spelling of your search terms</li>
				<li class="bullet">Verify your search syntax -- make sure you have closed parenthesis and double quotes</li>
				<li class="bullet">Broaden your search by using fewer search terms</li>
				<li class="bullet">Broaden your search by using wildcard symbol (&#42;) at the end of term(s)</li>
				<li class="bullet">Broaden your search by conducting OR searches</li>
				<li class="bullet">Visit the <a href="help.do">help page</a> for more information on searching</li>
          	</ul>
              </xsl:when>
              <xsl:otherwise>
                <p id="bookbagHelp">You have not selected any items.</p>
                <br/>
                <p>
                  <xsl:choose>
                    <xsl:when test="session:getData('queryURL')">
                      Return to your last <a href="{session:getData('queryURL')}">search results</a> or conduct a 
                    </xsl:when>
                    <xsl:otherwise>
                      Conduct a
                    </xsl:otherwise>
                  </xsl:choose>
                  <a href="search?smode=advanced">new search</a>.  
                In the search results you will see an "Add to My Selections" link. Please select this link for every citation 
                of interest to populate and email your selections.
                </p>
<!--                <xsl:choose>
                    <xsl:when test="session:getData('queryURL')">
                      <p>Return to your <a href="{session:getData('queryURL')}">search results</a> or conduct a </p>
                    </xsl:when>
                    <xsl:otherwise>
                      <p>Conduct a </p>
                    </xsl:otherwise>
                </xsl:choose>
--><!--                  <xsl:if test="session:getData('queryURL')">
                  <xsl:text>queryURL:</xsl:text>
                <xsl:value-of select="session:getData('queryURL')"></xsl:value-of>
                </xsl:if>
--><!--                <p>Click on the 'Add to My Selections' link in one or more items in your <a href="{session:getData('queryURL')}">Search Results</a>.</p>-->
              </xsl:otherwise>
            </xsl:choose>
          </div>
          
          </xsl:if>
        
          <xsl:if test="$smode != 'showBag'">
              <xsl:call-template name="searchBar"/>
          </xsl:if>
<!--          <br class="clear_both"/>-->
		  
            <xsl:if test="$smode != 'showBag' and @totalDocs != '0'">
              <div id="facets">
                <xsl:if test="facet[@field='facet-Publication_Year'][@totalDocs > 0]">
                  <xsl:apply-templates select="facet[@field='facet-Publication_Year']"/>
                </xsl:if>
                <xsl:if test="facet[@field='facet-genre'][@totalDocs > 0]">
                  <xsl:apply-templates select="facet[@field='facet-genre']"/>
                </xsl:if>
                <xsl:if test="facet[@field='facet-Author'][@totalDocs > 0]">
                  <xsl:apply-templates select="facet[@field='facet-Author']"/>
                </xsl:if>
                <xsl:if test="facet[@field='facet-publisher'][@totalDocs > 0]">
                  <xsl:apply-templates select="facet[@field='facet-publisher']"/>
                </xsl:if>
              </div>
            </xsl:if>

          <xsl:if test="docHit">
              <xsl:choose>
                <xsl:when test="$rmode = 'grid'">            
            			<xsl:for-each select="docHit[position() mod 5 = 1]">
            				<xsl:apply-templates select=". | following-sibling::docHit[position() &lt; 5]" mode="grid"/>
            			</xsl:for-each>
                  <xsl:apply-templates select="docHit" mode="grid"/>
                </xsl:when>            
                <xsl:when test="contains($rmode, 'compact')">            
                  <xsl:apply-templates select="docHit" mode="compact"/>
                </xsl:when>            
                <xsl:otherwise> 
                  <xsl:if test="$smode = 'showBag'">
                      <div class="paging">
                      <a>
                        <xsl:attribute name="href">javascript://</xsl:attribute>
                        <xsl:attribute name="onclick">
                          <xsl:text>javascript:window.open('</xsl:text><xsl:value-of
                            select="$xtfURL"/>search?smode=getAddress&amp;brand=<xsl:value-of select="$brand"/><xsl:text>','popup','width=500,height=200,resizable=no,scrollbars=no')</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="id">emailLink</xsl:attribute>
                        <xsl:text>E-mail My Selections</xsl:text>
                      </a>
                        <xsl:choose>
                          <xsl:when test="session:getData('queryURL')">
                            <div id="searchBacktrack">
                            Back to <a href="{session:getData('queryURL')}">search results</a>
                            </div>
                          </xsl:when>
                        </xsl:choose>
                      </div>
                      <xsl:if test="@totalDocs != '0'">
                      	<div id="mysel_pagetop">
            <span class="pagenumber-links">
              <xsl:call-template name="pages"/>
            </span>
            <form id="docsPerPage_form" method="get" action="{$xtfURL}{$crossqueryPath}">
              <fieldset>
                <label for="docsPerPage1">Results per page: </label>
                <xsl:call-template name="results.options">
                  <xsl:with-param name="mode" select="'docsPerPage'"/>
                  <xsl:with-param name="labelId" select="'docsPerPage1'"/>
                </xsl:call-template>
                <xsl:choose>
                  <xsl:when test="$browseText eq ''">
                    <xsl:call-template name="hidden.query"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type='hidden' name="browseText" value="{$browseText}"/>
                    <input type='hidden' name="text1" value="{$text1}"/>
                    <input type='hidden' name='field1' value="{$field1}"/>
                  </xsl:otherwise>
                </xsl:choose>
                <input type="hidden" name="style" value="{$style}"/>                
                <input type="hidden" name="smode">
                  <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
                </input>             
                <input type="hidden" name="brand" value="{$brand}"/>
                <noscript><div><input type="submit" value="Go!"/></div></noscript>
              </fieldset>
            </form>
            
          </div>
                      </xsl:if>
                    </xsl:if>
                  <div id="results">
                    
                  <xsl:apply-templates select="docHit"/>
                    </div>
                </xsl:otherwise>
              </xsl:choose>
          </xsl:if>
          
          <xsl:if test="@totalDocs != '0'">
          	<div id="mysel_pagebottom">
            <span class="pagenumber-links">
              <xsl:call-template name="pages"/>
            </span>
            <form id="docsPerPage_form2" method="get" action="{$xtfURL}{$crossqueryPath}">
              <fieldset>
                <label for="docsPerPage2">Results per page: </label>
                <xsl:call-template name="results.options">
                  <xsl:with-param name="mode" select="'docsPerPage'"/>
                  <xsl:with-param name="labelId" select="'docsPerPage2'"/>
                </xsl:call-template>
                <xsl:choose>
                  <xsl:when test="$browseText eq ''">
                    <xsl:call-template name="hidden.query"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type='hidden' name="browseText" value="{$browseText}"/>
                    <input type='hidden' name="text1" value="{$text1}"/>
                    <input type='hidden' name='field1' value="{$field1}"/>
                  </xsl:otherwise>
                </xsl:choose>
                <input type="hidden" name="style" value="{$style}"/>                
                <input type="hidden" name="smode">
                  <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
                </input>             
                <input type="hidden" name="brand" value="{$brand}"/>
                <noscript><div><input type="submit" value="Go!"/></div></noscript>
              </fieldset>
            </form>         
          	</div>
          </xsl:if>
          <xsl:comment>END SEARCH RESULTS</xsl:comment>
          
<!--          <br class="clear_both"/>-->
          
        </div>
      </div>
		<div id="footer" role="contentinfo">
    		<div class="contactinfo">
    			<xsl:copy-of select="$brand.footer"/>
	        </div>
        </div>
        <xsl:copy-of select="$brand.footerIU"/>

      </body>
    </html>
    
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Repository Browse Template                                             -->
  <!-- ====================================================================== -->
  
  <xsl:template match="crossQueryResult" mode="repository">
    
    <xsl:variable name="modifyString">
      <xsl:choose>
        <xsl:when test="contains($queryString,'smode=')">
          <xsl:value-of select="replace($queryString, '(smode=[A-Za-z0-9]*)', '$1-modify')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$queryString"/><xsl:text>&amp;smode=-modify</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <html lang="en" xml:lang="en">
      
      <head>
      	<meta name="viewport" content="width = 320" />
		<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />
        <title><xsl:value-of select="$brand.brandName"/>: Search Results</title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      
      <body>
        <xsl:copy-of select="$brand.headerIU"/>
        <div id="site_container">
          <xsl:copy-of select="$brand.header"/>
          
          
          <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>
          <div id="content" class="clearfix">
            
            <h3>
              <xsl:text>Browse Repository: </xsl:text><xsl:value-of select="iutei:getRepositoryName($repository)"/>
            </h3>
            
            <div class="number-items">
              <xsl:call-template name="page-summary">
                <xsl:with-param name="object-type" select="'items'"/>
              </xsl:call-template>
            </div>
            
            <xsl:call-template name="searchBar">
              <xsl:with-param name="mode" select="'repository'"/>
            </xsl:call-template>
            
            <xsl:if test="docHit">
                <xsl:choose>
                  <xsl:when test="$rmode = 'grid'">            
                    <xsl:for-each select="docHit[position() mod 5 = 1]">
                        <xsl:apply-templates select=". | following-sibling::docHit[position() &lt; 5]" mode="grid"/>
                    </xsl:for-each>
                    <xsl:apply-templates select="docHit" mode="grid"/>
                  </xsl:when>            
                  <xsl:when test="contains($rmode, 'compact')">            
                    <xsl:apply-templates select="docHit" mode="compact"/>
                  </xsl:when>            
                  <xsl:otherwise>            
                    <xsl:apply-templates select="docHit"/>
                  </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            
            <xsl:comment>END SEARCH RESULTS</xsl:comment>
            
            <xsl:call-template name="searchBar">
              <xsl:with-param name="mode" select="'repository'"/>
            </xsl:call-template>
            
          </div>
       </div>
          <div id="footer" role="contentinfo">
	    	<div class="contactinfo">
	          <xsl:copy-of select="$brand.footer"/>
	        </div>
	      </div>
          <xsl:copy-of select="$brand.footerIU"/>
      </body>
    </html>
    
  </xsl:template>

  
  <!-- ====================================================================== -->
  <!-- Results/form Template                                                  -->
  <!-- ====================================================================== -->
  <xsl:template name="searchOp">
    <xsl:param name="opname" select="'op1'"/>
    <xsl:param name="opvalue"></xsl:param>
    <label for="{$opname}" class="noshow">Connected By</label>
    <select id="{$opname}" name="{$opname}">
      <xsl:element name="option">
        <xsl:attribute name="value">and</xsl:attribute>
        <xsl:if test="$opvalue='and'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:text>and</xsl:text>
      </xsl:element>
      <xsl:element name="option">
        <xsl:attribute name="value">or</xsl:attribute>
        <xsl:if test="$opvalue='or'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:text>or</xsl:text>
      </xsl:element>
    </select>
  </xsl:template>

  <xsl:template name="searchType">
    <xsl:param name="fieldname" select="'field1'"/>
    <xsl:param name="fieldvalue"></xsl:param>
    <label for="{$fieldname}" class="noshow">As</label>
    <select id="{$fieldname}" name="{$fieldname}">
      <xsl:element name="option">
        <xsl:attribute name="value">text</xsl:attribute>
        <xsl:if test="$fieldvalue='text'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'keyword'"/>
      </xsl:element>
      <xsl:element name="option">
        <xsl:attribute name="value">creator</xsl:attribute>
        <xsl:if test="$fieldvalue='creator'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'author'"/>
      </xsl:element>
      <xsl:element name="option">
        <xsl:attribute name="value">title</xsl:attribute>
        <xsl:if test="$fieldvalue='title'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'title'"/>
      </xsl:element>		
      <xsl:element name="option">
        <xsl:attribute name="value">publisher</xsl:attribute>
        <xsl:if test="$fieldvalue='publisher'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'publisher'"/>
      </xsl:element>		
      
<!--      <xsl:element name="option">
        <xsl:attribute name="value">subject</xsl:attribute>
        <xsl:if test="$fieldvalue='subject'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Subject'"/>
      </xsl:element>    
      <xsl:element name="option">
        <xsl:attribute name="value">callnum</xsl:attribute>
        <xsl:if test="$fieldvalue='callnum'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Collection No.'"/>
      </xsl:element>	
      <xsl:element name="option">
        <xsl:attribute name="value">colltitle</xsl:attribute>
        <xsl:if test="$fieldvalue='colltitle'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Collection Title'"/>
      </xsl:element>	 
      <xsl:element name="option">
        <xsl:attribute name="value">eaddsc</xsl:attribute>
        <xsl:if test="$fieldvalue='eaddsc'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Contents List'"/>
      </xsl:element>   -->
    </select>	
  </xsl:template>
  
  <xsl:template name="searchRepository">
    <select name="repository" id="selectRepository">
      <xsl:element name="option">
        <xsl:attribute name="value">general</xsl:attribute>
        <xsl:if test="$repository=''">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'All Finding Aid Repositories'"/>
      </xsl:element>
      
      <!-- CSHM -->
      <xsl:element name="option">
        <xsl:attribute name="value">cshm</xsl:attribute>
        <xsl:if test="$repository='cshm'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Center for the Study of History and Memory, IU Bloomington'"/>
      </xsl:element>
      
      <!-- FOLKLORE -->
      <xsl:element name="option">
        <xsl:attribute name="value">folklore</xsl:attribute>
        <xsl:if test="$repository='folklore'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Folklore Collection, IU Bloomington'"/>
      </xsl:element>
      
      <!-- LCP -->
      <xsl:element name="option">
        <xsl:attribute name="value">lcp</xsl:attribute>
        <xsl:if test="$brand='lcp'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Liberian Collections, IU Bloomington'"/>
      </xsl:element>
      
      
      <!-- LILLY -->
      <xsl:element name="option">
        <xsl:attribute name="value">lilly</xsl:attribute>
        <xsl:if test="$repository='lilly'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Lilly Library, IU Bloomington'"/>
      </xsl:element>
      
      <!-- POLITICALPAPERS -->
      <xsl:element name="option">
        <xsl:attribute name="value">politicalpapers</xsl:attribute>
        <xsl:if test="$repository='politicalpapers'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'Political Papers, IU Bloomington'"/>
      </xsl:element>
      
      <!-- ARCHIVES -->
      <xsl:element name="option">
        <xsl:attribute name="value">archives</xsl:attribute>
        <xsl:if test="$repository='archives'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="'University Archives, IU Bloomington'"/>
      </xsl:element>
      
      <!-- WMI - apostrophe causes problems using xsl:value-of, even rendered as special char; xsl:text only way to get this to print -->
      <xsl:element name="option">
        <xsl:attribute name="value">wmi</xsl:attribute>
        <xsl:if test="$repository='wmi'">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:text>Working Men's Institute</xsl:text>
      </xsl:element>
      
    </select>
  </xsl:template>

  <xsl:template match="crossQueryResult" mode="results-form">
    <html lang="en" xml:lang="en">
      
      <head>
      	<meta name="viewport" content="width = 320" />
		<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />
        <title><xsl:value-of select="$brand.brandName"/>: Search Results</title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      
      <body>
        <xsl:copy-of select="$brand.headerIU"/>
        <div id="site_container"> 
        
 
         <xsl:copy-of select="$brand.header"/>

        <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>
          <div id="content" class="clearfix">

            <h3>
              <xsl:text>Search Results</xsl:text>
            </h3>
            <br/>
          <form class="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">
        		<input type="hidden" name="style" value="{$style}"/>
        		<input type="hidden" name="type" value="{$type}"/>
            <p><xsl:text>Your search for </xsl:text>

            <xsl:choose>
              <xsl:when test="not($type='advanced')">
        		<!-- EAD search is "content only" not metadata, uses sectionType's -->
        		<span class="search-term">
        		<input type="text" name="text1" value="{$text1}"/>
        		</span>
        		in
        		<span class="search-type">
        		  <xsl:call-template name="searchType">
        		    <xsl:with-param name="fieldname" select="'field1'"/>
        		    <xsl:with-param name="fieldvalue" select="$field1"/>
        		  </xsl:call-template>
        		</span>
        		in
        		
                <span class="search-type">
<!--                  <xsl:call-template name="searchRepository"/>-->
                </span>
              </xsl:when>
              <xsl:otherwise>
                    <p>
                    <input type="text" name="text1" size="30" value="{$text1}"/>
                      <xsl:call-template name="searchType">
                        <xsl:with-param name="fieldname" select="'field1'"/>
                        <xsl:with-param name="fieldvalue" select="$field1"/>
                      </xsl:call-template>
                      <xsl:call-template name="searchOp">
                        <xsl:with-param name="opname" select="'op1'"/>
                        <xsl:with-param name="opvalue" select="$op1"/>
                      </xsl:call-template>
                  </p>
                      
                      <p>
                         <input type="text" name="text2" size="30" value="{$text2}"/>
                        <xsl:call-template name="searchType">
                          <xsl:with-param name="fieldname" select="'field2'"/>
                          <xsl:with-param name="fieldvalue" select="$field2"/>
                        </xsl:call-template>
                        <xsl:call-template name="searchOp">
                          <xsl:with-param name="opname" select="'op2'"/>
                          <xsl:with-param name="opvalue" select="$op2"/>
                        </xsl:call-template>
                        </p>
                        
                        <p>
                        <input type="text" name="text3" size="30" value="{$text3}"/>
                          <xsl:call-template name="searchType">
                            <xsl:with-param name="fieldname" select="'field3'"/>
                            <xsl:with-param name="fieldvalue" select="$field3"/>
                          </xsl:call-template>
                        </p>
                        <p>
                      <span class="search-type">
<!--                        <xsl:call-template name="searchRepository"/>-->
                      </span>
                   </p>
              </xsl:otherwise>
            </xsl:choose>
	    <input type="hidden" name="relation" value="{$relation}"/>
            <xsl:text> found </xsl:text>
            <xsl:value-of select="@totalDocs"/>
            <xsl:text> item(s). </xsl:text>
            <span class="form-element">&#160;<input type="submit" value="Go!"/>
            </span></p>
          </form>
          
<!--          <div class="number-items">
            <xsl:call-template name="page-summary">
              <xsl:with-param name="object-type" select="'items'"/>
            </xsl:call-template>
          </div>
-->          
          <xsl:if test="@totalDocs eq 0">
          <div class="noresults">
          	<h3>Suggestions for revising your search:</h3>
          	<ul>
          		<li class="bullet">Check the spelling of your search terms</li>
				<li class="bullet">Verify your search syntax -- make sure you have closed parenthesis and double quotes</li>
				<li class="bullet">Broaden your search by using fewer search terms</li>
				<li class="bullet">Broaden your search by using wildcard symbol (&#42;) at the end of term(s)</li>
				<li class="bullet">Broaden your search by conducting OR searches</li>
				<li class="bullet">Visit the <a href="help.do">help page</a> for more information on searching</li>
          	</ul>
          </div>
          </xsl:if>
          
          <xsl:call-template name="searchBar"/>
          <xsl:if test="docHit">
              <xsl:choose>
                <xsl:when test="$rmode = 'grid'">            
            			<xsl:for-each select="docHit[position() mod 5 = 1]">
            				<xsl:apply-templates select=". | following-sibling::docHit[position() &lt; 5]" mode="grid"/>
            			</xsl:for-each>
                  <xsl:apply-templates select="docHit" mode="grid"/>
                </xsl:when>            
                <xsl:when test="contains($rmode, 'compact')">            
                  <xsl:apply-templates select="docHit" mode="compact"/>
                </xsl:when>            
                <xsl:otherwise>            
                  <xsl:apply-templates select="docHit"/>
                </xsl:otherwise>
              </xsl:choose>
          </xsl:if>
          
          <xsl:comment>END SEARCH RESULTS</xsl:comment>
          
          <xsl:call-template name="searchBar"/>
          
        </div>
      </div>
        <div id="footer" role="contentinfo">
	    	<div class="contactinfo">
	    		<xsl:copy-of select="$brand.footer"/>
    		</div>
    	</div>
        <xsl:copy-of select="$brand.footerIU"/>
         
      </body>
    </html>
    
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Form Template                                                          -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="form">  
    <html lang="en" xml:lang="en">
      
      <head>
      	<meta name="viewport" content="width = 320" />
		<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />
        <title><xsl:value-of select="$brand.brandName"/>: Search</title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      
      <body>
        <xsl:copy-of select="$brand.headerIU"/>        
        <div id="site_container">
          <xsl:copy-of select="$brand.header"/>
          <div id="content" class="clearfix">

        <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>

          
        <xsl:choose>
          <xsl:when test="$smode = 'simple' or $smode = ''">
            <!-- end header/nav table -->
              <h3>Simple Search</h3>
              <form class="search-form" method="get" action="{$xtfURL}{$crossqueryPath}" role="search">
                
                <input type="hidden" name="style" value="{$style}"/>                  
                <input type="hidden" name="smode">
                  <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
                </input>             
                <input type="hidden" name="rmode" value="{$rmode}"/>                  
                <!--<input type="hidden" name="brand" value="{$brand}"/> -->
             
                    <p>Word or phrase<span class="spacer">

                      <input name="text1" type="text" size="20" value="{$text1}"/></span>
                   
                    <!-- <span class="spacer">within</span> -->
                      <span class="search-type">
                        <xsl:call-template name="searchType">
                          <xsl:with-param name="fieldname" select="'field1'"/>
                          <xsl:with-param name="fieldvalue" select="$field1"/>
                        </xsl:call-template>
                      </span>
                    </p>
                    <p>
                      <span class="search-type">
<!--                        <xsl:call-template name="searchRepository"/>-->
                      </span>
                   </p>
                   <p>
                  <!-- <span class="spacer"> -->
                   <xsl:text>&#160;</xsl:text>
                   <input type="submit" value="Search"/>
                  <!-- </span> -->
                    </p>
              </form>                 
          </xsl:when>
          <xsl:otherwise>
          <h2 id="mainheading">Search</h2>
            <form id="search" method="get" action="{$xtfURL}{$crossqueryPath}" role="search">

                        
                    <p>Search for:</p>
                    <p>
                    <label for="text1" class="noshow">Search Term Field 1</label>
                    <input type="text" name="text1" id="text1" size="30" value=""/>
                      <xsl:call-template name="searchType">
                        <xsl:with-param name="fieldname" select="'field1'"/>
                        <xsl:with-param name="fieldvalue" select="$field1"/>
                      </xsl:call-template>
                      <xsl:call-template name="searchOp">
                        <xsl:with-param name="opname" select="'op1'"/>
                        <xsl:with-param name="opvalue" select="$op1"/>
                      </xsl:call-template>
                  </p>
                      
                      <p>
                      	<label for="text2" class="noshow">Search Term Field 2</label>
                         <input type="text" name="text2" id="text2" size="30" value=""/>
                        <xsl:call-template name="searchType">
                          <xsl:with-param name="fieldname" select="'field2'"/>
                          <xsl:with-param name="fieldvalue" select="$field2"/>
                        </xsl:call-template>
                        <xsl:call-template name="searchOp">
                          <xsl:with-param name="opname" select="'op2'"/>
                          <xsl:with-param name="opvalue" select="$op2"/>
                        </xsl:call-template>
                        </p>
                        
                        <p>
                        <label for="text3" class="noshow">Search Term Field 3</label>
                        <input type="text" name="text3" id="text3" size="30" value=""/>
                          <xsl:call-template name="searchType">
                            <xsl:with-param name="fieldname" select="'field3'"/>
                            <xsl:with-param name="fieldvalue" select="$field3"/>
                          </xsl:call-template>
                        </p>
                        <p>
                          <xsl:text>Year: </xsl:text>
                          <label for="fromYear" class="noshow">From Year</label>
                          <input type="text" id="fromYear" name="fromYear" size="5" value="{$fromYear}"/>
                          <xsl:text>To: </xsl:text>
                          <label for="toYear" class="noshow">To Year</label>
                          <input type="text" id="toYear" name="toYear" size="5" value="{$toYear}"/>
                        </p>
              
                        <p>
                      <span class="search-type">
<!--                        <xsl:call-template name="searchRepository"/>-->
                      </span>
                   </p>
                         
                          <p>
                          <input type="submit" value="Search" onclick="return checkSearch();"/> <input type="reset" value="Clear"/> 
                          <input type="hidden" name="step" value="query"/>
                          <input type="hidden" name="smode" value="advanced"/>
			  <input type="hidden" name="brand" value="{$brand}"/>
                          </p>
                    <!--< class="sideSection">-->
            </form>            
          </xsl:otherwise>
        </xsl:choose> 
<div id="tips">
	                  <h2 class="sidemenu_heading">Search Tips</h2>
					  <div class="sidemenu">
					  	<dl>
					  		<dt>How to Enter Terms</dt>
    						<dd>
    							Enter each term in a separate search box. More than one term typed per search box will be interpreted as a phrase. Use the Boolean menu to combine search terms with AND/OR.
    						</dd>
    						<dt>Stemming</dt>
    						<dd>
    							Broaden your search by using an asterisk * (e.g., sea* will find seas, seal, and seamstress).
    						</dd>
    						<dt>Search by Year</dt>
					    	<dd>
					    		By default, all publication years will be searched. Narrow your results by searching one year or a range (e.g., 1891 or 1891 to 1895). A year or year range search can be executed without entering search terms. 	
					    	</dd>
					    </dl>
				  	</div>
				  </div>
<!--<br class="clear_both" />-->
            
<!--            <h4>Search tips:</h4>
            <ul>
              <li>use single words or phrases, e.g., &quot;vonnegut.&quot; </li>
              <li>for searches of multiple words, e.g. &quot;wells&quot; and &quot;bloomington,&quot; use
                the Advanced Search</li>
            </ul>   
-->        

            </div>
          <div class="clear"></div>
          <xsl:comment>END SEARCH RESULTS</xsl:comment> 
      
      </div>

        <div id="footer" role="contentinfo">
	    	<div class="contactinfo">
	    		<xsl:copy-of select="$brand.footer"/>
    		</div>
    	</div>
        <xsl:copy-of select="$brand.footerIU"/>
      
      </body>
    </html>
  </xsl:template>

  <xsl:template name="hidden.query">
    <xsl:param name="queryString"/>
    <xsl:if test="$text1">
      <input type="hidden" name="text1" value="{$text1}"/>
    </xsl:if>
    <xsl:if test="$text2">
      <input type="hidden" name="text2" value="{$text2}"/>
    </xsl:if>
    <xsl:if test="$text3">
      <input type="hidden" name="text3" value="{$text3}"/>
    </xsl:if>
    <xsl:if test="$field1">
      <input type="hidden" name="field1" value="{$field1}"/>
    </xsl:if>
    <xsl:if test="$field2">
      <input type="hidden" name="field2" value="{$field2}"/>
    </xsl:if>
    <xsl:if test="$field3">
      <input type="hidden" name="field3" value="{$field3}"/>
    </xsl:if>
    <xsl:if test="$fromYear">
      <input type="hidden" name="fromYear" value="{$fromYear}"/>
    </xsl:if>
    <xsl:if test="$toYear">
      <input type="hidden" name="toYear" value="{$toYear}"/>
    </xsl:if>
    <xsl:if test="$op1">
      <input type="hidden" name="op1" value="{$op1}"/>
    </xsl:if>
    <xsl:if test="$op2">
      <input type="hidden" name="op2" value="{$op2}"/>
    </xsl:if>
    <xsl:if test="$freeformQuery != ''">
      <input type="hidden" name="freeformQuery" value="{$freeformQuery}"/>
    </xsl:if>
<!--    <xsl:if test="$docsPerPage">
      <input type="hidden" name="docsPerPage" value="{$docsPerPage}"/>
    </xsl:if>
-->    
<!--    <xsl:if test="$repository">
      <input type="hidden" name="repository" value="{$repository}"/>
    </xsl:if>
-->  </xsl:template>
  
  
  <!-- ====================================================================== -->
  <!-- Search Options (Overides Common Version)                               -->
  <!-- ====================================================================== -->

  <xsl:template name="sort.options">
    <xsl:param name="mode"/>
    <xsl:choose>
      <xsl:when test="$mode='repository'">
        <select size="1" name="sort">
          <xsl:choose>
            <xsl:when test="$sort = '' or $sort='title'">
              <option value="title" selected="selected">Collection Title</option>
              <option value="date">Collection Dates</option>
            </xsl:when>
            <xsl:when test="$sort = 'date'">
              <option value="title">Collection Title</option>
              <option value="date" selected="selected">Collection Dates</option>
            </xsl:when>
          </xsl:choose>
        </select>    
      </xsl:when>
      <xsl:otherwise>
        <select size="1" name="sort" id="sort" onchange="submit();">
          <xsl:choose>
            <xsl:when test="$sort = ''">
              <option value="" selected="selected">Relevance</option>
              <option value="title">Title</option>
              <option value="creator">Author</option>
              <option value="date">Publication Year</option>
            </xsl:when>
            <xsl:when test="$sort = 'title'">
              <option value="">Relevance</option>
              <option value="title" selected="selected">Title</option>
              <option value="creator">Author</option>
              <option value="date">Publication Year</option>
            </xsl:when>
            <xsl:when test="$sort = 'creator'">
              <option value="">Relevance</option>
              <option value="title">Title</option>
              <option value="creator" selected="selected">Author</option>
              <option value="date">Publication Year</option>
            </xsl:when>
            <xsl:when test="$sort = 'date'">
              <option value="">Relevance</option>
              <option value="title">Title</option>
              <option value="creator">Author</option>
              <option value="date" selected="selected">Publication Year</option>
            </xsl:when>
          </xsl:choose>
        </select>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="results.options">
    <xsl:param name="mode"/>
    <xsl:param name="labelId"/>
    <xsl:choose>
      <xsl:when test="$mode='docsPerPage'">
        <select size="1" name="docsPerPage" id="{$labelId}" onchange="submit();">
<!--          <option value="10">10</option>
          <option value="20">20</option>
          <option value="50">50</option>
-->          <xsl:choose>
            <xsl:when test="$docsPerPage = 10">
              <option value="10" selected="selected">10</option>
              <option value="20">20</option>
              <option value="50">50</option>
            </xsl:when>
            <xsl:when test="$docsPerPage = 20">
              <option value="10">10</option>
              <option value="20" selected="selected">20</option>
              <option value="50">50</option>
            </xsl:when>
            <xsl:when test="$docsPerPage = 50">
              <option value="10">10</option>
              <option value="20">20</option>
              <option value="50" selected="selected">50</option>
            </xsl:when>
          </xsl:choose>
        </select>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
 
  <!-- ====================================================================== -->
  <!-- Search Bar                                                             -->
  <!-- ====================================================================== -->
  
  <xsl:template name="searchBar">
    <xsl:param name="mode"/>
    <xsl:if test="docHit">
      <xsl:comment>BEGIN SEARCH BAR</xsl:comment>
<!--      <div class="search-option-bar">-->
<!--      	<div class="sort-form">-->
            <form id="sort_form" method="get" action="{$xtfURL}{$crossqueryPath}">
            	<fieldset>
<!--              <form class="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">-->
              <label for="sort">Sort by:</label>
              <xsl:call-template name="sort.options">
                <xsl:with-param name="mode" select="$mode"/>
              </xsl:call-template>
              <xsl:choose>
                <xsl:when test="$browseText eq ''">
                  <xsl:call-template name="hidden.query"/>
                  <xsl:if test="$docsPerPage">
                    <input type="hidden" name="docsPerPage" value="{$docsPerPage}"/>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <input type='hidden' name="browseText" value="{$browseText}"/>
                  <input type='hidden' name="text1" value="{$text1}"/>
                  <input type='hidden' name='field1' value="{$field1}"/>
                  <input type="hidden" name="docsPerPage" value="{$docsPerPage}"/>
                </xsl:otherwise>
              </xsl:choose>
              
             
              <input type="hidden" name="style" value="{$style}"/>                
              <input type="hidden" name="smode">
                <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
              </input>             
              <!-- input type="hidden" name="rmode" value="{$rmode}"/ -->
              <input type="hidden" name="brand" value="{$brand}"/>
              <noscript><div><input type="submit" value="Go!"/></div></noscript>
             </fieldset>
            </form>
      
      
<!--          </div>-->
          <div class="paging">
            <span class="pagenumber-links">
              <xsl:call-template name="pages"/>
            </span>
            <form id="docsPerPage_form" method="get" action="{$xtfURL}{$crossqueryPath}">
              <fieldset>
                <label for="docsPerPage1">Results per page: </label>
                <xsl:call-template name="results.options">
                  <xsl:with-param name="mode" select="'docsPerPage'"/>
                  <xsl:with-param name="labelId" select="'docsPerPage1'"/>
                </xsl:call-template>
                <xsl:choose>
                  <xsl:when test="$browseText eq ''">
                    <xsl:call-template name="hidden.query"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <input type='hidden' name="browseText" value="{$browseText}"/>
                    <input type='hidden' name="text1" value="{$text1}"/>
                    <input type='hidden' name='field1' value="{$field1}"/>
                  </xsl:otherwise>
                </xsl:choose>
                <input type="hidden" name="style" value="{$style}"/>                
                <input type="hidden" name="smode">
                  <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
                </input>             
                <input type="hidden" name="brand" value="{$brand}"/>
                <noscript><div><input type="submit" value="Go!"/></div></noscript>
              </fieldset>
            </form>
            
          </div>
<!--      </div>-->
      <xsl:comment>END SEARCH BAR</xsl:comment>
    </xsl:if>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- IUFA Help                                                               -->
  <!-- ====================================================================== -->

  <xsl:template name="oac-help">
    <table border="0" width="100%">
      <tr>
        <td>
          <p class="directions">Helpful hints to improve your results: <ul>
            <span class="help"> Try simple and direct words (example: if you 
              want to see pictures of squirrels use &quot;squirrel&quot; and 
              not &quot;rodent&quot;) <br/>If you want more results, try a 
                broader word (example:try &quot;animal&quot; not &quot;squirrel&quot;)
                <br/></span></ul></p>
        </td>
      </tr>
    </table>
  </xsl:template>
  
  
  <!-- ====================================================================== -->
  <!-- Parameters Template                                                    -->
  <!--                                                                        -->
  <!-- Format query feedback                                                  -->
  <!-- ====================================================================== -->
  <xsl:template match="parameters" mode="search">
    <xsl:variable name="textParams"
      select="param[count(*) &gt; 0 and matches(@name, 'text\d')]"/>
    <xsl:variable name="paramTotal" select="count($textParams)"/>
    <xsl:variable name="opParams"
      select="param[count(*) &gt; 0 and matches(@name, 'op\d')]"/>
    <xsl:variable name="fieldParams"
      select="param[count(*) &gt; 0 and matches(@name, 'field\d')]"/>
    <xsl:variable name="toRangeParam"
      select="param[matches(@name, 'toYear')]"/>
    <xsl:variable name="rangeParam"
      select="concat($fromYear,'-',$toYear)"/>
    
    <xsl:call-template name="param">
      <xsl:with-param name="allTextParams" select="$textParams"/>
      <xsl:with-param name="allOpParams" select="$opParams"/>
      <xsl:with-param name="allFieldParams" select="$fieldParams"/>
      <xsl:with-param name="textParams" select="$textParams"/>
      <xsl:with-param name="opParams" select="$opParams"/>
      <xsl:with-param name="fieldParams" select="$fieldParams"/>
      <xsl:with-param name="rangeParam" select="$rangeParam"/>
      <xsl:with-param name="number" select="1"/>
    </xsl:call-template>
    <xsl:if test="$fromYear">
      <xsl:variable name="newQueryString">
        <xsl:choose>
            <xsl:when test="$toYear">
              <xsl:value-of select="replace(replace($queryString, $toYear, ''),$fromYear,'')"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($queryString, $fromYear, '')"></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    <xsl:value-of select="$rangeParam"/>
      <a class="top-link" href="{$xtfURL}{$crossqueryPath}?{$newQueryString}&amp;brand={$brand}"><img src="images/remove.png" alt="Remove '{$rangeParam}' as Year Range" title="Remove '{$rangeParam}' as Year Range"/></a>
      <xsl:text> in </xsl:text> <em> <xsl:text>Year Range</xsl:text></em>
    </xsl:if>
  </xsl:template>  
  
  <xsl:template name="param">
    <xsl:param name="allTextParams"/>
    <xsl:param name="allOpParams"/>
    <xsl:param name="allFieldParams"/>
    <xsl:param name="textParams"/>
    <xsl:param name="opParams"/>
    <xsl:param name="fieldParams"/>
    <xsl:param name="number"/>
    <xsl:param name="rangeParam"/>
    <xsl:variable name="opNumber" select="$number"/>


    <xsl:variable name="otherTextParams"
      select="$allTextParams[not(@name=concat('text', string($number)))]"/>
    <xsl:variable name="otherOpParams"
      select="$allOpParams[not(@name=concat('op', string($number)))]"/>
    <xsl:variable name="otherFieldParams"
      select="$allFieldParams[not(@name=concat('field', string($number)))]"/>
    <xsl:variable name="text"
      select="$textParams[@name=concat('text', string($number))]"/>
    <xsl:variable name="field"
      select="$fieldParams[@name=concat('field', string($number))]"/>
    <xsl:variable name="op"
      select="$opParams[@name=concat('op', string($opNumber))]"/>

    <xsl:variable name="localTextParams"
      select="$textParams[not(@name=concat('text', string($number)))]"/>
    <xsl:variable name="localFieldParams"
      select="$fieldParams[not(@name=concat('field',string($number)))]"/>

    <xsl:variable name="localOpParams" select="$opParams[not(@name=concat('op', string($opNumber)))]"/>

    <!--    Begin search refinement controls-->
    <xsl:if test="$text1 or $text2 or $text3">
    <xsl:text> </xsl:text>
    <strong>
      <xsl:variable name="searchType">
      	<xsl:choose>
      		<xsl:when test="$field/@value = 'creator' or $field/@value = 'browse-creator'">Author</xsl:when>
	        <xsl:when test="$field/@value = 'title' or $field/@value = 'browse-title'">Title</xsl:when>
      		<xsl:when test="$field/@value = 'daterange' or $field/@value = 'browse-daterange'">Date</xsl:when>
      		<xsl:when test="$field/@value = 'publisher' or $field/@value = 'browse-publisher'">Publisher</xsl:when>
      		<xsl:otherwise>Keyword</xsl:otherwise>
    	</xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$browseText = ''">
          
          <xsl:value-of select="$text/@value"/>
          
          <xsl:variable name="newQueryString">
            <xsl:for-each select="$otherTextParams/@value">
              <xsl:variable name="paramPosition" select="position()"/>
              <xsl:value-of select="concat('text',$paramPosition,'=')"/><xsl:value-of select="$otherTextParams[$paramPosition]/@value"/><xsl:text>&amp;</xsl:text>
              <xsl:value-of select="concat('field',$paramPosition,'=')"/><xsl:value-of select="$otherFieldParams[$paramPosition]/@value"/><xsl:text>&amp;</xsl:text>
              <xsl:value-of select="concat('op',$paramPosition,'=')"/><xsl:value-of select="$otherOpParams[$paramPosition]/@value"/><xsl:text>&amp;</xsl:text>
              
            </xsl:for-each>
            <xsl:if test="$fromYear">
                <xsl:value-of select="concat('&amp;','fromYear=',$fromYear,'&amp;','toYear=',$toYear)"/>
            </xsl:if>
            <xsl:text>&amp;</xsl:text><xsl:text>smode=advanced</xsl:text>

          </xsl:variable>

          <a class="top-link" href="{$xtfURL}{$crossqueryPath}?{$newQueryString}&amp;brand={$brand}"><img src="images/remove.png" alt="Remove '{$text/@value}' as {$searchType}" title="Remove '{$text/@value}' as {$searchType}"/></a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$browseText"/>
        </xsl:otherwise>
      </xsl:choose>
    </strong>
    <xsl:text> in </xsl:text>
    <em>
    <xsl:choose>
      <xsl:when test="$field/@value = 'creator' or $field/@value = 'browse-creator'">Author</xsl:when>
      <xsl:when test="$field/@value = 'title' or $field/@value = 'browse-title'">Title</xsl:when>
      <xsl:when test="$field/@value = 'daterange' or $field/@value = 'browse-daterange'">Date</xsl:when>
      <xsl:when test="$field/@value = 'publisher' or $field/@value = 'browse-publisher'">Publisher</xsl:when>
      <xsl:otherwise>Keyword</xsl:otherwise>
    </xsl:choose>
    </em>
    <xsl:text> </xsl:text>
      <xsl:if test="$fromYear">
        <xsl:text> and </xsl:text>
        </xsl:if>
    </xsl:if>
<!--    End of search refinement controls-->
    
    <xsl:if test="count($localTextParams) &gt; 0">
      <xsl:value-of select="$op/@value"/>
      
      <xsl:call-template name="param">
        <xsl:with-param name="allTextParams" select="$allTextParams"/>
        <xsl:with-param name="allOpParams" select="$allOpParams"/>
        <xsl:with-param name="allFieldParams" select="$allFieldParams"/>
        <xsl:with-param name="textParams" select="$localTextParams"/>
        <xsl:with-param name="opParams" select="$localOpParams"/>
        <xsl:with-param name="fieldParams" select="$localFieldParams"/>
        <xsl:with-param name="number" select="$number + 1"/>
      </xsl:call-template>
    </xsl:if>
    
  </xsl:template>
  
  <!-- Page Linking -->  
  <xsl:template name="pages">
    
    
    <xsl:variable name="total" as="xs:integer">
      <xsl:value-of select="@totalDocs"/>
    </xsl:variable>
    
    <xsl:variable name="start" as="xs:integer">
      <xsl:value-of select="$startDoc"/>
    </xsl:variable>
    
    <xsl:variable name="startName">
      <xsl:value-of select="'startDoc'"/>
    </xsl:variable>
    
    <xsl:variable name="perPage" as="xs:integer">
      <xsl:value-of select="$docsPerPage"/>
    </xsl:variable>
    
    <xsl:variable name="nPages" as="xs:double">
      <xsl:value-of select="floor((($total+$perPage)-1) div $perPage)+1"/>
    </xsl:variable>
    
    <xsl:variable name="showPages" as="xs:integer">
      <xsl:choose>
        <xsl:when test="$nPages >= ($maxPages + 1)">
          <xsl:value-of select="$maxPages"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$nPages - 1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!--    Start debugging section-->
<!--    <xsl:text>total:</xsl:text><xsl:value-of select="@totalDocs"/>
    <xsl:text> startdoc:</xsl:text><xsl:value-of select="$startDoc"/>
    <xsl:text> startName:</xsl:text><xsl:value-of select="$startName"/>
-->
<!--    <xsl:text> perPage:</xsl:text><xsl:value-of select="$perPage"/>-->
<!--    <xsl:text> nPages:</xsl:text><xsl:value-of select="$nPages"/>
    <xsl:text> showPages:</xsl:text><xsl:value-of select="$showPages"/>
-->    <!--    End debugging section-->
    

    <xsl:variable name="pageQueryString">
      <xsl:value-of select="editURL:remove($queryString, 'startDoc')"/>
    </xsl:variable>  
    
    <xsl:variable name="currentPage">
      <xsl:value-of select="(($start - 1) div $perPage) + 1"></xsl:value-of>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$nPages &gt; 2">
        <xsl:text>Page: </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Page: 1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>


    <xsl:for-each select="(1 to $maxPages)">
      <!-- Figure out what page we're on -->
      <xsl:variable name="pageNum" as="xs:integer" select="position()"/>
      <xsl:variable name="pageStart" as="xs:integer" select="(($pageNum - 1) * $perPage) + 1"/>
      
      <!-- Individual Paging -->
      <xsl:if test="($pageNum = 1) and ($pageStart != $start)">
        <xsl:variable name="prevPage" as="xs:integer" select="$start - $perPage"/>
        <a href="{$xtfURL}{$crossqueryPath}?{$pageQueryString};{$startName}={$prevPage}">Prev</a>
        <xsl:text>&#160;&#160;</xsl:text>
      </xsl:if>

      <!-- If there are hits on the page, show it -->
      <xsl:if test="(($pageNum &gt;= $currentPage - 5) and ($pageNum &lt;= $currentPage + 4)) and
        (($nPages &gt; $pageNum) and ($nPages &gt; 2))">
        <xsl:choose>
          <!-- Make a hyperlink if it's not the page we're currently on. -->
          <xsl:when test="($pageStart != $start)">
            <a href="{$xtfURL}{$crossqueryPath}?{$pageQueryString};{$startName}={$pageStart}">
              <xsl:value-of select="$pageNum"/>
            </a>
            <xsl:if test="$pageNum &lt; $showPages">
              <xsl:text>&#160;</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:when test="($pageStart = $start)">
            <xsl:value-of select="$pageNum"/>
            <xsl:if test="$pageNum &lt; $showPages">
              <xsl:text>&#160;</xsl:text>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      
      <!-- Individual Paging -->      
      <xsl:if test="($pageNum = $showPages) and ($pageStart != $start)">
        <xsl:variable name="nextPage" as="xs:integer" select="$start + $perPage"/>
        <xsl:text>&#160;&#160;</xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$pageQueryString};{$startName}={$nextPage}">Next</a>
      </xsl:if>
      
    </xsl:for-each>
    
  </xsl:template>

  <xsl:template name="getAddress" exclude-result-prefixes="#all">
    <html xml:lang="en" lang="en">
      <head>
      	<meta name="viewport" content="width = 320" />
		<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />
        <title>E-mail My Selections: Get Address</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <xsl:copy-of select="$brand.links"/>
      </head>
      <body>
        <xsl:copy-of select="$brand.headerIU"/>
        <div class="getAddress" role="main">
          <h2>E-mail My Selections</h2>
          <hr/>
          <form action="{$xtfURL}{$crossqueryPath}" method="get" role="form">
          	<fieldset>
	            <label for="email"><span class="auraltext">Email </span><xsl:text>Address: </xsl:text></label>
    	        <input type="text" name="email" id="email" />
        	    <xsl:text>&#160;</xsl:text>
            	<input type="submit" value="Submit" onclick="return checkEmail();"/>
	            <xsl:text>&#160;</xsl:text>
    	        <input type="reset" value="Clear"/>
        	    <input type="hidden" name="smode" value="emailFolder"/>
        	</fieldset>
		<input type="hidden" name="brand" value="{$brand}"/>
          </form>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="crossQueryResult" mode="emailFolder" exclude-result-prefixes="#all">
    
    <xsl:variable name="bookbagContents" select="session:getData('bag')/bag"/>
    
    <!-- Change the values for @smtpHost and @from to those valid for your domain -->
    <mail:send xmlns:mail="java:/org.cdlib.xtf.saxonExt.Mail" 
      xsl:extension-element-prefixes="mail" 
      smtpHost="localhost"
      useSSL="no" 
      from="diglib@indiana.edu"
      to="{$email}" 
      subject="{$brand.brandName} - My Selections">
      Your Selections: <xsl:apply-templates select="$bookbagContents/savedDoc" mode="emailFolder"/>
    </mail:send>
    
    <html xml:lang="en" lang="en">
      <head>
        <title>E-mail My Citations: Success</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="viewport" content="width = 320" />
		<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />
        <xsl:copy-of select="$brand.links"/>
      </head>
      <body onload="autoCloseTimer = setTimeout('window.close()', 1000)">
        <xsl:copy-of select="$brand.headerIU"/>
        <div class="getAddress">
          <h1>E-mail My Citations</h1>
          <strong>Your citations have been sent.</strong>
        </div>
      </body>
    </html>
    
  </xsl:template>
  
  <xsl:template match="savedDoc" mode="emailFolder" exclude-result-prefixes="#all">
    <xsl:variable name="num" select="position()"/>
    <xsl:variable name="id" select="@id"/>
    <xsl:for-each select="$docHits[string(meta/identifier[1]) = $id][1]">
      <xsl:variable name="path" select="@path"/>
      <xsl:variable name="url">
        <xsl:value-of select="$xtfURL"/>
        <xsl:choose>
          <xsl:when test="matches(meta/display, 'dynaxml')">
            <xsl:call-template name="ead.dynaxml.url">
              <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="ead.dynaxml.url">
              <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
<!--            <xsl:call-template name="rawDisplay.url">
              <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
-->          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!--        [<xsl:value-of select="$url"/>]-->
        Title: <xsl:value-of select="normalize-space(meta/title[1])"/>
        Author: <xsl:if test="meta/creator and meta/creator != ''">
            <xsl:value-of select="normalize-space(replace(meta/creator[1], '-', '&#150;'))"/>
            <xsl:if test="not(ends-with(meta/creator[1],'.'))"/>
           </xsl:if>
        Publication Year: <xsl:choose>
          <xsl:when test="meta/dateDisplay and meta/dateDisplay != ''">
            <xsl:value-of select="meta/dateDisplay"/>
          </xsl:when><xsl:otherwise>
            <xsl:if test="meta/date and meta/date != ''">
              <xsl:value-of select="meta/date"/>
            </xsl:if></xsl:otherwise>
        </xsl:choose>
        Source: <xsl:if test="meta/pubPlace and meta/pubPlace != ''">
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
        http://purl.dlib.indiana.edu/iudl/<xsl:value-of select="$brand"/>/<xsl:value-of select="meta/identifier"></xsl:value-of>
          
    </xsl:for-each>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Facets and their Groups                                                -->
  <!-- ====================================================================== -->
  
  <!-- Facet -->
  <xsl:template match="facet[matches(@field,'^facet-')]" exclude-result-prefixes="#all">
    <xsl:variable name="field" select="replace(@field, 'facet-(.*)', '$1')"/>
    <xsl:variable name="needExpand" select="@totalGroups > count(group)"/>
    <h2 class="sidemenu_heading">
      <xsl:apply-templates select="." mode="facetName"/>
    </h2>
      
    <div class="sidemenu">
<!--      <div class="facetName">
        <xsl:apply-templates select="." mode="facetName"/>
      </div>
-->      <xsl:if test="$expand=$field">
        <div class="facetLess">
          <em><a href="{$xtfURL}{$crossqueryPath}?{editURL:remove($queryString,'expand')}">less<span class="auraltext"> results by <xsl:apply-templates select="." mode="facetName"/></span></a></em>
        </div>
      </xsl:if>
      <xsl:apply-templates/>
<!--      <div class="facetGroup">
          <xsl:apply-templates/>
      </div>
-->      <xsl:if test="$needExpand and not($expand=$field)">
        <div class="facetMore">
          <em><a href="{$xtfURL}{$crossqueryPath}?{editURL:set($queryString,'expand',$field)}">more<span class="auraltext"> results by <xsl:apply-templates select="." mode="facetName"/></span></a></em>
        </div>
      </xsl:if>
    </div>
  </xsl:template>
  
  <!-- Plain (non-hierarchical) group of a facet -->
  <xsl:template match="group[not(parent::group) and @totalSubGroups = 0]" exclude-result-prefixes="#all">
    <xsl:variable name="field" select="replace(ancestor::facet/@field, 'facet-(.*)', '$1')"/>
    <xsl:variable name="value" select="@value"/>
    <xsl:variable name="nextName" select="editURL:nextFacetParam($queryString, $field)"/>
    <xsl:variable name="facetType">
      <xsl:variable name="prettyName" select="replace($field, '_', ' ')"/>
      <xsl:value-of select="concat(upper-case(substring($prettyName, 1, 1)), substring($prettyName, 2))"/>
    </xsl:variable>
    
    <xsl:variable name="cleanSelectLink">
        <xsl:value-of select="editURL:remove($queryString, 'startDoc')"/>
      
    </xsl:variable>
    
    <xsl:variable name="selectLink" select="
      concat(xtfURL, $crossqueryPath, '?',
      editURL:set(editURL:remove($cleanSelectLink,'browse-all=yes'), $nextName, $value)
	)">
    </xsl:variable>
    
    <xsl:variable name="clearLink" select="
      concat(xtfURL, $crossqueryPath, '?',
      editURL:replaceEmpty(editURL:remove($queryString, concat('f[0-9]+-',$field,'=',$value)),
      'browse-all=yes'))">
    </xsl:variable>
    

      <ul>    
      <!-- Display the group name, with '[X]' box if it is selected. -->
      <xsl:choose>
        <xsl:when test="//param[matches(@name,concat('f[0-9]+-',$field))]/@value=$value">
            <li>
            <xsl:apply-templates select="." mode="beforeGroupValue"/>
            <em>
              <xsl:value-of select="iutei:restoreFacet($value)"/><xsl:text> </xsl:text>
            </em>
            <xsl:apply-templates select="." mode="afterGroupValue"/>
      
      
            <a href="{$clearLink}&amp;brand={$brand}"><img src="images/remove.png" alt="Remove '{iutei:restoreFacet($value)}' as {$facetType}" title="Remove '{iutei:restoreFacet($value)}' as {$facetType}"/></a>
            </li>
        </xsl:when>
        <xsl:otherwise>
            <li>
            <xsl:apply-templates select="." mode="beforeGroupValue"/>
            <a href="{$selectLink}">
              <xsl:value-of select="iutei:restoreFacet($value)"/>
              
<!--              <xsl:for-each select="$docHits[meta/facet-Publication_Year//text()[not(.=preceding::meta/facet-Publication_Year//text())] = $value]">
                <xsl:value-of  select="meta/daterange"/>
              </xsl:for-each>
              
              
              <xsl:for-each select="$docHits[meta/facet-Author//text()[not(.=preceding::meta/facet-Author//text())] = $value]">
                <xsl:value-of  select="meta/creator"/>
              </xsl:for-each>
              
              
              <xsl:for-each select="$docHits[meta/facet-publisher//text()[not(.=preceding::meta/facet-publisher//text())] = $value]">
                <xsl:value-of  select="meta/publisher"/>
              </xsl:for-each>
-->
            </a>
            <xsl:apply-templates select="." mode="afterGroupValue"/>
      
      
            (<xsl:value-of select="@totalDocs"/>)
            </li>
        </xsl:otherwise>
      </xsl:choose>
      </ul>  
  </xsl:template>

 <!-- Default template to display the name of a facet. Override to specialize. -->
   <xsl:template match="facet" mode="facetName" priority="-1">
      <xsl:variable name="rawName" select="replace(@field, '^facet-', '')"/>
      <xsl:variable name="prettyName" select="replace($rawName, '_', ' ')"/>
      <xsl:value-of select="concat(upper-case(substring($prettyName, 1, 1)), substring($prettyName, 2))"/>
   </xsl:template>

  <xsl:function name="iutei:restoreFacet"> 
    <xsl:param name="value"/> 
    <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace($value, 
      '%',     '%25'), 
      '[+]',   '%2B'), 
      'C-AMP', '&amp;'), 
      ';',     '%3B'), 
      '=',     '%3D'), 
      'C-LPAREN',     '('),
      'C-RPAREN',     ')'),
      '#',     '%23')"/> 
  </xsl:function>
  


</xsl:stylesheet>

