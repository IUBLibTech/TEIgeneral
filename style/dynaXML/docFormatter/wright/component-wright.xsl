<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<!-- ====================================================================== -->
<!-- Lists                                                                  -->
<!-- ====================================================================== -->
<!-- <xsl:template match="list">
<xsl:if test="head">
  <xsl:apply-templates select="head" />
</xsl:if>
  <xsl:choose>
  	<xsl:when test="ancestor::*[@type='contents'] or ancestor::*[@type='figures']">
  		<xsl:choose>
  			<xsl:when test="label">
		  		<dl class="toc">
		  			<xsl:for-each select="item">
		  				<xsl:apply-templates select="."/>
		  			</xsl:for-each>
		  		</dl>
		  	</xsl:when>
		  	<xsl:otherwise>
		  		<ul class="toc">
		  			<xsl:for-each select="item">
		  				<xsl:apply-templates select="."/>
		  			</xsl:for-each>
		  		</ul>
		  	</xsl:otherwise>
  		</xsl:choose>
  	</xsl:when>
    <xsl:when test="@type='bibliography'">
    	<dl class="bibliography">
    		<dt style="display:none"></dt>
    		<xsl:for-each select="item">
		  		<xsl:apply-templates select="."/>
		  	</xsl:for-each>	
    	</dl>
    </xsl:when>
    <xsl:when test="@type='footnotes'">
    	<ul class="footnote">
    		<li><hr /></li>
    		<xsl:for-each select="item">
		  		<xsl:apply-templates select="."/>
		  	</xsl:for-each>	
    	</ul>
    </xsl:when>
    <xsl:when test="@type='gloss'">
      <dl>
      	<xsl:for-each select="item">
		  	<xsl:apply-templates select="."/>
		</xsl:for-each>
      </dl>
    </xsl:when>
    <xsl:when test="@type='simple'">
      <ul class="nobull">
      	<xsl:for-each select="item">
		  	<xsl:apply-templates select="."/>
		</xsl:for-each>
      </ul>
    </xsl:when>
    <xsl:when test="@type='ordered'">
      <xsl:choose>
        <xsl:when test="@rend">
          <ol class="{@rend}">
          	<xsl:for-each select="item">
		  		<xsl:apply-templates select="."/>
		  	</xsl:for-each>
          </ol>
        </xsl:when>
        <xsl:otherwise>
          <ol>
          	<xsl:for-each select="item">
		  		<xsl:apply-templates select="."/>
		  	</xsl:for-each>
          </ol>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="@type='unordered'">
      <ul>
      	<xsl:for-each select="item">
		  	<xsl:apply-templates select="."/>
		</xsl:for-each>
      </ul>
    </xsl:when>
    <xsl:when test="@type='bulleted'">
      <xsl:choose>
        <xsl:when test="@rend='dash'">
          <ul class="nobull">
          	<xsl:text>- </xsl:text>
          	<xsl:for-each select="item">
		  		<xsl:apply-templates select="."/>
		  	</xsl:for-each>	
          </ul>
        </xsl:when>
        <xsl:when test="@rend">
        	<ul class="{@rend}">
        		<xsl:for-each select="item">
		  			<xsl:apply-templates select="."/>
		  		</xsl:for-each>
        	</ul>
        </xsl:when>
        <xsl:otherwise>
          <ul>
          	<xsl:for-each select="item">
		  		<xsl:apply-templates select="."/>
		  	</xsl:for-each>
          </ul>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="@type='bibliographic'">
      <ol>
      	<xsl:for-each select="item">
		  	<xsl:apply-templates select="."/>
		</xsl:for-each>
      </ol>
    </xsl:when>
    <xsl:when test="@type='special'">
      <ul>
      	<xsl:for-each select="item">
		  	<xsl:apply-templates select="."/>
		</xsl:for-each>
      </ul>
    </xsl:when>
    <xsl:otherwise>
    	<ul class="nobull">
    		<xsl:for-each select="item">
		  		<xsl:apply-templates select="."/>
		  	</xsl:for-each>
    	</ul>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->
<!-- ====================================================================== -->
<!-- Paragraphs                                                             -->
<!-- ====================================================================== -->

<!-- <xsl:template match="p">
<xsl:choose>
 <xsl:when test="(parent::p or ancestor::p) and not(ancestor::floatingText)">
 	<xsl:choose>
  	<xsl:when test="parent::div[@type='diary']">
  		<span class="indent {@rend}"><xsl:apply-templates/></span>
  	</xsl:when>
  	<xsl:when test="parent::figure">
  		<span class="figureText {@rend}"><xsl:apply-templates/></span>
  	</xsl:when>
    <xsl:when test="@rend">
      <span class="{@rend}"><xsl:apply-templates/></span>
    </xsl:when>
    <xsl:when test="name(preceding-sibling::node()[1])='pb'">
      <span class="noindent {@rend}"><xsl:apply-templates/></span>
    </xsl:when>
    <xsl:when test="parent::td">
      <span><xsl:apply-templates/></span>
    </xsl:when>
    <xsl:when test="contains(@rend, 'IndentHanging')">
      <span class="{@rend}"><xsl:apply-templates/></span>
    </xsl:when>
    <xsl:when test="not(preceding-sibling::p)">
      <xsl:choose>
        <xsl:when test="@rend">
          <span class="{@rend}"><xsl:apply-templates/></span>
        </xsl:when>
        <xsl:otherwise>
          <span class="noindent"><xsl:apply-templates/></span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="not(following-sibling::p)">
      <xsl:choose>
        <xsl:when test="@rend">
          <span class="{@rend}"><xsl:apply-templates/></span>
        </xsl:when>
        <xsl:otherwise>
          <span class="padded"><xsl:apply-templates/></span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="@rend">
          <span class="{@rend}"><xsl:apply-templates/></span>
        </xsl:when>
        <xsl:otherwise>
          <span class="normal"><xsl:apply-templates/></span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
 </xsl:when>
 <xsl:otherwise>
  <xsl:choose>
  	<xsl:when test="descendant::floatingText or descendant::lg or descendant::list">
    	<div class="normal {@rend}"><xsl:apply-templates/></div>
    </xsl:when>
  	<xsl:when test="ancestor::*[@type='letter'] or ancestor::*[@type='dedication']">
  		<p class="indent {@rend}"><xsl:apply-templates/></p>
  	</xsl:when>
  	<xsl:when test="parent::div[@type='diary']">
  		<p class="indent {@rend}"><xsl:apply-templates/></p>
  	</xsl:when>
  	<xsl:when test="parent::figure">
  		<p class="figureText {@rend}"><xsl:apply-templates/></p>
  	</xsl:when>
    <xsl:when test="@rend">
      <p class="{@rend}"><xsl:apply-templates/></p>
    </xsl:when>
    <xsl:when test="name(preceding-sibling::node()[1])='pb'">
      <p class="noindent {@rend}"><xsl:apply-templates/></p>
    </xsl:when>
    <xsl:when test="parent::td">
      <p><xsl:apply-templates/></p>
    </xsl:when>
    <xsl:when test="contains(@rend, 'IndentHanging')">
      <p class="{@rend}"><xsl:apply-templates/></p>
    </xsl:when>
    <xsl:when test="not(preceding-sibling::p)">
      <xsl:choose>
        <xsl:when test="@rend">
          <p class="{@rend}"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:when test="parent::div[@type='resolution']|parent::div[@type='vote']">
        	<p class="blockquote"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:otherwise>
          <p class="noindent"><xsl:apply-templates/></p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="not(following-sibling::p)">
      <xsl:choose>
        <xsl:when test="@rend">
          <p class="{@rend}"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:otherwise>
          <p class="padded"><xsl:apply-templates/></p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="@rend">
          <p class="{@rend}"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:otherwise>
          <p class="normal"><xsl:apply-templates/></p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
 </xsl:otherwise>
</xsl:choose>
</xsl:template>
-->

<!-- ====================================================================== -->
<!-- References                                                             -->
<!-- ====================================================================== -->

<xsl:template match="ref">

  <xsl:variable name="target">
  	<xsl:choose>
  		<xsl:when test="contains(@target, '#')">
			<xsl:value-of select="@target"/>
		</xsl:when>
		<xsl:otherwise>
			<!-- <xsl:text>#</xsl:text><xsl:value-of select="@target"/> -->
			<xsl:value-of select="@target"/>
		</xsl:otherwise>
  	</xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="targetMatch">
  	<xsl:choose>
  		<xsl:when test="contains(@target, '#')">
  			<xsl:value-of select="substring(@target,2)"/>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:value-of select="@target"/>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:variable>


  <xsl:variable name="chunk">
    <xsl:choose>
      <xsl:when test="@type='secref'">
        <xsl:value-of select="$target"/>
      </xsl:when>
      <xsl:when test="@type='noteref' or @type='endnote'">
        <xsl:value-of select="key('endnote-id', $target)/ancestor::*[matches(local-name(), '^div$')][1]/@*:id"/>
      </xsl:when>
      <xsl:when test="@type='fnoteref'">
        <xsl:value-of select="key('fnote-id', $target)/ancestor::*[matches(local-name(), '^div$')][1]/@*:id"/>
      </xsl:when>
      <xsl:when test="@type='pageref'">
        <xsl:choose>
          <xsl:when test="$target='endnotes'">
            <xsl:value-of select="'endnotes'"/>
          </xsl:when>
          <xsl:otherwise>
          <xsl:value-of select="key('pb-id', $target)/ancestor::*[matches(local-name(), '^div$')][1]/@*:id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="not(@type) and not(matches($targetMatch, 'VA.{5}-\d+'))">
      	<xsl:choose>
      		<xsl:when test="ancestor::note">
	      		<xsl:value-of select="key('ref-id', $targetMatch)/ancestor::*/@*[local-name()='id']"/>
	      	</xsl:when>
	      	<xsl:otherwise>
	      		<xsl:value-of select="key('note-id', $targetMatch)/ancestor::*/@*[local-name()='id']"/>
	      	</xsl:otherwise>
      	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="getRefChunk">
          <xsl:with-param name="refId">
            <xsl:value-of select="$target"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="toc" select="key('div-id', $chunk)/parent::*/@id"/>

  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="$anchor.id=@id">ref-hi</xsl:when>
      <xsl:otherwise>ref</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$anchor.id=@id">
    <a id="X"></a>
  </xsl:if>
  
  <xsl:if test="@xml:id">
  	<a id="{@*:id}"></a>
  </xsl:if>

  <xsl:choose>
  	<xsl:when test="ancestor::*[@type='contents'] or ancestor::*[@type='figures']">
  		<span class="tocRight"><xsl:apply-templates/></span>
  	</xsl:when>
    <xsl:when test="@type='noteref' or @type='endnote'">
      <sup>
        <xsl:attribute name="class">
          <xsl:value-of select="$class"/>
        </xsl:attribute>
        <xsl:text>[</xsl:text>
          <a>
            <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="$chunk"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/>&#038;doc.view=<xsl:value-of select="$doc.view"/><xsl:value-of select="$search"/>&#038;anchor.id=<xsl:value-of select="$target"/></xsl:attribute>
            <xsl:apply-templates/>
          </a>
        <xsl:text>]</xsl:text>
      </sup>
    </xsl:when>
    <xsl:when test="@type='fnoteref'">
      <sup>
        <xsl:attribute name="class">
          <xsl:value-of select="$class"/>
        </xsl:attribute>
        <xsl:text>[</xsl:text>
          <a>
            <xsl:attribute name="href">javascript://</xsl:attribute>
            <xsl:attribute name="onclick">
              <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/>&#038;doc.view=popup&#038;chunk.id=<xsl:value-of select="$target"/><xsl:text>','popup','width=300,height=300,resizable=yes,scrollbars=yes')</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
          </a>
        <xsl:text>]</xsl:text>
      </sup>
    </xsl:when>
    <xsl:when test="@type='pageref'">
      <xsl:if test="@rend='sup' or @rend='superscript' or @rend='super'">
      	<xsl:text disable-output-escaping='yes'> <![CDATA[<sup>]]></xsl:text>
      </xsl:if>
      <a>
<!--        <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="$chunk"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/>&#038;anchor.id=<xsl:value-of select="$target"/>#X</xsl:attribute>-->
        <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="$chunk"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/>&#038;doc.view=<xsl:value-of select="$doc.view"/>&#038;anchor.id=<xsl:value-of select="$target"/></xsl:attribute>
        <!-- <xsl:attribute name="target">_top</xsl:attribute> -->
        <xsl:apply-templates/>
      </a>
      <xsl:if test="@rend='sup' or @rend='superscript' or @rend='super'">
      	<xsl:text disable-output-escaping='yes'> <![CDATA[</sup>]]></xsl:text>
      </xsl:if>
    </xsl:when>
    <!-- <xsl:when test="parent::item and (ancestor::*[@type='contents'] or ancestor::*[@type='figures'])">
    		<xsl:choose>
    			<xsl:when test="@rend='right'">
    				<span class="tocRight"><xsl:apply-templates/></span>
    			</xsl:when>
    			<xsl:when test="@rend">
		    		<span class="{@rend}"><xsl:apply-templates/></span>
		    	</xsl:when>
		    	<xsl:otherwise>
		    		<xsl:apply-templates/>
		    	</xsl:otherwise>
		    </xsl:choose>
    </xsl:when> -->
    <xsl:when test="not(@*)">
    	<xsl:apply-templates/>
    </xsl:when>
    <xsl:when test="substring($target,1,1) != '#'">
    	<a href="{$target}"><xsl:apply-templates/></a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="@rend='sup' or @rend='superscript' or @rend='super'">
      	<xsl:text disable-output-escaping='yes'> <![CDATA[<sup>]]></xsl:text>
      </xsl:if>
      <xsl:if test="@id">
    	 <a id="{@id}"></a>
      </xsl:if>
      <a>
<!--        <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="$chunk"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/>&#038;anchor.id=<xsl:value-of select="$target"/>#X</xsl:attribute>-->
        <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="tokenize($chunk, '\s+')[last()]"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/>&#038;doc.view=<xsl:value-of select="$doc.view"/>&#038;anchor.id=<xsl:value-of select="$target"/></xsl:attribute>
        <!-- <xsl:attribute name="target">_top</xsl:attribute> -->
        <xsl:apply-templates/>
      </a>
      <xsl:if test="@rend='sup' or @rend='superscript' or @rend='super'">
      	<xsl:text disable-output-escaping='yes'> <![CDATA[</sup>]]></xsl:text>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- ====================================================================== -->
<!-- Label                                                                  -->
<!-- ====================================================================== -->

<xsl:template  match="label">
  	<xsl:choose>
  		<xsl:when test="ancestor::cell">
  			<xsl:value-of select="."/>
  		</xsl:when>
  		<xsl:when test="parent::p">
  			<xsl:apply-templates/><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
	  	</xsl:when>
  		<xsl:when test="parent::note">
  			<xsl:apply-templates/>
	  	</xsl:when>
  		<xsl:when test="ancestor::list or (ancestor::*[@type='contents'] or ancestor::*[@type='figures'])">
  			<dt><xsl:apply-templates/></dt>
	  	</xsl:when>
	  	<xsl:otherwise>
		  <xsl:apply-templates/>
		</xsl:otherwise>
  	</xsl:choose>
</xsl:template>

<!-- ====================================================================== -->
<!-- Table                                                                  -->
<!-- ====================================================================== -->

<xsl:template match="table">
	<xsl:if test="parent::p">
		<xsl:text disable-output-escaping='yes'> <![CDATA[</p>]]></xsl:text>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="note">
			<table summary="{note}"><xsl:apply-templates/></table>
		</xsl:when>
		<xsl:otherwise>
			<table><xsl:apply-templates/></table>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="parent::p">
		<xsl:text disable-output-escaping='yes'> <![CDATA[<p>]]></xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="cell">
	<xsl:choose>
		<xsl:when test="@n">
			<th class="bold" scope="row"><xsl:apply-templates/></th>
		</xsl:when>
		<xsl:when test="@role='label'">
			<th class="bold" scope="col"><xsl:apply-templates/></th>
		</xsl:when>
		<xsl:otherwise>
			<td><xsl:apply-templates/></td>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="table/note"/>

</xsl:stylesheet>