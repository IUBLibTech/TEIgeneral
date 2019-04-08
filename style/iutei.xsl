<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      exclude-result-prefixes="xs"
      xmlns:iutei="http://www.dlib.indiana.edu/collections/TEIgeneral/"
      version="2.0">
    
    <!-- This function returns the repository name given a repository code -->
    <!-- The full list of repository names can be found in the page: https://wiki.dlib.indiana.edu/confluence/x/IgBhBg -->
    <xsl:function name="iutei:getRepositoryName">
        <xsl:param name="repositoryCode"/>
        <xsl:value-of select='if ($repositoryCode eq "cshm") then "Center for the Study of History and Memory, IU Bloomington" 
            else if ($repositoryCode eq "lcp") then "Liberian Collections, IU Bloomington"
            else if ($repositoryCode eq "lilly") then "Lilly Library, IU Bloomington"
            else if ($repositoryCode eq "archives") then "University Archives, IU Bloomington"
            else if ($repositoryCode eq "wmi") then "Working Men&apos;s Institute"
            else if ($repositoryCode eq "folklore") then "Folklore Collection, IU Bloomington" 
            else if ($repositoryCode eq "politicalpapers") then "Political Papers, IU Bloomington" 
            else if ($repositoryCode eq "aaamc") then "Archives of African American Music and Culture (AAAMC), IU Bloomington"
            else if ($repositoryCode eq "africanstudies") then "African Studies Collections, IU Bloomington"
            else if ($repositoryCode eq "gimss") then "Government Information, Microforms &amp; Statistical Services, IU Bloomington"
            else if ($repositoryCode eq "bfca") then "Black Film Center/Archive, IU Bloomington"
            else if ($repositoryCode eq "wright") then "Wright American Fiction"
            else ""'/>
    </xsl:function>
    
    <!-- Returns true if a field is a meta field -->
    <xsl:function name="iutei:isMetaField">
        <xsl:param name="field"/>
        <xsl:value-of select='$field eq "text" or $field eq "callnum"
            or $field eq "abstract" or $field eq "creator"
            or $field eq "browse-subject" or $field eq "browse-creator"
            or $field eq "facet-publisher" or $field eq "publisher"
            or $field eq "browse-title" or $field eq "title"
            or $field eq "browse-daterange" or $field eq "year"
            or $field eq "id-previous" 
            or $field eq "year-max" or $field eq "genre" or $field eq "browse-genre"'/>
    </xsl:function>
</xsl:stylesheet>
