<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- Converts a process data module to a shell script with interaction via
       the dialog command. -->

  <xsl:output method="text"/>

  <xsl:param name="height" select="24"/>
  <xsl:param name="width" select="80"/>

  <xsl:template match="dmodule">
    <xsl:text>#!bin/sh</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="content/process"/>
    <xsl:text>clear</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="process">
    <xsl:apply-templates select="variableDeclarations|variablePreSet|dmSeq"/>
  </xsl:template>

  <xsl:template match="dmSeq|dmThenSeq|dmElseSeq">
    <xsl:if test="@applicRefId">
      <xsl:variable name="id" select="@applicRefId"/>
      <xsl:text>if [ </xsl:text>
      <xsl:apply-templates select="//applic[@id = $id]"/>
      <xsl:text> ]</xsl:text>
      <xsl:text>&#10;</xsl:text>
      <xsl:text>then</xsl:text>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="dmNode|dmNodeAlts|dmIf|dmLoop|dmSeqAlts"/>
    <xsl:if test="@applicRefId">
      <xsl:text>fi</xsl:text>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dmSeqAlts">
    <xsl:apply-templates select="dmSeq"/>
  </xsl:template>

  <xsl:template name="backtitle">
    <xsl:text> --backtitle "</xsl:text>
    <xsl:apply-templates select="ancestor-or-self::dmodule//dmAddressItems/dmTitle"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="dmTitle">
    <xsl:apply-templates select="techName"/>
    <xsl:if test="infoName">
      <xsl:text> - </xsl:text>
      <xsl:apply-templates select="infoName"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dmNode">
    <xsl:if test="@applicRefId">
      <xsl:variable name="id" select="@applicRefId"/>
      <xsl:text>if [ </xsl:text>
      <xsl:apply-templates select="//applic[@id = $id]"/>
      <xsl:text> ] </xsl:text>
      <xsl:text>&#10;</xsl:text>
      <xsl:text>then</xsl:text>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="proceduralStep">
      <xsl:text>dialog</xsl:text>
      <xsl:call-template name="backtitle"/>
      <xsl:apply-templates select="title"/>
      <xsl:text> --msgbox "</xsl:text>
      <xsl:apply-templates select="proceduralStep"/>
      <xsl:text>" </xsl:text>
      <xsl:value-of select="$height"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$width"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="variablePreSet|dialog|message|externalApplication"/>
    <xsl:if test="@applicRefId">
      <xsl:text>fi</xsl:text>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="proceduralStep">
    <xsl:number level="multiple"/>
    <xsl:text>. </xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:apply-templates select="para"/>
  </xsl:template>

  <xsl:template match="proceduralStep/title">
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="dmRef">
    <xsl:apply-templates select="dmRefIdent/dmCode"/>
  </xsl:template>

  <xsl:template match="dialog|dialogGroup">
    <xsl:apply-templates select="userEntry|menu|dialogGroup"/>
  </xsl:template>

  <xsl:template match="userEntry">
    <xsl:if test="validate">
      <xsl:text>valid=false&#10;</xsl:text>
      <xsl:text>while ! $valid&#10;</xsl:text>
      <xsl:text>do&#10;</xsl:text>
    </xsl:if>
    <xsl:text>dialog</xsl:text>
    <xsl:call-template name="backtitle"/>
    <xsl:if test="@mandatory = '1'">
      <xsl:text> --no-cancel</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="parent::title"/>
    <xsl:text> --inputbox "</xsl:text>
    <xsl:apply-templates select="prompt"/>
    <xsl:text>" </xsl:text>
    <xsl:value-of select="$height"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$width"/>
    <xsl:apply-templates select="default"/>
    <xsl:text> 2>tmp</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="variableRef/@variableName"/>
    <xsl:text>=$(cat tmp)</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>rm tmp</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="validate">
      <xsl:apply-templates select="validate"/>
      <xsl:text>done&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="default">
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="expression"/>
  </xsl:template>

  <xsl:template match="message">
    <xsl:text>dialog</xsl:text>
    <xsl:call-template name="backtitle"/>
    <xsl:text> --msgbox "</xsl:text>
    <xsl:apply-templates select="prompt"/>
    <xsl:text>" </xsl:text>
    <xsl:value-of select="$height"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$width"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="prompt">
    <xsl:apply-templates select="paraBasic|variableRef"/>
  </xsl:template>

  <xsl:template match="paraBasic">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="variableRef|globalPropertyRef">
    <xsl:if test="parent::expression and not(parent::expression/parent::expression/numberOperator)">
      <xsl:text>"</xsl:text>
    </xsl:if>
    <xsl:text>$</xsl:text>
    <xsl:value-of select="@variableName|@applicPropertyIdent"/>
    <xsl:if test="parent::expression and not (parent::expression/parent::expression/numberOperator)">
      <xsl:text>"</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="title">
    <xsl:text> --title "</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="menu">
    <xsl:text>dialog</xsl:text>
    <xsl:call-template name="backtitle"/>
    <xsl:if test="@mandatory = '1'">
      <xsl:text> --no-cancel</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="parent::title"/>
    <xsl:text> --no-tags </xsl:text>
    <xsl:choose>
      <xsl:when test="@choiceSelection = 'single'">
        <xsl:text>--radiolist </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>--checklist </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>"</xsl:text>
    <xsl:apply-templates select="prompt"/>
    <xsl:text>" </xsl:text>
    <xsl:value-of select="$height"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$width"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$height"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="menuChoice"/>
    <xsl:text> 2>tmp</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>choice=$(cat tmp)</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>rm tmp</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>case $choice in</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:for-each select="menuChoice">
      <xsl:value-of select="position()"/>
      <xsl:text>) </xsl:text>
      <xsl:apply-templates select="externalApplication|assertion"/>
      <xsl:text>;;</xsl:text>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    <xsl:text>esac</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="menuChoice">
    <xsl:variable name="on" select="@menuChoiceDefaultFlag = '1'"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="position()"/>
    <xsl:text>" "</xsl:text>
    <xsl:apply-templates select="prompt"/>
    <xsl:text>" </xsl:text>
    <xsl:choose>
      <xsl:when test="$on">
        <xsl:text>on</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>off</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="numberOperator|stringOperator|booleanOperator">
    <xsl:variable name="operation" select="@numberOperation|@stringOperation|@booleanOperation"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="$operation = 'equal'">=</xsl:when>
      <xsl:when test="$operation = 'divide'">/</xsl:when>
      <xsl:when test="$operation = 'greaterThan'">-gt</xsl:when>
      <xsl:when test="$operation = 'greaterThanOrEqual'">-ge</xsl:when>
      <xsl:when test="$operation = 'lessThan'">-lt</xsl:when>
      <xsl:when test="$operation = 'lessThanOrEqual'">-le</xsl:when>
      <xsl:when test="$operation = 'minus'">-</xsl:when>
      <xsl:when test="$operation = 'plus'">+</xsl:when>
      <xsl:when test="$operation = 'notEqual'">!=</xsl:when>
      <xsl:when test="$operation = 'times'">*</xsl:when>
      <xsl:when test="$operation = 'exponent'">**</xsl:when>
      <xsl:when test="$operation = 'modulus'">%</xsl:when>
      <xsl:when test="$operation = 'and'"> ] &amp;&amp; [ </xsl:when>
      <xsl:when test="$operation = 'or'"> ] || [ </xsl:when>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="expression">
    <xsl:choose>
      <xsl:when test="numberOperator[
        @numberOperation = 'divide' or
        @numberOperation = 'minus' or
        @numberOperation = 'plus' or
        @numberOperation = 'times' or
        @numberOperation = 'modulus']">
        <xsl:text>$((</xsl:text>
      </xsl:when>
      <xsl:when test="parent::dmIf or parent::dmLoop">
        <xsl:text>[ </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="*"/>
    <xsl:choose>
      <xsl:when test="numberOperator[
        @numberOperation = 'divide' or
        @numberOperation = 'minus' or
        @numberOperation = 'plus' or
        @numberOperation = 'times' or
        @numberOperation = 'modulus']">
        <xsl:text>))</xsl:text>
      </xsl:when>
      <xsl:when test="parent::dmIf or parent::dmLoop">
        <xsl:text> ]</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="assertion">
    <xsl:value-of select="variableRef/@variableName|globalPropertyRef/@applicPropertyIdent"/>
    <xsl:text>=</xsl:text>
    <xsl:apply-templates select="expression"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="stringValue">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="integerValue|realValue">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="booleanValue">
    <xsl:apply-templates select="falseValue|trueValue"/>
  </xsl:template>

  <xsl:template match="falseValue">
    <xsl:text>"false"</xsl:text>
  </xsl:template>

  <xsl:template match="trueValue">
    <xsl:text>"true"</xsl:text>
  </xsl:template>

  <xsl:template match="variablePreSet">
    <xsl:apply-templates select="assertion"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="dmIf">
    <xsl:text>if </xsl:text>
    <xsl:apply-templates select="expression"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>then</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="dmThenSeq"/>
    <xsl:if test="dmElseSeq">
      <xsl:text>else</xsl:text>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select="dmElseSeq"/>
    </xsl:if>
    <xsl:text>fi</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="dmLoop">
    <xsl:apply-templates select="variablePreSet"/>
    <xsl:text>while </xsl:text>
    <xsl:apply-templates select="expression"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>do</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="dmSeq"/>
    <xsl:apply-templates select="assertion"/>
    <xsl:text>done</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="booleanFunction">
    <xsl:choose>
      <xsl:when test="@booleanAction = 'not'">! </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="variableDeclarations">
    <xsl:apply-templates select="variable"/>
  </xsl:template>

  <xsl:template match="variable">
    <xsl:value-of select="@variableName"/>
    <xsl:text>=</xsl:text>
    <xsl:apply-templates select="initialize"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="initialize">
    <xsl:apply-templates select="expression"/>
  </xsl:template>

  <xsl:template match="assert">
    <xsl:text>"$</xsl:text>
    <xsl:value-of select="@applicPropertyIdent"/>
    <xsl:text>" = "</xsl:text>
    <xsl:value-of select="@applicPropertyValues"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="validate">
    <xsl:text>if [ </xsl:text>
    <xsl:apply-templates select="expression"/>
    <xsl:text> ]&#10;</xsl:text>
    <xsl:text>then&#10;</xsl:text>
    <xsl:text>valid=true&#10;</xsl:text>
    <xsl:text>else&#10;</xsl:text>
    <xsl:text>dialog </xsl:text>
    <xsl:call-template name="backtitle"/>
    <xsl:text> --title Error --msgbox "</xsl:text>
    <xsl:value-of select="@errorMessage"/>
    <xsl:text>" </xsl:text>
    <xsl:value-of select="$height"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$width"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>fi&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="noAssertions"/>

  <xsl:template match="applic">
    <xsl:apply-templates select="evaluate|assert|expression"/>
  </xsl:template>

  <xsl:template match="evaluate">
    <xsl:choose>
      <xsl:when test="@andOr = 'or'"> ] || [ </xsl:when>
      <xsl:when test="@andOr = 'and'"> ] &amp;&amp; [ </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="para">
    <xsl:apply-templates/>
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="dmCode">
    <xsl:value-of select="@modelIdentCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@systemDiffCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@systemCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@subSystemCode"/>
    <xsl:value-of select="@subSubSystemCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@assyCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@disassyCode"/>
    <xsl:value-of select="@disassyCodeVariant"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@infoCode"/>
    <xsl:value-of select="@infoCodeVariant"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@itemLocationCode"/>
    <xsl:if test="@learnCode">
      <xsl:text>-</xsl:text>
      <xsl:value-of select="@learnCode"/>
      <xsl:value-of select="@learnEventCode"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="externalApplication">
    <xsl:if test="receiveValue">
      <xsl:value-of select="receiveValue/variableRef/@variableName"/>
      <xsl:text>="$(</xsl:text>
    </xsl:if>
    <xsl:value-of select="unparsed-entity-uri(@application)"/>
    <xsl:apply-templates select="send"/>
    <xsl:if test="receiveValue">
      <xsl:text>)"</xsl:text>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="send">
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="variableRef|globalPropertyRef|stringValue"/>
  </xsl:template>

  <xsl:template match="dmNodeAlts">
    <xsl:apply-templates select="*"/>
  </xsl:template>

</xsl:stylesheet>
